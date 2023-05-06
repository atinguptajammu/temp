import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';

class ToastMessage {
  static Future<ToastFuture> showToastMessage(
      {required BuildContext context,
      required String message,
      required int duration,
      required Color backColor,
      required StyledToastPosition position}) async {
    return showToast(
      message,
      context: context,
      animation: StyledToastAnimation.fadeScale,
      reverseAnimation: StyledToastAnimation.fadeScale,
      axis: Axis.horizontal,
      position: position != null ? position : StyledToastPosition.bottom,
      animDuration: Duration(milliseconds: 300),
      duration: Duration(seconds: duration != null ? duration : 3),
      curve: Curves.bounceInOut,
      reverseCurve: Curves.bounceIn,
      backgroundColor: backColor,
      borderRadius: BorderRadius.circular(50),
      textStyle: GoogleFonts.sen(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      textAlign: TextAlign.center,
    );
  }
}
