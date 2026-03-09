import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/settings/presentation/settings_screens.dart';
import 'package:debt_destroyer/shared/models/backup_models.dart';
import 'package:debt_destroyer/shared/models/subscription_state.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets('data backups screen renders export and restore actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionStateProvider.overrideWith(
            (_) => Stream.value(SubscriptionState.free()),
          ),
        ],
        child: const MaterialApp(home: DataBackupsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Export CSV'), findsOneWidget);
    expect(find.text('Export full backup'), findsOneWidget);
    expect(find.text('Restore backup'), findsOneWidget);
  });

  testWidgets('export full backup shares encrypted file after passphrase entry', (
    tester,
  ) async {
    final backupFile = File(
      '${Directory.systemTemp.path}/backup_${DateTime.now().millisecondsSinceEpoch}.ddbackup',
    )..writeAsStringSync('{}');
    addTearDown(() async {
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    });
    final sharedPaths = <String>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          createFullBackupProvider.overrideWith(
            (_) =>
                (_) async => backupFile,
          ),
          shareFilesProvider.overrideWith(
            (_) => (paths) async {
              sharedPaths.addAll(paths);
            },
          ),
          subscriptionStateProvider.overrideWith(
            (_) => Stream.value(SubscriptionState.free()),
          ),
        ],
        child: const MaterialApp(home: DataBackupsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Export full backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'passphrase');
    await tester.enterText(find.byType(TextField).last, 'passphrase');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(sharedPaths, [backupFile.path]);
    expect(find.text('Encrypted backup created'), findsOneWidget);
  });

  testWidgets('restore backup shows validation failure safely', (tester) async {
    final pickedPath = '${Directory.systemTemp.path}/invalid.ddbackup';

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          backupFilePickerProvider.overrideWith(
            (_) =>
                () async => pickedPath,
          ),
          inspectBackupProvider.overrideWith(
            (_) =>
                (_, __) async => const BackupValidationResult(
                  isValid: false,
                  errors: ['Backup is corrupted'],
                ),
          ),
          subscriptionStateProvider.overrideWith(
            (_) => Stream.value(SubscriptionState.free()),
          ),
        ],
        child: const MaterialApp(home: DataBackupsScreen()),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'passphrase');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Backup is corrupted'), findsOneWidget);
  });

  testWidgets(
    'restore backup previews contents and completes replace restore',
    (tester) async {
      final pickedPath = '${Directory.systemTemp.path}/restore.ddbackup';
      final restored = <String>[];
      final preview = BackupPreview(
        manifest: BackupManifest(
          backupFormatVersion: 1,
          createdAt: DateTime(2026, 3, 10, 10),
          createdByAppVersion: '1.0.0+1',
          createdBySchemaVersion: 7,
          containsDocuments: true,
          debtCount: 2,
          paymentCount: 3,
          documentCount: 1,
          parsedExtractionCount: 1,
          scenarioCount: 1,
          reminderEventCount: 2,
        ),
        debtCount: 2,
        paymentCount: 3,
        documentCount: 1,
        parsedExtractionCount: 1,
        scenarioCount: 1,
        reminderEventCount: 2,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            backupFilePickerProvider.overrideWith(
              (_) =>
                  () async => pickedPath,
            ),
            inspectBackupProvider.overrideWith(
              (_) =>
                  (_, __) async => BackupValidationResult(
                    isValid: true,
                    errors: [],
                    preview: preview,
                  ),
            ),
            restoreBackupProvider.overrideWith(
              (_) => (file, _) async {
                restored.add(file.path);
                return preview;
              },
            ),
            subscriptionStateProvider.overrideWith(
              (_) => Stream.value(SubscriptionState.free()),
            ),
          ],
          child: const MaterialApp(home: DataBackupsScreen()),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore backup'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'passphrase');
      tester.binding.focusManager.primaryFocus?.unfocus();
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Replace local data?'), findsOneWidget);
      expect(find.text('Debts: 2'), findsOneWidget);
      await tester.tap(find.text('Replace data'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(restored, [pickedPath]);
      expect(
        find.text('Backup restored: 2 debts, 3 payments, 1 documents.'),
        findsOneWidget,
      );
    },
  );
}
