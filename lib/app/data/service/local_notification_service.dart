import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:grass/app/routes/app_pages.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const channelId = "grass";
  static const channelName = "Grass Mobile Node";
  static const channelDesc = "Grass Websocket Notification";

  void initializeNotifications() async {
    await _requestPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_notification');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> _requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlatform =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlatform != null) {
      await androidPlatform.requestNotificationsPermission();
    }
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      log('Notification payload: $payload');
      Get.toNamed(Routes.HOME);
    }
  }

  Future<void> showNotification(String body, {String? payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.max,
      priority: Priority.high,
      playSound: false,
      enableVibration: false,
      showWhen: false,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      icon: '@drawable/ic_notification',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      androidPlatformChannelSpecifics.channelName,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> dismissNotification() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(0);
    } catch (e) {
      log('Error dismissing notification: $e');
    }
  }
}
