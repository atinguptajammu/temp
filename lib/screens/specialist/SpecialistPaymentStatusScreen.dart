import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';

import 'home/specialist_home_screen.dart';

class SpecialistPaymentStatusScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpecialistPaymentStatusScreenState();
}

class _SpecialistPaymentStatusScreenState extends State<SpecialistPaymentStatusScreen> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  bool _paymentSuccessShow = false;

  @override
  void initState() {
    super.initState();
    _starTimer();
  }

  void _starTimer() {
    Timer(Duration(seconds: 2), () {
      setState(() {
        _paymentSuccessShow = true;
      });
      _stopAnimation();
    });
  }

  void _stopAnimation() {
    Timer(Duration(seconds: 1), () {
      _controller.stop();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => SpecialistHomeScreen(),
        ),
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gradientPayment1,
                AppColors.gradientPayment2,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Visibility(
                  visible: _paymentSuccessShow,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 50),
                    child: ScaleTransition(
                      scale: _animation,
                      child: Image.asset(
                        AppImages.completeIcon,
                        height: 115,
                        width: 115,
                      ),
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    "Your case is closed",
                    //#GCW 05-02-2024
                    //"Your payment is completed",
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 24, color: AppColors.whiteColor),
                  ),
                ),
                SizedBox(
                  height: 45,
                ),
                Visibility(
                  visible: _paymentSuccessShow == false,
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            "Please wait while we redirect",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.whiteColor),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 3),
                          child: Text(
                            "you to Home",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.whiteColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: _paymentSuccessShow,
                  child: Container(
                    margin: EdgeInsets.only(top: 3),
                    child: Text(
                      "Thanks",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.whiteColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
