class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime? readAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.readAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      isRead: json['is_read'] == true || json['is_read'] == 1,
    );
  }
}
