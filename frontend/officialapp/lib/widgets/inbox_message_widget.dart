import 'package:flutter/material.dart';
import 'inbox_message.dart';
import 'package:intl/intl.dart';

class InboxMessageWidget extends StatelessWidget {
  final InboxMessage message;
  final VoidCallback onTap;
  final Widget? actionButtons;

  const InboxMessageWidget({
    Key? key,
    required this.message,
    required this.onTap,
    this.actionButtons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            onTap: onTap,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor:
                  message.isRead ? Colors.grey[300] : Colors.deepPurple,
              child: const Icon(Icons.mail_outline, color: Colors.white),
            ),
            title: Row(
              children: [
                if (!message.isRead)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blueAccent,
                    ),
                    margin: const EdgeInsets.only(right: 8),
                  ),
                Expanded(
                  child: Text(
                    message.title,
                    style: TextStyle(
                      fontWeight:
                          message.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
              ],
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
                  const Icon(Icons.circle, color: Colors.deepPurple, size: 10),
              ],
            ),
          ),
          if (actionButtons != null) actionButtons!,
        ],
      ),
    );
  }
}
