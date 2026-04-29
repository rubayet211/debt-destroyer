class MoneyMath {
  const MoneyMath._();

  static int toCents(double value) => (value * 100).round();

  static double fromCents(int value) => value / 100;

  static int multiply(int cents, double factor) => (cents * factor).round();

  static int roundDouble(double value) => value.round();
}
