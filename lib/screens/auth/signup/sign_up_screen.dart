import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/signup_controller.dart';
import 'package:vsod_flutter/screens/auth/signup/signup_clinic_widget.dart';
import 'package:vsod_flutter/screens/auth/signup/signup_specialist_widget.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

import '../../../utils/utils.dart';
import '../../../widgets/common_button2.dart';
import '../../WebViewScreen.dart';

class SignUpScreen extends StatelessWidget {
  String? selectedValue;

  PageController controller = PageController();
  final SignUpController _signUpController = Get.put(SignUpController());
  GlobalKey<FormState> registerScreenKey1 = GlobalKey<FormState>();

  SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.appBackGroundColor,
      body: Obx(
        () => _signUpController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.only(left: 35, right: 35),
                child: SingleChildScrollView(
                  child: Form(
                    key: registerScreenKey1,
                    child: Column(
                      children: [
                        SizedBox(width: width, height: height * 0.05),
                        SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset(
                            AppImages.appLogo,
                          ),
                        ),
                        SizedBox(height: 10),
                        commonTextView(title: AppStrings.signUP, fontWeight: FontWeight.w300, fontSize: 40, textColor: AppColors.whiteColor),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              margin: const EdgeInsets.only(top: 2),
                              child: const Divider(
                                color: Colors.white,
                                thickness: 1.4,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, right: 5),
                              child: commonTextView(
                                title: "as",
                                fontWeight: FontWeight.w600,
                                fontSize: 12.0,
                                textColor: AppColors.whiteColor,
                              ),
                            ),
                            Container(
                              width: 60,
                              margin: const EdgeInsets.only(top: 2),
                              child: const Divider(
                                color: Colors.white,
                                thickness: 1.4,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        const SizedBox(height: 10),
                        Obx(
                          () => Padding(
                            padding: const EdgeInsets.only(left: 30, right: 30),
                            child: SizedBox(
                              height: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _signUpController.isSpecialistSelected.value = false;
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _signUpController.isSpecialistSelected.value ? AppColors.white04Color : Colors.white,
                                            ),
                                          ),
                                        ),
                                        commonTextView(
                                          title: AppStrings.clinic,
                                          textColor: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  GestureDetector(
                                    onTap: () {
                                      _signUpController.isSpecialistSelected.value = true;
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: Container(
                                            height: 12,
                                            width: 12,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _signUpController.isSpecialistSelected.value ? AppColors.whiteColor : AppColors.white04Color,
                                            ),
                                          ),
                                        ),
                                        commonTextView(
                                          title: AppStrings.specialist,
                                          textColor: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        ///Clinic
                        Obx(
                          () => _signUpController.isSpecialistSelected.value == false ? SignUpClinicWidget() : SignUpSpecialListWidget(),
                        ),

                        const SizedBox(height: 30),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => GestureDetector(
                                onTap: () {
                                  _signUpController.isCheckedTermCondition.value = !_signUpController.isCheckedTermCondition.value;
                                },
                                child: _signUpController.isCheckedTermCondition.value
                                    ? Container(
                                        height: 14,
                                        width: 14,
                                        color: Colors.white,
                                        child: const Icon(
                                          Icons.check,
                                          size: 15,
                                        ),
                                      )
                                    : Container(
                                        height: 14,
                                        width: 14,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: AppStrings.privacyData,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.6,
                                          fontSize: 11,
                                        ),
                                      ),
                                      TextSpan(
                                        text: AppStrings.termOfUse,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => WebViewScreen(url: AppStrings.TermsURL, type: "Terms of Use"),
                                              ),
                                            );
                                          },
                                      ),
                                      const TextSpan(
                                        text: ' and ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          letterSpacing: 0.6,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: AppStrings.privacyPolicy,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: new TapGestureRecognizer()
                                          ..onTap = () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => WebViewScreen(url: AppStrings.PolicyURL, type: "Privacy Policy"),
                                              ),
                                            );
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        CommonButton2(
                          buttonName: AppStrings.register,
                          iconData: Icons.arrow_forward,
                          backgroundColor: _signUpController.isCheckedTermCondition.value ? Colors.white : Colors.grey,
                          onTap: () async {
                            if (_signUpController.isCheckedTermCondition.value == true) {
                              var isInternetAvailable = await Utils.isInternetAvailable(context);
                              if (!isInternetAvailable) {
                                return;
                              }
                              if (registerScreenKey1.currentState?.validate() ?? false) {
                                if (_signUpController.isCheckedTermCondition.value == true) {
                                  if (_signUpController.createPasswordController.text == _signUpController.confirmPasswordController.text) {
                                    if (_signUpController.isSpecialistSelected.value == true) {
                                      if (_signUpController.specialistMobileNumberController.text.length == 10) {
                                        _signUpController.getRegisterSpecialist(
                                            firstNameSpecialization: _signUpController.specialistFirstNameController.text,
                                            lastNameSpecialization: _signUpController.specialistLastNameController.text,
                                            specializationId: _signUpController.selectSpecialization.value,
                                            passwordSpecialization: _signUpController.confirmPasswordController.text,
                                            mobileSpecialization: _signUpController.specialistMobileNumberController.text,
                                            stateIdSpecialization: _signUpController.selectSpecialistStateId.value,
                                            cityNameSpecialization: _signUpController.specialistAddressController.text,
                                            emailSpecialization: _signUpController.specialistEmailController.text,
                                            typeSpecialization: AppConstants.specialist,
                                            educationSpecialization: _signUpController.specialistEducationConfirmController.text,
                                            degreeSpecialization: _signUpController.specialistDegreeConfirmController.text,
                                            licenseSpecialization: _signUpController.specialistLicenceController.text,
                                            addressSpecialization: _signUpController.specialistAddressController.text);
                                      } else {
                                        Fluttertoast.showToast(msg: "Enter A Valid Mobile Number");
                                      }
                                    } else {
                                      if (_signUpController.clinicMobileNumberController.text.length == 10) {
                                        _signUpController.getRegisterClinic(
                                          clinicName: _signUpController.clinicMyPetClinicController.text,
                                          mobileClinic: _signUpController.clinicMobileNumberController.text,
                                          firstNameClinic: _signUpController.clinicFirstNameController.text,
                                          lastNameClinic: _signUpController.clinicLastNameController.text,
                                          emailClinic: _signUpController.clinicEmailController.text,
                                          clinicAddress: _signUpController.clinicAddressController.text,
                                          stateIdClinic: _signUpController.selectClientStateId.value,
                                          passwordClinic: _signUpController.createPasswordController.text,
                                          cityNameClinic: "howrah",

                                          ///UI Not Impliment
                                          typeClinic: AppConstants.clinic,
                                        );
                                      } else {
                                        Fluttertoast.showToast(msg: "Enter A Valid Mobile Number");
                                      }
                                    }
                                  } else {
                                    Fluttertoast.showToast(msg: AppStrings.passwordNotMatch);
                                  }
                                } else {
                                  Fluttertoast.showToast(msg: AppStrings.selectPrivecyPolicy);
                                }
                              }
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            commonTextView(
                              title: AppStrings.alreadyHaveAccount,
                              fontSize: 12,
                              textColor: AppColors.white04Color,
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.login);
                              },
                              child: commonTextView(
                                title: AppStrings.signInHere,
                                fontSize: 12,
                                textColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
