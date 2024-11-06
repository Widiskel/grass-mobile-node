// ignore: unused_import
// ignore_for_file: unused_field

import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/models/api_response.dart';
import 'package:grass/app/data/models/node_data_model.dart';
import 'package:grass/app/data/repository/global_repository.dart';
import 'package:grass/app/data/repository/grass_repository.dart';
import 'package:grass/app/widget/snackbar_widget.dart';
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
  String deviceIp = "";

  @override
  void onInit() async {
    super.onInit();
    await getEpochStage();
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

  Future<void> startBackgroundService() async {
    bool? isBatteryOptimizationDisabled =
        await GrassService().requestDisableBatteryOptimization();

    if (isBatteryOptimizationDisabled != true) {
      bool userConsent = await showBatteryOptimizationDialog();

      if (!userConsent) {
        SuccessSnack.show(
            message:
                "Running with battery optimization enable, can cause app process stopped when minized");
      }
    }

    if (await GrassService().service.isRunning()) {
      GrassService().service.invoke("stop");
    }
    await GrassService().service.startService();
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

  void stopBackgroundService() async {
    if (await GrassService().service.isRunning()) {
      GrassService().service.invoke("stop");
    }
  }

  void updateFromBackground(Map<String, dynamic> data) {
    NodeData nodeData = NodeData.fromJson(data);
    isConnected = nodeData.isConnected ?? false;
    isConnecting = nodeData.isConnecting ?? false;
    connectionText = nodeData.statusText ?? connectionText;
    deviceIp = nodeData.deviceIp ?? deviceIp;
    networkQuality = nodeData.networkScore ?? networkQuality;
    update();
  }
}
