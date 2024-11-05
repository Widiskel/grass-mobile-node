import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grass/app/data/utils/pallete.dart';

class SuccessSnack extends StatelessWidget {
  final String message;

  const SuccessSnack({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static void show({required String message}) {
    Get.snackbar(
      'Success !!!',
      '',
      backgroundColor: Pallete.colorPrimary,
      colorText: Colors.white,
      icon: const Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      messageText: SuccessSnack(message: message),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
    );
  }
}

class ErrorSnack extends StatelessWidget {
  final String message;

  const ErrorSnack({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static void show({required String message, int duration = 2}) {
    Get.snackbar(
      'Error !!!',
      '',
      backgroundColor: Pallete.colorError,
      colorText: Colors.white,
      icon: const Icon(
        Icons.error_outline,
        color: Colors.white,
      ),
      messageText: ErrorSnack(message: message),
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
    );
  }
}
