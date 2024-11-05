import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grass/app/data/utils/pallete.dart';
import 'package:grass/app/widget/webview_widget.dart';
import '../controllers/website_controller.dart';

class WebsiteView extends GetView<WebsiteController> {
  const WebsiteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Pallete.colorTextSecondary,
        ),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: const WebViewWidget(),
        ),
      ),
    );
  }
}
