class Invoice {
  final String month;
  final double electricityUsage;
  final double waterUsage;
  final bool isPaid;

  final double pricePerKwh;
  final double pricePerM3;

  Invoice({
    required this.month,
    required this.electricityUsage,
    required this.waterUsage,
    required this.isPaid,
    this.pricePerKwh = 1500,
    this.pricePerM3 = 2000,
  });

  double get electricityTotal => electricityUsage * pricePerKwh;
  double get waterTotal => waterUsage * pricePerM3;
  double get grandTotal => electricityTotal + waterTotal;

  String get totalFormatted =>
      "Rp. ${grandTotal.toInt().toString().replaceAllMapped(
        RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'),
        (Match m) => '${m[1]}.',
      )}";

  String get electricityDisplay =>
      "${electricityUsage.toStringAsFixed(0)} Kwh";

  String get waterDisplay =>
      "${waterUsage.toStringAsFixed(0)} m³";
}