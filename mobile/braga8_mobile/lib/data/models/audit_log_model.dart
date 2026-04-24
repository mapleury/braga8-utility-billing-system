class AuditLogResponse {
  final List<AuditLog> data;
  final int currentPage;
  final int lastPage;

  AuditLogResponse({required this.data, required this.currentPage, required this.lastPage});

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    return AuditLogResponse(
      data: (json['data'] as List).map((i) => AuditLog.fromJson(i)).toList(),
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
    );
  }
}

class AuditLog {
  final int id;
  final String userName;
  final String action;
  final String description; // Ini kuncinya!
  final String createdAt;

  AuditLog({
    required this.id,
    required this.userName,
    required this.action,
    required this.description,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      userName: json['user']?['name'] ?? 'System',
      action: json['action'] ?? 'unknown',
      description: json['description'] ?? '-',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}