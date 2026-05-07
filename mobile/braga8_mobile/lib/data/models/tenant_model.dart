import 'package:flutter/foundation.dart';

// ── Tenant ────────────────────────────────────────────────────────────────────
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

// ── Meter ─────────────────────────────────────────────────────────────────────
class Meter {
  final int id;
  final String? meterNumber;
  final String? meterType; // 'electricity' | 'water'

  Meter({required this.id, this.meterNumber, this.meterType});

  factory Meter.fromJson(Map<String, dynamic> json) => Meter(
    id: json['id'],
    meterNumber: json['meter_number'],
    meterType: json['meter_type'],
  );
}

// ── Unit ──────────────────────────────────────────────────────────────────────
class Unit {
  final int id;
  final String unitNumber;
  final String floor;
  final bool isElecChecked;
  final bool isWaterChecked;
  final String? elecStatus;
  final String? waterStatus;
  final String? electricMeterNumber;
  final String? waterMeterNumber;
  final List<Meter>? meters;

  // Reading IDs (untuk edit)
  final int? elecReadingId;
  final int? waterReadingId;

  // Fallback location
  final String? locationAddress;

  // ── Current ───────────────────────────────────────────────────────────────
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

  // ── Previous ──────────────────────────────────────────────────────────────
  final String? prevElecReadingValue;
  final String? prevElecPhotoPath;
  final String? prevElecRecordedAt;
  final String? prevElecLocationAddress;

  final String? prevWaterReadingValue;
  final String? prevWaterPhotoPath;
  final String? prevWaterRecordedAt;
  final String? prevWaterLocationAddress;

  const Unit({
    required this.id,
    required this.unitNumber,
    required this.floor,
    required this.isElecChecked,
    required this.isWaterChecked,
    this.meters,
    this.elecReadingId,
    this.waterReadingId,
    this.locationAddress,
    this.electricMeterNumber,
    this.waterMeterNumber,
    this.elecStatus,
    this.waterStatus,
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
    this.prevElecReadingValue,
    this.prevElecPhotoPath,
    this.prevElecRecordedAt,
    this.prevElecLocationAddress,
    this.prevWaterReadingValue,
    this.prevWaterPhotoPath,
    this.prevWaterRecordedAt,
    this.prevWaterLocationAddress,
  });

  // ── copyWith ──────────────────────────────────────────────────────────────
  Unit copyWith({
    int? id,
    String? unitNumber,
    String? floor,
    bool? isElecChecked,
    bool? isWaterChecked,
    List<Meter>? meters,
    int? elecReadingId,
    int? waterReadingId,
    String? locationAddress,
    String? electricMeterNumber,
    String? waterMeterNumber,
    String? elecStatus,
    String? waterStatus,
    String? elecReadingValue,
    String? elecPhotoPath,
    String? elecRecordedAt,
    String? elecDescription,
    String? elecLocationAddress,
    String? waterReadingValue,
    String? waterPhotoPath,
    String? waterRecordedAt,
    String? waterDescription,
    String? waterLocationAddress,
    String? prevElecReadingValue,
    String? prevElecPhotoPath,
    String? prevElecRecordedAt,
    String? prevElecLocationAddress,
    String? prevWaterReadingValue,
    String? prevWaterPhotoPath,
    String? prevWaterRecordedAt,
    String? prevWaterLocationAddress,
  }) {
    return Unit(
      id: id ?? this.id,
      unitNumber: unitNumber ?? this.unitNumber,
      floor: floor ?? this.floor,
      isElecChecked: isElecChecked ?? this.isElecChecked,
      isWaterChecked: isWaterChecked ?? this.isWaterChecked,
      meters: meters ?? this.meters,
      elecReadingId: elecReadingId ?? this.elecReadingId,
      waterReadingId: waterReadingId ?? this.waterReadingId,
      locationAddress: locationAddress ?? this.locationAddress,
      electricMeterNumber: electricMeterNumber ?? this.electricMeterNumber,
      waterMeterNumber: waterMeterNumber ?? this.waterMeterNumber,
      elecStatus: elecStatus ?? this.elecStatus,
      waterStatus: waterStatus ?? this.waterStatus,
      elecReadingValue: elecReadingValue ?? this.elecReadingValue,
      elecPhotoPath: elecPhotoPath ?? this.elecPhotoPath,
      elecRecordedAt: elecRecordedAt ?? this.elecRecordedAt,
      elecDescription: elecDescription ?? this.elecDescription,
      elecLocationAddress: elecLocationAddress ?? this.elecLocationAddress,
      waterReadingValue: waterReadingValue ?? this.waterReadingValue,
      waterPhotoPath: waterPhotoPath ?? this.waterPhotoPath,
      waterRecordedAt: waterRecordedAt ?? this.waterRecordedAt,
      waterDescription: waterDescription ?? this.waterDescription,
      waterLocationAddress: waterLocationAddress ?? this.waterLocationAddress,
      prevElecReadingValue: prevElecReadingValue ?? this.prevElecReadingValue,
      prevElecPhotoPath: prevElecPhotoPath ?? this.prevElecPhotoPath,
      prevElecRecordedAt: prevElecRecordedAt ?? this.prevElecRecordedAt,
      prevElecLocationAddress:
          prevElecLocationAddress ?? this.prevElecLocationAddress,
      prevWaterReadingValue:
          prevWaterReadingValue ?? this.prevWaterReadingValue,
      prevWaterPhotoPath: prevWaterPhotoPath ?? this.prevWaterPhotoPath,
      prevWaterRecordedAt: prevWaterRecordedAt ?? this.prevWaterRecordedAt,
      prevWaterLocationAddress:
          prevWaterLocationAddress ?? this.prevWaterLocationAddress,
    );
  }

