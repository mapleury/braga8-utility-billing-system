import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

class Tenant {
  final int id;
  final String name;
  final List<Unit> units;

  Tenant({required this.id, required this.name, required this.units});

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    name: json['tenant_name'] ?? json['name'] ?? 'Unknown Shop',
    units: (json['units'] as List? ?? []).map((u) => Unit.fromJson(u)).toList(),
  );
}
class Unit {
  final int id;
  final String unitNumber;
  final String floor;
  final bool isElecChecked;
  final bool isWaterChecked;
  final String? electricMeterNumber;
  final String? waterMeterNumber;

  // --- GENERAL FALLBACK (Jika butuh satu alamat utama unit) ---
  final String? locationAddress;

  // --- CURRENT DATA (Index 0) ---
  final String? elecReadingValue;
  final String? elecPhotoPath;
  final String? elecRecordedAt;
  final String? elecDescription;
  final String? elecLocationAddress; // NEW: Categorized
  
  final String? waterReadingValue;
  final String? waterPhotoPath;
  final String? waterRecordedAt;
  final String? waterDescription;
  final String? waterLocationAddress; // NEW: Categorized

  // --- PREVIOUS DATA (Index 1) ---
  final String? prevElecReadingValue;
  final String? prevElecPhotoPath;
  final String? prevElecRecordedAt;
  final String? prevElecLocationAddress; // NEW: Categorized
  
  final String? prevWaterReadingValue;
  final String? prevWaterPhotoPath;
  final String? prevWaterRecordedAt;
  final String? prevWaterLocationAddress; // NEW: Categorized

  Unit({
    required this.id,
    required this.unitNumber,
    required this.floor,
    required this.isElecChecked,
    required this.isWaterChecked,
    this.locationAddress,
    this.electricMeterNumber,
    this.waterMeterNumber,
    // Current
    this.elecReadingValue,
    this.elecPhotoPath,
    this.elecRecordedAt,
    this.elecDescription,
    this.elecLocationAddress,
    this.waterReadingValue,
    this.waterPhotoPath,
    this.waterRecordedAt,
    this.waterDescription,
    this.waterLocationAddress,
    // Previous
    this.prevElecReadingValue,
    this.prevElecPhotoPath,
    this.prevElecRecordedAt,
    this.prevElecLocationAddress,
    this.prevWaterReadingValue,
    this.prevWaterPhotoPath,
    this.prevWaterRecordedAt,
    this.prevWaterLocationAddress,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    final List meters = json['meters'] as List? ?? [];

    // Helper untuk ambil reading berdasarkan index
    Map<String, dynamic>? getReadingAt(Map<String, dynamic>? meter, int index) {
      if (meter == null) return null;
      final List readings = meter['readings'] as List? ?? [];
      if (readings.length > index) return readings[index];
      return null;
    }

    // 1. Identifikasi Meter
    final Map<String, dynamic>? elecMeter = meters.firstWhere(
      (m) => m['meter_type'] == 'electricity', orElse: () => null,
    );
    final Map<String, dynamic>? waterMeter = meters.firstWhere(
      (m) => m['meter_type'] == 'water', orElse: () => null,
    );

    // 2. Ambil Reading (Index 0 = Current, Index 1 = Previous)
    final latestElec = getReadingAt(elecMeter, 0);
    final prevElec = getReadingAt(elecMeter, 1);
    final latestWater = getReadingAt(waterMeter, 0);
    final prevWater = getReadingAt(waterMeter, 1);

    return Unit(
      id: json['id'],
      unitNumber: json['unit_number'] ?? 'N/A',
      floor: json['floor'] ?? '-',
      isElecChecked: latestElec != null,
      isWaterChecked: latestWater != null,
      electricMeterNumber: elecMeter?['meter_number'],
      waterMeterNumber: waterMeter?['meter_number'],

      // Fallback Alamat Utama (Ambil dari mana saja yang tersedia pertama kali)
      locationAddress: latestElec?['location_address'] ?? latestWater?['location_address'],

      // --- CURRENT MAPPINGS ---
      elecReadingValue: latestElec?['reading_value']?.toString(),
      elecPhotoPath: latestElec?['photo_path'],
      elecRecordedAt: latestElec?['recorded_at'],
      elecDescription: latestElec?['description'],
      elecLocationAddress: latestElec?['location_address'], // Mapped!

      waterReadingValue: latestWater?['reading_value']?.toString(),
      waterPhotoPath: latestWater?['photo_path'],
      waterRecordedAt: latestWater?['recorded_at'],
      waterDescription: latestWater?['description'],
      waterLocationAddress: latestWater?['location_address'], // Mapped!

      // --- PREVIOUS MAPPINGS ---
      prevElecReadingValue: prevElec?['reading_value']?.toString(),
      prevElecPhotoPath: prevElec?['photo_path'],
      prevElecRecordedAt: prevElec?['recorded_at'],
      prevElecLocationAddress: prevElec?['location_address'], // Mapped!

      prevWaterReadingValue: prevWater?['reading_value']?.toString(),
      prevWaterPhotoPath: prevWater?['photo_path'],
      prevWaterRecordedAt: prevWater?['recorded_at'],
      prevWaterLocationAddress: prevWater?['location_address'], // Mapped!
    );
  }
}