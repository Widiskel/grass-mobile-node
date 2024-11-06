// ignore_for_file: unnecessary_null_comparison, unused_local_variable

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:disable_battery_optimization/disable_battery_optimization.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/models/active_device_list_model.dart';
import 'package:grass/app/data/models/api_response.dart';
import 'package:grass/app/data/models/node_data_model.dart';
import 'package:grass/app/data/models/public_ip_model.dart';
import 'package:grass/app/data/repository/global_repository.dart';
import 'package:grass/app/data/repository/grass_repository.dart';
import 'package:grass/app/data/service/local_notification_service.dart';
import 'package:grass/app/data/utils/prefs_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@pragma("vm:entry-point")
class GrassService {
  final service = FlutterBackgroundService();

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

  Future<bool?> requestDisableBatteryOptimization() async {
    bool? isBatteryOptimizationDisabled =
        await DisableBatteryOptimization.isBatteryOptimizationDisabled;

    if (isBatteryOptimizationDisabled != true) {
      await DisableBatteryOptimization.showDisableBatteryOptimizationSettings();
    }

    return isBatteryOptimizationDisabled;
  }
}

@pragma("vm:entry-point")
startService(ServiceInstance service) async {
  LocalNotificationService localNotificationService =
      LocalNotificationService();
  SendPort? mainSendPort = IsolateNameServer.lookupPortByName('node_service');
  GlobalRepository globalRepository = GlobalRepository();
  GrassRepository grassRepository = GrassRepository();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int pongCount = 0;
  Timer? pingInterval;
  String deviceIp = "";
  ActiveDevices? currentDevice;
  int networkQuality = 0;

  Future<void> getDeviceIp() async {
    try {
      ApiResponse<PublicIpModel> res = await globalRepository.getIp();
      deviceIp = res.res!.ip!;
    } catch (e) {
      log("API Failed to get device IP");
    }
  }

  Future<void> getActiveDevices() async {
    await getDeviceIp();
    try {
      ApiResponse<ActiveDeviceListModel> res =
          await grassRepository.getActiveDevices();

      List<ActiveDevices> devices = res.res!.result!.data!;
      currentDevice =
          devices.firstWhereOrNull((device) => device.ipAddress == deviceIp);
      if (currentDevice != null) {
        networkQuality = currentDevice!.ipScore ?? 0;

        mainSendPort?.send(
          NodeData(
            isConnected: true,
            isConnecting: false,
            deviceIp: deviceIp,
            networkScore: networkQuality,
          ).toJson(),
        );

        log("API ACTIVE DEVICES  ${currentDevice!.toJson()}");
      } else {
        log("API ACTIVE DEVICES CURRENT DEVICE NOT FOUND");
      }
    } catch (e) {
      log("API Failed To Get Epoch Stage");
    }
  }

  String content = "Connecting To Grass Server";
  mainSendPort?.send(
    NodeData(
      isConnected: false,
      isConnecting: true,
      networkScore: networkQuality,
    ).toJson(),
  );
  log("SERVICE WSS :$content");
  localNotificationService.showNotification(content);

  WebSocketChannel? channel = WebSocketChannel.connect(
    Uri.parse('wss://proxy2.wynd.network:4444/'),
  );
  await channel.ready;
  await getDeviceIp();

  content = "Connected to Grass Server";
  log("SERVICE WSS :$content");
  localNotificationService.showNotification(content);

  service.on("stop").listen((event) async {
    log("SERVICE WSS : STOPPING SERVICE");
    networkQuality = 0;
    deviceIp = "";
    channel = null;

    localNotificationService.dismissNotification();
    localNotificationService
        .showDismissableNotification("Disconnected By User");
    service.stopSelf();
    mainSendPort?.send(
      NodeData(
        isConnected: false,
        isConnecting: false,
        statusText: "Connect to start earning",
        networkScore: networkQuality,
      ).toJson(),
    );
    await Future.delayed(const Duration(seconds: 3));
    await localNotificationService.dismissNotification();

    log("SERVICE WSS : STOPPED");
  });

  mainSendPort?.send(
    NodeData(
            isConnected: true,
            isConnecting: false,
            deviceIp: deviceIp,
            networkScore: networkQuality,
            statusText:
                "You're doing great! Keep conneted to this network to earn.")
        .toJson(),
  );

  channel?.stream.listen(
    (message) async {
      Map<String, dynamic> msg = jsonDecode(message);

      String action = msg["action"];
      content = "Receiving Message : $msg";
      log("SERVICE WSS :$content");
      localNotificationService.showNotification(content);

      switch (action) {
        case "AUTH":
          String authBody = jsonEncode({
            "id": msg["id"],
            "origin_action": "AUTH",
            "result": {
              "browser_id": prefs.getString(PrefsConstant.deviceId),
              "user_id": prefs.getString(PrefsConstant.userId),
              "user_agent": prefs.getString(PrefsConstant.userAgent),
              "timestamp": DateTime.now().millisecondsSinceEpoch,
              "device_type": "extension",
              "version": "4.26.2",
              "extension_id": "lkbnfiajjmbhnfledhphioinpickokdi",
            },
          });
          content = "Sending Auth Response";
          log("SERVICE WSS :$content");
          localNotificationService.showNotification(content);

          channel?.sink.add(authBody);
          content = "Auth Response To Sended";
          log("SERVICE WSS :$content");
          localNotificationService.showNotification(content);

          await getActiveDevices();

          pingInterval ??=
              Timer.periodic(const Duration(minutes: 2), (timer) async {
            content = "Sending PING Request";
            log("SERVICE WSS :$content");
            localNotificationService.showNotification(content);
            Uuid uuid = const Uuid();
            String pingBody = jsonEncode({
              "id": uuid.v4(),
              "version": "1.0.0",
              "action": "PING",
              "data": {},
            });
            channel?.sink.add(pingBody);

            content = "PING request Sent";
            log("SERVICE WSS :$content");
            localNotificationService.showNotification(content);
          });
          break;
        case "PONG":
          if (currentDevice == null) await getActiveDevices();
          String pongBody = jsonEncode(
              {"id": msg["id"], "version": "1.0.0", "origin_action": "PONG"});
          channel?.sink.add(pongBody);
          pongCount += 1;
          content = "You have response $pongCount x PONG";
          log("SERVICE WSS :$content");
          localNotificationService.showNotification(content);

        default:
      }
    },
    onError: (error) {
      networkQuality = 0;
      deviceIp = "";
      log("SERVICE WSS WebSocket Error: $error");
      localNotificationService.dismissNotification();
      localNotificationService
          .showDismissableNotification("Disconnected by Error");

      mainSendPort?.send(
        NodeData(
          isConnected: false,
          isConnecting: false,
          statusText: "Connect to start earning",
          networkScore: networkQuality,
        ).toJson(),
      );

      pingInterval?.cancel();
      service.stopSelf();
    },
    onDone: () {
      log("SERVICE WSS WebSocket connection closed.");
      localNotificationService.dismissNotification();
      localNotificationService.showDismissableNotification("Disconnected");

      networkQuality = 0;
      deviceIp = "";
      mainSendPort?.send(
        NodeData(
          isConnected: false,
          isConnecting: false,
          statusText: "Connect to start earning",
          networkScore: networkQuality,
        ).toJson(),
      );
      pingInterval?.cancel();
      service.stopSelf();
    },
  );
}
