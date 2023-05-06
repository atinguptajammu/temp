import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_activtyhistory_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_profile_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';

import 'doctor_affiliatepage_screen.dart';
import 'doctor_cases_screen.dart';
import 'home/doctor_home_screen.dart';

class DoctorDashBoardScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorDashBoardScreenState();
}

class _DoctorDashBoardScreenState extends State<DoctorDashBoardScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int _page = 0;
  String headerTitle = 'Home';
  late SharedPreferences sharedPreferences;
  var _profileImage = "";
  var _firstName;
  var _lastName;

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
    _firstName = (sharedPreferences.getString("FirstName") ?? '');
    _lastName = (sharedPreferences.getString("LastName") ?? '');

    setState(() {});

    // await AppConstants.pusher.init(apiKey: 'd79dc069dad8d83f1c1e', cluster: 'mt1', onEvent: onEvent);
    //
    // await AppConstants.pusher.subscribe(channelName: "CaseStatus");
    // await AppConstants.pusher.connect();
  }

  void onEvent(PusherEvent event) {
    log("onEvent: $event");
  }

  String caseType = "PENDING";

  void funcViewCase(String type) {
    setState(() {
      _page = 2;
      caseType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = Container();
    switch (_page) {
      case 0:
        headerTitle = 'Home';
        child = DoctorHomeScreen(
          viewCase: funcViewCase,
        );
        break;
      case 1:
        headerTitle = 'Activity History';
        child = ActivityHistoryScreen();
        break;
      case 2:
        headerTitle = 'Cases';
        child = DoctorCasesScreen(
          caseType: caseType,
        );
        break;
    }
    return Scaffold(
      key: _key,
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
                                  fontSize: 28,
                                ),
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
                      SizedBox(
                        height: 44,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DoctorProfileScreen(),
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
                              child: _profileImage != ""
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: AppImages.defaultProfile,
                                        image: AppConstants.publicImage + _profileImage,
                                        height: 57,
                                        width: 57,
                                        fit: BoxFit.fill,
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.asset(
                                        AppImages.defaultProfile,
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
                                    style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Color(0xFF002045), fontSize: 18),
                                  ),
                                ),
                                //#GCW 31-01-2023 remove pet clinic
                                // Container(
                                //   margin: EdgeInsets.only(top: 3),
                                //   child: Text(
                                //     "Pet Clinic",
                                //     textAlign: TextAlign.left,
                                //     style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 1.5, color: Color(0xFFD6D6D6), fontSize: 14),
                                //   ),
                                // )
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
                              builder: (context) => DoctorProfileScreen(),
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
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 20),
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
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 20),
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
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AffiliatePageScreen(),
                            ),
                          );
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
                                  AppImages.settingsIcon,
                                  height: 38,
                                  width: 38,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 58),
                                child: Text(
                                  "Affiliate Page",
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, color: AppColors.textPrussianBlueColor, fontSize: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 28),
                            child: Text(
                              //#GCW 31-01-2023 change IT Team by VSOD.io
                              "Designed & Developed by VSOD.io",
                              style: GoogleFonts.roboto(fontWeight: FontWeight.w500, letterSpacing: 0.75, color: AppColors.textPrussianBlueColor, fontSize: 14),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 22),
                            child: Text(
                              "App Version 0.1.3",
                              style: GoogleFonts.roboto(fontWeight: FontWeight.w500, letterSpacing: 0.75, color: AppColors.textPrussianBlueColor, fontSize: 14),
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
      body: Container(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(bottom: 70, top: 83),
              child: child,
            ),
            Positioned(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      color: AppColors.headerColor,
                      child: Container(
                        margin: EdgeInsets.only(top: 49, bottom: 20),
                        child: Row(
                          children: [
                            _page == 0
                                ? InkWell(
                                    onTap: () {
                                      _key.currentState!.openDrawer();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Image.asset(
                                        AppImages.menuIcon,
                                        height: 22,
                                        width: 22,
                                      ),
                                    ),
                                  )
                                : InkWell(
                                    onTap: () {
                                      setState(() {
                                        _page = 0;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Image.asset(
                                        AppImages.backArrow,
                                        height: 20,
                                        width: 20,
                                      ),
                                    ),
                                  ),
                            Expanded(
                              child: Padding(
                                padding: _page == 0 ? EdgeInsets.only(left: 37.0) : EdgeInsets.only(left: 15.0),
                                child: Text(
                                  headerTitle,
                                  textAlign: _page == 0 ? TextAlign.center : TextAlign.left,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.15, color: Colors.white, fontSize: 20),
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DoctorProfileScreen(),
                                  ),
                                ).then((value) {
                                  _init();
                                });
                              },
                              child: Container(
                                height: 35,
                                width: 35,
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
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(100),
                                        child: Image.asset(
                                          AppImages.defaultProfile,
                                          height: 34,
                                          width: 34,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
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
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(0.0),
                  ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 5.0,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _page = 0;
                          });
                        },
                        child: Container(
                          child: _page == 0
                              ? Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.selectedHomeIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Home',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF003F5A),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.homeIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Home',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF809FAD),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Container(
                      height: 75,
                      width: 1,
                      color: Colors.black26,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _page = 1;
                          });
                        },
                        child: Container(
                          child: _page == 1
                              ? Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.selectedHistoryIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'History',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF003F5A),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.historyIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'History',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF809FAD),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Container(
                      height: 75,
                      width: 1,
                      color: Colors.black26,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _page = 2;
                            caseType = "PENDING";
                          });
                        },
                        child: Container(
                          child: _page == 2
                              ? Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.selectedCasesIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Cases',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF003F5A),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  height: 75,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AppImages.casesIcon,
                                        height: 28,
                                        width: 28,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Cases',
                                        style: GoogleFonts.roboto(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF809FAD),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Container(
                      height: 75,
                      width: 1,
                      color: Colors.black26,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorProfileScreen(),
                            ),
                          ).then((value) {
                            _init();
                          });
                        },
                        child: Container(
                          height: 75,
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                AppImages.profileMenuIcon,
                                height: 28,
                                width: 28,
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Profile',
                                style: GoogleFonts.roboto(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF809FAD),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onLogoutClick() async {
    log("Logout Click");
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.getKeys();
    for (String key in sharedPreferences.getKeys()) {
      if (key != "PreFilledEmail" && key != "PreFilledPassword" && key != "PreFilledType") {
        sharedPreferences.remove(key);
        Get.offAllNamed(Routes.login);
      }
    }
  }
}
