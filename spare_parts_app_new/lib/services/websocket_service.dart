import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../utils/constants.dart';

class WebSocketService {
  StompClient? _client;

  void connect(Function(Map<String, dynamic>) onMessageReceived) {
    if (!Constants.useRemote || !Constants.enableWebSocket) {
      if (kDebugMode) {
        debugPrint('WebSocket Mock: Standalone mode active');
      }
      return;
    }

    final wsUrl = Constants.wsUrl;
    if (kDebugMode) {
      debugPrint('Connecting to WebSocket: $wsUrl');
    }

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: (frame) {
          if (kDebugMode) {
            debugPrint('WebSocket Connected: ${frame.headers}');
          }

          // Subscribe to general notifications
          _client?.subscribe(
            destination: '/topic/notifications',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                onMessageReceived(data);
              }
            },
          );

          // You could also subscribe to user-specific or role-specific topics here
          // For example, if you had the user's role:
          // _client?.subscribe(destination: '/topic/notifications/ROLE_MECHANIC', ...);
        },
        onWebSocketError: (error) => debugPrint('WebSocket Error: $error'),
        onStompError: (frame) => debugPrint('STOMP Error: ${frame.body}'),
        onDisconnect: (frame) => debugPrint('WebSocket Disconnected'),
      ),
    );

    _client?.activate();
  }

  void disconnect() {
    _client?.deactivate();
  }
}
