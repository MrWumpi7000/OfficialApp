class InboxMessage {
  final int id;
  final String senderEmail;
  final String recipientEmail;
  final String title;
  final String message;
  final String messageType;
  bool isRead; // ✅ make mutable
  final DateTime createdAt;

  InboxMessage({
    required this.id,
    required this.senderEmail,
    required this.recipientEmail,
    required this.title,
    required this.message,
    required this.messageType,
    required this.isRead,
    required this.createdAt,
  });

  factory InboxMessage.fromJson(Map<String, dynamic> json) {
    return InboxMessage(
      id: json['id'],
      senderEmail: json['sender_email'] ?? '',
      recipientEmail: json['recipient_email'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      messageType: json['message_type'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
