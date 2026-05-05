class MeterReadingHistory {
  final int id;
  final int meterId;
  final String? meterNumber;
  final String meterType; // 'electricity' atau 'water'
  final String readingValue;
  final String? photoPath;
  final String? recordedAt;
  final String? locationAddress;
  final String? description;
  final String? status;

  MeterReadingHistory({
    required this.id,
    required this.meterId,
    this.meterNumber,
    required this.meterType,
    required this.readingValue,
    this.photoPath,
    this.recordedAt,
    this.locationAddress,
    this.description,
    this.status,
  });

  factory MeterReadingHistory.fromJson(Map<String, dynamic> json) {
    return MeterReadingHistory(
      id: json['id'],
      meterId: json['meter_id'],
      meterNumber: json['meter_number'],
      meterType: json['meter_type'] ?? 'electricity',
      readingValue: json['reading_value']?.toString() ?? '0',
      photoPath: json['photo_path'],
      recordedAt: json['recorded_at'],
      locationAddress: json['location_address'],
      description: json['description'],
      status: json['status'],
    );
  }

  bool get isElectric => meterType == 'electricity';
  bool get isChecked => status == 'checked';
}