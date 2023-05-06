import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsod_flutter/contoller/auth_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthenticationController authenticationController = Get.put(AuthenticationController());

  GlobalKey<ScaffoldState> _globalKey = GlobalKey();

  late StreamSubscription<ConnectivityResult> _onConnectivityChanged;

  final Connectivity _connectivity = Connectivity();

  Future<void> checkConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();

      if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
        authenticationController.onInit();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            duration: Duration(seconds: 6000),
            content: Text(
              "No Internet Connection",
              textAlign: TextAlign.center,
            ),
          ),
        );

        _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((event) {
          bool isNotConnected = event != ConnectivityResult.wifi && event != ConnectivityResult.mobile;
          isNotConnected ? SizedBox() : ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: isNotConnected ? Colors.red : Colors.green,
              duration: Duration(seconds: isNotConnected ? 6000 : 1),
              content: Text(
                isNotConnected ? "No Internet Connection" : "Connected to Internet",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    //color: !isNotConnected ? Theme.of(context).primaryColor : Colors.white,
                    ),
              ),
            ),
          );
          if (!isNotConnected) {
            authenticationController.onInit();
          }
        });
      }
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status = $e');
      return;
    }
  }

  @override
  void initState() {
    super.initState();

    checkConnectivity();
    //startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    _onConnectivityChanged.cancel();
  }

  @override
  Widget build(BuildContext context) {
    /*final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;*/
    return Scaffold(
      key: _globalKey,
      backgroundColor: AppColors.appBackGroundColor,
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Image.asset(
                AppImages.appLogo,
              ),
            ),
            commonTextView(title: AppStrings.appName, fontWeight: FontWeight.bold, fontSize: 35, textColor: AppColors.whiteColor),
            SizedBox(height: 5),
            commonTextView(title: AppStrings.appFullName, fontWeight: FontWeight.w400, fontSize: 16.0, textColor: AppColors.whiteColor),
            /*SizedBox(height: height * 0.1),
            TweenAnimationBuilder(
              builder: (BuildContext context, double? value, Widget? child) {
                return Transform.scale(
                  scale: value! * 0.5,
                  child: child,
                );
              },
              tween: authenticationController.scaleTween,
              duration: const Duration(seconds: 1),
              child: SizedBox(
                width: width * 0.8,
                child: Image.asset(
                  AppImages.splashImage,
                ),
              ),
            ),
            const Spacer(),
            commonTextView(
              title: AppStrings.splashTitle,
              fontWeight: FontWeight.w600,
              fontSize: 16,
              textColor: AppColors.whiteColor,
            ),
            const SizedBox(height: 10),
            commonTextView(
              title: AppStrings.description,
              fontWeight: FontWeight.w400,
              fontSize: 11,
              textColor: AppColors.whiteColor,
            ),
            const Spacer(flex: 2),*/
          ],
        ),
      ),
    );
  }
}
