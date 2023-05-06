import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_quetionheader.dart';

import '../../utils/utils.dart';
import 'doctor_question10_screen.dart';
import 'doctor_question8_screen.dart';
import 'package:http/http.dart' as http;

class Question9Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Question9ScreenState();
  String caseId;

  Question9Screen({required this.caseId});
}

class _Question9ScreenState extends State<Question9Screen> {
  TextEditingController medicalRecordNoController = TextEditingController();
  List<String> listOfValue = ['Yes', 'No'];
  var _selectedValue;
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
        child: Stack(
          children: [
            Column(
              children: [
                CommonQuestionHeader(),
                Container(
                  height: 14,
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: 0.81,
                    backgroundColor: Colors.white,
                    color: Color(0xFF31D9F8),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  child: Text(
                    "9 of 11",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.44, color: Colors.black, fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 6,
                ),
                Container(
                  child: Image.asset(
                    AppImages.question1,
                    height: 201,
                    width: 283,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Text(
                    "Is referral to a Specialist an option?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.black, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 33,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25, top: 0),
                    child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        isDense: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 6),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                          ),
                          disabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                          ),
                          errorBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 2),
                          ),
                        ),
                        value: _selectedValue,
                        hint: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '-------Select-------',
                            style: TextStyle(fontSize: 14, color: Color(0xFF141414).withOpacity(0.37)),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedValue = value.toString();
                          });
                        },
                        items: listOfValue.map((String val) {
                          return DropdownMenuItem(
                            value: val,
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                val,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        }).toList()),
                  ),
                )
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 46, bottom: 27),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: Question8Screen(
                              caseId: this.widget.caseId,
                            ),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      },
                      child: Container(
                        height: 34,
                        width: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF4AA16),
                              const Color(0xFFA16C00),
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
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Previous",
                                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14, letterSpacing: -0.17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 46, bottom: 27),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedValue != null) {
                          _submitAnswer(_selectedValue, "9", this.widget.caseId);
                        } else {
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Please select any one',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        }
                      },
                      child: Container(
                        height: 34,
                        width: 130,
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
                              width: 5,
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
                  )
                ],
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
          _selectedValue = jsonData['data'][8]['answers'] != null ? jsonData['data'][8]['answers'] : null;
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
              child: Question10Screen(caseId: this.widget.caseId),
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
