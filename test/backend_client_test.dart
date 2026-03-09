import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:debt_destroyer/core/services/backend_services.dart';
import 'package:debt_destroyer/features/scan_import/domain/import_services.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/backend_models.dart';

const _backendConfig = BackendConfig(
  baseUrl: 'https://api.example.com',
  environment: 'test',
  playIntegrityCloudProjectNumber: null,
  playIntegrityPackageName: 'com.debtdestroyer.app',
  debugAttestationSecret: null,
  requestTimeout: Duration(seconds: 1),
  premiumProductId: 'premium',
  premiumMonthlyBasePlanId: 'monthly',
  premiumYearlyBasePlanId: 'yearly',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackendApiClient', () {
    test('refreshes once after 401 and retries successfully', () async {
      final sessionManager = _FakeSessionManager();
      final client = BackendApiClient(
        httpClient: _SequenceClient([
          http.Response('{"error":"invalid_auth"}', 401),
          http.Response('{"ok":true}', 200),
        ]),
        config: _backendConfig,
        sessionManager: sessionManager,
      );

      final response = await client.postAuthorized('/v1/import/extract', {});
      expect(response['ok'], true);
      expect(sessionManager.refreshCount, 1);
    });
  });

  group('BackendAiExtractionService', () {
    test(
      'falls back to heuristic parse when cloud extraction is disabled',
      () async {
        final parser = HeuristicExtractionParser();
        final service = BackendAiExtractionService(
          client: BackendApiClient(
            httpClient: _SequenceClient([]),
            config: _backendConfig.copyWith(baseUrl: ''),
            sessionManager: _FakeSessionManager(),
          ),
          sessionManager: _FakeSessionManager(),
          config: _backendConfig.copyWith(baseUrl: ''),
          parser: parser,
        );

        final candidate = await service.extract(
          classification: DocumentClassification.creditCardStatement,
          normalizedText: 'Current balance: \$1200\nMinimum payment: \$40',
          sourceType: DocumentSourceType.gallery,
          allowCloud: false,
        );

        expect(candidate.currentBalance, 1200);
        expect(candidate.warnings, isEmpty);
      },
    );

    test(
      'returns fallback with quota warning when backend denies quota',
      () async {
        final service = BackendAiExtractionService(
          client: BackendApiClient(
            httpClient: _SequenceClient([
              http.Response(
                jsonEncode({
                  'error': 'quota_exhausted',
                  'message': 'No cloud extraction quota remaining',
                  'details': {
                    'quota': {
                      'allowed': false,
                      'remaining_free_scans': 0,
                      'premium_required': true,
                      'reset_at': '2026-04-01T00:00:00.000Z',
                    },
                  },
                }),
                429,
              ),
            ]),
            config: _backendConfig,
            sessionManager: _FakeSessionManager(),
          ),
          sessionManager: _FakeSessionManager(),
          config: _backendConfig,
          parser: HeuristicExtractionParser(),
        );

        final candidate = await service.extract(
          classification: DocumentClassification.creditCardStatement,
          normalizedText: 'Current balance: \$900',
          sourceType: DocumentSourceType.gallery,
          allowCloud: true,
        );

        expect(candidate.warnings, contains('quota_exhausted'));
        expect(candidate.quotaSnapshot?.premiumRequired, true);
      },
    );
  });

  group('PlayIntegrityAttestationService', () {
    const channel = MethodChannel('debt_destroyer/play_integrity');

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test(
      'passes cloud project number through method channel payload',
      () async {
        MethodCall? capturedCall;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              capturedCall = call;
              return 'token-1';
            });
        final service = PlayIntegrityAttestationService(
          _backendConfig.copyWith(playIntegrityCloudProjectNumber: '123456789'),
        );

        final token = await service.requestAttestationToken(
          installId: 'install-1',
          nonce: 'nonce-1',
        );

        expect(token, 'token-1');
        expect(capturedCall?.arguments, {
          'installId': 'install-1',
          'nonce': 'nonce-1',
          'cloudProjectNumber': '123456789',
          'debugSecret': null,
        });
      },
    );
  });
}

class _FakeSessionManager implements BackendSessionManager {
  int refreshCount = 0;

  @override
  Future<void> clearSession() async {}

  @override
  Future<InstallSession?> ensureSession() async {
    return InstallSession(
      installId: 'install-1',
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      attestationStatus: 'debug',
    );
  }

  @override
  Future<String> getOrCreateInstallId() async => 'install-1';

  @override
  Future<InstallSession> refreshSession() async {
    refreshCount += 1;
    return InstallSession(
      installId: 'install-1',
      accessToken: 'access-token-2',
      refreshToken: 'refresh-token-2',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      attestationStatus: 'debug',
    );
  }
}

class _SequenceClient extends http.BaseClient {
  _SequenceClient(this.responses);

  final List<http.Response> responses;
  int _index = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = responses.isEmpty
        ? http.Response('{}', 200)
        : responses[_index++ % responses.length];
    return http.StreamedResponse(
      Stream.value(utf8.encode(response.body)),
      response.statusCode,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
