import 'dart:async';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/utils/parsers.dart';
import '../../features/scan_import/domain/import_services.dart';
import '../../shared/enums/app_enums.dart';
import '../../shared/models/backend_models.dart';
import '../../shared/models/import_models.dart';

abstract class AttestationService {
  Future<String> requestAttestationToken({
    required String installId,
    required String nonce,
  });
}

class PlayIntegrityAttestationService implements AttestationService {
  const PlayIntegrityAttestationService(this._config);

  static const _channel = MethodChannel('debt_destroyer/play_integrity');
  final BackendConfig _config;

  @override
  Future<String> requestAttestationToken({
    required String installId,
    required String nonce,
  }) async {
    try {
      final token = await _channel
          .invokeMethod<String>('requestIntegrityToken', {
            'installId': installId,
            'nonce': nonce,
            'cloudProjectNumber': _config.playIntegrityCloudProjectNumber,
            'debugSecret': _config.debugAttestationSecret,
          });
      if (token != null && token.isNotEmpty) {
        return token;
      }
    } catch (error, stackTrace) {
      AppLogger.instance.error(
        'attestation.channel_failed',
        error,
        stackTrace,
        context: const {
          'category': 'attestation',
          'operation': 'requestIntegrityToken',
        },
      );
    }
    final localDebugToken = await _buildLocalDebugToken(
      installId: installId,
      nonce: nonce,
    );
    if (localDebugToken != null) {
      return localDebugToken;
    }
    throw const AppException(
      'Attestation token unavailable for secure backend extraction.',
      code: 'attestation_unavailable',
    );
  }

  Future<String?> _buildLocalDebugToken({
    required String installId,
    required String nonce,
  }) async {
    if ((_config.environment != 'development' &&
            _config.environment != 'test') ||
        _config.debugAttestationSecret == null ||
        _config.debugAttestationSecret!.isEmpty) {
      return null;
    }
    final hmac = Hmac.sha256();
    final mac = await hmac.calculateMac(
      utf8.encode('$installId:$nonce'),
      secretKey: SecretKey(utf8.encode(_config.debugAttestationSecret!)),
    );
    final signature = mac.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return 'debug-attestation:v1:$signature';
  }
}

abstract class BackendSessionManager {
  Future<InstallSession?> ensureSession();
  Future<InstallSession> refreshSession();
  Future<String> getOrCreateInstallId();
  Future<void> clearSession();
}

class BackendAuthService implements BackendSessionManager {
  const BackendAuthService({
    required this.storage,
    required this.httpClient,
    required this.config,
    required this.attestationService,
  });

  final FlutterSecureStorage storage;
  final http.Client httpClient;
  final BackendConfig config;
  final AttestationService attestationService;

  static const _installIdKey = 'backend_install_id';
  static const _sessionKey = 'backend_install_session';

  @override
  Future<String> getOrCreateInstallId() async {
    final existing = await storage.read(key: _installIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final next = const Uuid().v4();
    await storage.write(key: _installIdKey, value: next);
    return next;
  }

  @override
  Future<InstallSession?> ensureSession() async {
    if (!config.isConfigured) {
      return null;
    }
    final session = await _readSession();
    if (session != null &&
        session.expiresAt.isAfter(
          DateTime.now().add(const Duration(seconds: 30)),
        )) {
      return session;
    }
    if (session != null) {
      return refreshSession();
    }
    return _bootstrap();
  }

  @override
  Future<InstallSession> refreshSession() async {
    final session = await _readSession();
    if (session == null) {
      return _bootstrap();
    }
    final response = await _post('/v1/mobile/token/refresh', {
      'refresh_token': session.refreshToken,
    });
    final refreshed = InstallSession(
      installId: session.installId,
      accessToken: response['access_token'] as String,
      refreshToken: response['refresh_token'] as String,
      expiresAt: DateTime.now().add(
        Duration(seconds: response['expires_in_seconds'] as int),
      ),
      attestationStatus: session.attestationStatus,
    );
    await _writeSession(refreshed);
    return refreshed;
  }

  @override
  Future<void> clearSession() async {
    await storage.delete(key: _sessionKey);
  }

  Future<InstallSession> _bootstrap() async {
    final installId = await getOrCreateInstallId();
    final challenge = await _post('/v1/mobile/bootstrap/challenge', {
      'app_version': AppConstants.appVersion,
      'platform': 'android',
      'install_id': installId,
    });
    final attestationToken = await attestationService.requestAttestationToken(
      installId: installId,
      nonce: challenge['nonce'] as String,
    );
    final verify = await _post('/v1/mobile/bootstrap/verify', {
      'challenge_id': challenge['challenge_id'],
      'install_id': installId,
      'attestation_token': attestationToken,
      'device': {
        'platform': 'android',
        'app_version': AppConstants.appVersion,
        'build_mode': config.environment,
      },
    });
    final created = InstallSession(
      installId: installId,
      accessToken: verify['access_token'] as String,
      refreshToken: verify['refresh_token'] as String,
      expiresAt: DateTime.now().add(
        Duration(seconds: verify['expires_in_seconds'] as int),
      ),
      attestationStatus:
          (verify['session'] as Map<String, dynamic>)['attestation_status']
              as String,
    );
    await _writeSession(created);
    return created;
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await httpClient
        .post(
          Uri.parse('${config.baseUrl}$path'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(config.requestTimeout);
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw AppException(
        decoded['message']?.toString() ?? 'Backend auth failed',
        code: decoded['error']?.toString(),
      );
    }
    return decoded;
  }

  Future<InstallSession?> _readSession() async {
    final raw = await storage.read(key: _sessionKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return InstallSession(
      installId: json['installId'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      attestationStatus: json['attestationStatus'] as String,
    );
  }

  Future<void> _writeSession(InstallSession session) {
    return storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'installId': session.installId,
        'accessToken': session.accessToken,
        'refreshToken': session.refreshToken,
        'expiresAt': session.expiresAt.toIso8601String(),
        'attestationStatus': session.attestationStatus,
      }),
    );
  }
}

class BackendHttpException implements Exception {
  const BackendHttpException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.payload,
  });

  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? payload;
}

