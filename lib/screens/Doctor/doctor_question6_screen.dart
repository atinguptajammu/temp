import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'doctor_question5_screen.dart';
import 'doctor_question7_screen.dart';
import 'package:http/http.dart' as http;

class Question6Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Question6ScreenState();
  String caseId;

  Question6Screen({required this.caseId});
}

class _Question6ScreenState extends State<Question6Screen> {
  TextEditingController ageController = TextEditingController();
  TextEditingController monthController = TextEditingController();
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
                    Container(
                      height: 14,
                      alignment: Alignment.topCenter,
                      child: LinearProgressIndicator(
                        value: 0.54,
                        backgroundColor: Colors.white,
                        color: Color(0xFF31D9F8),
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Container(
                      child: Text(
                        "6 of 11",
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
                        "What is the age of the patient?",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.4, color: Colors.black, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      height: 41,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 45),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Year:",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.blackColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 45, right: 45, top: 10),
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF000000).withOpacity(0.3), width: 0.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: ageController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF737373),
                              ),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),],
                              autofocus: false,
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                contentPadding: EdgeInsets.only(left: 15),
                                focusColor: Colors.transparent,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: '',
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15, top: 2),
                            child: Column(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (int.parse(ageController.text) != 0) {
                                          ageController.text = (int.parse(ageController.text) - 1).toString();
                                        }
                                      });
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      print("Plus Cliuck");
                                      setState(() {
                                        ageController.text = (int.parse(ageController.text) + 1).toString();
                                      });
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_up_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 45, vertical: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Month:",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.blackColor),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 45, right: 45),
                      height: 45,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF000000).withOpacity(0.3), width: 0.5),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: TextFormField(
                              controller: monthController,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF737373),
                              ),
                              maxLength: 2,
                              autofocus: false,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),],
                              onChanged: (value) {
                                if(int.parse(value) > 11){
                                  ToastMessage.showToastMessage(
                                    context: context,
                                    message: 'Enter month between 0-11',
                                    duration: 3,
                                    backColor: Colors.red,
                                    position: StyledToastPosition.center,
                                  );
                                }
                              },
                              decoration: InputDecoration(
                                isDense: true,
                                filled: false,
                                contentPadding: EdgeInsets.only(left: 15),
                                focusColor: Colors.transparent,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                hintText: '',
                                counterText: '',
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 15, top: 2),
                            child: Column(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (int.parse(monthController.text) != 0) {
                                          monthController.text = (int.parse(monthController.text) - 1).toString();
                                        }
                                      });
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_down_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      print("Plus Cliuck");
                                      setState(() {
                                        if(int.parse(monthController.text.toString()) > 10){
                                          ToastMessage.showToastMessage(
                                            context: context,
                                            message: 'Enter month between 0-11',
                                            duration: 3,
                                            backColor: Colors.red,
                                            position: StyledToastPosition.center,
                                          );
                                        }else{
                                          monthController.text = (int.parse(monthController.text) + 1).toString();
                                        }
                                      });
                                    },
                                    child: Icon(
                                      Icons.arrow_drop_up_outlined,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(horizontal: 45),
                    //   child: TextFormField(
                    //     controller: ageController,
                    //     cursorHeight: 20,
                    //     keyboardType: TextInputType.number,
                    //     cursorRadius: const Radius.circular(10),
                    //     style: GoogleFonts.roboto(
                    //       fontSize: 14,
                    //       fontWeight: FontWeight.w500,
                    //       color: Color(0xFF737373),
                    //     ),
                    //     decoration: InputDecoration(
                    //       contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                    //       hintStyle: GoogleFonts.roboto(
                    //         fontSize: 14,
                    //         fontWeight: FontWeight.w500,
                    //         color: Color(0xFF737373).withOpacity(0.40),
                    //       ),
                    //       enabledBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 2),
                    //       ),
                    //       focusedBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 2),
                    //       ),
                    //       disabledBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black.withOpacity(0.50), width: 1.7),
                    //       ),
                    //       errorBorder: const UnderlineInputBorder(
                    //         borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
                    //       ),
                    //       hintText: 'Age',
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 25),
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
                            child: Question5Screen(
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
                        if (ageController.text == "0") {
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Please enter year',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        }else if(int.parse(monthController.text) > 11){
                          ToastMessage.showToastMessage(
                            context: context,
                            message: 'Please enter valid month',
                            duration: 3,
                            backColor: Colors.red,
                            position: StyledToastPosition.center,
                          );
                        } else {
                          String answer = ageController.text + "." + monthController.text;
                          _submitAnswer(answer, "6", this.widget.caseId);
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
    ageController.text = "0";
    monthController.text = "0";
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
          ageController.text = jsonData['data'][5]['answers'] != '0 Year and 0 Months' ? jsonData['data'][5]['answers'].toString().split(" ").first : '0';
          monthController.text = jsonData['data'][5]['answers'] != '0 Year and 0 Months' ? jsonData['data'][5]['answers'].toString().split(" ")[3] : '0';

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
              child: Question7Screen(caseId: this.widget.caseId),
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
