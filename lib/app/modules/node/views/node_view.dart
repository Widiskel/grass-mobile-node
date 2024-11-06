import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/utils/pallete.dart';
import '../controllers/node_controller.dart';

class NodeView extends GetView<NodeController> {
  const NodeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<NodeController>(builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image.asset(
                "assets/logos/grass-horizontal-logo.png",
                height: 40,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              controller.currentStage?.stageName ?? "Epoch 2",
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () async {
                controller.isConnected
                    ? controller.stopBackgroundService()
                    : await controller.startBackgroundService();
              },
              child: Container(
                width: Get.width * 0.5,
                height: Get.width * 0.5,
                decoration: BoxDecoration(
                  color: controller.isConnected
                      ? Pallete.colorPrimary
                      : Pallete.colorSecondary,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Pallete.colorBlack,
                      blurRadius: 1,
                      spreadRadius: 8,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: controller.isConnecting
                      ? SizedBox(
                          width: Get.width * 0.3,
                          height: Get.width * 0.3,
                          child: const CircularProgressIndicator(
                            color: Pallete.colorBlack,
                            strokeWidth: 10,
                          ),
                        )
                      : Icon(
                          !controller.isConnected
                              ? Icons.power_settings_new_sharp
                              : Icons.stop_circle_rounded,
                          size: Get.width * 0.3,
                        ),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            controller.isConnected
                ? Column(
                    children: [
                      Text(
                        !controller.isConnecting
                            ? "Grass Is Connected"
                            : "Connecting...",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        "(${controller.deviceIp})",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () async {
                      await controller.startBackgroundService();
                    },
                    child: Container(
                      width: Get.width * 0.6,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Pallete.colorPrimary,
                        border: Border.all(
                          color: Pallete.colorBlack,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: Text(
                          "Connect Grass",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            Container(
              width: Get.width * 0.8,
              height: 50,
              decoration: BoxDecoration(
                color: controller.isConnected
                    ? Pallete.colorSecondary
                    : Pallete.colorErrorSecondary,
                boxShadow: [
                  BoxShadow(
                    color: controller.isConnected
                        ? Pallete.colorBlack
                        : Pallete.colorTextSecondary,
                    blurRadius: 1,
                    spreadRadius: 5,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Center(
                child: Text(
                  "Network Quality : ${controller.networkQuality} %",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                controller.connectionText,
                maxLines: 2,
                softWrap: true,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        );
      }),
    );
  }
}
