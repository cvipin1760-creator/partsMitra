import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/notification_provider.dart';
import '../providers/auth_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user != null) {
        final role = auth.user!.roles.first;
        final userId = auth.user!.id;
        Provider.of<NotificationProvider>(context, listen: false)
            .init(role, userId: userId);
        Provider.of<NotificationProvider>(context, listen: false)
            .markAllAsRead();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              if (auth.user != null) {
                final role = auth.user!.roles.first;
                final userId = auth.user!.id;
                Provider.of<NotificationProvider>(context, listen: false)
                    .refresh(role, userId: userId);
              }
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          final notifications = notificationProvider.notifications;

          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              final title = n['title'] ?? 'No Title';
              final body = n['message'] ?? n['body'] ?? 'No Message';
              final dateStr = n['createdAt'] ?? '';
              final date = dateStr.isNotEmpty
                  ? DateFormat('MMM dd, yyyy HH:mm')
                      .format(DateTime.parse(dateStr))
                  : 'Unknown date';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.notifications, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(body),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
