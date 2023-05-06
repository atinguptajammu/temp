
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import '../widgets/ToastMessage.dart';

class Utils {
  static void dismissKeyboard(BuildContext context) => FocusScope.of(context).requestFocus(FocusNode());

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<bool> isInternetAvailable(BuildContext context) async {
    bool result = await InternetConnectionChecker().hasConnection;
    if (result == true) {
      return true;
    } else {
      displayMsg(context, "No Internet Connection");
      return false;
    }
  }

  static void displayMsg(BuildContext context, String toastMsg) {
    ToastMessage.showToastMessage(
      context: context,
      message: '$toastMsg',
      duration: 3,
      backColor: Colors.red,
      position: StyledToastPosition.center,
    );
  }
}
