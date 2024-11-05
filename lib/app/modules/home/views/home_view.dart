// ignore: unused_import
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/utils/pallete.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (controller) {
      return Scaffold(
        backgroundColor: Pallete.colorBg,
        appBar: AppBar(
          shadowColor: Pallete.colorBlack,
          backgroundColor: Pallete.colorBg,
          elevation: 2,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                "assets/logos/grass-horizontal-logo.png",
                height: 30,
              ),
              // PopupMenuButton<String>(
              //   position: PopupMenuPosition.under,
              //   menuPadding: const EdgeInsets.symmetric(horizontal: 20),
              //   icon: const CircleAvatar(
              //     backgroundColor: Pallete.colorPrimary,
              //     backgroundImage: AssetImage(
              //       "assets/img/avatar.png",
              //     ),
              //   ),
              //   onSelected: (value) async {
              //     if (value == "logout") {
              //       await controller.websiteController.logout();
              //     }
              //   },
              //   itemBuilder: (BuildContext context) {
              //     return [
              //       const PopupMenuItem<String>(
              //         value: "logout",
              //         child: Text("Logout"),
              //       ),
              //     ];
              //   },
              // ),
            ],
          ),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: controller.bottomNavIdx,
          children: controller.menu,
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: const BoxDecoration(
            color: Pallete.colorBg,
            border: Border(
              top: BorderSide(
                color: Pallete.colorBlack,
                width: 2,
              ),
              left: BorderSide(
                color: Pallete.colorBlack,
                width: 2,
              ),
              right: BorderSide(
                color: Pallete.colorBlack,
                width: 2,
              ),
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.only(top: 5),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent, // So the container color shows
            elevation: 0, // Reduce elevation for seamless look
            selectedIconTheme: const IconThemeData(
              color: Pallete.colorBlack,
              size: 30,
            ),
            unselectedIconTheme: const IconThemeData(
              color: Pallete.colorTextSecondary,
              size: 30,
            ),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: (value) async {
              log("Bottom Nav Index $value");
              controller.bottomNavIdx = value;
              controller.update();
            },
            items: [
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: controller.bottomNavIdx == 0
                        ? Border.all(color: Pallete.colorBlack, width: 2)
                        : Border.all(color: Colors.transparent),
                    color: controller.bottomNavIdx == 0
                        ? Pallete.colorPrimary
                        : Colors.transparent,
                  ),
                  child: const Icon(Icons.webhook_rounded),
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: controller.bottomNavIdx == 1
                        ? Border.all(color: Pallete.colorBlack, width: 2)
                        : Border.all(color: Colors.transparent),
                    color: controller.bottomNavIdx == 1
                        ? Pallete.colorPrimary
                        : Colors.transparent,
                  ),
                  child: const Icon(Icons.laptop_chromebook_rounded),
                ),
                label: '',
              ),
            ],
          ),
        ),
      );
    });
  }
}
