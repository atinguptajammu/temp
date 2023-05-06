import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/need_help_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';
import 'package:vsod_flutter/widgets/common_button/common_button3.dart';
import 'package:vsod_flutter/widgets/drop_down_decoration.dart';
import 'package:vsod_flutter/widgets/widget.dart';

class NeedHelpScreen extends StatefulWidget {

  NeedHelpScreen({Key? key}) : super(key: key);

  @override
  State<NeedHelpScreen> createState() => _NeedHelpScreenState();
}

class _NeedHelpScreenState extends State<NeedHelpScreen> {
  final NeedHelpController _needHelpController = Get.put(NeedHelpController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.appBackGroundColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 35, right: 35),
        child: SingleChildScrollView(
          child: Form(
            key: _needHelpController.formKeyNeedHelp,
            child: Column(
              children: [
                SizedBox(width: width, height: height * 0.05),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: const SizedBox(
                        height: 25,
                        width: 25,
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset(
                        AppImages.appLogo,
                      ),
                    ),
                    const SizedBox(width: 25),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 50),
                commonTextView(title: AppStrings.needHelp, fontWeight: FontWeight.w300, fontSize: 33, textColor: AppColors.whiteColor),
                commonTextView(title: AppStrings.doctorReachOut, fontWeight: FontWeight.w400, fontSize: 11.0, textColor: AppColors.whiteColor),
                SizedBox(height: height * 0.05),
                SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: commonTextFormField(
                          hintText: AppStrings.firstName,
                          labelText: AppStrings.firstName,
                          validator: AppValidator.emptyValidator,
                          leftPadding: 0.0,
                          rightPadding: 25.0,
                          textFieldController: _needHelpController.firstNameController,
                        ),
                        flex: 1,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: commonTextFormField(
                          hintText: AppStrings.lastName,
                          labelText: AppStrings.lastName,
                          leftPadding: 25.0,
                          rightPadding: 0.0,
                          textFieldController: _needHelpController.lastNameController,
                          validator: AppValidator.emptyValidator,
                        ),
                        flex: 1,
                      )
                    ],
                  ),
                ),
                SizedBox(
                  child: commonTextFormField(
                    hintText: AppStrings.emailHint,
                    labelText: AppStrings.email,
                    textFieldController: _needHelpController.emailController,
                    validator: AppValidator.emailValidator,
                  ),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 25),
                          child: DropdownButtonFormField(
                            isExpanded: true,

                            ///Add Validator
                            decoration: commonDropDownDecoration(lableText: AppStrings.selectRole),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              size: 30,
                              color: AppColors.halfWhite,
                            ),
                            hint: Text(
                              '---Select---',
                              style: TextStyle(fontSize: 16, color: AppColors.halfWhite),
                            ),
                            style: TextStyle(
                              color: AppColors.halfWhite,
                              fontSize: 13.5,
                            ),
                            selectedItemBuilder: (_) {
                              return ["Specialist", "Doctor", "Admin"].map((e) {
                                return Container(
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: AppColors.white04Color,
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            //value: _needHelpController.selectStateID.value,
                            onChanged: (value) {
                              setState(() {
                                _needHelpController.selectStateID.value = value.toString().toLowerCase();
                              });
                            },
                            items: ["Specialist", "Doctor", "Admin"].map((map) {
                              return DropdownMenuItem<String>(
                                value: map,
                                child: Text(map, style: const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: commonTextFormField(
                          hintText: AppStrings.mobileNo,
                          labelText: AppStrings.mobileNo,
                          leftPadding: 25.0,
                          prefixText: Text("+1 ", style: TextStyle(color: AppColors.halfWhite)),
                          textFieldController: _needHelpController.mobileController,
                          validator: AppValidator.phoneValidator,
                        ),
                        flex: 1,
                      )
                    ],
                  ),
                ),
                Visibility(
                  visible: _needHelpController.selectStateID.value.toString().toLowerCase() == "doctor",
                  child: const SizedBox(height: 10),
                ),
                Visibility(
                  visible: _needHelpController.selectStateID.value.toString().toLowerCase() == "doctor",
                  child: SizedBox(
                    child: commonTextFormField(
                      hintText: AppStrings.clinicName2,
                      labelText: AppStrings.clinicName,
                      textFieldController: _needHelpController.clinicNameController,
                      validator: AppValidator.emptyValidator,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    commonTextView(
                      title: AppStrings.issue,
                      textColor: Colors.white,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.halfWhite, width: 0.5),
                  ),
                  child: TextFormField(
                    cursorColor: AppColors.cursorColor,
                    controller: _needHelpController.issueController,
                    validator: AppValidator.emptyValidator,
                    decoration: const InputDecoration(
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsetsDirectional.only(start: 10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                CommonButton3(
                  buttonName: AppStrings.submitTicket,
                  textColor: AppColors.appBackGroundColor,
                  onTap: () {
                    if (_needHelpController.formKeyNeedHelp.currentState?.validate() ?? false) {
                      _needHelpController.getNeedHelp(
                        emailAddress: _needHelpController.emailController.text,
                        name: _needHelpController.firstNameController.text + _needHelpController.lastNameController.text,
                        mobileNumber: _needHelpController.mobileController.text,
                        type: _needHelpController.selectStateID.value,
                        issue: _needHelpController.issueController.text,
                        context: context
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                bottomSignUpText(
                    title1: AppStrings.dontHaveAccount2,
                    title2: " Sign Up",
                    onTap: () {
                      Get.toNamed(Routes.signUpScreen);
                    }),
                const SizedBox(height: 7),
                bottomSignUpText(
                    title1: AppStrings.alreadyHaveAccount,
                    title2: " Sign In",
                    onTap: () {
                      Get.toNamed(Routes.login);
                    }),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bottomSignUpText({title1, title2, onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonTextView(
          title: title1,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.white04Color,
        ),
        GestureDetector(
          onTap: onTap,
          child: commonTextView(
            fontWeight: FontWeight.w500,
            title: title2,
            fontSize: 14,
            textColor: Colors.white,
          ),
        )
      ],
    );
  }
}
