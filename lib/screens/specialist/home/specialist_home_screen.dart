import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
// import 'package:vsod_flutter/screens/specialist/AccountDetailsScreen.dart';
import 'package:vsod_flutter/screens/specialist/SpecialistProfileScreen.dart';
import 'package:vsod_flutter/screens/specialist/home/bottom_navigation/bottom_history_screen.dart';
import 'package:vsod_flutter/screens/specialist/home/bottom_navigation/bottom_nav_payment_screen.dart';
import 'package:vsod_flutter/screens/specialist/home/bottom_navigation/specialist_home_tab.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/navigation_utils/routes.dart';
import '../../../utils/utils.dart';
import '../../../widgets/AnimDialog.dart';
import '../../../widgets/ToastMessage.dart';
import '../../Doctor/doctor_notification_screen.dart';

class SpecialistHomeScreen extends StatefulWidget {
  @override
  State<SpecialistHomeScreen> createState() => _SpecialistHomeScreenState();
}

class _SpecialistHomeScreenState extends State<SpecialistHomeScreen> {
  final GlobalKey<SpecializationHomeTabState> _keyGlobal = GlobalKey();

  LoginController loginController = Get.put(LoginController());
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  String headerTitle = 'Cases';
  late SharedPreferences sharedPreferences;
  var _profileImage;
  var _firstName;
  var _lastName;
  var _specialization;

  late String apiToken;

  static List<Widget> _widgetOptions = <Widget>[];

  int _page = 0;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();

    _widgetOptions = <Widget>[
      SpecializationHomeTab(key: _keyGlobal),
      BottomNavHistoryScreen(),
      /*RatingTabScreen(),*/
      PaymentTabScreen(),
    ];

    _init();
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

    _profileImage = (sharedPreferences.getString("ProfilePicture"));
    _firstName = (sharedPreferences.getString("FirstName") ?? '');
    _lastName = (sharedPreferences.getString("LastName") ?? '');

    _getStatus(apiToken);
    _getSpecialistProfile(apiToken);

    FirebaseMessaging.instance.getToken().then((token) {
      log('Firebase TOKEN : $token');
      _storeFcmToken("$token");
    });

    setState(() {});
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

