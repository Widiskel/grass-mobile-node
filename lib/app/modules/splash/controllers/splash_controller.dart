import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/service/local_notification_service.dart';
import 'package:grass/app/data/utils/prefs_constant.dart';
import 'package:grass/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SplashController extends GetxController {
  final LocalNotificationService localNotificationService =
      LocalNotificationService();

  @override
  void onInit() async {
    super.onInit();

    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Future.delayed(const Duration(seconds: 3)).then((value) async {
      localNotificationService.initializeNotifications();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLogin = prefs.getBool(PrefsConstant.loginStatus) ?? false;
      Uuid uuid = const Uuid();
      String? deviceId = prefs.getString(PrefsConstant.deviceId);

      if (deviceId == null) {
        deviceId =
            uuid.v5(Namespace.dns.value, DateTime.now().toIso8601String());
        await prefs.setString(PrefsConstant.deviceId, deviceId);
      }

      log("Is User Login : ${isLogin.toString()}");
      log("Device ID : ${deviceId.toString()}");
      if (isLogin) {
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }
}
