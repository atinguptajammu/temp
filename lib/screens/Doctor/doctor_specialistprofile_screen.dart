import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_chat_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';

import '../../utils/utils.dart';

class DoctorSpecialistProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorSpecialistProfileScreenState();
  String channelName;
  String caseId;
  String specialistId;
  String caseSeconds;

  DoctorSpecialistProfileScreen({
    required this.channelName,
    required this.caseId,
    required this.specialistId,
    required this.caseSeconds,
  });
}

class _DoctorSpecialistProfileScreenState
    extends State<DoctorSpecialistProfileScreen> {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;
  var _profileImage;
  var _specialistProfileImage = "";
  var _firstName;
  var _lastName;
  var _rating;
  var _degree;
  var _bio;
  var _education;
  var _specialization;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 390,
              child: Stack(
                children: [
                  Container(
                    height: 348,
                    width: double.infinity,
                    child: _specialistProfileImage != ""
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: FadeInImage.assetNetwork(
                              placeholder: '',
                              image: AppConstants.publicImage +
                                  _specialistProfileImage,
                              height: 348,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Image.asset(
                            AppImages.defaultProfile,
                            height: 348,
                            width: double.infinity,
                            fit: BoxFit.fill,
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
                                height: 26,
                                width: 26,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                "Specialist Profile",
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
                            child: _profileImage != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AppImages.defaultProfile,
                                      image: AppConstants.publicImage +
                                          _profileImage,
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
                      height: 110,
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0.5,
                        child: Container(
                          margin: EdgeInsets.only(top: 12),
                          width: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Dr. ${_firstName} ${_lastName}",
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.15,
                                            color: AppColors.textDarkBlue,
                                            fontSize: 18),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        "$_specialization",
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textDarkBlue,
                                            fontSize: 14),
                                      ),
                                    ),
                                    //27-10-2022 | Remove 2 textfeilds and add specialization || #GWC
                                    // Container(
                                    //   child: Text(
                                    //     "10 years of experience",
                                    //     style: GoogleFonts.roboto(
                                    //         fontWeight: FontWeight.w400,
                                    //         color: AppColors.textDarkGrey,
                                    //         fontSize: 12),
                                    //   ),
                                    // )
                                  ],
                                ),
                              ),
                              Spacer(),
                              Container(
                                margin: EdgeInsets.only(right: 20),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      width: 75,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors
                                                .gradientScheduleRectangle1,
                                            AppColors
                                                .gradientScheduleRectangle2,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: [0.0, 1.0],
                                          tileMode: TileMode.clamp,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.blackColor
                                                .withOpacity(0.25),
                                            blurRadius: 2,
                                            offset: const Offset(
                                                0, 5), // Shadow position
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        _rating != null ? _rating : '',
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                            fontSize: 28),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    //27-10-2022 | Remove 2 textfeilds and add specialization || #GWC
                                    // Container(
                                    //   child: Text(
                                    //     "89+ Reviews",
                                    //     style: GoogleFonts.encodeSans(
                                    //         fontWeight: FontWeight.w500,
                                    //         letterSpacing: 0.4,
                                    //         color: AppColors.textDarkBlue,
                                    //         fontSize: 11),
                                    //   ),
                                    // ),
                                  ],
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
            SizedBox(
              height: 25,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "Biography",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    color: AppColors.textPrussianBlueColor,
                    fontSize: 16),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 15),
              alignment: Alignment.centerLeft,
              child: Text(
                "${_bio}",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                    color: AppColors.textDarkBlue,
                    fontSize: 12),
              ),
            ),
            SizedBox(
              height: 22,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "Education",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrussianBlueColor,
                    fontSize: 16),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: Text(
                "${_education}",
                style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    color: AppColors.textDarkBlue,
                    fontSize: 12,
                    letterSpacing: 2),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: CommonButtonGradient(
                height: 60,
                fontSize: 22,
                buttonName: AppStrings.connect,
                colorGradient1: AppColors.gradientSchedule1,
                colorGradient2: AppColors.gradientSchedule2,
                fontWeight: FontWeight.w700,
                onTap: () {
                  AppConstants.pusher.unsubscribe(channelName: "CaseStatus");

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorChatScreen(
                        channelName: this.widget.channelName,
                        firstName: _firstName,
                        lastName: _lastName,
                        degree: _degree,
                        specialistProfile: _specialistProfileImage,
                        caseId: this.widget.caseId,
                        specialistId: this.widget.specialistId,
                        caseSeconds: widget.caseSeconds,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
      _getSpecialistData(this.widget.specialistId);
      setState(() {});
    });
  }

  _getSpecialistData(String specialistId) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.getSpecialistData;

    log('url--> $url');

    var body = {"specialist_id": '$specialistId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _specialistProfileImage =
              jsonData['data'][0]!['profile_picture'] != null
                  ? jsonData['data'][0]!['profile_picture'].toString()
                  : '';
          _firstName = jsonData['data'][0]!['first_name'] != null
              ? jsonData['data'][0]!['first_name']
              : '';
          _lastName = jsonData['data'][0]!['last_name'] != null
              ? jsonData['data'][0]!['last_name']
              : '';
          _rating = jsonData['data'][0]!['rating'] != null
              ? jsonData['data'][0]!['rating'].toString()
              : '';
          _degree = jsonData['data'][0]!['degree'] != null
              ? jsonData['data'][0]!['degree']
              : '';
          _bio = jsonData['data'][0]!['bio'] != null
              ? jsonData['data'][0]!['bio']
              : '';
          _education = jsonData['data'][0]!['education'] != null
              ? jsonData['data'][0]!['education']
              : '';
          _specialization = jsonData['data'][0]!['specialization'] != null
              ? jsonData['data'][0]!['specialization']
              : '';
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
      log("doctorSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
}
