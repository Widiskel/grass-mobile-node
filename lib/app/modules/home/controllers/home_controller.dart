import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/modules/node/views/node_view.dart';
import 'package:grass/app/modules/website/controllers/website_controller.dart';
import 'package:grass/app/modules/website/views/website_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  late SharedPreferences prefs;
  WebsiteController websiteController = Get.find<WebsiteController>();
  int bottomNavIdx = 0;

  List<Widget> menu = [
    const NodeView(),
    const WebsiteView(),
  ];

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
  }
}
