import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/model/NotificationModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';

import '../../utils/utils.dart';

class NotificationScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NotificationState();
}

class _NotificationState extends State<NotificationScreen> {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;
  //var _profileImage;
  List<NotificationModel> _notificationList = <NotificationModel>[];

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
            Container(
              color: AppColors.headerColor,
              child: Container(
                margin: EdgeInsets.only(top: 49, bottom: 15),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 15),
                        child: Image.asset(
                          AppImages.backArrow,
                          height: 26,
                          width: 26,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "Notification",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.15, color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                    /*Container(
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
                          : Image.asset(
                              AppImages.defaultProfile,
                              height: 34,
                              width: 34,
                            ),
                    ),*/
                  ],
                ),
              ),
            ),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 10),
                  child: ListView.builder(
                      itemCount: _notificationList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: Card(
                            margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            elevation: 3,
                            shadowColor: Colors.black.withOpacity(0.45),
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    child: Text(
                                      '${_notificationList[index].title}',
                                      maxLines: 2,
                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 3),
                                    child: Text(
                                      DateFormat('dd-MMM-yyyy kk:mm').format(DateTime.parse(_notificationList[index].createdAt)),
                                      style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xFF747474),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      //_profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
      _getNotification();
      setState(() {});
    });
  }

  _getNotification() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.notification;

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
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _notificationList.clear();
          for (Map array in jsonData['data'] as List) {
            NotificationModel notificationModel = NotificationModel(array['id'].toString(), array['title'], array['created_at']);
            _notificationList.add(notificationModel);
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
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("getOpenCases Error--> Error:-$e stackTrace:-$s");
    }
  }
}
