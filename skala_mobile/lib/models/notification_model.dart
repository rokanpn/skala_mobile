class NotificationModel {
  final int id;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    return NotificationModel(
      id: j['id'],
      message: j['message'] ?? '',
      type: j['type'] ?? 'SYSTEM',
      isRead: j['read'] ?? false,
      createdAt: j['createdAt']?.toString().substring(0, 10) ?? '',
    );
  }
}
