import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  final NotificationService _apiService = NotificationService();
  List<Map<String, dynamic>> _notifications = [];
  bool _isConnected = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isConnected => _isConnected;

  void init(String role) {
    _wsService.connect((data) {
      _notifications.insert(0, data);
      notifyListeners();
      // You can also show a local notification here if you use a package like flutter_local_notifications
    });
    _isConnected = true;
    _fetchNotifications(role);
  }

  Future<void> _fetchNotifications(String role) async {
    final list = await _apiService.getMyNotifications(role);
    _notifications = list;
    notifyListeners();
  }

  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
