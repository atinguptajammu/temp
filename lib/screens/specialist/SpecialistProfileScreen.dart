import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';
import 'package:vsod_flutter/widgets/widget.dart';

import '../../model/timezone_model.dart';

import '../../utils/utils.dart';
import '../../widgets/AnimDialog.dart';

class SpecialistProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpecialistProfileScreenState();
}

class _SpecialistProfileScreenState extends State<SpecialistProfileScreen> {
  String? apiToken;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> timeZoneMap = Map();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  late SharedPreferences sharedPreferences;

  var profileImage;
  late String firstName = '';
  late String lastName = '';

  RxList<String> timezoneList = <String>[].obs;
  Rx<TimezoneModel> timezoneModel = TimezoneModel().obs;
  RxString selectTimeZoneSpecialist = ''.obs;
  RxString selectedTimeZoneSpecialistKey = "".obs;

  @override
  void initState() {
    super.initState();
    _init();
    passwordController.text = "*****";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.headerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 365,
              child: Stack(
                children: [
                  Container(
                    height: 330,
                    width: double.infinity,
                    child: profileImage != null && profileImage != ""
                        ? Container(
                            child: FadeInImage.assetNetwork(
                              placeholder: AppImages.profilePlaceHolder,
                              image: AppConstants.publicImage + profileImage,
                              height: 330,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            child: Image.asset(
                              AppImages.profilePlaceHolder,
                              height: 330,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(top: 50, bottom: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Image.asset(
                                AppImages.backArrow,
                                height: 22,
                                width: 22,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                "Profile",
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.15,
                                    color: Colors.white,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(),
                                ),
                              );
                            },
                            child: Container(
                              child: Image.asset(
                                AppImages.notificationIcon,
                                height: 28,
                                width: 28,
                              ),
                            ),
                          ),
                          Container(
                            height: 34,
                            width: 34,
                            margin: EdgeInsets.only(left: 14, right: 13),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                            child: profileImage != null && profileImage != ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AppImages.profilePlaceHolder,
                                      image: AppConstants.publicImage +
                                          profileImage,
                                      height: 34,
                                      width: 34,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: AppColors
                                        .appBackGroundColor
                                        .withOpacity(0.3),
                                    backgroundImage: AssetImage(
                                      AppImages.profilePlaceHolder,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 74,
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.45),
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Text(
                                  "Dr. $firstName $lastName",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.15,
                                    color: AppColors.textPrussianBlueColor,
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                              Spacer(),
                              InkWell(
                                onTap: () {
                                  _showImagePicker(context);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        child: Image.asset(
                                          AppImages.cameraIcon,
                                          height: 27,
                                          width: 30,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Container(
                                        child: Text(
                                          "Change Photo",
                                          style: GoogleFonts.encodeSans(
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 0.4,
                                              color: Color(0xFF070821),
                                              fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      child: commonTextFormField(
                          hintText: AppStrings.emailHint,
                          labelText: AppStrings.email,
                          textFieldController: emailController,
                          leftPadding: 25.0,
                          rightPadding: 25.0,
                          validator: AppValidator.emailValidator,
                          enable: true),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          Container(
                            child: commonTextFormFieldPasswordChange(
                              hintText: AppStrings.passwordHint,
                              leftPadding: 25.0,
                              rightPadding: 25.0,
                              validator: AppValidator.passwordValidator,
                              textFieldController: passwordController,
                              obscureText: true,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(left: 25),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  _changePasswordDialog(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Password',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 2),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' (Change)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.orangeColor,
                                              fontSize: 12,
                                              height: 2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //#GCW 18-12-2022
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          Container(
                            child: commonTextFormFieldPasswordChange(
                              hintText: AppStrings.specializationIn,
                              leftPadding: 25.0,
                              rightPadding: 25.0,
                              textFieldController: specializationController,
                              obscureText: true,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(left: 25),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  //#GCW 14-02-2023
                                  //_changePasswordDialog(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: AppStrings.specializationIn,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 2),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: ' (non editable)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.orangeColor,
                                              fontSize: 12,
                                              height: 2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.only(top: 10),
                    //   child: commonTextFormField(
                    //       hintText: AppStrings.specializationIn,
                    //       labelText: AppStrings.specializationIn,
                    //       textFieldController: specializationController,
                    //       leftPadding: 25.0,
                    //       rightPadding: 25.0,
                    //       validator: AppValidator.emptyValidator,
                    //       enable: false),
                    // ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 10, left: 25),
                      child: Text(
                        "Address",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 12,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(left: 25, right: 25),
                      child: TextFormField(
                        controller: addressController,
                        enabled: true,
                        maxLines: null,
                        style: TextStyle(color: AppColors.white04Color),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white04Color,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldEnableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldFocusUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldDisableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldErrorUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          hintText: AppStrings.addressHint,
                        ),
                      ),
                    ),
                    /* Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                        hintText: AppStrings.addressHint,
                        labelText: AppStrings.addressHint,
                        textFieldController: addressController,
                        leftPadding: 25.0,
                        rightPadding: 25.0,
                        validator: AppValidator.emptyValidator,
                        enable: true,
                      ),
                    ),*/
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: commonTextFormField(
                                hintText: AppStrings.education,
                                labelText: AppStrings.education,
                                textFieldController: educationController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.emptyValidator,
                                enable: true,
                              ),
                            ),
                          ),
                          //gcw
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Stack(
                                children: [
                                  Container(
                                    child: TextFormField(
                                      obscureText: false,
                                      validator: AppValidator.phoneValidator,
                                      controller: mobileNoController,
                                      cursorHeight: 20,
                                      cursorRadius: const Radius.circular(10),
                                      style: TextStyle(
                                        color: AppColors.white04Color,
                                      ),
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        labelText: "",
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                0, 5, 0, 0),
                                        labelStyle: const TextStyle(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 12,
                                            height: 2),
                                        hintStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.white04Color,
                                        ),
                                        errorStyle: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.redColor,
                                        ),
                                        errorMaxLines: 2,
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors
                                                  .textFieldEnableUnderLineColor,
                                              width: 1.7),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors
                                                  .textFieldFocusUnderLineColor,
                                              width: 1.7),
                                        ),
                                        disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors
                                                  .textFieldDisableUnderLineColor,
                                              width: 1.7),
                                        ),
                                        errorBorder: const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: AppColors
                                                  .textFieldErrorUnderLineColor,
                                              width: 1.7),
                                        ),
                                      ),
                                    ),
                                    //   validator: AppValidator.phoneValidator,
                                    //   enable: true,
                                    // ),
                                  ),
                                  Positioned(
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: InkWell(
                                        onTap: () {
                                          //_changePasswordDialog(context);
                                        },
                                        child: Text(
                                          AppStrings.mobileNo,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 10,
                                              height: 2),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Flexible(

                          // child: Container(
                          //   child: commonTextFormField(
                          //     hintText: AppStrings.hintMobileNo,
                          //     labelText: AppStrings.mobileNo,
                          //     textFieldController: mobileNoController,
                          //     leftPadding: 25.0,
                          //     rightPadding: 25.0,
                          //     validator: AppValidator.emptyValidator,
                          //     enable: true,
                          //   ),
                          // ),
                          //),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                        hintText: AppStrings.degreeHint,
                        labelText: AppStrings.degreeHint,
                        textFieldController: degreeController,
                        leftPadding: 25.0,
                        rightPadding: 25.0,
                        validator: AppValidator.emptyValidator,
                        enable: true,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 10, left: 25),
                      child: Text(
                        "Timezone",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 12,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25, right: 25),
                        child: Obx(
                          () {
                            return PopupMenuButton<String>(
                              itemBuilder: (context) {
                                return timezoneList.map((str) {
                                  return PopupMenuItem(
                                    value: str,
                                    child: Text(
                                      str,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: AppColors
                                              .textFieldFocusUnderLineColor,
                                          width: 1.7)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${selectTimeZoneSpecialist.value != "" ? selectTimeZoneSpecialist.value : "---TimeZone---"}",
                                        style: TextStyle(
                                          color: AppColors.white04Color,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      size: 28,
                                      color: AppColors.white04Color,
                                    ),
                                  ],
                                ),
                              ),
                              onSelected: (v) {
                                setState(() {
                                  print('!!!===== $v');
                                  selectTimeZoneSpecialist.value = v.toString();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 10, left: 25),
                      child: Text(
                        "Biography",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 12,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5, left: 25, right: 25),
                      child: TextFormField(
                        controller: bioController,
                        maxLines: 3,
                        style: TextStyle(color: AppColors.white04Color),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white04Color,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldEnableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldFocusUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldDisableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldErrorUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          hintText: "Type here",
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 20, bottom: 10, left: 30, right: 30),
                      child: MaterialButton(
                        onPressed: () {
                          var usdKey = timeZoneMap.keys.firstWhere(
                              (k) =>
                                  timeZoneMap[k] ==
                                  selectTimeZoneSpecialist.value,
                              orElse: () => " ");
                          log("KEY_________> $usdKey");
                          selectedTimeZoneSpecialistKey = usdKey.obs;
                          //gwc | 21-11-2022
                          // for (int i = 0; i < timezoneList.length; i++) {
                          //   log("TESTETSTST" + timezoneList[i]);
                          //   if (selectTimeZoneSpecialist.value ==
                          //       timezoneList[i]) {
                          //     if (timezoneList[i] ==
                          //         "UTC-10: Hawaii-Aleutian Standard Time (HAT)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "Pacific/Honolulu".obs;
                          //     } else if (timezoneList[i] ==
                          //         "UTC-9: Alaska Standard Time (AKT)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "America/Anchorage".obs;
                          //     } else if (timezoneList[i] ==
                          //         "UTC-8: Pacific Standard Time (PT)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "America/Los_Angeles".obs;
                          //     } else if (timezoneList[i] ==
                          //         "UTC-7: Mountain Standard Time (MT)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "America/Denver".obs;
                          //     } else if (timezoneList[i] ==
                          //         "UTC-6: Central Standard Time (CT)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "America/Chicago".obs;
                          //     } else if (timezoneList[i] ==
                          //         "UTC-5: Eastern Standard Time (ET)") {
                          //       selectedTimeZoneSpecialistKey =
                          //           "America/New_York".obs;
                          //     } else {
                          //       selectedTimeZoneSpecialistKey = "".obs;
                          //     }
                          //
                          //     //gwc | 19-11-2022
                          //     //   if (timezoneList[i] ==
                          //     //       "UTC-10: Hawaii-Aleutian Daylight Time (HAT)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "Pacific/Honolulu".obs;
                          //     //   } else if (timezoneList[i] ==
                          //     //       "UTC-9: Alaska Daylight Time (AKT)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "America/Anchorage".obs;
                          //     //   } else if (timezoneList[i] ==
                          //     //       "UTC-8: Pacific Daylight Time (PT)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "America/Los_Angeles".obs;
                          //     //   } else if (timezoneList[i] ==
                          //     //       "UTC-6: Mountain Daylight Time (MT)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "America/Denver".obs;
                          //     //   } else if (timezoneList[i] ==
                          //     //       "UTC-5: Central Daylight Time (CT)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "America/Chicago".obs;
                          //     //   } else if (timezoneList[i] ==
                          //     //       "UTC-4: Eastern Daylight Time (ET)") {
                          //     //     selectedTimeZoneSpecialistKey =
                          //     //         "America/New_York".obs;
                          //     //   } else {
                          //     //     selectedTimeZoneSpecialistKey = "".obs;
                          //     //   }
                          //     //   print(
                          //     //       "${selectedTimeZoneSpecialistKey} ${timezoneList[i]}");
                          //     // }
                          //   }
                          // }
                          if (bioController.text.isEmpty) {
                            log("BIO--->> ${bioController.text}");
                            ToastMessage.showToastMessage(
                              context: context,
                              message: 'Please enter bio.',
                              duration: 3,
                              backColor: Colors.red,
                              position: StyledToastPosition.center,
                            );
                          } else if (mobileNoController.text
                                  .toString()
                                  .length !=
                              10) {
                            //log("BIO--->> ${bioController.text}");
                            ToastMessage.showToastMessage(
                              context: context,
                              message: 'Please enter Valid Mobile Number.',
                              duration: 3,
                              backColor: Colors.red,
                              position: StyledToastPosition.center,
                            );
                          } else {
                            _setProfile(
                              bioController.text.toString(),
                              selectedTimeZoneSpecialistKey.toString(),
                              emailController.text.toString(),
                              mobileNoController.text.toString(),
                              addressController.text.toString(),
                              educationController.text.toString(),
                              degreeController.text.toString(),
                            );
                          }
                        },
                        height: 40,
                        minWidth: double.infinity,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        child: Text(
                          //#GCW 31-01-2023
                          "Save Changes",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.headerColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

    Future.delayed(Duration.zero, () {
      getTimeZone();
      _getSpecialistProfile(apiToken!, true);
    });
  }

  Future<void> getTimeZone() async {
    final url = AppConstants.timezone;
    print('TimeZone getItemSave url--> $url');
    try {
      final response = await http.get(Uri.parse(url));
      print('TimeZone response--> ${response}');
      log('TimeZone response--> statusCode:-${response.statusCode}');
      print('TimeZone response--> body:-${response.body}');
      if (response.statusCode == 200) {
        final bodyy = json.decode((response.body));
        timeZoneMap = bodyy['data'];
        log("TimeZone MAp  ----- > $timeZoneMap");
        final TimezoneModel result =
            TimezoneModel.fromJson(json.decode(response.body));

        if (result.status?.error == false) {
          timezoneModel.value = result;

          final data =
              timezoneModel.value.data?.americaNewYork ?? "Something wrong";

          print("dataaa--->> ${data}");
          timezoneList.add(
            result.data?.americaAnchorage ?? "",
          );
          timezoneList.add(
            result.data?.americaChicago ?? "",
          );
          timezoneList.add(
            result.data?.americaDenver ?? "",
          );
          timezoneList.add(
            result.data?.americaLosAngeles ?? "",
          );
          timezoneList.add(
            result.data?.pacificHonolulu ?? "",
          );
          timezoneList.add(
            result.data?.americaNewYork ?? "",
          );

          print("timezoneList.length--> ${timezoneList.length}");
          timezoneList.refresh();
          timezoneModel.refresh();
        } else {
          Fluttertoast.showToast(
              msg: result.status?.message?.first.toString() ?? "");
        }
      } else {}
    } catch (e, s) {
      print("Error--> Error:-$e stackTrace:-$s");
    }
  }

  _setProfile(String bio, String timezone, String email, String mobile,
      String address, String education, String degree) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    final url = AppConstants.specialistSetProfile;
    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({
      "biography": '$bio',
      "timezone": '$timezone',
      "email": '$email',
      "mobile": '$mobile',
      "address": '$address',
      "education": '$education',
      "degree": '$degree'
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistSetProfile response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          //Navigator.pop(context);

          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );

          _getSpecialistProfile(token, false);
          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
      log("specialistSetProfile Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getSpecialistProfile(String token, bool isShow) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    isShow ? AnimDialog.showLoadingDialog(context, _key, "Loading...") : null;
    final url = AppConstants.specialistProfile;
    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log('getSpecialistProfile response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          isShow
              ? Navigator.of(_key.currentContext!, rootNavigator: true).pop()
              : null;

          var data = jsonData['data'] as List;

          if (data.length > 0) {
            var item = data[0];

            sharedPreferences.setString(
                "ProfilePicture", item['profile_picture'].toString());

            profileImage =
                item['profile_picture'] != null ? item['profile_picture'] : "";

            firstName = item['first_name'];

            lastName = item['last_name'];

            emailController.text = item['email'] != null ? item['email'] : "";
            specializationController.text =
                item['specialization'] != null ? item['specialization'] : "";
            addressController.text =
                item['address'] != null ? item['address'] : "";
            educationController.text =
                item['education'] != null ? item['education'] : "";
            mobileNoController.text =
                item['mobile'] != null ? item['mobile'] : "";
            degreeController.text =
                item['degree'] != null ? item['degree'] : "";
            bioController.text = item['bio'] != null ? item['bio'] : "";
            selectTimeZoneSpecialist.value =
                item['timezone'] != null ? item['timezone'] : "";
            sharedPreferences.setString(
                "Specialization", item['specialization']);
          }

          setState(() {});
        } else {
          isShow
              ? Navigator.of(_key.currentContext!, rootNavigator: true).pop()
              : null;
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        isShow
            ? Navigator.of(_key.currentContext!, rootNavigator: true).pop()
            : null;
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getSpecialistProfile Error--> Error:-$e stackTrace:-$s");
      isShow
          ? Navigator.of(_key.currentContext!, rootNavigator: true).pop()
          : null;
    }
  }

  void _showImagePicker(context) {
    showGeneralDialog(
      barrierLabel: "Upload Image",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        color: Theme.of(context).primaryColor.withAlpha(5),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 5,
                              child: Container(
                                child: MaterialButton(
                                  minWidth: double.maxFinite,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _imgFromCamera();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Camera",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 16),
                                        ),
                                        Icon(
                                          Icons.linked_camera_outlined,
                                          color: AppColors.headerColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.black,
                              width: 1,
                              height: 50,
                            ),
                            Flexible(
                              flex: 5,
                              child: Container(
                                child: MaterialButton(
                                  minWidth: double.maxFinite,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _imgFromGallery();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Gallery",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 16),
                                        ),
                                        Icon(
                                          Icons.photo_camera_back,
                                          color: AppColors.headerColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Container(
                        color: Theme.of(context).primaryColor.withAlpha(5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          minWidth: double.maxFinite,
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrussianBlueColor,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
          child: SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  // _imgFromGallery() async {
  //   File? pickedFile = await takePicture();
  //   if (pickedFile != null) {
  //     final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
  //     final kb = bytes / 1024;
  //     final mb = kb / 1024;

  //     print("FileSize == $mb mb");
  //     //#GCW 20-12-2022
  //     if (mb > 10) {
  //       ToastMessage.showToastMessage(
  //         context: context,
  //         message: "Maximum 10 MB of file size limit has reached",
  //         duration: 3,
  //         backColor: Colors.red,
  //         position: StyledToastPosition.center,
  //       );
  //     } else {
  //       _cropImage(pickedFile.path);
  //     }
  //     print(pickedFile.path);
  //   }
  // }

  // // Future<File?> takePicture() async {
  // //   try {
  // //     // Get the available cameras
  // //     List<CameraDescription> cameras =  Cameras.cameras;

  // //     // Initialize the first camera in the list
  // //     CameraController controller = CameraController(cameras[0], ResolutionPreset.medium);
  // //     await controller.initialize();

  // //     // Get a temporary directory for the image
  // //     //Directory directory = await getTemporaryDirectory();
  // //     // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  // //     // String filePath = directory.path+'$fileName.jpg';
  // //     //
  // //     // Take the picture
  // //     XFile picture = await controller.takePicture();

  // //     // Return the image as a File object
  // //     return File(picture.path);
  // //   } catch (e) {
  // //     print(e);
  // //     return null;
  // //   }
  // // }

  // _imgFromCamera() async {
  //   File? pickedFile = await takePicture();
  //   if (pickedFile != null) {
  //     final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
  //     final kb = bytes / 1024;
  //     final mb = kb / 1024;

  //     print("FileSize == $mb mb");

  //     if (mb > 10) {
  //       ToastMessage.showToastMessage(
  //         context: context,
  //         message: "Maximum 10 MB of file size limit has reached",
  //         duration: 3,
  //         backColor: Colors.red,
  //         position: StyledToastPosition.center,
  //       );
  //     } else {
  //       _cropImage(pickedFile.path);
  //     }

  //     print(pickedFile.path);
  //   }
  // }
_imgFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print("FileSize == $mb mb");
      //#GCW 20-12-2022
      if (mb > 10) {
        ToastMessage.showToastMessage(
          context: context,
          message: "Maximum 10 MB of file size limit has reached",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      } else {
        _cropImage(pickedFile.path);
      }

      print(pickedFile.path);
    }
  }

  _imgFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print("FileSize == $mb mb");

      if (mb > 10) {
        ToastMessage.showToastMessage(
          context: context,
          message: "Maximum 10 MB of file size limit has reached",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      } else {
        _cropImage(pickedFile.path);
      }

      print(pickedFile.path);
    }
  }

  _cropImage(filePath) async {
    File? _croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
    );
    if (_croppedImage != null) {
      _changePhoto(_croppedImage);
    }
  }

  _changePhoto(File imageFile) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");

    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _key, "Loading...");

    var url = AppConstants.doctorChangePhoto;

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var response = new http.MultipartRequest("POST", Uri.parse(url));
    response.headers.addAll(headers);
    if (imageFile != null) {
      response.files.addAll([
        await http.MultipartFile.fromPath('profile_pic', imageFile.path),
      ]);
    }
    response.send().then(
      (response) {
        http.Response.fromStream(response).then(
          (onValue) {
            try {
              print(onValue.body);
              if (onValue.statusCode == 200) {
                var jsonData = jsonDecode(onValue.body);

                if (jsonData['status']['error'] == false) {
                  //#GCW 14-02-2023
                  Navigator.of(_key.currentContext!, rootNavigator: true).pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.black.withOpacity(0.7),
                    position: StyledToastPosition.center,
                  );
                  _getSpecialistProfile(token, false);
                  setState(() {});
                } else {
                  Navigator.of(_key.currentContext!, rootNavigator: true).pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.red,
                    position: StyledToastPosition.center,
                  );
                }
              } else {
                Navigator.of(_key.currentContext!, rootNavigator: true).pop();
                ToastMessage.showToastMessage(
                  context: context,
                  message: "Something bad happened,try again after some time.",
                  duration: 3,
                  backColor: Colors.red,
                  position: StyledToastPosition.center,
                );
              }
            } catch (e, s) {
              log("specialistPhotoChange Error--> Error:-$e stackTrace:-$s");
              Navigator.of(_key.currentContext!, rootNavigator: true).pop();
            }
          },
        );
      },
    );
  }

  _changePassword(String password) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    final url = AppConstants.specialistUpdatePassword;
    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode(
        {"password": '$password', "password_confirmation": '$password'});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistUpdatePassword response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );
          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
      log("specialistUpdatePassword Error--> Error:-$e stackTrace:-$s");
    }
  }

  void _changePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: EdgeInsets.only(top: 10, right: 15),
                      alignment: Alignment.centerRight,
                      child: Image.asset(
                        AppImages.closeIcon,
                        height: 20,
                        width: 20,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 35, right: 35, top: 10),
                    alignment: Alignment.center,
                    child: Text(
                      "Change Password",
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w700,
                          fontSize: 26,
                          letterSpacing: 0.4,
                          color: AppColors.textPrussianBlueColor),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30),
                      child: TextFormField(
                        obscureText: _isObscureNewPassword,
                        validator: AppValidator.passwordValidator,
                        controller: newPasswordController,
                        cursorHeight: 20,
                        cursorRadius: const Radius.circular(10),
                        style: TextStyle(
                          color: AppColors.textPrussianBlueColor,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.newPassword,
                          contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrussianBlueColor,
                              fontSize: 12,
                              height: 2),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrussianBlueColor,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.textFieldErrorUnderLineColor,
                                width: 1.7),
                          ),
                          hintText: AppStrings.passwordHint,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscureNewPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.headerColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscureNewPassword = !_isObscureNewPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 30, right: 30, top: 20),
                      child: TextFormField(
                        obscureText: _isObscureConfirmPassword,
                        validator: AppValidator.passwordValidator,
                        controller: confirmPasswordController,
                        cursorHeight: 20,
                        cursorRadius: const Radius.circular(10),
                        style: TextStyle(
                          color: AppColors.textPrussianBlueColor,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.confirmPassword,
                          contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.w400,
                              color: AppColors.textPrussianBlueColor,
                              fontSize: 12,
                              height: 2),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrussianBlueColor,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(0xFF003F5A), width: 1.7),
                          ),
                          errorBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: AppColors.textFieldErrorUnderLineColor,
                                width: 1.7),
                          ),
                          hintText: AppStrings.passwordHint,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isObscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: AppColors.headerColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _isObscureConfirmPassword =
                                    !_isObscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: CommonButtonGradient(
                      height: 40,
                      width: 148,
                      fontSize: 14,
                      colorGradient1: AppColors.gradientGreen1,
                      colorGradient2: AppColors.gradientGreen2,
                      buttonName: AppStrings.submit,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        if (newPasswordController.text.isEmpty) {
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Please enter new  password',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        } else if (confirmPasswordController.text.isEmpty) {
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Please re-enter your password',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        } else if (newPasswordController.text !=
                            confirmPasswordController.text) {
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Passwords not match',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        } else {
                          Navigator.pop(context);
                          _changePassword(
                              confirmPasswordController.text.toString());
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
