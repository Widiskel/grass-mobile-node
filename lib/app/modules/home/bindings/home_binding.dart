import 'package:get/get.dart';
import 'package:grass/app/modules/node/controllers/node_controller.dart';
import 'package:grass/app/modules/website/controllers/website_controller.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.find<NodeController>();
    Get.put<WebsiteController>(WebsiteController(), permanent: true);
    Get.put<HomeController>(HomeController(), permanent: true);
  }
}
