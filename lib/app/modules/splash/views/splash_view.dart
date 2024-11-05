import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/utils/pallete.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.colorPrimary,
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: Get.width,
              height: Get.height * 0.9,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(100),
              child: Hero(
                tag: "logo",
                child: Image.asset(
                  "assets/logos/grass-vertical-logo.png",
                  width: Get.width,
                  height: Get.width,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "By : Skel Drop Hunt".toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            )
          ],
        ),
      ),
    );
  }
}
