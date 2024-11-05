import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:get/get.dart';
import 'package:grass/app/routes/app_pages.dart';

class LocalNotificationService {
  LocalNotificationService() {
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'grass node',
          channelKey: 'grass',
          channelName: 'Grass Notification',
          channelDescription: 'Grass Websocket Notification',
          importance: NotificationImportance.High,
          playSound: false,
          channelShowBadge: true,
        ),
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications(
            channelKey: "grass",
            permissions: [
              NotificationPermission.Alert,
              NotificationPermission.Badge,
            ]);
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

  Future<void> showNotification(String body, {String? payload}) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        channelKey: 'grass',
        body: body,
        locked: true,
        displayOnBackground: true,
        displayOnForeground: true,
        autoDismissible: false,
        notificationLayout: NotificationLayout.BigText,
        payload: payload != null ? {'payload': payload} : null,
        id: 0,
        actionType: ActionType.Default,
        category: NotificationCategory.Service,
      ),
    );
  }

  Future<void> dismissNotification() async {
    await AwesomeNotifications().cancelAll();
  }
}

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Get.toNamed(Routes.HOME);
  }
}
