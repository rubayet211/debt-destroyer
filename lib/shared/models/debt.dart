import '../enums/app_enums.dart';

class Debt {
  const Debt({
    required this.id,
    required this.title,
    required this.creditorName,
    required this.type,
    required this.currency,
    required this.originalBalance,
    required this.currentBalance,
    required this.apr,
    required this.minimumPayment,
    required this.dueDate,
    required this.paymentFrequency,
    required this.createdAt,
    required this.updatedAt,
    required this.notes,
    required this.tags,
    required this.status,
    required this.remindersEnabled,
    required this.customPriority,
  });

  final String id;
  final String title;
  final String creditorName;
  final DebtType type;
  final String currency;
  final double originalBalance;
  final double currentBalance;
  final double apr;
  final double minimumPayment;
  final DateTime? dueDate;
  final PaymentFrequency paymentFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String notes;
  final List<String> tags;
  final DebtStatus status;
  final bool remindersEnabled;
  final int customPriority;

  bool get isActive => status == DebtStatus.active;

  Debt copyWith({
    String? id,
    String? title,
    String? creditorName,
    DebtType? type,
    String? currency,
    double? originalBalance,
    double? currentBalance,
    double? apr,
    double? minimumPayment,
    DateTime? dueDate,
    PaymentFrequency? paymentFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? notes,
    List<String>? tags,
    DebtStatus? status,
    bool? remindersEnabled,
    int? customPriority,
  }) {
    return Debt(
      id: id ?? this.id,
      title: title ?? this.title,
      creditorName: creditorName ?? this.creditorName,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      originalBalance: originalBalance ?? this.originalBalance,
      currentBalance: currentBalance ?? this.currentBalance,
      apr: apr ?? this.apr,
      minimumPayment: minimumPayment ?? this.minimumPayment,
      dueDate: dueDate ?? this.dueDate,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      customPriority: customPriority ?? this.customPriority,
    );
  }
}
