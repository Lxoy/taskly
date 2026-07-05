import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/network/api_client.dart';

class NotificationService {
  final ApiClient apiClient;

  NotificationService(this.apiClient);

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission();

    final token = await messaging.getToken();

    print('FCM TOKEN: $token');

    if (token != null) {
      await apiClient.dio.post(
        '/api/notifications/register-token',
        data: {'token': token, 'platform': 'android'},
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await apiClient.dio.post(
        '/api/notifications/register-token',
        data: {'token': newToken, 'platform': 'android'},
      );
    });
  }
}
