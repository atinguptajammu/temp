import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vsod_flutter/screens/Doctor/DoctorDashBoardScreen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_specialistprofile_screen.dart';
import 'package:vsod_flutter/screens/Doctor/model/SlotModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';

class DoctorConnectingScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorConnectingScreenState();
  String caseId;
  String channelName;

  DoctorConnectingScreen({required this.caseId, required this.channelName});
}

class _DoctorConnectingScreenState extends State<DoctorConnectingScreen> {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;
  var _profileImage;
  late Timer _timer;

  //late Timer _apiCallTimer;
  //27-10-2022 | Set countdown timer to 5 minutes |#GWC
  int _startSec = 59;
  int _startMin = 4;
  bool countDownComplete = false;

  late List<ScheduleTimeModel> _timeList;
  bool _setTimeVisible = false;
  var _selectedDate;
  List<SlotModel> _slotList = <SlotModel>[];


  String _currentTime = "";

  @override
  void initState() {
    super.initState();
    _init();
    _timeList = [
      ScheduleTimeModel('0', '7:00 am', '7:00'),
      ScheduleTimeModel('0', '7:20 am', '7:20'),
      ScheduleTimeModel('0', '7:40 am', '7:40'),
      ScheduleTimeModel('0', '8:00 am', '8:00'),
      ScheduleTimeModel('0', '8:20 am', '8:20'),
      ScheduleTimeModel('0', '8:40 am', '8:40'),
      ScheduleTimeModel('0', '9:00 am', '9:00'),
      ScheduleTimeModel('0', '9:20 am', '9:20'),
      ScheduleTimeModel('0', '9:40 am', '9:40'),
      ScheduleTimeModel('0', '10:00 am', '10:00'),
      ScheduleTimeModel('0', '10:20 am', '10:20'),
      ScheduleTimeModel('0', '10:40 am', '10:40'),
      ScheduleTimeModel('0', '11:00 am', '11:00'),
      ScheduleTimeModel('0', '11:20 am', '11:20'),
      ScheduleTimeModel('0', '11:40 am', '11:40'),
      ScheduleTimeModel('0', '12:00 pm', '12:00'),
      ScheduleTimeModel('0', '12:20 pm', '12:20'),
      ScheduleTimeModel('0', '12:40 pm', '12:40'),
      ScheduleTimeModel('0', '1:00 pm', '13:00'),
      ScheduleTimeModel('0', '1:20 pm', '13:20'),
      ScheduleTimeModel('0', '1:40 pm', '13:40'),
      ScheduleTimeModel('0', '2:00 pm', '14:00'),
      ScheduleTimeModel('0', '2:20 pm', '14:20'),
      ScheduleTimeModel('0', '2:40 pm', '14:40'),
      ScheduleTimeModel('0', '3:00 pm', '15:00'),
      ScheduleTimeModel('0', '3:20 pm', '15:20'),
      ScheduleTimeModel('0', '3:40 pm', '15:40'),
      ScheduleTimeModel('0', '4:00 pm', '16:00'),
      ScheduleTimeModel('0', '4:20 pm', '16:20'),
      ScheduleTimeModel('0', '4:40 pm', '16:40'),
      ScheduleTimeModel('0', '5:00 pm', '17:00'),
      ScheduleTimeModel('0', '5:20 pm', '17:20'),
      ScheduleTimeModel('0', '5:40 pm', '17:40'),
      ScheduleTimeModel('0', '6:00 pm', '18:00'),
      ScheduleTimeModel('0', '6:20 pm', '18:20'),
      ScheduleTimeModel('0', '6:40 pm', '18:40')
    ];
    startTimer();
  }


