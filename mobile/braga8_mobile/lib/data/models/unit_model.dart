import 'invoice_modal.dart';

class Unit {
  final int id;
  final String name;
  
  final String unit;
  final String floor;
  final List<Invoice> invoices;

  Unit({
    required this.unit,
    required this.floor,
    required this.invoices, required this.id, required this.name,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '', unit: json['unit'] ?? '', floor: json['floor'] ?? '', invoices: [],
    );
  }
}
