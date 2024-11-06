import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grass/app/data/service/grass_service.dart';
import 'app/modules/node/controllers/node_controller.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  GrassService().initialize();
  final NodeController nodeController =
      Get.put(NodeController(), permanent: true);

  ReceivePort receivePort = ReceivePort();
  IsolateNameServer.registerPortWithName(receivePort.sendPort, 'node_service');

  receivePort.listen((data) {
    nodeController.updateFromBackground(data);
  });

  runApp(
    GetMaterialApp(
      title: "Grass Mobile Node",
      initialRoute: AppPages.INITIAL,
      theme: ThemeData(
        textTheme: GoogleFonts.karlaTextTheme().copyWith(
          titleLarge: GoogleFonts.karla(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: GoogleFonts.karla(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          titleSmall: GoogleFonts.karla(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
          bodyLarge: GoogleFonts.karla(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.karla(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.karla(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
          labelLarge: GoogleFonts.karla(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelMedium: GoogleFonts.karla(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          labelSmall: GoogleFonts.karla(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      defaultTransition: Transition.noTransition,
      getPages: AppPages.routes,
    ),
  );
}
