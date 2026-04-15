import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key}); // <-- const constructor زیاد کرا

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await NotificationService.markAllRead();
    final data = await NotificationService.getAll();
    if (mounted) {
      setState(() {
        notifications = data;
        isLoading = false;
      });
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case "SUPPORT":
        return Icons.thumb_up_outlined;
      case "COMPLAINT_UPDATE":
        return Icons.update;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ئاگادارکردنەوەکان"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        "هیچ ئاگادارکردنەوەیەک نییە",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = notifications[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber[50],
                        child:
                            Icon(_typeIcon(n.type), color: Colors.amber[700]),
                      ),
                      title: Text(n.message),
                      subtitle: Text(
                        n.createdAt,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      tileColor: n.isRead ? null : Colors.amber[50],
                    );
                  },
                ),
    );
  }
}
