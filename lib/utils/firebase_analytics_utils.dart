
/// TOdo: Firebase Analytics
// import 'package:firebase_analytics/firebase_analytics.dart';
//
// class FirebaseAnalyticsUtils {
//   static late FirebaseAnalytics analytics;
//   static late FirebaseAnalyticsObserver observer;
//
//   static const String signIn = 'signIn';
//   static const String signUp = 'signUp';
//   static const String forgetPassword = 'forgetPassword';
//   static const String otp = 'otp';
//   static const String resetPassword = 'resetPassword';
//   static const String dashboard = 'dashboard';
//   static const String botMartingle = 'martingle';
//   static const String strategies = 'strategies';
//   static const String martingleStrategies = 'martingle';
//   static const String selectCoin = 'selectCoins';
//   static const String myPlans = 'myPlans';
//   static const String subscriptionRecords = 'subscriptionRecords';
//   static const String buyPlans = 'buyPlans';
//   static const String support = 'support';
//   static const String supportCreate = 'supportCreate';
//   static const String supportChatScreen = 'supportChatScreen';
//   static const String configure = 'configure';
//
//   void init() {
//     analytics = FirebaseAnalytics.instance;
//     observer = FirebaseAnalyticsObserver(analytics: analytics);
//   }
//
//   void sendCurrentScreen(String screenName) async {
//     await analytics.setCurrentScreen(
//       screenName: screenName,
//       screenClassOverride: screenName,
//     );
//   }
//
//   void sendAnalyticsEvent(String buttonClick) async {
//     await analytics.logEvent(
//       name: buttonClick,
//     );
//   }
// }
//
// ///TODO:- init
// // FirebaseAnalyticsUtils().sendCurrentScreen(FirebaseAnalyticsUtils.createTeamScreen);
// ///TODO:- onTap
// // FirebaseAnalyticsUtils().sendAnalyticsEvent(FirebaseAnalyticsUtils.termsAndConditionsScreen);
