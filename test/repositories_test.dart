import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debt_destroyer/shared/data/local/app_database.dart';
import 'package:debt_destroyer/shared/data/repositories.dart';
import 'package:debt_destroyer/shared/enums/app_enums.dart';
import 'package:debt_destroyer/shared/models/debt.dart';
import 'package:debt_destroyer/shared/models/payment.dart';

void main() {
  late AppDatabase database;
  late DriftDebtsRepository debtsRepository;
  late DriftPaymentsRepository paymentsRepository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    debtsRepository = DriftDebtsRepository(database);
    paymentsRepository = DriftPaymentsRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('saving a payment recalculates debt balance', () async {
    final debt = Debt(
      id: 'd1',
      title: 'Visa',
      creditorName: 'Bank',
      type: DebtType.creditCard,
      currency: 'USD',
      originalBalance: 1000,
      currentBalance: 1000,
      apr: 20,
      minimumPayment: 60,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    await paymentsRepository.savePayment(
      Payment(
        id: 'p1',
        debtId: debt.id,
        amount: 250,
        date: DateTime(2026, 1, 20),
        method: 'ACH',
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 1, 20),
      ),
    );

    final updated = await debtsRepository.loadDebts();
    expect(updated.single.currentBalance, 750);
    expect(updated.single.status, DebtStatus.active);
  });

  test('paying full balance marks debt as paid off', () async {
    final debt = Debt(
      id: 'd2',
      title: 'BNPL',
      creditorName: 'Provider',
      type: DebtType.bnpl,
      currency: 'USD',
      originalBalance: 300,
      currentBalance: 300,
      apr: 0,
      minimumPayment: 50,
      dueDate: null,
      paymentFrequency: PaymentFrequency.monthly,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      notes: '',
      tags: const [],
      status: DebtStatus.active,
      remindersEnabled: false,
      customPriority: 1,
    );
    await debtsRepository.saveDebt(debt);

    await paymentsRepository.savePayment(
      Payment(
        id: 'p2',
        debtId: debt.id,
        amount: 300,
        date: DateTime(2026, 2, 1),
        method: null,
        sourceType: PaymentSourceType.manual,
        notes: '',
        tags: const [],
        createdAt: DateTime(2026, 2, 1),
      ),
    );

    final updated = await debtsRepository.loadDebts();
    expect(updated.single.currentBalance, 0);
    expect(updated.single.status, DebtStatus.paidOff);
  });
}
