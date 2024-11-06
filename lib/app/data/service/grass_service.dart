import 'dart:async';
import 'dart:developer';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:grass/app/data/service/local_notification_service.dart';

@pragma('vm:entry-point')
startService(ServiceInstance service) {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  String content = "Initializing";
  service.on("stop").listen((event) {
    service.stopSelf();
    log("BACKGTOUND SERVICE IS NOW STOPPED");
  });

  service.on("update").listen((msg) {
    content = msg!['content'];
  });

  log("SERVICE IS RUNNING ${DateTime.now()} - $content");
  localNotificationService.showNotification(content);
  Timer.periodic(const Duration(seconds: 1), (timer) {
    log("SERVICE IS RUNNING ${DateTime.now()} - $content");
    localNotificationService.showNotification(content);
  });
}

@pragma('vm:entry-point')
class GrassService {
  final service = FlutterBackgroundService();

  @pragma('vm:entry-point')
  initialize() async {
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: (service) {},
        onBackground: (service) {
          return true;
        },
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: startService,
        isForegroundMode: false,
        autoStartOnBoot: false,
      ),
    );
    log("SERVICE IS CONFIGURED");
  }

  @pragma('vm:entry-point')
  Future<bool?> requestDisableBatteryOptimization() async {
    bool? isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    if (isBatteryOptimizationDisabled != true) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }

    return isBatteryOptimizationDisabled;
  }
}
