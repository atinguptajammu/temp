import 'package:get/get.dart';
import 'package:vsod_flutter/screens/Doctor/DoctorDashBoardScreen.dart';
import 'package:vsod_flutter/screens/auth/forget_password_screen.dart';
import 'package:vsod_flutter/screens/auth/login_screen.dart';
import 'package:vsod_flutter/screens/auth/need_help_screen.dart';
import 'package:vsod_flutter/screens/auth/signup/sign_up_screen.dart';
import 'package:vsod_flutter/screens/splash_screen.dart';
import 'package:vsod_flutter/screens/specialist/home/specialist_home_screen.dart';

mixin Routes {
  static const defaultTransition = Transition.rightToLeft;


  // get started
  static const String splash = '/splash';
  static const String doctorDashboard = '/doctorDashboard';
  static const String specialistHomepage = '/specialist_home';
  static const String login = '/login_screen';
  static const String needHelp = '/need_help_screen';
  static const String signUpScreen = '/sign_up_screen';
  static const String forgetPassword = '/forget_password_screen';


  static List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: splash,
      page: () => SplashScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: specialistHomepage,
      page: () => SpecialistHomeScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: doctorDashboard,
      page: () => DoctorDashBoardScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: login,
      page: () => LoginScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: forgetPassword,
      page: () => ForgetPasswordScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: needHelp,
      page: () => NeedHelpScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: signUpScreen,
      page: () => SignUpScreen(),
      transition: defaultTransition,
    ),
  ];
}
