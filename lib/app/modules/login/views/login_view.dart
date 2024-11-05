import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/utils/pallete.dart';
import 'package:grass/app/widget/webview_widget.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (controller) {
      return Stack(
        children: [
          const WebViewWidget(),
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 2)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Container();
              } else {
                return Container(
                  width: Get.width,
                  height: Get.height,
                  color: Pallete.colorPrimary,
                  child: Center(
                    child: Hero(
                      tag: "logo",
                      child: Image.asset(
                        "assets/logos/grass-vertical-logo.png",
                        width: Get.width * 0.6,
                        height: Get.width * 0.6,
                      ),
                    ),
                  ),
                );
              }
            },
          )
        ],
      );
    });
  }
}
