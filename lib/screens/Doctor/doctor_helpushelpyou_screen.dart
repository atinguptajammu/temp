import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_paymentstatus_Screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';

import '../../utils/utils.dart';

class HelpUsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HelpUsScreenState();
  String caseId;

  HelpUsScreen({required this.caseId});
}

class _HelpUsScreenState extends State<HelpUsScreen> {
  TextEditingController appBetterController = TextEditingController();
  TextEditingController specialistBetterController = TextEditingController();
  TextEditingController userExperienceController = TextEditingController();
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  bool _isBetterVisible = false;
  bool _isSpecialistVisible = false;
  late SharedPreferences sharedPreferences;
  var _profileImage;
  late double appBetterRating = 6.0;
  late double specialistExperienceRating = 6.0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.headerColor,
              child: Container(
                margin: EdgeInsets.only(top: 49, bottom: 20),
                child: Row(
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
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Help us, help YOU",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 20),
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
                          height: 34,
                          width: 34,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Container(
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
                                  image: AppConstants.publicImage + _profileImage,
                                  height: 34,
                                  width: 34,
                                  fit: BoxFit.fill,
                                ),
                              )
                            : Image.asset(
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
            SizedBox(
              height: 20,
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.45),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Text(
                        "Q. Your case has concluded. How would you rate your App experience?",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.2, color: AppColors.textPrussianBlueColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8, left: 15),
                      alignment: Alignment.centerLeft,
                      child: RatingBar.builder(
                        initialRating: 6,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        unratedColor: AppColors.unSelectedStar,
                        itemCount: 6,
                        itemSize: 28.0,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            log("Rate ==> $rating");
                            appBetterRating = rating;
                            if (rating < 3.0) {
                              _isBetterVisible = true;
                            } else {
                              _isBetterVisible = false;
                            }
                          });
                        },
                        updateOnDrag: false,
                      ),
                    ),
                    Visibility(
                      visible: _isBetterVisible,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black.withOpacity(0.30), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.45),
                        margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                        child: Container(
                          height: 45,
                          child: TextFormField(
                            controller: appBetterController,
                            keyboardType: TextInputType.multiline,
                            cursorRadius: const Radius.circular(10),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF737373),
                            ),
                            maxLines: 1,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF737373).withOpacity(0.40),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 2),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 1.7),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
                              ),
                              hintText: 'How could we have made this app better?',
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
            Card(
              margin: EdgeInsets.symmetric(horizontal: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.45),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Text(
                        "Q. How would you rate your Specialist experience?",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.2, color: AppColors.textPrussianBlueColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(bottom: 8, left: 15),
                      alignment: Alignment.centerLeft,
                      child: RatingBar.builder(
                        initialRating: 6,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        unratedColor: AppColors.unSelectedStar,
                        itemCount: 6,
                        itemSize: 28.0,
                        itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            log("Rate ==> $rating");
                            specialistExperienceRating = rating;
                            if (rating < 3.0) {
                              _isSpecialistVisible = true;
                            } else {
                              _isSpecialistVisible = false;
                            }
                          });
                        },
                        updateOnDrag: true,
                      ),
                    ),
                    Visibility(
                      visible: _isSpecialistVisible,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black.withOpacity(0.30), width: 1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 1,
                        shadowColor: Colors.black.withOpacity(0.45),
                        margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                        child: Container(
                          height: 45,
                          child: TextFormField(
                            controller: specialistBetterController,
                            keyboardType: TextInputType.multiline,
                            cursorRadius: const Radius.circular(10),
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF737373),
                            ),
                            maxLines: 1,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF737373).withOpacity(0.40),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 2),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 2),
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.transparent, width: 1.7),
                              ),
                              errorBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
                              ),
                              hintText: 'How could we have made this better?',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: Text(
                "Tell us about your experience.",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  letterSpacing: 0.2,
                  color: AppColors.textPrussianBlueColor,
                ),
              ),
            ),
            Visibility(
              visible: specialistExperienceRating < 2.0 || appBetterRating < 2.0,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black.withOpacity(0.30), width: 1),
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 1,
                shadowColor: Colors.black.withOpacity(0.45),
                margin: EdgeInsets.only(left: 30, right: 30, bottom: 15),
                child: Container(
                  child: TextFormField(
                    controller: userExperienceController,
                    keyboardType: TextInputType.multiline,
                    cursorRadius: const Radius.circular(10),
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF737373),
                    ),
                    maxLines: 4,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                      hintStyle: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF737373).withOpacity(0.40),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent, width: 2),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent, width: 2),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent, width: 1.7),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: CommonButtonGradient(
                height: 55,
                fontSize: 20,
                buttonName: AppStrings.submit,
                colorGradient1: AppColors.gradientSchedule1,
                colorGradient2: AppColors.gradientSchedule2,
                fontWeight: FontWeight.w700,
                onTap: () {
                  print(this.widget.caseId.toString() +
                      " " +
                      appBetterRating.toString() +
                      " " +
                      appBetterController.text.toString() +
                      " " +
                      specialistExperienceRating.toString() +
                      " " +
                      specialistBetterController.text.toString() +
                      " " +
                      userExperienceController.text.toString());
                  _submit(this.widget.caseId, appBetterRating, appBetterController.text, specialistExperienceRating, specialistBetterController.text, userExperienceController.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  _submit(String caseId, double appBetterRating, String appBetter, double specialistRating, String specialistBetter, String experience) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log("AppBetter Rating --> $appBetterRating  \n AppBetter --> $appBetter \n Specialist Rating --> $specialistRating \n Specialist Better --> $specialistBetter");
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorSubmitReview;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({
      "case_id": '$caseId',
      "app_rating": '$appBetterRating',
      "app_experience": appBetter.length > 0 ? appBetter : "${'"'}${'"'}",
      "specialist_rating": '$specialistRating',
      "specialist_experience": specialistBetter.length > 0 ? specialistBetter : "${'"'}${'"'}",
      "dispute_description": experience.length > 0 ? experience : "null",
    });

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitReview response status--> ${response.statusCode}');
      log('doctorSubmitReview response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(),
            ),
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
      log("doctorSubmitReview Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
}
