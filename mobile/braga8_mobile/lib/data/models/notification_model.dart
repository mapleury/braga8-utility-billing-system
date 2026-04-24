class NotificationModel {
  final int id;
  final String title;
  final String message;
  final DateTime? readAt;
  

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
    );
  }
}