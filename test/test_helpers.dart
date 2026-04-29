import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/debt_financial_terms.dart';
import 'package:debt_destroyer/shared/models/payment.dart';
import 'package:debt_destroyer/shared/models/user_preferences.dart';

Debt buildTestDebt({
  String id = 'debt-1',
  String title = 'Visa',
  double originalBalance = 1200,
  double currentBalance = 950,
  double apr = 19.9,
  double minimumPayment = 55,
  DateTime? dueDate,
  DebtStatus status = DebtStatus.active,
  PaymentFrequency paymentFrequency = PaymentFrequency.monthly,
  bool remindersEnabled = true,
  int customPriority = 1,
  DebtFinancialTerms financialTerms = const DebtFinancialTerms(),
}) {
  return Debt(
    id: id,
    title: title,
    creditorName: 'Bank',
    type: DebtType.creditCard,
    currency: 'USD',
    originalBalance: originalBalance,
    currentBalance: currentBalance,
    apr: apr,
    minimumPayment: minimumPayment,
    dueDate: dueDate,
    paymentFrequency: paymentFrequency,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 3, 1),
    notes: '',
    tags: const [],
    status: status,
    remindersEnabled: remindersEnabled,
    customPriority: customPriority,
    financialTerms: financialTerms,
  );
}

Payment buildTestPayment({
  String id = 'payment-1',
  String debtId = 'debt-1',
  double amount = 125,
  DateTime? date,
  PaymentSourceType sourceType = PaymentSourceType.manual,
}) {
  final resolvedDate = date ?? DateTime(2026, 3, 9);
  return Payment(
    id: id,
    debtId: debtId,
    amount: amount,
    date: resolvedDate,
    method: 'ACH',
    sourceType: sourceType,
    notes: '',
    tags: const [],
    createdAt: resolvedDate,
  );
}

UserPreferences buildTestPreferences({
  bool hideBalances = false,
  ThemePreference themeMode = ThemePreference.system,
  bool notificationsEnabled = true,
}) {
  return UserPreferences.defaults().copyWith(
    hideBalances: hideBalances,
    themeMode: themeMode,
    notificationsEnabled: notificationsEnabled,
  );
}
