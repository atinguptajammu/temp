import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

class SpecialListHomeScreen extends StatelessWidget {
  static const routeName = '/home_screen';
  final LoginController loginController = Get.find();

  SpecialListHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            commonTextView(title: "Specialist Home Screen"),
            commonTextView(title: loginController.doctorLoginModel.value.data?.first.user?.address),
            commonTextView(title: loginController.doctorLoginModel.value.data?.first.user?.firstName),
          ],
        ),
      ),
    );
  }
}
