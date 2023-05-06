import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_quetionheader.dart';

import '../../utils/utils.dart';
import 'doctor_question3_screen.dart';

class Question1Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Question1ScreenState();
  String caseId;

  Question1Screen({required this.caseId});
}

class _Question1ScreenState extends State<Question1Screen> {
  TextEditingController medicalRecordNoController = TextEditingController();
  late SharedPreferences sharedPreferences;
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    CommonQuestionHeader(),
                    Container(height: 14, alignment: Alignment.topCenter, child: LinearProgressIndicator(value: 0.09, backgroundColor: Colors.white, color: Color(0xFF31D9F8))),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      child: Text(
                        "1 of 4",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.44, color: Colors.black, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 6),
                    Container(
                      child: Image.asset(
                        AppImages.question1,
                        height: 201,
                        width: 283,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      child: Text(
                        "What is the Patient's Medical Record Number?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.black, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 41,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 45),
                      child: TextFormField(
                        controller: medicalRecordNoController,
                        cursorHeight: 20,
                        cursorRadius: const Radius.circular(10),
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF737373),
                        ),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF737373).withOpacity(0.40),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 2),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 1.7),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
                          ),
                          hintText: 'Medical Record Number',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(right: 46, bottom: 27, top: 25),
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  if (medicalRecordNoController.text.isEmpty) {
                    ToastMessage.showToastMessage(
                      context: context,
                      message: 'Please enter Patient Medical Record Number.',
                      duration: 3,
                      backColor: Colors.red,
                      position: StyledToastPosition.center,
                    );
                  } else {
                    _submitAnswer(medicalRecordNoController.text.toString(), "1", this.widget.caseId);
                  }
                },
                child: Container(
                  height: 34,
                  width: 148,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4BD863),
                        const Color(0xFF038F12),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerRight,
                          child: Text(
                            "Next",
                            style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: -0.17),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 17),
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _getAnswer(this.widget.caseId);
  }

  _getAnswer(String caseId) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorGetAnswer;

    log('url--> $url');

    var body = {"case_id": '$caseId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          medicalRecordNoController.text = jsonData['data']['answers'][0]['answers'] != null ? jsonData['data']['answers'][0]['answers'] : '';
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

  _submitAnswer(String medicalRecordNumber, String questionId, String caseId) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorSubmitAnswer;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"answer": '$medicalRecordNumber', "questionnaire_id": '$questionId', "case_id": '$caseId'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.pushReplacement(
            context,
            PageTransition(
              child: Question3Screen(caseId: this.widget.caseId),
              type: PageTransitionType.rightToLeft,
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
      log("doctorSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
}
