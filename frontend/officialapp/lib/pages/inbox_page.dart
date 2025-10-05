import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/inbox_message.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  late Future<List<InboxMessage>> _inboxFuture;

  @override
  void initState() {
    super.initState();
    _inboxFuture = AuthService.fetchInbox();
  }

  void _refreshInbox() {
    setState(() {
      _inboxFuture = AuthService.fetchInbox();
    });
  }

  void _openMessage(InboxMessage msg) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                Text(
                  msg.message,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  msg.createdAt.toString(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(InboxMessage msg) {
    print(msg);
    if (msg.messageType == "friend_request_incoming") {
      print(msg);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  bool success = await AuthService.acceptFriendRequest(msg.id);
                  if (success) _refreshInbox();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Accept"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  bool success = await AuthService.declineFriendRequest(msg.id);
                  if (success) _refreshInbox();
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Decline"),
              ),
            ),
          ],
        ),
      );
    }

    if (msg.messageType == "friend_request_outgoing") {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ElevatedButton(
          onPressed: () async {
            bool success = await AuthService.cancelFriendRequest(msg.id);
            if (success) _refreshInbox();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text("Cancel"),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pushNamed(context, "/"),
        ),
        title: const Text(
          "Inbox",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<InboxMessage>>(
        future: _inboxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading inbox"));
          }

          final messages = snapshot.data ?? [];
          if (messages.isEmpty) {
            return const Center(child: Text("No messages"));
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshInbox(),
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Dismissible(
                    key: Key(msg.id.toString()),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: Icon(
                        msg.isRead ? Icons.mark_email_unread : Icons.mark_email_read,
                        color: Colors.white,
                      ),
                    ),
                    secondaryBackground: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await AuthService.markMessageReadToggle(msg.id, msg.isRead);
                        setState(() {
                          msg.isRead = !msg.isRead;
                        });
                        return false;
                      } else if (direction == DismissDirection.endToStart) {
                        await AuthService.deleteMessage(msg.id);
                        return true;
                      }
                      return false;
                    },
                    onDismissed: (_) => _refreshInbox(),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _openMessage(msg);
                            AuthService.markMessageReadToggle(msg.id, msg.isRead);
                            setState(() {
                              msg.isRead = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Row(
                                children: [
                                  if (!msg.isRead)
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
                                      msg.title,
                                      style: TextStyle(
                                        fontWeight:
                                            msg.isRead ? FontWeight.normal : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                msg.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                msg.createdAt.toString(),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                        _buildActionButtons(msg),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
