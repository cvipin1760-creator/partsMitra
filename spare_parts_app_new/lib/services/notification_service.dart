import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(initializationSettings);
  }

  static void showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'spare_parts_channel',
      'Spare Parts Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _localNotifications.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    await _saveNotificationLocally(title, body);
  }

  static Future<void> _saveNotificationLocally(
      String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('local_notifications') ?? [];
    Map<String, dynamic> data = {
      'title': title,
      'body': body,
      'createdAt': DateTime.now().toIso8601String(),
    };
    notifications.add(jsonEncode(data));
    await prefs.setStringList('local_notifications', notifications);
  }

  static Future<List<Map<String, dynamic>>> getLocalHistory() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList('local_notifications') ?? [];
    return notifications
        .map((e) => jsonDecode(e) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  static Future<List<dynamic>> fetchRemoteHistory(String role,
      {int? userId}) async {
    try {
      String url = "${Constants.baseUrl}/notifications/my?role=$role";
      if (userId != null) {
        url += "&userId=$userId";
      }
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      debugPrint("Failed to fetch remote history: $e");
    }
    return [];
  }

  // Compatibility methods for NotificationProvider
  Future<List<Map<String, dynamic>>> getMyNotifications(String role,
      {int? userId}) async {
    final remote = await fetchRemoteHistory(role, userId: userId);
    final local = await getLocalHistory();
    return [...remote.map((e) => e as Map<String, dynamic>), ...local];
  }

  Future<int> getUnreadCount(String role) async {
    return 0;
  }

  Future<void> markAllAsRead() async {
    // Placeholder
  }

  Future<void> sendNotification(String title, String message, String targetRole,
      {String? imageUrl}) async {
    try {
      String endpoint = targetRole == 'ALL'
          ? "/notifications/send/broadcast"
          : "/notifications/send/role/$targetRole";

      await http.post(
        Uri.parse("${Constants.baseUrl}$endpoint"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "message": message,
          if (imageUrl != null) "imageUrl": imageUrl,
        }),
      );
    } catch (e) {
      debugPrint("Failed to send notification: $e");
    }
  }
}
