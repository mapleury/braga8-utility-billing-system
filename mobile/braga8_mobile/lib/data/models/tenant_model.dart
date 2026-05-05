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
        units: (json['units'] as List? ?? [])
            .map((u) => Unit.fromJson(u))
            .toList(),
      );
}

// ── Meter model ───────────────────────────────────────────────────────────────
class Meter {
  final int id;
  final String? meterNumber;
  final String? meterType; // 'electricity' or 'water'

  Meter({
    required this.id,
    this.meterNumber,
    this.meterType,
  });

  factory Meter.fromJson(Map<String, dynamic> json) => Meter(
        id: json['id'],
        meterNumber: json['meter_number'],
        meterType: json['meter_type'],
      );
}

// ── Unit model ────────────────────────────────────────────────────────────────
class Unit {
  final int id;
  final String unitNumber;
  final String floor;
  final bool isElecChecked;
  final bool isWaterChecked;
  final String? electricMeterNumber;
  final String? waterMeterNumber;

  // ── Parsed meter objects (NEW) ─────────────────────────────────────────────
  final List<Meter> meters;

  // ── Reading IDs (for edit) ─────────────────────────────────────────────────
  final int? elecReadingId;
  final int? waterReadingId;

  // ── General fallback ───────────────────────────────────────────────────────
  final String? locationAddress;

  // ── Current data ───────────────────────────────────────────────────────────
  final String? elecReadingValue;
  final String? elecPhotoPath;
  final String? elecRecordedAt;
  final String? elecDescription;
  final String? elecLocationAddress;

  final String? waterReadingValue;
  final String? waterPhotoPath;
  final String? waterRecordedAt;
  final String? waterDescription;
  final String? waterLocationAddress;

  // ── Previous data ──────────────────────────────────────────────────────────
  final String? prevElecReadingValue;
  final String? prevElecPhotoPath;
  final String? prevElecRecordedAt;
  final String? prevElecLocationAddress;

  final String? prevWaterReadingValue;
  final String? prevWaterPhotoPath;
  final String? prevWaterRecordedAt;
  final String? prevWaterLocationAddress;

  Unit({
    required this.id,
    required this.unitNumber,
    required this.floor,
    required this.isElecChecked,
    required this.isWaterChecked,
    required this.meters,
    this.elecReadingId,
    this.waterReadingId,
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
    final List rawMeters = json['meters'] as List? ?? [];

    // ── Parse all meters into Meter objects ───────────────────────────────────
    final List<Meter> parsedMeters =
        rawMeters.map((m) => Meter.fromJson(m as Map<String, dynamic>)).toList();

    // ── Helper: get reading at index from a raw meter map ─────────────────────
    Map<String, dynamic>? getReadingAt(Map<String, dynamic>? meter, int index) {
      if (meter == null) return null;
      final List readings = meter['readings'] as List? ?? [];
      if (readings.length > index) return readings[index];
      return null;
    }

    // ── Identify electric / water meter maps ──────────────────────────────────
    final Map<String, dynamic>? elecMeter = rawMeters.firstWhere(
      (m) => m['meter_type'] == 'electricity',
      orElse: () => null,
    );
    final Map<String, dynamic>? waterMeter = rawMeters.firstWhere(
      (m) => m['meter_type'] == 'water',
      orElse: () => null,
    );

    // ── Readings (index 0 = current, index 1 = previous) ─────────────────────
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

      // ── Meter objects list ─────────────────────────────────────────────────
      meters: parsedMeters,

      // ── Reading IDs ────────────────────────────────────────────────────────
      elecReadingId: latestElec != null ? latestElec['id'] : null,
      waterReadingId: latestWater != null ? latestWater['id'] : null,

      electricMeterNumber: elecMeter?['meter_number'],
      waterMeterNumber: waterMeter?['meter_number'],

      locationAddress:
          latestElec?['location_address'] ?? latestWater?['location_address'],

      // ── Current ────────────────────────────────────────────────────────────
      elecReadingValue: latestElec?['reading_value']?.toString(),
      elecPhotoPath: latestElec?['photo_path'],
      elecRecordedAt: latestElec?['recorded_at'],
      elecDescription: latestElec?['description'],
      elecLocationAddress: latestElec?['location_address'],

      waterReadingValue: latestWater?['reading_value']?.toString(),
      waterPhotoPath: latestWater?['photo_path'],
      waterRecordedAt: latestWater?['recorded_at'],
      waterDescription: latestWater?['description'],
      waterLocationAddress: latestWater?['location_address'],

      // ── Previous ───────────────────────────────────────────────────────────
      prevElecReadingValue: prevElec?['reading_value']?.toString(),
      prevElecPhotoPath: prevElec?['photo_path'],
      prevElecRecordedAt: prevElec?['recorded_at'],
      prevElecLocationAddress: prevElec?['location_address'],

      prevWaterReadingValue: prevWater?['reading_value']?.toString(),
      prevWaterPhotoPath: prevWater?['photo_path'],
      prevWaterRecordedAt: prevWater?['recorded_at'],
      prevWaterLocationAddress: prevWater?['location_address'],
    );
  }
}