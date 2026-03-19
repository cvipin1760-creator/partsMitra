import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static GlobalKey<NavigatorState>? _navKey;

  static void configureNavigationKey(GlobalKey<NavigatorState> key) {
    _navKey = key;
  }

  static Future<void> initialize() async {
    // 1. Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (_navKey != null && payload != null) {
          try {
            final data = jsonDecode(payload) as Map<String, dynamic>;
            final route = data['route'] as String?;
            final offerType = data['offerType'] as String?;
            final role = data['role'] as String?;
            _navigateByRoleThenOffers(role, offerType, route);
          } catch (_) {
            _navKey!.currentState?.pushNamed('/offers');
          }
        }
      },
    );
    // Android 13+ permission prompt will be handled by the system when needed.

    // 2. Request FCM permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) debugPrint('User granted notification permission');
    }

    // 3. Handle foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        String? route = message.data['route'];
        String? offerType = message.data['offerType'];
        String? role = message.data['role'];
        final String? orderId = message.data['orderId'];
        final String? title =
            message.data['title'] ?? message.notification!.title;
        final String? msg =
            message.data['message'] ?? message.notification!.body;
        final String? imageUrl = message.data['imageUrl'];
        String payloadStr;
        if (route != null) {
          payloadStr = jsonEncode({
            'route': route,
            'offerType': offerType,
            'role': role,
            'orderId': orderId,
            'title': title,
            'message': msg,
            'imageUrl': imageUrl
          });
        } else {
          payloadStr = jsonEncode({
            'route': 'offers',
            'role': role,
            'offerType': offerType,
            'orderId': orderId,
            'title': title,
            'message': msg,
            'imageUrl': imageUrl
          });
        }
        showLocalNotification(
          title ?? 'New Notification',
          msg ?? '',
          payload: payloadStr,
        );
      }
    });

    // 4. Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (_navKey != null) {
        String? route = message.data['route'] ?? 'offers';
        String? offerType = message.data['offerType'];
        String? role = message.data['role'];
        final String? orderId = message.data['orderId'];
        final String? title =
            message.data['title'] ?? message.notification?.title;
        final String? msg =
            message.data['message'] ?? message.notification?.body;
        final String? imageUrl = message.data['imageUrl'];

        if (route == 'orders' && orderId != null && orderId.isNotEmpty) {
          _navKey!.currentState
              ?.pushNamed('/orders', arguments: {'orderId': orderId});
        }
        _navigateByRoleThenOffers(role, offerType, route,
            title: title, message: msg, imageUrl: imageUrl);
      }
    });

    // 5. If app was terminated and opened via notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null && _navKey != null) {
      String? route = initialMessage.data['route'] ?? 'offers';
      String? offerType = initialMessage.data['offerType'];
      String? role = initialMessage.data['role'];
      final String? orderId = initialMessage.data['orderId'];
      final String? title =
          initialMessage.data['title'] ?? initialMessage.notification?.title;
      final String? msg =
          initialMessage.data['message'] ?? initialMessage.notification?.body;
      final String? imageUrl = initialMessage.data['imageUrl'];

      if (route == 'orders' && orderId != null && orderId.isNotEmpty) {
        _navKey!.currentState
            ?.pushNamed('/orders', arguments: {'orderId': orderId});
      }

      _navigateByRoleThenOffers(role, offerType, route,
          title: title, message: msg, imageUrl: imageUrl);
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      debugPrint("Error getting FCM token: $e");
      return null;
    }
  }

  static Future<void> updateTokenOnServer(int userId, String token) async {
    try {
      final response = await http.post(
        Uri.parse("${Constants.baseUrl}/auth/update-fcm-token"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "token": token,
        }),
      );
      if (response.statusCode == 200) {
        if (kDebugMode) debugPrint("FCM Token updated on server");
      }
    } catch (e) {
      debugPrint("Failed to update FCM token on server: $e");
    }
  }

  static void showLocalNotification(String title, String body,
      {String? payload}) async {
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
      payload: payload,
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

  static void _navigateByRoleThenOffers(
      String? role, String? offerType, String? route,
      {String? title, String? message, String? imageUrl}) {
    if (_navKey == null) return;
    final nav = _navKey!.currentState;
    if (nav == null) return;
    if (title != null || message != null) {
      final ctx = _navKey!.currentContext;
      if (ctx != null) {
        final text = [if (title != null) title, if (message != null) message]
            .where((e) => e != null && e.isNotEmpty)
            .join(' — ');
        if (text.isNotEmpty) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(text),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
    String? targetRoute = route;
    if ((targetRoute == null || targetRoute.isEmpty) && role != null) {
      targetRoute = 'offers';
    }
    if (role != null) {
      final r = role.toUpperCase();
      if (r == 'RETAILER') {
        nav.pushNamed('/dashboard/retailer', arguments: {
          'offerType': offerType,
          'title': title,
          'message': message,
          'imageUrl': imageUrl
        });
      } else if (r == 'MECHANIC') {
        nav.pushNamed('/dashboard/mechanic', arguments: {
          'offerType': offerType,
          'title': title,
          'message': message,
          'imageUrl': imageUrl
        });
      } else if (r == 'WHOLESALER') {
        nav.pushNamed('/dashboard/wholesaler', arguments: {
          'offerType': offerType,
          'title': title,
          'message': message,
          'imageUrl': imageUrl
        });
      } else if (r == 'ADMIN' || r == 'SUPER_MANAGER') {
        nav.pushNamed('/dashboard/admin', arguments: {
          'offerType': offerType,
          'title': title,
          'message': message,
          'imageUrl': imageUrl
        });
      } else if (r == 'STAFF') {
        nav.pushNamed('/dashboard/staff', arguments: {
          'offerType': offerType,
          'title': title,
          'message': message,
          'imageUrl': imageUrl
        });
      }
    }
    if (targetRoute == 'offers') {
      nav.pushNamed('/offers', arguments: {
        'offerType': offerType,
        'title': title,
        'message': message,
        'imageUrl': imageUrl
      });
    }
  }

  // Compatibility methods for NotificationProvider
  Future<List<Map<String, dynamic>>> getMyNotifications(String role,
      {int? userId}) async {
    final remote = await fetchRemoteHistory(role, userId: userId);
    final local = await getLocalHistory();
    return [...remote.map((e) => e as Map<String, dynamic>), ...local];
  }

  static Future<void> subscribeToTopicsForRole(String role) async {
    try {
      await _fcm.subscribeToTopic('all-users');
      await _fcm.subscribeToTopic('role-$role');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  static void showInAppMessage(String title, String body) {
    if (_navKey == null) return;
    final ctx = _navKey!.currentContext;
    if (ctx == null) return;
    final text = [if (title.isNotEmpty) title, if (body.isNotEmpty) body]
        .where((e) => e.isNotEmpty)
        .join(' — ');
    if (text.isEmpty) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<int> getUnreadCount(String role) async {
    return 0;
  }

  Future<void> markAllAsRead() async {
    // Placeholder
  }

  Future<void> sendNotification(String title, String message, String targetRole,
      {String? imageUrl, String? offerType, String route = 'offers'}) async {
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
          "route": route,
          if (offerType != null) "offerType": offerType,
          if (imageUrl != null) "imageUrl": imageUrl,
        }),
      );
    } catch (e) {
      debugPrint("Failed to send notification: $e");
    }
  }
}
