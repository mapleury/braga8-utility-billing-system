import 'invoice_modal.dart';

class Unit {
  final String unit;
  final String floor;
  final List<Invoice> invoices;

  Unit({
    required this.unit,
    required this.floor,
    required this.invoices,
  });
}