class BackendApiClient {
  const BackendApiClient({
    required this.httpClient,
    required this.config,
    required this.sessionManager,
  });

  final http.Client httpClient;
  final BackendConfig config;
  final BackendSessionManager sessionManager;

  Future<Map<String, dynamic>> getAuthorized(String path) async {
    return _sendAuthorized(method: 'GET', path: path, body: null);
  }

  Future<Map<String, dynamic>> postAuthorized(
    String path,
    Map<String, dynamic> body,
  ) {
    return _sendAuthorized(method: 'POST', path: path, body: body);
  }

  Future<Map<String, dynamic>> _sendAuthorized({
    required String method,
    required String path,
    required Map<String, dynamic>? body,
    bool refreshed = false,
    int transientRetry = 0,
  }) async {
    final session = await sessionManager.ensureSession();
    if (session == null) {
      throw const BackendHttpException(
        statusCode: 503,
        code: 'backend_unavailable',
        message: 'Backend not configured',
      );
    }

    try {
      final requestUri = Uri.parse('${config.baseUrl}$path');
      final response = await () {
        if (method == 'GET') {
          return httpClient.get(
            requestUri,
            headers: _headers(session.accessToken),
          );
        }
        return httpClient.post(
          requestUri,
          headers: _headers(session.accessToken),
          body: jsonEncode(body),
        );
      }().timeout(config.requestTimeout);

      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 401 && !refreshed) {
        await sessionManager.refreshSession();
        return _sendAuthorized(
          method: method,
          path: path,
          body: body,
          refreshed: true,
          transientRetry: transientRetry,
        );
      }
      if ((response.statusCode >= 500 || response.statusCode == 429) &&
          transientRetry < 1 &&
          response.statusCode != 429) {
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (transientRetry + 1)),
        );
        return _sendAuthorized(
          method: method,
          path: path,
          body: body,
          refreshed: refreshed,
          transientRetry: transientRetry + 1,
        );
      }
      if (response.statusCode >= 400) {
        throw BackendHttpException(
          statusCode: response.statusCode,
          code: decoded['error']?.toString() ?? 'backend_error',
          message: decoded['message']?.toString() ?? 'Backend request failed',
          payload: decoded,
        );
      }
      return decoded;
    } on TimeoutException {
      if (transientRetry < 1) {
        await Future<void>.delayed(
          Duration(milliseconds: 300 * (transientRetry + 1)),
        );
        return _sendAuthorized(
          method: method,
          path: path,
          body: body,
          refreshed: refreshed,
          transientRetry: transientRetry + 1,
        );
      }
      throw const BackendHttpException(
        statusCode: 504,
        code: 'backend_timeout',
        message: 'Backend request timed out',
      );
    } on http.ClientException {
      throw const BackendHttpException(
        statusCode: 503,
        code: 'network_error',
        message: 'Network unavailable',
      );
    }
  }

  Map<String, String> _headers(String accessToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
  }
}

class BackendCapabilitiesService {
  const BackendCapabilitiesService(this.client);

  final BackendApiClient client;

