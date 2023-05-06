import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
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
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';
import 'package:vsod_flutter/widgets/widget.dart';

import '../../utils/camera.dart';
import '../../utils/utils.dart';

class DoctorProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController clinicAddressController = TextEditingController();
  TextEditingController veterinarySchoolController = TextEditingController();
  TextEditingController graduationYearController = TextEditingController();
  TextEditingController veterinaryLicenseNumberController =
      TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController timeZoneController = TextEditingController();

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool _isObscureNewPassword = true;
  bool _isObscureConfirmPassword = true;

  late SharedPreferences sharedPreferences;
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  late String profileImage = '';
  late String firstName = '';
  late String lastName = '';

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
                    child: profileImage != ''
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: FadeInImage.assetNetwork(
                              placeholder: '',
                              image: AppConstants.publicImage + profileImage,
                              height: 330,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Image.asset(
                            AppImages.defaultProfile,
                            height: 330,
                            fit: BoxFit.fill,
                            width: double.infinity,
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
                            child: profileImage != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AppImages.defaultProfile,
                                      image: AppConstants.publicImage +
                                          profileImage,
                                      height: 34,
                                      width: 34,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.asset(
                                      AppImages.defaultProfile,
                                      height: 34,
                                      width: 34,
                                      fit: BoxFit.fill,
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
                                      fontSize: 26),
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
                          enable: false),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          Container(
                              child: InkWell(
                            onTap: () {
                              _changePasswordDialog(context);
                            },
                            child: commonTextFormFieldPasswordChange(
                              hintText: AppStrings.passwordHint,
                              leftPadding: 25.0,
                              rightPadding: 25.0,
                              //validator: AppValidator.passwordValidator,
                              textFieldController: passwordController,
                              obscureText: true,
                            ),
                          )),
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(left: 25),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  //_changePasswordDialog(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: 'Password',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 10,
                                        height: 2),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '(Editable)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.orangeColor,
                                              fontSize: 10,
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
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                          hintText: AppStrings.clinicAddress,
                          labelText: AppStrings.clinicAddress,
                          textFieldController: clinicAddressController,
                          leftPadding: 25.0,
                          rightPadding: 25.0,
                          validator: AppValidator.emptyValidator,
                          enable: false),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Stack(
                        children: [
                          Container(
                            child: commonTextFormField(
                              hintText: AppStrings.hintVeterinarySchool,
                              textFieldController: veterinarySchoolController,
                              leftPadding: 25.0,
                              rightPadding: 25.0,
                              validator: AppValidator.emptyValidator,
                              enable: true,
                            ),
                          ),
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(left: 25),
                              alignment: Alignment.centerLeft,
                              child: InkWell(
                                onTap: () {
                                  //_changePasswordDialog(context);
                                },
                                child: RichText(
                                  text: TextSpan(
                                    text: AppStrings.veterinarySchool,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        fontSize: 10,
                                        height: 2),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '(Editable)',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.orangeColor,
                                              fontSize: 10,
                                              height: 2)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 06-11-22 | Task - 4 doctor profile edits |gwc
                      // commonTextFormField(
                      //   hintText: AppStrings.hintVeterinarySchool,
                      //   labelText: AppStrings.veterinarySchool,
                      //   textFieldController: veterinarySchoolController,
                      //   leftPadding: 25.0,
                      //   rightPadding: 25.0,
                      //   validator: AppValidator.emptyValidator,
                      //   enable: true,
                      // ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Stack(
                            children: [
                              Container(
                                //margin: EdgeInsets.only(top: 10),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 25),
                                  child: TextFormField(
                                    obscureText: false,
                                    validator: AppValidator.yearValidator,
                                    controller: graduationYearController,
                                    cursorHeight: 10,
                                    cursorRadius: const Radius.circular(10),
                                    style: TextStyle(
                                      color: AppColors.white04Color,
                                    ),
                                    keyboardType: TextInputType.number,
                                    maxLength: 4,
                                    decoration: InputDecoration(
                                      counterText: "",
                                      labelText: "",
                                      contentPadding:
                                          const EdgeInsets.fromLTRB(0, 5, 0, 0),
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
                                ),
                              ),
                              // 06-11-22 | Task - 4 doctor profile edits |gwc
                              // commonTextFormField(
                              //   hintText: AppStrings.hintGraduationYear,
                              //   textFieldController: graduationYearController,
                              //   leftPadding: 25.0,
                              //   rightPadding: 25.0,
                              //   validator: AppValidator.emptyValidator,
                              //   enable: true,
                              // ),

                              Positioned(
                                child: Container(
                                  margin: EdgeInsets.only(left: 25),
                                  alignment: Alignment.centerLeft,
                                  child: InkWell(
                                    onTap: () {
                                      //_changePasswordDialog(context);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: AppStrings.hintGraduationYear,
                                        style: TextStyle(
                                            //fontWeight: FontWeight.w400,
                                            color: Colors.white,
                                            fontSize: 10,
                                            height: 2),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '(Editable)',
                                              style: TextStyle(
                                                  //fontWeight: FontWeight.w400,
                                                  color: AppColors.orangeColor,
                                                  fontSize: 10,
                                                  height: 2)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // 06-11-22 | Task - 4 doctor profile edits |gwc
                          //Container(
                          //   margin: EdgeInsets.only(top: 10),
                          //   child: Container(
                          //     padding: EdgeInsets.symmetric(horizontal: 25),
                          //     child:
                          // TextFormField(
                          //       obscureText: false,
                          //       validator: AppValidator.yearValidator,
                          //       controller: graduationYearController,
                          //       cursorHeight: 20,
                          //       cursorRadius: const Radius.circular(10),
                          //       style: TextStyle(
                          //         color: AppColors.white04Color,
                          //       ),
                          //       keyboardType: TextInputType.number,
                          //       maxLength: 4,
                          //       decoration: InputDecoration(
                          //         counterText: "",
                          //         labelText: AppStrings.hintGraduationYear,
                          //         contentPadding:
                          //             const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          //         labelStyle: const TextStyle(
                          //             fontWeight: FontWeight.w400,
                          //             color: Colors.white,
                          //             fontSize: 12,
                          //             height: 2),
                          //         hintStyle: TextStyle(
                          //           fontSize: 12,
                          //           fontWeight: FontWeight.w600,
                          //           color: AppColors.white04Color,
                          //         ),
                          //         errorStyle: TextStyle(
                          //           fontSize: 11,
                          //           color: AppColors.redColor,
                          //         ),
                          //         errorMaxLines: 2,
                          //         enabledBorder: UnderlineInputBorder(
                          //           borderSide: BorderSide(
                          //               color: AppColors
                          //                   .textFieldEnableUnderLineColor,
                          //               width: 1.7),
                          //         ),
                          //         focusedBorder: UnderlineInputBorder(
                          //           borderSide: BorderSide(
                          //               color: AppColors
                          //                   .textFieldFocusUnderLineColor,
                          //               width: 1.7),
                          //         ),
                          //         disabledBorder: UnderlineInputBorder(
                          //           borderSide: BorderSide(
                          //               color: AppColors
                          //                   .textFieldDisableUnderLineColor,
                          //               width: 1.7),
                          //         ),
                          //         errorBorder: const UnderlineInputBorder(
                          //           borderSide: BorderSide(
                          //               color: AppColors
                          //                   .textFieldErrorUnderLineColor,
                          //               width: 1.7),
                          //         ),
                          //         hintText: AppStrings.hintGraduationYear,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ),
                        // Expanded(
                        //   flex: 2,
                        //   child: Container(
                        //     margin:
                        //         EdgeInsets.only(top: 20, left: 25, right: 25),
                        //     child: MaterialButton(
                        //       onPressed: () {},
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(10),
                        //       ),
                        //       elevation: 0,
                        //       color: Colors.white,
                        //       minWidth: 250,
                        //       child: Text(
                        //         "Connect",
                        //         style: TextStyle(
                        //           color: Colors.black,
                        //           fontWeight: FontWeight.w700,
                        //           fontSize: 14,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: Stack(
                              children: [
                                Container(
                                  child: commonTextFormField(
                                    hintText:
                                        AppStrings.hintVeterinaryLicenseNumber,
                                    textFieldController:
                                        veterinaryLicenseNumberController,
                                    leftPadding: 25.0,
                                    rightPadding: 25.0,
                                    validator: AppValidator.emptyValidator,
                                    enable: true,
                                  ),
                                ),
                                Positioned(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 25),
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        //_changePasswordDialog(context);
                                      },
                                      child: RichText(
                                        text: TextSpan(
                                          text: AppStrings
                                              .veterinaryLicenseNumber,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white,
                                              fontSize: 8,
                                              height: 2),
                                          children: <TextSpan>[
                                            TextSpan(
                                                text: '(Editable)',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        AppColors.orangeColor,
                                                    fontSize: 8,
                                                    height: 2)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // 06-11-22 | Task - 4 doctor profile edits |gwc
                            // Container(
                            //   child: commonTextFormField(
                            //     hintText:
                            //         AppStrings.hintVeterinaryLicenseNumber,
                            //     labelText: AppStrings.veterinaryLicenseNumber,
                            //     textFieldController:
                            //         veterinaryLicenseNumberController,
                            //     leftPadding: 25.0,
                            //     rightPadding: 25.0,
                            //     validator: AppValidator.emptyValidator,
                            //     enable: true,
                            //   ),
                            // ),
                          ),
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
                                        child: RichText(
                                          text: TextSpan(
                                            text: AppStrings.mobileNo,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white,
                                                fontSize: 10,
                                                height: 2),
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: '(Editable)',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          AppColors.orangeColor,
                                                      fontSize: 10,
                                                      height: 2)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // 06-11-22 | Task - 4 doctor profile edits |gwc
                              //TextFormField(
                              //   obscureText: false,
                              //   validator: AppValidator.phoneValidator,
                              //   controller: mobileNoController,
                              //   cursorHeight: 20,
                              //   cursorRadius: const Radius.circular(10),
                              //   style: TextStyle(
                              //     color: AppColors.white04Color,
                              //   ),
                              //   keyboardType: TextInputType.number,
                              //   maxLength: 10,
                              //   decoration: InputDecoration(
                              //     counterText: "",
                              //     labelText: AppStrings.mobileNo,
                              //     contentPadding:
                              //         const EdgeInsets.fromLTRB(0, 5, 0, 0),
                              //     labelStyle: const TextStyle(
                              //         fontWeight: FontWeight.w400,
                              //         color: Colors.white,
                              //         fontSize: 12,
                              //         height: 2),
                              //     hintStyle: TextStyle(
                              //       fontSize: 12,
                              //       fontWeight: FontWeight.w600,
                              //       color: AppColors.white04Color,
                              //     ),
                              //     errorStyle: TextStyle(
                              //       fontSize: 11,
                              //       color: AppColors.redColor,
                              //     ),
                              //     errorMaxLines: 2,
                              //     enabledBorder: UnderlineInputBorder(
                              //       borderSide: BorderSide(
                              //           color: AppColors
                              //               .textFieldEnableUnderLineColor,
                              //           width: 1.7),
                              //     ),
                              //     focusedBorder: UnderlineInputBorder(
                              //       borderSide: BorderSide(
                              //           color: AppColors
                              //               .textFieldFocusUnderLineColor,
                              //           width: 1.7),
                              //     ),
                              //     disabledBorder: UnderlineInputBorder(
                              //       borderSide: BorderSide(
                              //           color: AppColors
                              //               .textFieldDisableUnderLineColor,
                              //           width: 1.7),
                              //     ),
                              //     errorBorder: const UnderlineInputBorder(
                              //       borderSide: BorderSide(
                              //           color: AppColors
                              //               .textFieldErrorUnderLineColor,
                              //           width: 1.7),
                              //     ),
                              //     hintText: AppStrings.mobileNo,
                              //   ),
                              // ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                        hintText: AppStrings.hintTimeZone,
                        labelText: AppStrings.timeZone,
                        textFieldController: timeZoneController,
                        leftPadding: 25.0,
                        rightPadding: 25.0,
                        validator: AppValidator.emptyValidator,
                        enable: false,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: MaterialButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            print("SAVEEEEEEEEEEEEe");
                            _updateProfile(
                              veterinarySchoolController.text.toString(),
                              graduationYearController.text.toString(),
                              veterinaryLicenseNumberController.text.toString(),
                              mobileNoController.text.toString(),
                            );
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                        color: Colors.white,
                        minWidth: 250,
                        //#GCW 31-01-2023 change to 'save changes'
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
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
    Future.delayed(Duration.zero, () {
      _getDoctorProfile();
    });
  }

  _getDoctorProfile() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorProfile;
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
      log('getDoctorProfile response status--> ${response.statusCode}');
      log('getDoctorProfile response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          sharedPreferences.setString("ProfilePicture",
              jsonData['data'][0]!['user']!['profile_picture'].toString());
          profileImage =
              jsonData['data'][0]!['user']!['profile_picture'] != null
                  ? jsonData['data'][0]!['user']!['profile_picture'].toString()
                  : '';
          emailController = new TextEditingController(
              text: jsonData['data'][0]!['user']!['email'] != null
                  ? jsonData['data'][0]!['user']!['email']
                  : '');
          clinicAddressController = new TextEditingController(
              text: jsonData['data'][0]!['user']!['address'] != null
                  ? jsonData['data'][0]!['user']!['address']
                  : '');
          veterinarySchoolController = new TextEditingController(
              text: jsonData['data'][0]!['school'] != null
                  ? jsonData['data'][0]!['school']
                  : '');
          graduationYearController = new TextEditingController(
              text: jsonData['data'][0]!['grad_year'] != null
                  ? jsonData['data'][0]!['grad_year'].toString()
                  : '');
          veterinaryLicenseNumberController = new TextEditingController(
              text: jsonData['data'][0]!['license'] != null
                  ? jsonData['data'][0]!['license'].toString()
                  : '');
          mobileNoController = new TextEditingController(
              text: jsonData['data'][0]!['user']!['mobile'] != null
                  ? jsonData['data'][0]!['user']!['mobile']
                  : '');
          firstName = jsonData['data'][0]!['user']!['first_name'] != null
              ? jsonData['data'][0]!['user']!['first_name']
              : '';
          lastName = jsonData['data'][0]!['user']!['last_name'] != null
              ? jsonData['data'][0]!['user']!['last_name']
              : '';
          timeZoneController = new TextEditingController(
              text: jsonData['data'][0]['timezone'] != null
                  ? jsonData['data'][0]!['timezone']
                  : '');
          setState(() {});
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getDoctorProfile Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
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
  //   File? pickedFile = null;
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //       type: FileType.image,
  //       allowMultiple: false,
  //       allowedExtensions: ['png','jpg','jpeg','heif','heic','doc','pdf','txt']
  //   );
  //   if(result != null) {
  //     List<File> files = result!.paths.map((path) => File(path!)).toList();
  //     pickedFile = files.first;
  //   }
  //   if (pickedFile != null) {
  //     final bytes = File(pickedFile!.path).readAsBytesSync().lengthInBytes;
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
  //   //_cropImage(pickedFile!.path);
  //   //print(pickedFile.path);
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
    //_cropImage(pickedFile!.path);
    //print(pickedFile.path);
  }

  Future<File?> takePicture() async {
    try {
      // Get the available cameras
      List<CameraDescription> cameras = Cameras.cameras;

      // Initialize the first camera in the list
      CameraController controller =
          CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();

      // Get a temporary directory for the image
      //Directory directory = await getTemporaryDirectory();
      // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // String filePath = directory.path+'$fileName.jpg';
      //
      // Take the picture
      XFile picture = await controller.takePicture();

      // Return the image as a File object
      return File(picture.path);
    } catch (e) {
      print(e);
      return null;
    }
  }

  // _imgFromCamera() async {
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

  _imgFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
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

  _cropImage(filePath) async {
    File? _croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
    );
    if (_croppedImage != null) {
      print(_croppedImage);
      _changePhoto(_croppedImage);
      setState(() {});
    }
  }

  _changePhoto(File imageFile) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");

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
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.black.withOpacity(0.7),
                    position: StyledToastPosition.center,
                  );
                  _getDoctorProfile();
                  setState(() {});
                } else {
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.red,
                    position: StyledToastPosition.center,
                  );
                }
              } else {
                Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                    .pop();
                ToastMessage.showToastMessage(
                  context: context,
                  message: "Something bad happened,try again after some time.",
                  duration: 3,
                  backColor: Colors.red,
                  position: StyledToastPosition.center,
                );
              }
            } catch (e, s) {
              log("doctorPhotoChange Error--> Error:-$e stackTrace:-$s");
              Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                  .pop();
            }
          },
        );
      },
    );
  }

  _changePassword(String password) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorUpdatePassword;
    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"password": '$password'});

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorUpdatePassword response status--> ${response.statusCode}');
      log('doctorUpdatePassword response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.pop(context);
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );
          setState(() {});
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("doctorUpdatePassword Error--> Error:-$e stackTrace:-$s");
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
                            message: 'password not match',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        } else {
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

  _updateProfile(
      String school, String gradYear, String licence, String mobile) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorProfile;
    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({
      "school": '$school',
      "grad_year": '$gradYear',
      "license": '$licence',
      "mobile": '$mobile',
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorUpdateProfile response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );

          Navigator.pop(context);

          setState(() {});
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("doctorUpdateProfile Error--> Error:-$e stackTrace:-$s");
    }
  }
}
