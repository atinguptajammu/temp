import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_question1_screen.dart';
import 'package:vsod_flutter/screens/Doctor/model/SpecializationModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';

import '../../../utils/utils.dart';

class DoctorHomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorHomeScreenState();

  final Function viewCase;

  DoctorHomeScreen({required this.viewCase});
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<SpecializationModel> _specialization = <SpecializationModel>[];
  late SharedPreferences sharedPreferences;

  String openCase = '0';
  String pendingCase = '0';
  bool supportCaseAvailable = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: 162,
            child: Stack(
              children: [
                Container(
                  color: AppColors.headerColor,
                  height: 115,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 38,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                widget.viewCase("PENDING");
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                height: 20,
                                child: Container(
                                  margin: EdgeInsets.only(left: 30),
                                  child: Text(
                                    "Pending Cases : $pendingCase",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.17,
                                        color: Colors.white,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                widget.viewCase("OPEN");
                              },
                              child: Container(
                                height: 20,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: EdgeInsets.only(right: 40),
                                  child: Text(
                                    "Open Cases : $openCase",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: -0.17,
                                        color: Colors.white,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 90,
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
                              margin: EdgeInsets.only(left: 35),
                              child: Image.asset(
                                AppImages.doctorIcon,
                                height: 57,
                                width: 64,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  "What do you need\nhelp with?",
                                  maxLines: 2,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.15,
                                    color: Color(0xff004464),
                                    fontSize: 20,
                                  ),
                                ),
                              ),
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
          SizedBox(height: 20),
          Expanded(
            child: MediaQuery.removePadding(
              removeTop: true,
              context: context,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  itemCount: _specialization.length,
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(23),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black,
                      child: InkWell(
                        onTap: () {
                          _createCase(_specialization[index].id);
                        },
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(23),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF0683B8),
                                const Color(0xFF003F5A),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp,
                            ),
                          ),
                          //#GCW 09-02-2023 email change
                          child: (supportCaseAvailable && index == _specialization.length-1)?
                          ServiceButton(_specialization[index].image,
                                  _specialization[index].name,true):ServiceButton(_specialization[index].image,
                              _specialization[index].name,false),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _getSpecializations();
      _getOpenCases();
      _pendingCases();
    });

    FirebaseMessaging.instance.getToken().then((token) {
      log('Firebase TOKEN : $token');
      _storeFcmToken("$token");
    });
  }

  _getSpecializations() async {
    String email = sharedPreferences.getString("Email").toString();
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.getSpecializations;

    log('url--> $url');
    try {
      final response = await http.get(Uri.parse(url));
      log('getSpecialization response status--> ${response.statusCode}');
      log('getSpecialization response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _specialization.clear();
          for (Map array in jsonData['data'] as List) {
            SpecializationModel specializationModel = SpecializationModel(
                array['id'].toString(),
                array['name'],
                array['description'],
                array['image']);
            _specialization.add(specializationModel);
          }
          //#GCW 09-02-2023 email change
          // 26-10-2022 | Create one more speciality in doctor side for this user only : doctor@vsod.io and name that speciality : Support | GWC
          if (email == "doctorv@vsod.io") {
            supportCaseAvailable = true;
            _specialization.add(SpecializationModel("17", "Support", "_",
                _specialization[_specialization.length - 1].image));
          }
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
      log("getSpecializations Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  _getOpenCases() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    final url = AppConstants.doctorOpenCases;

    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getOpenCases response status--> ${response.statusCode}');
      log('getOpenCases response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          openCase = jsonData['data'].length != 0
              ? jsonData['data'].length.toString()
              : '0';
          log('Open Case ==> $openCase');
          setState(() {});
        } else {
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getOpenCases Error--> Error:-$e stackTrace:-$s");
    }
  }

  _pendingCases() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    final url = AppConstants.doctorPendingCases;

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
          pendingCase = jsonData['data'].length != 0
              ? jsonData['data'].length.toString()
              : '0';
          log('Pending Cases ==> $pendingCase');
          setState(() {});
        } else {
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getPendingCases Error--> Error:-$e stackTrace:-$s");
    }
  }

  _createCase(String id) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorCreateCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"specialization_id": '$id'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('getSpecialization response status--> ${response.statusCode}');
      log('getSpecialization response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Question1Screen(
                  caseId: jsonData['data']!['case_id'].toString()),
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
      log("getSpecializations Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  _storeFcmToken(String fcmToken) async {
    final url = AppConstants.STORE_FCM_TOKEN;

    log('url--> $url');

    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"fcm_token": '$fcmToken'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), body: body, headers: headers);

      log('storeFCM response body--> ${response.body}');
    } catch (e, s) {
      log("doctorAgoraRtcToken Error--> Error:-$e stackTrace:-$s");
    }
  }
}


//#GCW 09-02-2023 email change
// 26-10-2022 | Create one more speciality in doctor side for this user only : doctor@vsod.io and name that speciality : Support | GWC
ServiceButton(String endpoint, String name, bool supportButton) {
  print("ATIN TEST $name : $supportButton");
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Container(
        child:supportButton?Image(
          image: AssetImage(AppImages.settingsIcon),
          height: 45,
          width: 45,
          fit: BoxFit.contain,
          color: Colors.white,
        ): Image.network(
          AppConstants.baseUrl + endpoint,
          height: 45,
          width: 45,
          fit: BoxFit.contain,
          color: Colors.white,
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: 8),
        child: Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
              fontWeight: FontWeight.w400,
              letterSpacing: 0.4,
              color: Colors.white,
              fontSize: 12),
        ),
      )
    ],
  );
}


//#GCW 09-02-2023 email change
// ExtraCustomServiceButton(SharedPreferences sharedPreferences) {
//   String email = sharedPreferences.getString("Email").toString();
//   if (email == "doctorv@vsod.io") {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           child: Image(
//             image: AssetImage(AppImages.settingsIcon),
//             height: 45,
//             width: 45,
//             fit: BoxFit.contain,
//             color: Colors.white,
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.only(top: 8),
//           child: Text(
//             "Support",
//             textAlign: TextAlign.center,
//             style: GoogleFonts.roboto(
//                 fontWeight: FontWeight.w400,
//                 letterSpacing: 0.4,
//                 color: Colors.white,
//                 fontSize: 12),
//           ),
//         )
//       ],
//     );
//   } else {
//     return Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             child: Container(color: Colors.transparent),
//           )
//         ]);
//   }
// }
