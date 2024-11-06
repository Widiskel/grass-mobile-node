// ignore: unused_import
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/models/active_device_list_model.dart';
import 'package:grass/app/data/models/api_response.dart';
import 'package:grass/app/data/models/public_ip_model.dart';
import 'package:grass/app/data/repository/global_repository.dart';
import 'package:grass/app/data/repository/grass_repository.dart';
import 'package:grass/app/data/service/local_notification_service.dart';
import 'package:grass/app/data/utils/prefs_constant.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../../data/models/stage_list_model.dart';
import '../../../data/service/grass_service.dart';

class NodeController extends GetxController {
  GrassRepository grassRepository = GrassRepository();
  GlobalRepository globalRepository = GlobalRepository();
  StageModel? currentStage;
  bool isConnected = false;
  bool isConnecting = false;
  int networkQuality = 0;
  String connectionText = "Connect to start earning.";
  WebSocketChannel? channel;
  Timer? _reconnectTimer;
  final int _reconnectInterval = 3;
  final int _maxRetries = 5;
  int _retryCount = 0;
  SharedPreferences? prefs;
  Timer? pingInterval;
  String? deviceIp;
  final LocalNotificationService localNotificationService =
      LocalNotificationService();
  ActiveDevices? currentDevice;
  int pongCount = 0;
  GrassService grassService = GrassService();

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
    await grassService.initialize();
    await getDeviceIp();
    await getEpochStage();
  }

  Future<void> getDeviceIp() async {
    try {
      ApiResponse<PublicIpModel> res = await globalRepository.getIp();
      deviceIp = res.res!.ip!;
    } catch (e) {
      log("FAILED TO GET DEVICE IP");
    }
  }

  Future<void> getEpochStage() async {
    try {
      ApiResponse<StageListModel> res = await grassRepository.getEpochStage();

      List<StageModel> stages = res.res!.result!.data!;
      currentStage = stages.last;
      log("API CURRENT STAGE  ${currentStage!.toJson()}");
      update();
    } catch (e) {
      log("API Failed To Get Epoch Stage");
    }
  }

  Future<void> getActiveDevices() async {
    try {
      await getDeviceIp();
      ApiResponse<ActiveDeviceListModel> res =
          await grassRepository.getActiveDevices();

      List<ActiveDevices> devices = res.res!.result!.data!;
      currentDevice =
          devices.firstWhereOrNull((device) => device.ipAddress == deviceIp);
      if (currentDevice != null) {
        networkQuality = currentDevice!.ipScore ?? 0;
        log("API ACTIVE DEVICES  ${currentDevice!.toJson()}");
      } else {
        log("API ACTIVE DEVICES CURRENT DEVICE NOT FOUND");
      }
      update();
    } catch (e) {
      log("API Failed To Get Epoch Stage");
    }
  }

  Future<void> wssConnect() async {
    _retryCount = 0;
    connectionText = "Connecting to Grass Server...!";
    isConnecting = true;
    update();
    updateServiceContent("Connecting to Grass Server...!");

    channel = WebSocketChannel.connect(
      Uri.parse('wss://proxy2.wynd.network:4444/'),
    );
    await channel!.ready;
    isConnecting = false;
    isConnected = true;
    connectionText =
        "You’re doing great! Keep connected to this network to earn.";
    updateServiceContent(
        "Connected. You’re doing great! Keep connected to this network to earn.");
    update();

    channel?.stream.listen(
      (message) {
        handleMessage(message);
      },
      onError: (error) {
        log("WSS WebSocket Error: $error");
        connectionText = "Connection error. Attempting to reconnect...";
        updateServiceContent("Connection error. Attempting to reconnect...");
        isConnecting = false;
        isConnected = false;
        deviceIp = null;
        networkQuality = 0;
        currentDevice = null;
        update();
        stopPing();
        attemptReconnect();
      },
      onDone: () {
        log("WSS WebSocket connection closed.");
        updateServiceContent("Disconnecting....");
        connectionText = "Connect to start earning.";
        isConnecting = false;
        isConnected = false;
        deviceIp = null;
        networkQuality = 0;
        currentDevice = null;
        updateServiceContent("Disconnected");
        update();
      },
    );
  }

  Future<void> handleMessage(dynamic message) async {
    log("WSS Receiving message: $message");
    updateServiceContent("Receiving Message : $message");
    Map<String, dynamic> msg = jsonDecode(message);
    String action = msg["action"];

    switch (action) {
      case "AUTH":
        await handleAuth(msg);
        await startPing();
        break;
      case "PONG":
        await sendPong(msg);
      default:
    }
  }

  Future<void> handleAuth(Map<String, dynamic> msg) async {
    Map<String, dynamic> res = {
      "id": msg["id"],
      "origin_action": "AUTH",
      "result": {
        "browser_id": prefs!.getString(PrefsConstant.deviceId),
        "user_id": prefs!.getString(PrefsConstant.userId),
        "user_agent": prefs!.getString(PrefsConstant.userAgent),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "device_type": "extension",
        "version": "4.26.2",
        "extension_id": "lkbnfiajjmbhnfledhphioinpickokdi",
      },
    };
    await sendMessage(jsonEncode(res));
  }

  Future<void> startPing() async {
    pingInterval ??= Timer.periodic(const Duration(minutes: 2), (timer) async {
      if (isConnected) {
        await sendPing();
      }
    });
    update();
  }

  Future<void> sendPing() async {
    Uuid uuid = const Uuid();
    Map<String, dynamic> res = {
      "id": uuid.v4(),
      "version": "1.0.0",
      "action": "PING",
      "data": {},
    };
    await sendMessage(jsonEncode(res));
    updateServiceContent("PING Message sended");
  }

  void stopPing() {
    if (pingInterval != null) {
      pingInterval?.cancel();
      pingInterval = null;
      update();
    }
  }

  Future<void> sendPong(Map<String, dynamic> data) async {
    Map<String, dynamic> res = {
      "id": data["id"],
      "version": "1.0.0",
      "origin_action": "PONG"
    };
    await sendMessage(jsonEncode(res));
    pongCount += 1;
    updateServiceContent("You has response $pongCount x PONG");
  }

  Future<void> sendMessage(String message) async {
    updateServiceContent("Sending Message : $message");
    if (channel != null && isConnected) {
      channel?.sink.add(message);
      log("WSS Sent message: $message");
      updateServiceContent("Message sent : $message");
      if (currentDevice == null) {
        await getActiveDevices();
      }
    } else {
      log("WSS Cannot send message. WebSocket not connected.");
      attemptReconnect();
    }
    update();
  }

  void attemptReconnect() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      _reconnectTimer = Timer(Duration(seconds: _reconnectInterval), () {
        log("WSS Reconnection attempt #$_retryCount");
        updateServiceContent("Reconnect attemnt $_retryCount");
        wssConnect();
      });
    } else {
      log("WSS Max reconnection attempts reached. Unable to reconnect.");
      updateServiceContent(
          "Max reconnection attempts reached. Unable to reconnect");
      connectionText = "Connection lost. Please retry manually.";
      update();
    }
  }

  Future<void> startBackgroundService() async {
    bool? isBatteryOptimizationDisabled =
        await grassService.requestDisableBatteryOptimization();

    if (isBatteryOptimizationDisabled != true) {
      bool userConsent = await showBatteryOptimizationDialog();

      if (!userConsent) {
        return;
      }
    }

    if (await grassService.service.isRunning()) {
      grassService.service.invoke("stop");
    }
    await grassService.service.startService();
    await wssConnect();
    update();
  }

  Future<bool> showBatteryOptimizationDialog() async {
    bool userConsent = false;
    await Get.dialog(
      AlertDialog(
        title: const Text("Battery Optimization Enabled"),
        content: const Text(
            "Running the app with battery optimization may stop the service when minimized. Do you want to proceed anyway?"),
        actions: [
          TextButton(
            onPressed: () {
              userConsent = false;
              Get.back();
            },
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              userConsent = true;
              Get.back();
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    return userConsent;
  }

  updateServiceContent(msg) async {
    if (await grassService.service.isRunning()) {
      grassService.service.invoke("update", {"content": msg});
    }
  }

  void stopBackgroundService() async {
    _reconnectTimer?.cancel();
    if (channel != null) {
      channel?.sink.close();
      isConnected = false;
      connectionText = "Connect to start earning.";
      grassService.service.invoke("stop");
      update();
    }
  }
}
