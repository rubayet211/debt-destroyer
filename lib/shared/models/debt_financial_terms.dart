import '../enums/app_enums.dart';

class DebtFinancialTerms {
  const DebtFinancialTerms({
    this.interestCompounding = InterestCompounding.monthlyCompound,
    this.statementDayOfMonth,
    this.minimumPaymentRule = MinimumPaymentRule.fixedAmount,
    this.minimumPaymentPercent,
    this.promoApr,
    this.promoEndsOn,
    this.monthlyFee = 0,
    this.lateFee = 0,
    this.lateFeeGraceDays = 0,
    this.penaltyApr,
  });

  final InterestCompounding interestCompounding;
  final int? statementDayOfMonth;
  final MinimumPaymentRule minimumPaymentRule;
  final double? minimumPaymentPercent;
  final double? promoApr;
  final DateTime? promoEndsOn;
  final double monthlyFee;
  final double lateFee;
  final int lateFeeGraceDays;
  final double? penaltyApr;

  bool get hasAdvancedTerms =>
      statementDayOfMonth != null ||
      minimumPaymentRule != MinimumPaymentRule.fixedAmount ||
      minimumPaymentPercent != null ||
      promoApr != null ||
      promoEndsOn != null ||
      monthlyFee > 0 ||
      lateFee > 0 ||
      lateFeeGraceDays > 0 ||
      penaltyApr != null ||
      interestCompounding != InterestCompounding.monthlyCompound;

  Map<String, Object?> toJson() {
    return {
      'interestCompounding': interestCompounding.name,
      'statementDayOfMonth': statementDayOfMonth,
      'minimumPaymentRule': minimumPaymentRule.name,
      'minimumPaymentPercent': minimumPaymentPercent,
      'promoApr': promoApr,
      'promoEndsOn': promoEndsOn?.toIso8601String(),
      'monthlyFee': monthlyFee,
      'lateFee': lateFee,
      'lateFeeGraceDays': lateFeeGraceDays,
      'penaltyApr': penaltyApr,
    };
  }

  factory DebtFinancialTerms.fromJson(Map<String, Object?> json) {
    return DebtFinancialTerms(
      interestCompounding: InterestCompounding.values.byName(
        json['interestCompounding']?.toString() ??
            InterestCompounding.monthlyCompound.name,
      ),
      statementDayOfMonth: _asInt(json['statementDayOfMonth']),
      minimumPaymentRule: MinimumPaymentRule.values.byName(
        json['minimumPaymentRule']?.toString() ??
            MinimumPaymentRule.fixedAmount.name,
      ),
      minimumPaymentPercent: _asDouble(json['minimumPaymentPercent']),
      promoApr: _asDouble(json['promoApr']),
      promoEndsOn: _asDate(json['promoEndsOn']),
      monthlyFee: _asDouble(json['monthlyFee']) ?? 0,
      lateFee: _asDouble(json['lateFee']) ?? 0,
      lateFeeGraceDays: _asInt(json['lateFeeGraceDays']) ?? 0,
      penaltyApr: _asDouble(json['penaltyApr']),
    );
  }

  DebtFinancialTerms copyWith({
    InterestCompounding? interestCompounding,
    int? statementDayOfMonth,
    MinimumPaymentRule? minimumPaymentRule,
    double? minimumPaymentPercent,
    double? promoApr,
    DateTime? promoEndsOn,
    double? monthlyFee,
    double? lateFee,
    int? lateFeeGraceDays,
    double? penaltyApr,
  }) {
    return DebtFinancialTerms(
      interestCompounding: interestCompounding ?? this.interestCompounding,
      statementDayOfMonth: statementDayOfMonth ?? this.statementDayOfMonth,
      minimumPaymentRule: minimumPaymentRule ?? this.minimumPaymentRule,
      minimumPaymentPercent:
          minimumPaymentPercent ?? this.minimumPaymentPercent,
      promoApr: promoApr ?? this.promoApr,
      promoEndsOn: promoEndsOn ?? this.promoEndsOn,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      lateFee: lateFee ?? this.lateFee,
      lateFeeGraceDays: lateFeeGraceDays ?? this.lateFeeGraceDays,
      penaltyApr: penaltyApr ?? this.penaltyApr,
    );
  }

  static double? _asDouble(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toDouble();
    }
    return double.tryParse(raw.toString());
  }

  static int? _asInt(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is num) {
      return raw.toInt();
    }
    return int.tryParse(raw.toString());
  }

  static DateTime? _asDate(Object? raw) {
    if (raw == null) {
      return null;
    }
    return DateTime.tryParse(raw.toString());
  }
}
