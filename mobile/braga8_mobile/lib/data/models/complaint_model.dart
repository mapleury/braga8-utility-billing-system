class Complaint {
  final int id;
  final String title;
  final String description;
  final String status; // 'pending' | 'in_progress' | 'resolved' | 'rejected'
  final String? imageUrl;
  final String? reportDate;
  final String? solution;

  const Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.imageUrl,
    this.reportDate,
    this.solution,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) => Complaint(
    id: int.tryParse(json['id'].toString()) ?? 0,
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    status: json['status'] as String? ?? 'pending',
    imageUrl: json['image'] as String?,
    reportDate: json['report_date'] as String?,
    solution: json['solution'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    if (imageUrl != null) 'image': imageUrl,
    if (reportDate != null) 'report_date': reportDate,
    if (solution != null) 'solution': solution,
  };

  Complaint copyWith({
    int? id,
    String? title,
    String? description,
    String? status,
    String? imageUrl,
    String? reportDate,
    String? solution,
  }) => Complaint(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    imageUrl: imageUrl ?? this.imageUrl,
    reportDate: reportDate ?? this.reportDate,
    solution: solution ?? this.solution,
  );
}
