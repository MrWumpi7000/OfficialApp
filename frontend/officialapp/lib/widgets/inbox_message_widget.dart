import 'package:flutter/material.dart';
import 'inbox_message.dart';
import 'package:intl/intl.dart';

class InboxMessageWidget extends StatelessWidget {
  final InboxMessage message;
  final VoidCallback onTap;

  const InboxMessageWidget({
    Key? key,
    required this.message,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: message.isRead ? Colors.grey[300] : Colors.deepPurple,
          child: Icon(Icons.mail_outline, color: Colors.white),
        ),
        title: Text(
          message.title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: message.isRead ? Colors.grey[800] : Colors.black),
        ),
        subtitle: Text(
          message.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat.jm().format(message.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            if (!message.isRead)
              Icon(Icons.circle, color: Colors.deepPurple, size: 10),
          ],
        ),
      ),
    );
  }
}
