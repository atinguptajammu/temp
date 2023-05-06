import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';
import 'package:vsod_flutter/widgets/common_button.dart';
import 'package:vsod_flutter/widgets/common_button2.dart';
import 'package:vsod_flutter/widgets/widget.dart';

import '../../utils/utils.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.appBackGroundColor,
      body: SingleChildScrollView(
        child: Form(
          key: loginController.formLoginKey,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(width: width, height: height * 0.095),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset(
                    AppImages.appLogo,
                  ),
                ),
                SizedBox(height: height * 0.01),
                commonTextView(title: AppStrings.appName, fontWeight: FontWeight.bold, fontSize: 43, textColor: AppColors.whiteColor),
                Text(
                  AppStrings.appFullName,
                  style: TextStyle(fontWeight: FontWeight.w400, fontSize: 11.0, color: AppColors.whiteColor, height: 0.5),
                ),
                SizedBox(height: height * 0.03),
                //commonTextView(title: AppStrings.signIn, fontWeight: FontWeight.w300, fontSize: 33.0, textColor: AppColors.whiteColor),
                commonTextFormField(
                  hintText: AppStrings.emailHint,
                  labelText: AppStrings.email1,
                  textFieldController: loginController.emailController,
                  leftPadding: 30.0,
                  rightPadding: 30.0,
                  validator: AppValidator.emailValidator,
                ),
                SizedBox(height: 5),
                commonTextFormField(
                  hintText: AppStrings.passwordHint,
                  labelText: AppStrings.password,
                  leftPadding: 30.0,
                  rightPadding: 30.0,
                  validator: AppValidator.passwordValidator,
                  textFieldController: loginController.passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Row(
                    children: [
                      commonTextView(
                        title: AppStrings.loginUs,
                        textColor: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30),
                    child: SizedBox(
                      height: 20,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              loginController.isSpecialistSelected.value = false;
                            },
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: Container(
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: loginController.isSpecialistSelected.value ? AppColors.halfWhite : Colors.white,
                                    ),
                                  ),
                                ),
                                commonTextView(
                                  title: AppStrings.doctor,
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 40),
                          GestureDetector(
                            onTap: () {
                              loginController.isSpecialistSelected.value = true;
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: loginController.isSpecialistSelected.value ? AppColors.whiteColor : AppColors.halfWhite,
                                  ),
                                ),
                                const SizedBox(width: 15),
                                commonTextView(
                                  title: AppStrings.specialists,
                                  textColor: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                CommonButton(
                  buttonName: AppStrings.log_in,
                  textColor: AppColors.appBackGroundColor,
                  onTap: () async {
                    var isInternetAvailable = await Utils.isInternetAvailable(context);
                    if (!isInternetAvailable) {
                      return;
                    }
                    if (loginController.formLoginKey.currentState!.validate()) {
                      loginController.getDoctorLogin(
                        context: context,
                        email: loginController.emailController.text,
                        password: loginController.passwordController.text,
                        type: loginController.isSpecialistSelected.value ? AppStrings.specialist : AppStrings.doctor,
                      );
                    }
                  },
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    commonTextView(
                      title: AppStrings.forgotPassword,
                      textColor: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 3),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routes.forgetPassword);
                      },
                      child: commonTextView2(
                        title: AppStrings.clickHere,
                        textColor: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    )
                  ],
                ),
                Obx(
                  () => loginController.isSpecialistSelected.value
                      ? Column(
                          children: [
                            SizedBox(height: height * 0.07),
                            commonTextView(
                              title: AppStrings.dontHaveAccount,
                              textColor: AppColors.white04Color,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            CommonButton2(
                              onTap: () {
                                Get.toNamed(Routes.signUpScreen);
                              },
                              buttonName: AppStrings.signUP,
                              backgroundColor: AppColors.button2BGColor,
                              textColor: Colors.white,
                              iconColor: Colors.white,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 50),
                            commonTextView(
                              title: AppStrings.dontHaveAccount3,
                              textColor: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            const SizedBox(height: 20),
                          ],
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
