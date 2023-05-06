import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';


class AnimDialog {
  static Future<void> showLoadingDialog(BuildContext context, GlobalKey key, String message)  {
    return showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      //barrierColor: Colors.white,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          //for disable hide dialog on device back button press
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: AlertDialog(
              elevation: 0,
              //insetPadding: EdgeInsets.symmetric(horizontal: 120),
              key: key,
              shape: CircleBorder(),
              backgroundColor: Colors.transparent,
              //contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              content: Builder(
                builder: (context) {
                  return Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    child: Container(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(strokeWidth: 5,backgroundColor: Colors.white,),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      animationType: DialogTransitionType.fade,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 500),
    );
  }


  static var isLoaderVisible = false;

  static void showLoadingDialog1(BuildContext context) {
    isLoaderVisible = true;
    showAnimatedDialog(
      context: context,
      barrierDismissible: false,
      //barrierColor: Colors.white,
      builder: (BuildContext context) {
        return new WillPopScope(
          onWillPop: () async => false,
          //for disable hide dialog on device back button press
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: AlertDialog(
              elevation: 0,
              //insetPadding: EdgeInsets.symmetric(horizontal: 120),
              shape: CircleBorder(),
              backgroundColor: Colors.transparent,
              content: Builder(
                builder: (context) {
                  return Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    child: Container(
                      height: 35,
                      width: 35,
                      child: CircularProgressIndicator(strokeWidth: 5,backgroundColor: Colors.white,),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
      animationType: DialogTransitionType.fade,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 500),
    );
  }

  static void dismissLoadingDialog(BuildContext context) {
    if (isLoaderVisible) {
      isLoaderVisible = false;
      Navigator.of(context).pop();
    }
  }

}

// final GlobalKey<State> _key = new GlobalKey<State>();  TODO first define global key for show and hide dialog in screen
// AnimDialog.showLoadingDialog(context, _key, "Loading..."); TODO display dialog
// Navigator.of(_key.currentContext, rootNavigator: true).pop();  TODO call this to any screen for hide dialog
