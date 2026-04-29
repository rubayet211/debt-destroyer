import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/features/debts/presentation/debts_screens.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/import_models.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';
import 'package:debt_destroyer/shared/providers/app_providers.dart';

void main() {
  testWidgets(
    'debt details shows ongoing promo apr without missing date text',
    (tester) async {
      final debt = Debt(
        id: 'promo-debt',
        title: 'Promo card',
        creditorName: 'Bank',
        type: DebtType.creditCard,
        currency: 'USD',
        originalBalance: 2000,
        currentBalance: 1500,
        apr: 19.9,
        minimumPayment: 75,
        dueDate: DateTime(2026, 3, 15),
        paymentFrequency: PaymentFrequency.monthly,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 3, 1),
        notes: '',
        tags: const [],
        status: DebtStatus.active,
        remindersEnabled: true,
        customPriority: 1,
        financialTerms: const DebtFinancialTerms(
          promoApr: 0,
          promoEndsOn: null,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            debtProvider(debt.id).overrideWith((_) => Stream.value(debt)),
            paymentsByDebtProvider(
              debt.id,
            ).overrideWith((_) => Stream.value(const <Payment>[])),
            documentsByDebtProvider(
              debt.id,
            ).overrideWith((_) => Stream.value(const <ImportedDocument>[])),
            userPreferencesProvider.overrideWith(
              (_) => Stream.value(UserPreferences.defaults()),
            ),
          ],
          child: MaterialApp(home: DebtDetailsScreen(debtId: debt.id)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0.00% ongoing'), findsOneWidget);
      expect(find.textContaining('Not set'), findsNothing);
    },
  );
}
