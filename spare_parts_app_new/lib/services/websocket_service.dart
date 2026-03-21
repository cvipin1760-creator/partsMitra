import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../utils/constants.dart';

class WebSocketService {
  StompClient? _client;

  void connect(Function(Map<String, dynamic>) onMessageReceived,
      {String? role, int? userId}) {
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
        stompConnectHeaders: const {
          // request heartbeats: 10s outgoing, 10s incoming
          'heart-beat': '10000,10000',
        },
        onConnect: (frame) {
          if (kDebugMode) {
            debugPrint('WebSocket Connected: ${frame.headers}');
          }

          // 1. Subscribe to general broadcast notifications
          _client?.subscribe(
            destination: '/topic/notifications',
            callback: (frame) {
              if (frame.body != null) {
                final data = jsonDecode(frame.body!);
                onMessageReceived(data);
              }
            },
          );

          // 2. Subscribe to role-specific notifications
          if (role != null) {
            _client?.subscribe(
              destination: '/topic/notifications/$role',
              callback: (frame) {
                if (frame.body != null) {
                  final data = jsonDecode(frame.body!);
                  onMessageReceived(data);
                }
              },
            );
          }

          // 3. Subscribe to user-specific notifications
          if (userId != null) {
            _client?.subscribe(
              destination: '/user/$userId/queue/notifications',
              callback: (frame) {
                if (frame.body != null) {
                  final data = jsonDecode(frame.body!);
                  onMessageReceived(data);
                }
              },
            );
          }
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
