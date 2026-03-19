import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.user != null) {
      final role = auth.user!.roles.first;
      final remote = await NotificationService.fetchRemoteHistory(role);
      final local = await NotificationService.getLocalHistory();

      setState(() {
        _notifications = [...remote, ...local];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications yet'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
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
                          child: Icon(Icons.notifications,
                              color: Color(0xFF2E7D32)),
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
                ),
    );
  }
}
