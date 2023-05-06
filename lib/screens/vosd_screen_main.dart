import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/firebase_notification.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/utils/app_string.dart';

class VSODApp extends StatefulWidget {
  const VSODApp({Key? key}) : super(key: key);

  @override
  _VSODAppState createState() => _VSODAppState();
}

class _VSODAppState extends State<VSODApp> {

  @override
  void initState() {
    super.initState();

    FirebaseMessagingUtils.init();

  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      navigatorKey: Get.key,
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,
      theme: ThemeData(
        brightness: Brightness.light,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        disabledColor: Colors.transparent,
        fontFamily: AppConstants.openSans,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: AppColors.blackColor,
        ),
        scaffoldBackgroundColor: AppColors.whiteColor,
        buttonTheme: const ButtonThemeData(
          buttonColor: AppColors.appThemeColor,
        ),
        appBarTheme: const AppBarTheme(
          color: AppColors.whiteColor,
          iconTheme: IconThemeData(
            color: AppColors.blackColor,
          ),
        ),
        buttonBarTheme: const ButtonBarThemeData(alignment: MainAxisAlignment.center),
      ),
      initialRoute: Routes.splash,
      // initialRoute: Routes.specialistHomepage,
      getPages: Routes.pages,
    );
  }
}
