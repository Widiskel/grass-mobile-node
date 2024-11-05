import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebsiteController extends GetxController {
  late SharedPreferences prefs;
  bool isWebsiteReady = false;

  @override
  void onInit() async {
    super.onInit();
    prefs = await SharedPreferences.getInstance();
  }
}