  _getStatus(String token) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    final url = AppConstants.specialistGetStatus;
    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('setStatus response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          var data = jsonData['data'] as List;
          _isAvailable = data[0]['status'] == true ? false : true;

          _keyGlobal.currentState!.methodChange(_isAvailable);

          setState(() {});
        }
      } else {
        log("Something bad happened,try again after some time.");
      }
    } catch (e, s) {
      log("setStatus Error--> Error:-$e stackTrace:-$s");
    }
  }

  _setStatus(String token) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    log('Bearer Token ==>  $token');
    final url = AppConstants.specialistSetStatus;
    log('url--> $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('setStatus response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          var data = jsonData['data'] as List;
          _isAvailable = data[0]['status'] == true ? false : true;

          _keyGlobal.currentState!.methodChange(_isAvailable);

          ToastMessage.showToastMessage(
            context: context,
            message: "Status updated.",
            duration: 3,
            backColor: Colors.green,
            position: StyledToastPosition.center,
          );
          setState(() {});
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        setState(() {});
        log("Something bad happened,try again after some time.");
      }
    } catch (e, s) {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
      setState(() {});
      log("setStatus Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getSpecialistProfile(String token) async {
    log('Bearer Token ==>  $token');

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
          var data = jsonData['data'] as List;

          if (data.length > 0) {
            var item = data[0];

            sharedPreferences.setString(
                "ProfilePicture", item['profile_picture'].toString());

            _profileImage =
                item['profile_picture'] != null ? item['profile_picture'] : "";
            _specialization = item['specialization'];

            sharedPreferences.setString(
                "Specialization", item['specialization']);
          }

          setState(() {});
        } else {
          log("Specialist Profile ==> ${jsonData['status']['message'][0].toString()}");
        }
      } else {
        log("Specialist Profile ==> Something bad happened,try again after some time.");
      }
    } catch (e, s) {
      log("getSpecialistProfile Error--> Error:-$e stackTrace:-$s");
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _page = index;
      switch (_page) {
        case 0:
          headerTitle = 'Cases';
          break;
        case 1:
          headerTitle = 'Activity History';
          break;
        /*case 2:
          headerTitle = 'Rating';
          break;*/
        case 2:
          headerTitle = 'Payment';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      backgroundColor: Colors.white,
      drawer: Container(
        width: 340,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF003F5A).withOpacity(0.65),
              const Color(0xFF4CA1C6).withOpacity(0.65),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 45,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 138),
                              child: Text(
                                "Profile",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.25,
                                    color: Colors.white,
                                    fontSize: 28),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 17),
                              child: Image.asset(
                                AppImages.closeMenu,
                                height: 22,
                                width: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 44),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SpecialistProfileScreen(),
                                ),
                              ).then((value) {
                                _init();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 27),
                              height: 57,
                              width: 57,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: _profileImage != null &&
                                      _profileImage != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            AppImages.profilePlaceHolder,
                                        image: AppConstants.publicImage +
                                            _profileImage,
                                        height: 57,
                                        width: 57,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        AppImages.profilePlaceHolder,
                                        height: 57,
                                        width: 57,
                                      ),
                                    ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 54),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    'Dr. $_firstName $_lastName',
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF002045),
                                        fontSize: 18),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 3),
                                  child: Text(
                                    "${_specialization != null ? _specialization : ""}",
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1.5,
                                        color: Color(0xFFD6D6D6),
                                        fontSize: 14),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 70,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpecialistProfileScreen(),
                            ),
                          ).then((value) {
                            _init();
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                            ),
                            color: Color(0xFF003F5A),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 27),
                                child: Image.asset(
                                  AppImages.profileIcon,
                                  height: 38,
                                  width: 38,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 58),
                                child: Text(
                                  "Profile",
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            _page = 1;
                            headerTitle = 'Activity History';
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                            ),
                            color: Color(0xFF003F5A),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 27),
                                child: Image.asset(
                                  AppImages.activityHistoryIcon,
                                  height: 38,
                                  width: 38,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 58),
                                child: Text(
                                  "Activity History",
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            _page = 2;
                            headerTitle = 'Payment';
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                            ),
                            color: Color(0xFF003F5A),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 27),
                                child: Image.asset(
                                  AppImages.tab_payment_white,
                                  height: 38,
                                  width: 38,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 58),
                                child: Text(
                                  "Payments",
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      /*SizedBox(
                        height: 6,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            Navigator.pop(context);
                            _page = 2;
                            headerTitle = 'Ratings';
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(27),
                            ),
                            color: Color(0xFF003F5A),
                          ),
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 27),
                                child: Image.asset(
                                  AppImages.tab_star,
                                  height: 38,
                                  width: 38,
                                  color: Colors.white,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 58),
                                child: Text(
                                  "Ratings",
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 22),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                      SizedBox(
                        height: 6,
                      ),
                      // InkWell(
                      //   onTap: () {
                      //     Navigator.pop(context);
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => AccountDetailsScreen(),
                      //       ),
                      //     );
                      //   },
                      //   child: Container(
                      //     margin: EdgeInsets.only(left: 15),
                      //     height: 56,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.only(
                      //         topLeft: Radius.circular(27),
                      //       ),
                      //       color: Color(0xFF003F5A),
                      //     ),
                      //     child: Row(
                      //       children: [
                      //         Container(
                      //           margin: EdgeInsets.only(left: 27),
                      //           child: Image.asset(
                      //             AppImages.tab_account_settings_white,
                      //             height: 38,
                      //             width: 38,
                      //             color: Colors.white,
                      //           ),
                      //         ),
                      //         // Container(
                      //         //   margin: EdgeInsets.only(left: 58),
                      //         //   child: Text(
                      //         //     "Account Settings",
                      //         //     style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 22),
                      //         //   ),
                      //         // ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    child: Container(
                      margin: EdgeInsets.only(left: 52),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              _onLogoutClick();
                            },
                            child: Container(
                              child: Row(
                                children: [
                                  Container(
                                    child: Image.asset(
                                      AppImages.logoutIcon,
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Text(
                                      "Logout",
                                      style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.w700,
                                          color:
                                              AppColors.textPrussianBlueColor,
                                          fontSize: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 28),
                            child: Text(
                              //#GCW 31-01-2023
                              "Designed & Developed by VSOD.io",
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.75,
                                  color: AppColors.textPrussianBlueColor,
                                  fontSize: 14),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 22),
                            child: Text(
                              "App Version 0.1.3",
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.75,
                                  color: AppColors.textPrussianBlueColor,
                                  fontSize: 14),
                            ),
                          ),
                          SizedBox(
                            height: 55,
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.homeIcon,
                height: 28,
                width: 28,
              ),
            ),
            activeIcon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.selectedHomeIcon,
                height: 28,
                width: 28,
              ),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.historyIcon,
                height: 28,
                width: 28,
              ),
            ),
            activeIcon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.selectedHistoryIcon,
                height: 28,
                width: 28,
              ),
            ),
            label: 'History',
          ),
          /*BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.casesIcon,
                height: 28,
                width: 28,
              ),
            ),
            activeIcon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.selectedCasesIcon,
                height: 28,
                width: 28,
              ),
            ),
            label: 'Rating',
          ),*/
          BottomNavigationBarItem(
            icon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.tab_payment,
                height: 28,
                width: 28,
              ),
            ),
            activeIcon: Container(
              margin: EdgeInsets.only(bottom: 5, top: 8),
              child: Image.asset(
                AppImages.tab_payment_selected,
                height: 28,
                width: 28,
              ),
            ),
            label: 'Payment',
          ),
        ],
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: IconThemeData(color: Color(0xFF003F5A)),
        selectedLabelStyle:
            GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle:
            GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.w500),
        selectedItemColor: Color(0xFF003F5A),
        backgroundColor: Color(0xffFFFFFF),
        currentIndex: _page,
        onTap: _onItemTapped,
        elevation: 0,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            height: 50,
            color: AppColors.appBackGroundColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: _page == 0,
                  child: IconButton(
                    onPressed: () {
                      _key.currentState!.openDrawer();
                    },
                    icon: Image.asset(
                      AppImages.drawerMenuIcon,
                      height: 22,
                      width: 22,
                    ),
                  ),
                ),
                Visibility(
                  visible: _page != 0,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _page = 0;
                        headerTitle = 'Cases';
                      });
                    },
                    icon: Image.asset(
                      AppImages.backArrow,
                      height: 22,
                      width: 22,
                    ),
                  ),
                ),
                Text(
                  "$headerTitle",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    child: Visibility(
                      visible: _page == 0,
                      child: FlutterSwitch(
                        activeText: "Not available",
                        inactiveText: "Available    .",
                        inactiveTextColor: Color(0xFF007536),
                        inactiveColor: Color(0xFFB2F1C8),
                        value: _isAvailable,
                        activeColor: Colors.grey,
                        activeTextColor: Colors.white,
                        valueFontSize: 10.0,
                        width: 110,
                        height: 30,
                        borderRadius: 30.0,
                        showOnOff: true,
                        onToggle: (val) {
                          _setStatus(apiToken);
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotificationScreen(),
                      ),
                    );
                  },
                  icon: Image.asset(
                    AppImages.notificationIcon,
                    width: 29,
                    height: 29,
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialistProfileScreen(),
                      ),
                    ).then((value) {
                      _init();
                    });
                  },
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(100),
                      ),
                    ),
                    child: _profileImage != null && _profileImage != ""
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: FadeInImage.assetNetwork(
                              placeholder: AppImages.profilePlaceHolder,
                              image: AppConstants.publicImage + _profileImage,
                              height: 34,
                              width: 34,
                              fit: BoxFit.fill,
                            ),
                          )
                        : CircleAvatar(
                            backgroundColor:
                                AppColors.appBackGroundColor.withOpacity(0.3),
                            backgroundImage: AssetImage(
                              AppImages.profilePlaceHolder,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ),
        backgroundColor: AppColors.appBackGroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: _widgetOptions.elementAt(_page),
      ),
    );
  }

  void _onLogoutClick() async {
    print("Logout Click");
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.getKeys();
    for (String key in sharedPreferences.getKeys()) {
      if (key != "PreFilledEmail" &&
          key != "PreFilledPassword" &&
          key != "PreFilledType") {
        sharedPreferences.remove(key);
        Get.offAllNamed(Routes.login);
      }
    }
  }
}
