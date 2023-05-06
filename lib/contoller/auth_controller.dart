import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';

import '../utils/app_string.dart';

class AuthenticationController extends GetxController {
  final Tween<double> scaleTween = Tween<double>(begin: 0.5, end: 2);
  late SharedPreferences sharedPreferences;

  @override
  void onInit() async {
    super.onInit();

    sharedPreferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    bool isLogin = (sharedPreferences.getBool("isLogin") ?? false);
    if(isLogin == true){
      String loginType = (sharedPreferences.getString("LoginType") ?? "");
      if(loginType == AppStrings.doctor){
        Get.offNamed(Routes.doctorDashboard);
      }else{
        Get.offNamed(Routes.specialistHomepage);
      }
    }else{
      Get.offNamed(Routes.login);
    }
  
    // Get.offNamed(Routes.specialistHomepage);
  }
}
