import '../enums/app_enums.dart';

class Payment {
  const Payment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    required this.method,
    required this.sourceType,
    required this.notes,
    required this.tags,
    required this.createdAt,
  });

  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? method;
  final PaymentSourceType sourceType;
  final String notes;
  final List<String> tags;
  final DateTime createdAt;

  Payment copyWith({
    String? id,
    String? debtId,
    double? amount,
    DateTime? date,
    String? method,
    PaymentSourceType? sourceType,
    String? notes,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return Payment(
      id: id ?? this.id,
      debtId: debtId ?? this.debtId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      sourceType: sourceType ?? this.sourceType,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
