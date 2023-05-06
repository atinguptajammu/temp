import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class AppSnackBar {
  static void showErrorSnackBar({
    required String message,
    required String title,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      borderRadius: 8,
      backgroundColor: title.toLowerCase() == "error"
          ? AppColors.appColor
          : title.toLowerCase() == "success"
              ? Colors.green
              : Colors.black45,
      animationDuration: const Duration(milliseconds: 500),
      duration: const Duration(seconds: 2),
      barBlur: 10,
      colorText: Colors.white,
      isDismissible: false,
    );
  }
}