  //#GCW 02-01-2023 Set date to current date of Doctor timezone
  void getCurrentTime() async {
    log("GET CURERNT TIME CALLED");
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    final url = AppConstants.getCurrentTime;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      log('doctorGetCurrentTime response status--> ${response.statusCode}');
      log('doctorGetCurrentTime response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          //Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();

          var data = jsonData['data'] as List;

          if (data.length > 0) {
            _currentTime = data[0]['time'];
          }
        }
      }
    }catch (e, s) {
      log("doctorGetCurrentTime Error--> Error:-$e stackTrace:-$s");
      _currentTime= "";
      //Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        //27-10-2022 | Set countdown timer to 5 minutes |#GWC
        if (_startMin == -1) {
          setState(() {
            timer.cancel();
            countDownComplete = true;
          });
        } else {
          setState(() {
            if (_startSec == 0) {
              _startSec = 59;
              _startMin -= 1;
            } else {
              _startSec--;
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    //_apiCallTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    //#GCW 02-01-2023 Set date to current date of Doctor timezone
    _currentTime == ""?getCurrentTime():null;

    return WillPopScope(
      onWillPop: () {
        AppConstants.pusher
            .unsubscribe(channelName: "CaseAcceptedBySpecialist");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DoctorDashBoardScreen()),
          (Route<dynamic> route) => false,
        );
        return Future.value(false);
      },
      child: Scaffold(
        body: Container(
          child: Column(
            children: [
              Container(
                color: AppColors.headerColor,
                child: Container(
                  margin: EdgeInsets.only(top: 49, bottom: 15),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          _timer.cancel();
                          //Navigator.pop(context);
                          AppConstants.pusher.unsubscribe(
                              channelName: "CaseAcceptedBySpecialist");
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => DoctorDashBoardScreen()),
                            (Route<dynamic> route) => false,
                          );
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
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            "connecting...",
                            textAlign: TextAlign.left,
                            style: GoogleFonts.roboto(
                                fontWeight: FontWeight.w400,
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
                                  image:
                                      AppConstants.publicImage + _profileImage,
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
              SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 30, right: 37),
                child: Text(
                  "Hang on",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: 0.4,
                      color: AppColors.textDarkGreyColor),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 30, right: 37, top: 3),
                child: Text(
                  "while we're matching you with the best Specialist for this case",
                  textAlign: TextAlign.left,
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                      fontSize: 18,
                      color: AppColors.textDarkGreyColor),
                ),
              ),
              Container(
                child: Image.asset(
                  AppImages.connecting,
                  height: 380,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Visibility(
                visible: !countDownComplete,
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 20),
                  alignment: Alignment.center,
                  child: Text(
                    "${_startMin.toString().padLeft(2, '0')}:${_startSec.toString().padLeft(2, '0')}",
                    textAlign: TextAlign.left,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        letterSpacing: 0.25,
                        color: AppColors.textRedColor),
                  ),
                ),
              ),
              Visibility(
                visible: countDownComplete,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 35, vertical: 5),
                  child: CommonButtonGradient(
                    height: 50,
                    fontSize: 20,
                    buttonName: AppStrings.resubmit,
                    colorGradient1: AppColors.gradientSchedule1,
                    colorGradient2: AppColors.gradientSchedule2,
                    fontWeight: FontWeight.w700,
                    onTap: () {
                      _updateTime(this.widget.caseId);
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 35),
                child: CommonButtonGradient(
                  height: 50,
                  fontSize: 20,
                  buttonName: AppStrings.schedule,
                  colorGradient1: AppColors.gradientSchedule1,
                  colorGradient2: AppColors.gradientSchedule2,
                  fontWeight: FontWeight.w700,
                  onTap: () {
                    _setTimeVisible = false;
                    _slotList.clear();
                    _showScheduleDialog(context, this.widget.caseId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
      setState(() {});
    });
    /*_apiCallTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _checkCaseStatus(this.widget.caseId);
    });*/

    AppConstants.pusher.subscribe(
      channelName: "CaseStatus",
      onEvent: (event) {
        log("onEvent: $event");

        if (event.eventName.toString().contains('CaseAcceptedBySpecialist')) {
          print("Case Accepted by specialist");

          if (event.data != null) {
            var data = jsonDecode(event.data);

            if (data['case'] != null) {
              print("Specialist Id == ${data['case']['specialist_id']}");
              print("Show Date");
              print(
                  "StartDateTime == ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(data['start_time']))}");
              print(
                  "EndDateTime == ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(data['end_time']))}");
              print("Seconds == ${data['seconds']}");
              _timer.cancel();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DoctorSpecialistProfileScreen(
                    channelName: this.widget.channelName,
                    caseId: widget.caseId,
                    specialistId: "${data['case']['specialist_id']}",
                    caseSeconds: "${data['seconds']}",
                  ),
                ),
              );
            }
          }
        }
      },
      onSubscriptionError: (String message, dynamic e) {
        log("onSubscriptionError: $message Exception: $e");
      },
      onSubscriptionSucceeded: (data) {
        log("onSubscriptionSucceeded: data: $data");
      },
    );
    AppConstants.pusher.connect();
  }

  _updateTime(String caseId) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorUpdateTime;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          countDownComplete = false;
          _startMin = 4;
          _startSec = 59;
          startTimer();
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

  /*_checkCaseStatus(String caseId) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    final url = AppConstants.doctorCaseStatus + caseId;

    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getPendingCases response status--> ${response.statusCode}');
      log('getPendingCases response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          if (jsonData['data'][0]!['status'] == 'active') {
            _timer.cancel();
            _apiCallTimer.cancel();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SpecialistProfileScreen(
                  channelName: this.widget.channelName,
                  caseId: jsonData['data'][0]!['id'].toString(),
                  specialistId: jsonData['data'][0]!['specialist']!['id'].toString(),
                ),
              ),
            );
          }
          setState(() {});
        }
      }
    } catch (e, s) {
      log("getPendingCases Error--> Error:-$e stackTrace:-$s");
    }
  }*/
  //#GCW 31-12-2022 Set Time slots from 8 am to 11:40pm
  // void _showScheduleDialog(BuildContext context, String caseId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
  //         return Dialog(
  //           insetPadding: EdgeInsets.symmetric(horizontal: 20),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //             side: BorderSide(
  //               width: 1,
  //               color: AppColors.dialogBorderColor.withOpacity(0.40),
  //             ),
  //           ),
  //           elevation: 0,
  //           backgroundColor: Colors.white,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.only(top: 5),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         margin: EdgeInsets.only(left: 35),
  //                         alignment: Alignment.center,
  //                         child: Text(
  //                           "Schedule Request",
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor),
  //                         ),
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Container(
  //                         margin: EdgeInsets.only(right: 10),
  //                         child: Image.asset(
  //                           AppImages.scheduleClose,
  //                           height: 21,
  //                           width: 25,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.only(top: 5),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "Every slot is of 20 minutes",
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
  //                 ),
  //               ),
  //               Container(
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "You can choose 5 slots",
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 5,
  //               ),
  //               Container(
  //                 height: _slotList.length > 0 ? 103 : 5,
  //                 alignment: Alignment.centerLeft,
  //                 margin: EdgeInsets.symmetric(horizontal: 15),
  //                 child: ListView.builder(
  //                   itemCount: _slotList.length,
  //                   shrinkWrap: true,
  //                   scrollDirection: Axis.horizontal,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     return Container(
  //                       margin: EdgeInsets.symmetric(horizontal: 2),
  //                       width: 70,
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           colors: [
  //                             AppColors.gradientScheduleRectangle1,
  //                             AppColors.gradientScheduleRectangle2,
  //                           ],
  //                           begin: Alignment.topCenter,
  //                           end: Alignment.bottomCenter,
  //                           stops: [0.0, 1.0],
  //                           tileMode: TileMode.clamp,
  //                         ),
  //                         borderRadius: BorderRadius.circular(4),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: AppColors.blackColor.withOpacity(0.25),
  //                             blurRadius: 2,
  //                             offset: const Offset(0, 5), // Shadow position
  //                           ),
  //                         ],
  //                       ),
  //                       child: InkWell(
  //                         onTap: () {
  //                           _slotList.removeAt(index);
  //                           setState(() {});
  //                         },
  //                         child: Column(
  //                           children: [
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 // "Jan, 2022",
  //                                 DateFormat('MMM,yyyy').format(DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10, color: AppColors.textLightGrayColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 DateFormat('dd').format(DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.2, color: AppColors.whiteColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 DateFormat('EEE').format(DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.whiteColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 3,
  //                             ),
  //                             Container(
  //                               margin: EdgeInsets.symmetric(horizontal: 1),
  //                               child: Card(
  //                                 color: Colors.white,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(4),
  //                                 ),
  //                                 elevation: 5,
  //                                 shadowColor: Colors.black.withOpacity(0.45),
  //                                 child: Container(
  //                                   height: 28,
  //                                   alignment: Alignment.center,
  //                                   child: Text(
  //                                     "${(DateFormat('hh:mm aa').format(DateFormat('HH:mm').parse(_slotList[index].slotTime))).toString()}",
  //                                     style: GoogleFonts.roboto(
  //                                       fontWeight: FontWeight.w700,
  //                                       letterSpacing: 0.15,
  //                                       color: AppColors.textPrussianBlueColor,
  //                                       fontSize: 12,
  //                                     ),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.only(left: 20, right: 20),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         child: SfDateRangePicker(
  //                           view: DateRangePickerView.month,
  //                           selectionColor: AppColors.textPrussianBlueColor,
  //                           selectionMode: DateRangePickerSelectionMode.single,
  //                           minDate: DateTime.now(),
  //                           maxDate: DateTime(2100),
  //                           // initialSelectedDate: _selectedDate,
  //                           onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
  //                             print(args.value);
  //                             _selectedDate = args.value;
  //
  //                             String token = (sharedPreferences.getString("Bearer Token") ?? "");
  //                             log('Bearer Token ==>  $token');
  //                             AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
  //                             final url = AppConstants.getCurrentTime;
  //
  //                             log('url--> $url');
  //
  //                             Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
  //
  //                             try {
  //                               final response = await http.get(Uri.parse(url), headers: headers);
  //
  //                               log('doctorGetCurrentTime response status--> ${response.statusCode}');
  //                               log('doctorGetCurrentTime response body--> ${response.body}');
  //
  //                               if (response.statusCode == 200) {
  //                                 var jsonData = jsonDecode(response.body);
  //                                 if (jsonData['status']['error'] == false) {
  //                                   Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
  //
  //                                   var data = jsonData['data'] as List;
  //
  //                                   if (data.length > 0) {
  //                                     _currentTime = data[0]['time'];
  //                                   }
  //
  //                                   _timeList.clear();
  //
  //                                   DateTime current = DateFormat("MM/dd/yyyy").parse(_currentTime.split(" ")[0]);
  //
  //                                   if (isSameDate(_selectedDate, current)) {
  //                                     String _startingHour = _currentTime.split(" ")[1].split(":")[0];
  //                                     String _startingMinutes = _currentTime.split(" ")[1].split(":")[1];
  //
  //                                     int convertedMinute = 00;
  //
  //                                     if (int.parse(_startingMinutes) > 0 && int.parse(_startingMinutes) < 20) {
  //                                       convertedMinute = 20;
  //                                     } else if (int.parse(_startingMinutes) > 20 && int.parse(_startingMinutes) < 40) {
  //                                       convertedMinute = 40;
  //                                     } else if (int.parse(_startingMinutes) > 40) {
  //                                       convertedMinute = 00;
  //                                       _startingHour = (int.parse(_startingHour) + 1).toString();
  //                                     }
  //
  //                                     print("Current Time = $_currentTime");
  //                                     print("Starting Time = $_startingHour : $convertedMinute");
  //
  //                                     final endTime = TimeOfDay(hour: 18, minute: 40);
  //                                     final step = Duration(minutes: 20);
  //
  //                                     if (int.parse(_startingHour) >= 7 && int.parse(_startingHour) < 19) {
  //                                       final startTime = TimeOfDay(hour: int.parse(_startingHour), minute: convertedMinute);
  //                                       final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();
  //
  //                                       for (int i = 0; i < times.length; i++) {
  //                                         _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
  //                                       }
  //
  //                                       print("Times == $times");
  //                                     } else {
  //                                       final startTime = TimeOfDay(hour: 7, minute: 0);
  //
  //                                       final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();
  //
  //                                       for (int i = 0; i < times.length; i++) {
  //                                         _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
  //                                       }
  //
  //                                       print("Times == $times");
  //                                     }
  //                                   } else {
  //                                     final startTime = TimeOfDay(hour: 7, minute: 0);
  //                                     final endTime = TimeOfDay(hour: 18, minute: 40);
  //                                     final step = Duration(minutes: 20);
  //
  //                                     if (startTime.hour >= 7 && startTime.hour < 19) {
  //                                       final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();
  //
  //                                       for (int i = 0; i < times.length; i++) {
  //                                         _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
  //                                       }
  //
  //                                       print("Times == $times");
  //                                     }
  //                                   }
  //                                   _setTimeVisible = true;
  //
  //                                   setState(() {});
  //                                 } else {
  //                                   Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
  //                                 }
  //                               } else {
  //                                 Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
  //                               }
  //                             } catch (e, s) {
  //                               log("doctorGetCurrentTime Error--> Error:-$e stackTrace:-$s");
  //                               Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
  //                             }
  //
  //                             setState(() {});
  //
  //                             // Navigator.pop(context);
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     Visibility(
  //                       visible: _setTimeVisible,
  //                       child: Container(
  //                         width: 92,
  //                         child: Column(
  //                           children: [
  //                             Container(
  //                               child: Text(
  //                                 "Set Time",
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.textDarkBlue),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 250,
  //                               margin: EdgeInsets.only(top: 5),
  //                               child: _timeList.length > 0
  //                                   ? ListView.builder(
  //                                 itemCount: _timeList.length,
  //                                 shrinkWrap: true,
  //                                 itemBuilder: (BuildContext context, int index) {
  //                                   return Container(
  //                                     child: InkWell(
  //                                       onTap: () {
  //                                         if (_slotList.length == 5) {
  //                                           ToastMessage.showToastMessage(
  //                                             context: context,
  //                                             message: 'Max 5 Slot Select',
  //                                             duration: 3,
  //                                             backColor: Colors.red,
  //                                             position: StyledToastPosition.center,
  //                                           );
  //                                         } else {
  //                                           for (int i = 0; i < _slotList.length; i++) {
  //                                             if (_slotList[i].date == _selectedDate.toString()) {
  //                                               log("SLot Date ==> " + _slotList[i].date.toString());
  //                                               if (_slotList[i].slotTime == _timeList[index]._time1) {
  //                                                 ToastMessage.showToastMessage(
  //                                                   context: context,
  //                                                   message: 'Already Select',
  //                                                   duration: 3,
  //                                                   backColor: Colors.red,
  //                                                   position: StyledToastPosition.center,
  //                                                 );
  //                                                 return;
  //                                               }
  //                                             }
  //                                           }
  //                                           SlotModel slotModel = SlotModel(_selectedDate.toString(), _timeList[index]._time1);
  //                                           _slotList.add(slotModel);
  //                                         }
  //                                         setState(() {});
  //                                       },
  //                                       child: Card(
  //                                         color: AppColors.lightGreyColor,
  //                                         shape: RoundedRectangleBorder(
  //                                           borderRadius: BorderRadius.circular(4),
  //                                         ),
  //                                         elevation: 0,
  //                                         child: Container(
  //                                           height: 28,
  //                                           width: 82,
  //                                           alignment: Alignment.center,
  //                                           child: Row(
  //                                             children: [
  //                                               Expanded(
  //                                                 child: Container(
  //                                                   alignment: Alignment.center,
  //                                                   child:
  //                                                   Text(
  //                                                     _timeList[index]._time,
  //                                                     style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.15, color: AppColors.textPrussianBlueColor, fontSize: 12),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               )
  //                                   : Container(
  //                                 height: 250,
  //                                 alignment: Alignment.center,
  //                                 child: Text(
  //                                   "No slots\navailable",
  //                                   style: GoogleFonts.roboto(
  //                                     fontSize: 11,
  //                                   ),
  //                                   textAlign: TextAlign.center,
  //                                 ),
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 child: CommonButtonGradient(
  //                   height: 48,
  //                   width: 148,
  //                   fontSize: 14,
  //                   buttonName: AppStrings.submit,
  //                   colorGradient1: AppColors.gradientGreen1,
  //                   colorGradient2: AppColors.gradientGreen2,
  //                   fontWeight: FontWeight.w500,
  //                   onTap: () {
  //                     String? slotTime = '';
  //                     for (int j = 0; j < _slotList.length; j++) {
  //                       slotTime = slotTime! + (DateFormat('MM/dd/yyyy').format(DateTime.parse(_slotList[j].date))).toString() + " " + _slotList[j].slotTime + ",";
  //                     }
  //                     if (slotTime != null && slotTime.length > 0) {
  //                       slotTime = slotTime.substring(0, slotTime.length - 1);
  //                     }
  //                     print("Slot Time ==> " + slotTime.toString());
  //
  //                     if (slotTime != null && slotTime.length > 0) {
  //                       _startCase('schedule', caseId, slotTime);
  //                     } else {
  //                       ToastMessage.showToastMessage(
  //                         context: context,
  //                         message: 'Please select slot',
  //                         duration: 3,
  //                         backColor: Colors.red,
  //                         position: StyledToastPosition.center,
  //                       );
  //                     }
  //                   },
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 25,
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  void _showScheduleDialog(BuildContext context, String caseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {

        log("in show dialog tim current ${_currentTime}");
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                width: 1,
                color: AppColors.dialogBorderColor.withOpacity(0.40),
              ),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 35),
                          alignment: Alignment.center,
                          child: Text(
                            "Schedule Request",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          child: Image.asset(
                            AppImages.scheduleClose,
                            height: 21,
                            width: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  alignment: Alignment.center,
                  child: Text(
                    //#GCW 13-02-2023
                    //"Every slot is of 20 minutes",
                    "You have requested this case for the times below. If case is not accepted, click \"re-schedule\" to submit different times or to resubmit as a live case",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "You can choose 5 slots",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: _slotList.length > 0 ? 103 : 5,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.builder(
                    itemCount: _slotList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        width: 70,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientScheduleRectangle1,
                              AppColors.gradientScheduleRectangle2,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.blackColor.withOpacity(0.25),
                              blurRadius: 2,
                              offset: const Offset(0, 5), // Shadow position
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            _slotList.removeAt(index);
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  // "Jan, 2022",
                                  DateFormat('MMM,yyyy').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10, color: AppColors.textLightGrayColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('dd').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.2, color: AppColors.whiteColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('EEE').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.whiteColor),
                                ),
                              ),
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 1),
                                child: Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black.withOpacity(0.45),
                                  child: Container(
                                    height: 28,
                                    alignment: Alignment.center,
                                    child: Text(
                                      "${(DateFormat('hh:mm aa').format(DateFormat('HH:mm').parse(_slotList[index].slotTime))).toString()}",
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.15,
                                        color: AppColors.textPrussianBlueColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: SfDateRangePicker(
                            view: DateRangePickerView.month,
                            selectionColor: AppColors.textPrussianBlueColor,
                            selectionMode: DateRangePickerSelectionMode.single,
                            //#GCW 02-01-2023 Set date to current date of Doctor timezone
                            minDate: _currentTime == ""?DateTime.now():DateFormat("MM/dd/yyyy").parse(_currentTime.split(" ")[0]),
                            maxDate: DateTime(2100),
                            // initialSelectedDate: _selectedDate,
                            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) async {
                              print(args.value);
                              _selectedDate = args.value;
                              String token = (sharedPreferences.getString("Bearer Token") ?? "");
                              log('Bearer Token ==>  $token');
                              AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
                              final url = AppConstants.getCurrentTime;

                              log('url--> $url');

                              Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};

                              try {
                                final response = await http.get(Uri.parse(url), headers: headers);

                                log('doctorGetCurrentTime response status--> ${response.statusCode}');
                                log('doctorGetCurrentTime response body--> ${response.body}');

                                if (response.statusCode == 200) {
                                  var jsonData = jsonDecode(response.body);
                                  if (jsonData['status']['error'] == false) {
                                    Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();

                                    var data = jsonData['data'] as List;

                                    if (data.length > 0) {
                                      _currentTime = data[0]['time'];
                                    }

                                    _timeList.clear();

                                    //get current date and time
                                    DateTime current = DateFormat("MM/dd/yyyy").parse(_currentTime.split(" ")[0]);

                                    if (isSameDate(_selectedDate, current)) {
                                      String _startingHour = _currentTime.split(" ")[1].split(":")[0];
                                      String _startingMinutes = _currentTime.split(" ")[1].split(":")[1];

                                      int convertedMinute = 00;

                                      if (int.parse(_startingMinutes) > 0 && int.parse(_startingMinutes) < 20) {
                                        convertedMinute = 20;
                                      } else if (int.parse(_startingMinutes) > 20 && int.parse(_startingMinutes) < 40) {
                                        convertedMinute = 40;
                                      } else if (int.parse(_startingMinutes) > 40) {
                                        convertedMinute = 00;
                                        _startingHour = (int.parse(_startingHour) + 1).toString();
                                      }

                                      print("Current Time = $_currentTime");
                                      print("Starting Time = $_startingHour : $convertedMinute");

                                      final endTime = TimeOfDay(hour: 23, minute: 40);
                                      final step = Duration(minutes: 20);

                                      if (int.parse(_startingHour) >= 8 && int.parse(_startingHour) <= 23) {
                                        final startTime = TimeOfDay(hour: int.parse(_startingHour), minute: convertedMinute);
                                        final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();

                                        for (int i = 0; i < times.length; i++) {
                                          _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
                                        }

                                        print("Times == $times");
                                      } else {
                                        final startTime = TimeOfDay(hour: 8, minute: 0);

                                        final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();

                                        for (int i = 0; i < times.length; i++) {
                                          _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
                                        }

                                        print("Times == $times");
                                      }
                                    } else {
                                      final startTime = TimeOfDay(hour: 8, minute: 0);
                                      final endTime = TimeOfDay(hour: 23, minute: 40);
                                      final step = Duration(minutes: 20);

                                      if (startTime.hour >= 8 && startTime.hour <= 23) {
                                        final times = getTimes(startTime, endTime, step).map((tod) => tod.format(context)).toList();

                                        for (int i = 0; i < times.length; i++) {
                                          _timeList.add(ScheduleTimeModel('0', '${times[i]}', '${time12to24Format(times[i])}'));
                                        }

                                        print("Times == $times");
                                      }
                                    }
                                    _setTimeVisible = true;

                                    setState(() {});
                                  } else {
                                    Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
                                  }
                                } else {
                                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
                                }
                              } catch (e, s) {
                                log("doctorGetCurrentTime Error--> Error:-$e stackTrace:-$s");
                                Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
                              }

                              setState(() {});

                              // Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _setTimeVisible,
                        child: Container(
                          width: 92,
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                  "Set Time",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.textDarkBlue),
                                ),
                              ),
                              Container(
                                height: 250,
                                margin: EdgeInsets.only(top: 5),
                                child: _timeList.length > 0
                                    ? ListView.builder(
                                  itemCount: _timeList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      child: InkWell(
                                        onTap: () {
                                          if (_slotList.length == 5) {
                                            ToastMessage.showToastMessage(
                                              context: context,
                                              message: 'Max 5 Slot Select',
                                              duration: 3,
                                              backColor: Colors.red,
                                              position: StyledToastPosition.center,
                                            );
                                          } else {
                                            for (int i = 0; i < _slotList.length; i++) {
                                              if (_slotList[i].date == _selectedDate.toString()) {
                                                log("SLot Date ==> " + _slotList[i].date.toString());
                                                if (_slotList[i].slotTime == _timeList[index]._time1) {
                                                  ToastMessage.showToastMessage(
                                                    context: context,
                                                    message: 'Already Select',
                                                    duration: 3,
                                                    backColor: Colors.red,
                                                    position: StyledToastPosition.center,
                                                  );
                                                  return;
                                                }
                                              }
                                            }
                                            SlotModel slotModel = SlotModel(_selectedDate.toString(), _timeList[index]._time1);
                                            _slotList.add(slotModel);
                                          }
                                          setState(() {});
                                        },
                                        child: Card(
                                          color: AppColors.lightGreyColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          elevation: 0,
                                          child: Container(
                                            height: 28,
                                            width: 82,
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child:
                                                    Text(
                                                      _timeList[index]._time,
                                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.15, color: AppColors.textPrussianBlueColor, fontSize: 12),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                    : Container(
                                  height: 250,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "No slots\navailable",
                                    style: GoogleFonts.roboto(
                                      fontSize: 11,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: CommonButtonGradient(
                    height: 48,
                    width: 148,
                    fontSize: 14,
                    buttonName: AppStrings.submit,
                    colorGradient1: AppColors.gradientGreen1,
                    colorGradient2: AppColors.gradientGreen2,
                    fontWeight: FontWeight.w500,
                    onTap: () {
                      String? slotTime = '';
                      for (int j = 0; j < _slotList.length; j++) {
                        slotTime = slotTime! + (DateFormat('MM/dd/yyyy').format(DateTime.parse(_slotList[j].date))).toString() + " " + _slotList[j].slotTime + ",";
                      }
                      if (slotTime != null && slotTime.length > 0) {
                        slotTime = slotTime.substring(0, slotTime.length - 1);
                      }
                      print("Slot Time ==> " + slotTime.toString());

                      if (slotTime != null && slotTime.length > 0) {
                        _startCase('schedule', caseId, slotTime);
                      } else {
                        ToastMessage.showToastMessage(
                          context: context,
                          message: 'Please select slot',
                          duration: 3,
                          backColor: Colors.red,
                          position: StyledToastPosition.center,
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          );
        });
      },
    );
  }

  _startCase(String caseType, String caseId, String slotTime) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorStartCase;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"case_type": '$caseType', "case_id": '$caseId', "slots": '$slotTime'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.pop(context);
          Navigator.pop(context);
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
      log("doctorSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
  //#GCW 22-12-2022
  //void _showScheduleDialog(BuildContext context, String caseId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //           builder: (BuildContext context, StateSetter setState) {
  //         return Dialog(
  //           insetPadding: EdgeInsets.symmetric(horizontal: 20),
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //               side: BorderSide(
  //                 width: 1,
  //                 color: AppColors.dialogBorderColor.withOpacity(0.40),
  //               )),
  //           elevation: 0,
  //           backgroundColor: Colors.white,
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Container(
  //                 margin: EdgeInsets.only(top: 5),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         margin: EdgeInsets.only(left: 35),
  //                         alignment: Alignment.center,
  //                         child: Text(
  //                           "Schedule Request",
  //                           textAlign: TextAlign.center,
  //                           style: GoogleFonts.roboto(
  //                               fontWeight: FontWeight.w700,
  //                               fontSize: 24,
  //                               letterSpacing: 0.25,
  //                               color: AppColors.textPrussianBlueColor),
  //                         ),
  //                       ),
  //                     ),
  //                     InkWell(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child: Container(
  //                         margin: EdgeInsets.only(right: 10),
  //                         child: Image.asset(
  //                           AppImages.scheduleClose,
  //                           height: 21,
  //                           width: 25,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.only(top: 5),
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "Every slot is of 20 minutes",
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.roboto(
  //                       fontWeight: FontWeight.w400,
  //                       fontSize: 12,
  //                       letterSpacing: 0.25,
  //                       color: AppColors.textDarkBlue),
  //                 ),
  //               ),
  //               Container(
  //                 alignment: Alignment.center,
  //                 child: Text(
  //                   "You can choose 5 slots",
  //                   textAlign: TextAlign.center,
  //                   style: GoogleFonts.roboto(
  //                       fontWeight: FontWeight.w400,
  //                       fontSize: 12,
  //                       letterSpacing: 0.25,
  //                       color: AppColors.textDarkBlue),
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 5,
  //               ),
  //               Container(
  //                 height: _slotList.length > 0 ? 103 : 5,
  //                 alignment: Alignment.centerLeft,
  //                 margin: EdgeInsets.symmetric(horizontal: 15),
  //                 child: ListView.builder(
  //                   itemCount: _slotList.length,
  //                   shrinkWrap: true,
  //                   scrollDirection: Axis.horizontal,
  //                   itemBuilder: (BuildContext context, int index) {
  //                     return Container(
  //                       margin: EdgeInsets.symmetric(horizontal: 2),
  //                       width: 65,
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           colors: [
  //                             AppColors.gradientScheduleRectangle1,
  //                             AppColors.gradientScheduleRectangle2,
  //                           ],
  //                           begin: Alignment.topCenter,
  //                           end: Alignment.bottomCenter,
  //                           stops: [0.0, 1.0],
  //                           tileMode: TileMode.clamp,
  //                         ),
  //                         borderRadius: BorderRadius.circular(4),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: AppColors.blackColor.withOpacity(0.25),
  //                             blurRadius: 2,
  //                             offset: const Offset(0, 5), // Shadow position
  //                           ),
  //                         ],
  //                       ),
  //                       child: InkWell(
  //                         onTap: () {
  //                           _slotList.removeAt(index);
  //                           setState(() {});
  //                         },
  //                         child: Column(
  //                           children: [
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 // "Jan, 2022",
  //                                 DateFormat('MMM,yyyy').format(
  //                                     DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(
  //                                     fontWeight: FontWeight.w400,
  //                                     fontSize: 10,
  //                                     color: AppColors.textLightGrayColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 DateFormat('dd').format(
  //                                     DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(
  //                                     fontWeight: FontWeight.w700,
  //                                     fontSize: 18,
  //                                     letterSpacing: 0.2,
  //                                     color: AppColors.whiteColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 5,
  //                             ),
  //                             Container(
  //                               child: Text(
  //                                 DateFormat('EEE').format(
  //                                     DateTime.parse(_slotList[index].date)),
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(
  //                                     fontWeight: FontWeight.w400,
  //                                     fontSize: 12,
  //                                     letterSpacing: 0.2,
  //                                     color: AppColors.whiteColor),
  //                               ),
  //                             ),
  //                             SizedBox(
  //                               height: 3,
  //                             ),
  //                             Container(
  //                               child: Card(
  //                                 color: Colors.white,
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(4),
  //                                 ),
  //                                 elevation: 5,
  //                                 shadowColor: Colors.black.withOpacity(0.45),
  //                                 child: Container(
  //                                   height: 28,
  //                                   width: 55,
  //                                   alignment: Alignment.center,
  //                                   child: Text(
  //                                     _slotList[index].slotTime,
  //                                     style: GoogleFonts.roboto(
  //                                         fontWeight: FontWeight.w700,
  //                                         letterSpacing: 0.15,
  //                                         color:
  //                                             AppColors.textPrussianBlueColor,
  //                                         fontSize: 12),
  //                                   ),
  //                                 ),
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                 ),
  //               ),
  //               Container(
  //                 margin: EdgeInsets.only(left: 20, right: 20),
  //                 child: Row(
  //                   children: [
  //                     Expanded(
  //                       child: Container(
  //                         child: SfDateRangePicker(
  //                           view: DateRangePickerView.month,
  //                           selectionColor: AppColors.textPrussianBlueColor,
  //                           selectionMode: DateRangePickerSelectionMode.single,
  //                           minDate: DateTime.now(),
  //                           maxDate: DateTime(2100),
  //                           // initialSelectedDate: _selectedDate,
  //                           onSelectionChanged:
  //                               (DateRangePickerSelectionChangedArgs args) {
  //                             print(args.value);
  //                             _selectedDate = args.value;
  //                             _setTimeVisible = true;
  //                             setState(() {});
  //
  //                             // Navigator.pop(context);
  //                           },
  //                         ),
  //                       ),
  //                     ),
  //                     Visibility(
  //                       visible: _setTimeVisible,
  //                       child: Container(
  //                         width: 92,
  //                         child: Column(
  //                           children: [
  //                             Container(
  //                               child: Text(
  //                                 "Set Time",
  //                                 textAlign: TextAlign.center,
  //                                 style: GoogleFonts.roboto(
  //                                     fontWeight: FontWeight.w400,
  //                                     fontSize: 12,
  //                                     letterSpacing: 0.2,
  //                                     color: AppColors.textDarkBlue),
  //                               ),
  //                             ),
  //                             Container(
  //                               height: 250,
  //                               margin: EdgeInsets.only(top: 5),
  //                               child: ListView.builder(
  //                                 itemCount: _timeList.length,
  //                                 shrinkWrap: true,
  //                                 itemBuilder:
  //                                     (BuildContext context, int index) {
  //                                   return Container(
  //                                     child: InkWell(
  //                                       onTap: () {
  //                                         if (_slotList.length == 5) {
  //                                           ToastMessage.showToastMessage(
  //                                             context: context,
  //                                             message: 'Max 5 Slot Select',
  //                                             duration: 3,
  //                                             backColor: Colors.red,
  //                                             position:
  //                                                 StyledToastPosition.center,
  //                                           );
  //                                         } else {
  //                                           for (int i = 0;
  //                                               i < _slotList.length;
  //                                               i++) {
  //                                             if (_slotList[i].date ==
  //                                                 _selectedDate.toString()) {
  //                                               log("SLot Date ==> " +
  //                                                   _slotList[i]
  //                                                       .date
  //                                                       .toString());
  //                                               if (_slotList[i].slotTime ==
  //                                                   _timeList[index]._time1) {
  //                                                 ToastMessage.showToastMessage(
  //                                                   context: context,
  //                                                   message: 'Already Select',
  //                                                   duration: 3,
  //                                                   backColor: Colors.red,
  //                                                   position:
  //                                                       StyledToastPosition
  //                                                           .center,
  //                                                 );
  //                                                 return;
  //                                               }
  //                                             }
  //                                           }
  //                                           SlotModel slotModel = SlotModel(
  //                                               _selectedDate.toString(),
  //                                               _timeList[index]._time1);
  //                                           _slotList.add(slotModel);
  //                                         }
  //                                         setState(() {});
  //                                       },
  //                                       child: Card(
  //                                         color: AppColors.lightGreyColor,
  //                                         shape: RoundedRectangleBorder(
  //                                           borderRadius:
  //                                               BorderRadius.circular(4),
  //                                         ),
  //                                         elevation: 0,
  //                                         child: Container(
  //                                           height: 28,
  //                                           width: 82,
  //                                           alignment: Alignment.center,
  //                                           child: Row(
  //                                             children: [
  //                                               Expanded(
  //                                                 child: Container(
  //                                                   alignment: Alignment.center,
  //                                                   child: Text(
  //                                                     _timeList[index]._time,
  //                                                     style: GoogleFonts.roboto(
  //                                                         fontWeight:
  //                                                             FontWeight.w700,
  //                                                         letterSpacing: 0.15,
  //                                                         color: AppColors
  //                                                             .textPrussianBlueColor,
  //                                                         fontSize: 12),
  //                                                   ),
  //                                                 ),
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                     ),
  //                                   );
  //                                 },
  //                               ),
  //                             )
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Container(
  //                 child: CommonButtonGradient(
  //                   height: 48,
  //                   width: 148,
  //                   fontSize: 14,
  //                   buttonName: AppStrings.submit,
  //                   colorGradient1: AppColors.gradientGreen1,
  //                   colorGradient2: AppColors.gradientGreen2,
  //                   fontWeight: FontWeight.w500,
  //                   onTap: () {
  //                     String? slotTime = ',';
  //                     for (int j = 0; j < _slotList.length; j++) {
  //                       slotTime = slotTime! +
  //                           (DateFormat('MM/dd/yyyy')
  //                                   .format(DateTime.parse(_slotList[j].date)))
  //                               .toString() +
  //                           " " +
  //                           _slotList[j].slotTime +
  //                           ",";
  //                     }
  //                     if (slotTime != null && slotTime.length > 0) {
  //                       slotTime = slotTime.substring(0, slotTime.length - 1);
  //                     }
  //                     print("Slot Time ==> " + slotTime.toString());
  //
  //                     if (slotTime != null && slotTime.length > 0) {
  //                       _startSecCase('schedule', caseId, slotTime);
  //                     } else {
  //                       ToastMessage.showToastMessage(
  //                         context: context,
  //                         message: 'Please select slot',
  //                         duration: 3,
  //                         backColor: Colors.red,
  //                         position: StyledToastPosition.center,
  //                       );
  //                     }
  //                   },
  //                 ),
  //               ),
  //               SizedBox(
  //                 height: 25,
  //               ),
  //             ],
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }


  _startSecCase(String caseType, String caseId, String slotTime) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorStartCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode(
        {"case_type": '$caseType', "case_id": '$caseId', "slots": '$slotTime'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.pop(context);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => DoctorDashBoardScreen()),
              (Route<dynamic> route) => false);
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
      log("doctorSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
  Iterable<TimeOfDay> getTimes(TimeOfDay startTime, TimeOfDay endTime, Duration step) sync* {
    var hour = startTime.hour;
    var minute = startTime.minute;

    do {
      yield TimeOfDay(hour: hour, minute: minute);
      minute += step.inMinutes;
      while (minute >= 60) {
        minute -= 60;
        hour++;
      }
    } while (hour < endTime.hour || (hour == endTime.hour && minute <= endTime.minute));
  }

  String time12to24Format(String time) {
// var time = "12:01 AM";
    int h = int.parse(time.split(":").first);
    int m = int.parse(time.split(":").last.split(" ").first);
    String meridium = time.split(":").last.split(" ").last.toLowerCase();
    if (meridium == "pm") {
      if (h != 12) {
        h = h + 12;
      }
    }
    if (meridium == "am") {
      if (h == 12) {
        h = 00;
      }
    }
    String newTime = "${h == 0 ? "00" : h}:${m == 0 ? "00" : m}";
    print(newTime);

    return newTime;
  }

  bool isSameDate(DateTime selected, DateTime other) {
    return selected.year == other.year && selected.month == other.month && selected.day == other.day;
  }
}

class ScheduleTimeModel {
  String _selected;
  String _time;
  String _time1;

  ScheduleTimeModel(this._selected, this._time, this._time1);

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get selected => _selected;

  set selected(String value) {
    _selected = value;
  }

  String get time1 => _time1;

  set time1(String value) {
    _time1 = value;
  }
}