  Future<BackendCapabilities> loadCapabilities() async {
    final response = await client.getAuthorized('/v1/mobile/me/capabilities');
    return BackendCapabilities(
      premium: response['premium'] as bool? ?? false,
      features: (response['features'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      freeScanRemaining: response['free_scan_remaining'] as int? ?? 0,
      rateLimitState: response['rate_limit_state']?.toString() ?? 'unknown',
      entitlement: _parseEntitlement(
        response['entitlement'] as Map<String, dynamic>?,
      ),
    );
  }

  BackendEntitlement? _parseEntitlement(Map<String, dynamic>? json) {
    if (json == null) {
      return null;
    }
    return BackendEntitlement(
      isPremium: json['is_premium'] as bool? ?? false,
      planId: json['plan_id']?.toString(),
      status: json['status']?.toString() ?? 'free',
      validUntil: json['valid_until'] == null
          ? null
          : DateTime.tryParse(json['valid_until'].toString()),
      features: (json['features'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      lastVerifiedAt: json['last_verified_at'] == null
          ? null
          : DateTime.tryParse(json['last_verified_at'].toString()),
      productId: json['product_id']?.toString(),
      billingProvider: json['billing_provider']?.toString(),
    );
  }
}

class BackendAiExtractionService implements AiExtractionService {
  const BackendAiExtractionService({
    required this.client,
    required this.sessionManager,
    required this.config,
    required this.parser,
  });

  final BackendApiClient client;
  final BackendSessionManager sessionManager;
  final BackendConfig config;
  final HeuristicExtractionParser parser;

  @override
  Future<ImportExtractionResult> extract({
    required DocumentClassification classification,
    required String normalizedText,
    required DocumentSourceType sourceType,
    required bool allowCloud,
  }) async {
    final local = parser.parse(classification, normalizedText);
    if (!allowCloud || !config.isConfigured) {
      return local;
    }

    final installId = await sessionManager.getOrCreateInstallId();
    try {
      final response = await client.postAuthorized('/v1/import/extract', {
        'request_id': const Uuid().v4(),
        'install_id': installId,
        'document_classification': classification.name,
        'normalized_ocr_text': normalizedText,
        'source_type': sourceType.name,
        'app_version': AppConstants.appVersion,
        'consented_at': DateTime.now().toIso8601String(),
      });
      final quota = _parseQuota(
        response['quota'] as Map<String, dynamic>? ?? const {},
      );
      final summaryJson =
          (response['summary'] as Map<String, dynamic>?) ??
          (response['extraction'] as Map<String, dynamic>? ?? {});
      final lineItems = (response['line_items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(_parseLineItem)
          .whereType<StatementLineItemCandidate>()
          .toList();
      final warnings = (response['warnings'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList();
      return ImportExtractionResult(
        summary: _mergeSummary(local.summary, _parseSummary(summaryJson)),
        statementLineItems: _mergeLineItems(
          local.statementLineItems,
          lineItems,
        ),
        warnings: {...local.warnings, ...warnings}.toList(),
        documentSignals: {
          ...local.documentSignals,
          ...(response['document_signals'] as List<dynamic>? ?? []).map(
            (item) => item.toString(),
          ),
        }.toList(),
        errorMessage: null,
        quotaSnapshot: quota,
      );
    } on BackendHttpException catch (error) {
      final quota = error.payload?['details']?['quota'];
      return ImportExtractionResult(
        summary: local.summary,
        statementLineItems: local.statementLineItems,
        warnings: {
          ...local.warnings,
          error.code,
          if (error.statusCode == 401) 'reauth_required',
          if (error.statusCode >= 500) 'backend_unavailable',
        }.toList(),
        documentSignals: [...local.documentSignals, 'local_fallback'],
        errorMessage: _backendErrorMessage(error),
        quotaSnapshot: quota is Map<String, dynamic>
            ? _parseQuota(quota)
            : null,
      );
    } on AppException catch (error) {
      return ImportExtractionResult(
        summary: local.summary,
        statementLineItems: local.statementLineItems,
        warnings: [...local.warnings, error.code ?? 'backend_error'],
        documentSignals: [...local.documentSignals, 'local_fallback'],
        errorMessage: error.message,
        quotaSnapshot: null,
      );
    }
  }

  StatementSummaryCandidate _parseSummary(Map<String, dynamic> extraction) {
    return StatementSummaryCandidate(
      title: extraction['title']?.toString(),
      creditorName: extraction['issuer_name']?.toString(),
      debtType: parser.mapDebtType(extraction['debt_type']?.toString()),
      currentBalance: _asDouble(extraction['current_balance']),
      originalBalance: _asDouble(extraction['original_balance']),
      aprPercentage: _asDouble(extraction['apr_percentage']),
      minimumPayment: _asDouble(extraction['minimum_payment']),
      dueDate: Parsers.parseDate(extraction['due_date']?.toString()),
      paymentDate: Parsers.parseDate(extraction['payment_date']?.toString()),
      paymentAmount: _asDouble(extraction['payment_amount']),
      statementStartDate: Parsers.parseDate(
        extraction['statement_start_date']?.toString(),
      ),
      statementEndDate: Parsers.parseDate(
        extraction['statement_end_date']?.toString(),
      ),
      currency: extraction['currency']?.toString(),
      notes: extraction['notes']?.toString(),
      confidence: _asDouble(extraction['confidence']) ?? 0,
      last4: extraction['last4']?.toString(),
      labels: (extraction['raw_detected_labels'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  StatementLineItemCandidate? _parseLineItem(Map<String, dynamic> item) {
    final description = item['description']?.toString().trim() ?? '';
    final amount = _asDouble(item['amount']);
    if (description.isEmpty || amount == null) {
      return null;
    }
    return StatementLineItemCandidate(
      id: item['id']?.toString() ?? const Uuid().v4(),
      description: description,
      amount: amount,
      type: _parseItemType(item['type']?.toString()),
      confidence: _asDouble(item['confidence']) ?? 0,
      date: Parsers.parseDate(item['date']?.toString()),
      currency: item['currency']?.toString(),
      warnings: (item['warnings'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }

  StatementSummaryCandidate _mergeSummary(
    StatementSummaryCandidate local,
    StatementSummaryCandidate remote,
  ) {
    return StatementSummaryCandidate(
      title: remote.title ?? local.title,
      creditorName: remote.creditorName ?? local.creditorName,
      debtType: remote.debtType ?? local.debtType,
      currentBalance: remote.currentBalance ?? local.currentBalance,
      originalBalance: remote.originalBalance ?? local.originalBalance,
      aprPercentage: remote.aprPercentage ?? local.aprPercentage,
      minimumPayment: remote.minimumPayment ?? local.minimumPayment,
      dueDate: remote.dueDate ?? local.dueDate,
      paymentDate: remote.paymentDate ?? local.paymentDate,
      paymentAmount: remote.paymentAmount ?? local.paymentAmount,
      statementStartDate: remote.statementStartDate ?? local.statementStartDate,
      statementEndDate: remote.statementEndDate ?? local.statementEndDate,
      currency: remote.currency,
      notes: remote.notes ?? local.notes,
      confidence: remote.confidence > 0 ? remote.confidence : local.confidence,
      last4: remote.last4 ?? local.last4,
      labels: {...local.labels, ...remote.labels}.toList(),
    );
  }

  List<StatementLineItemCandidate> _mergeLineItems(
    List<StatementLineItemCandidate> local,
    List<StatementLineItemCandidate> remote,
  ) {
    if (remote.isEmpty) {
      return local;
    }
    final merged = <String, StatementLineItemCandidate>{};
    for (final item in [...local, ...remote]) {
      final normalizedAmount = _normalizedLineItemAmount(item);
      final normalizedType = item.type.name;
      final key =
          '${item.description.toLowerCase()}|$normalizedType|$normalizedAmount|${item.date?.toIso8601String() ?? 'none'}';
      final existing = merged[key];
      if (existing == null || item.confidence >= existing.confidence) {
        merged[key] = item.copyWith(amount: normalizedAmount);
      }
    }
    return merged.values.toList();
  }

  double _normalizedLineItemAmount(StatementLineItemCandidate item) {
    final absolute = item.amount.abs();
    return switch (item.type) {
      StatementLineItemType.payment => absolute,
      StatementLineItemType.charge ||
      StatementLineItemType.fee ||
      StatementLineItemType.interest => -absolute,
      StatementLineItemType.other => item.amount,
    };
  }

  StatementLineItemType _parseItemType(String? raw) {
    return switch (raw?.toLowerCase()) {
      'payment' => StatementLineItemType.payment,
      'charge' => StatementLineItemType.charge,
      'fee' => StatementLineItemType.fee,
      'interest' => StatementLineItemType.interest,
      _ => StatementLineItemType.other,
    };
  }

  String _backendErrorMessage(BackendHttpException error) {
    if (error.code == 'quota_exhausted') {
      return 'Cloud extraction quota is exhausted. Continue with local OCR review.';
    }
    if (error.code == 'network_error' || error.code == 'backend_timeout') {
      return 'Network or backend timeout. Local OCR results are shown instead.';
    }
    return error.message;
  }

  BackendQuotaSnapshot _parseQuota(Map<String, dynamic> json) {
    return BackendQuotaSnapshot(
      allowed: json['allowed'] as bool? ?? true,
      remainingFreeScans: json['remaining_free_scans'] as int? ?? 0,
      premiumRequired: json['premium_required'] as bool? ?? false,
      resetAt: json['reset_at'] == null
          ? null
          : DateTime.tryParse(json['reset_at'].toString()),
    );
  }

  double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