  // ── fromJson ──────────────────────────────────────────────────────────────
  factory Unit.fromJson(Map<String, dynamic> json) {
    final List rawMeters = json['meters'] as List? ?? [];

    final List<Meter> parsedMeters = rawMeters
        .map((m) => Meter.fromJson(m as Map<String, dynamic>))
        .toList();

    final Map<String, dynamic>? elecMeter = rawMeters.firstWhere(
      (m) => m['meter_type'] == 'electricity',
      orElse: () => null,
    );
    final Map<String, dynamic>? waterMeter = rawMeters.firstWhere(
      (m) => m['meter_type'] == 'water',
      orElse: () => null,
    );

    final Map<String, dynamic>? latestElec =
        elecMeter?['latest_reading'] as Map<String, dynamic>?;
    final Map<String, dynamic>? prevElec =
        elecMeter?['previous_reading'] as Map<String, dynamic>?;
    final Map<String, dynamic>? latestWater =
        waterMeter?['latest_reading'] as Map<String, dynamic>?;
    final Map<String, dynamic>? prevWater =
        waterMeter?['previous_reading'] as Map<String, dynamic>?;

    return Unit(
      id: json['id'],
      unitNumber: json['unit_number'] ?? 'N/A',
      floor: json['floor'] ?? '-',
      isElecChecked: latestElec != null,
      isWaterChecked: latestWater != null,
      meters: parsedMeters,
      elecReadingId: latestElec?['id'],
      waterReadingId: latestWater?['id'],
      electricMeterNumber: elecMeter?['meter_number'],
      waterMeterNumber: waterMeter?['meter_number'],
      elecStatus: latestElec?['status'],
      waterStatus: latestWater?['status'],
      locationAddress:
          latestElec?['location_address'] ?? latestWater?['location_address'],
      // Current electric
      elecReadingValue: latestElec?['reading_value']?.toString(),
      elecPhotoPath: latestElec?['photo_path'],
      elecRecordedAt: latestElec?['recorded_at'],
      elecDescription: latestElec?['description'],
      elecLocationAddress: latestElec?['location_address'],
      // Current water
      waterReadingValue: latestWater?['reading_value']?.toString(),
      waterPhotoPath: latestWater?['photo_path'],
      waterRecordedAt: latestWater?['recorded_at'],
      waterDescription: latestWater?['description'],
      waterLocationAddress: latestWater?['location_address'],
      // Previous electric
      prevElecReadingValue: prevElec?['reading_value']?.toString(),
      prevElecPhotoPath: prevElec?['photo_path'],
      prevElecRecordedAt: prevElec?['recorded_at'],
      prevElecLocationAddress: prevElec?['location_address'],
      // Previous water
      prevWaterReadingValue: prevWater?['reading_value']?.toString(),
      prevWaterPhotoPath: prevWater?['photo_path'],
      prevWaterRecordedAt: prevWater?['recorded_at'],
      prevWaterLocationAddress: prevWater?['location_address'],
    );
  }
}
