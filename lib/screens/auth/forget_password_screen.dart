import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';
import 'package:vsod_flutter/widgets/common_button/common_button3.dart';
import 'package:vsod_flutter/widgets/common_widget/common_widget.dart';
import 'package:vsod_flutter/widgets/widget.dart';

class ForgetPasswordScreen extends StatefulWidget {
  ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackGroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Form(
            key: loginController.formForgetPasswordKey,
            child: Column(
              children: [
                CommonTitleLogo(title: AppStrings.passwordReset),
                const SizedBox(height: 40),
                commonTextFormField(
                    textFieldController: loginController.forgetEmailController,
                    hintText: AppStrings.emailHint,
                    labelText: AppStrings.enterEmail1,
                    leftPadding: 30.0,
                    rightPadding: 30.0,
                    validator: AppValidator.emailValidator),
                const SizedBox(height: 35),
                CommonButton3(
                  buttonName: AppStrings.submit,
                  onTap: () {
                    if (loginController.formForgetPasswordKey.currentState!.validate()) {
                      loginController.getForgetPasswordService(email: loginController.forgetEmailController.text,context: context);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    commonTextView(title: AppStrings.haveTroubleLogin, textColor: AppColors.halfWhite, fontWeight: FontWeight.w500, fontSize: 13),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.needHelp);
                      },
                      child: commonTextView(title: AppStrings.clickHere, textColor: Colors.white, fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
