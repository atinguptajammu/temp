import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/assets.dart';
import '../../utils/utils.dart';
import '../../widgets/AnimDialog.dart';
import '../../widgets/ToastMessage.dart';
import '../Doctor/doctor_notification_screen.dart';
import 'SpecialistProfileScreen.dart';

class AccountDetailsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  String? apiToken;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late SharedPreferences sharedPreferences;
  var _profileImage;

  TextEditingController accountNumberController = new TextEditingController();
  TextEditingController confirmAccountNumberController = new TextEditingController();
  TextEditingController routingNumberController = new TextEditingController();
  TextEditingController accountNameController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      AppImages.backArrow,
                      height: 22,
                      width: 22,
                    ),
                  ),
                ),
                Text(
                  "Account Detail",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
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
                  onTap: (){
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
                    child: _profileImage != ''
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
                            backgroundColor: AppColors.appBackGroundColor.withOpacity(0.3),
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
      body: Container(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Text(
                  "Account Detail",
                  style: GoogleFonts.roboto(
                    color: AppColors.appBackGroundColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 35,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: accountNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    decoration: InputDecoration(
                      labelText: "Account Number",
                      contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      hintText: "*****************",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: confirmAccountNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    decoration: InputDecoration(
                      labelText: "Confirm Account Number",
                      contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      hintText: "*****************",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: routingNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    decoration: InputDecoration(
                      labelText: "Routing Number(Branch Code)",
                      contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      hintText: "*****************",
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: accountNameController,
                    keyboardType: TextInputType.text,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    ],
                    decoration: InputDecoration(
                      labelText: "Account Nickname",
                      contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackColor,
                        fontSize: 12,
                      ),
                      hintStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.darkDescriptionColor, width: 1.7),
                      ),
                      hintText: "Name",
                    ),
                  ),
                ),
                SizedBox(height: 50),
                InkWell(
                  onTap: () {
                    if (accountNumberController.text.isEmpty) {
                      ToastMessage.showToastMessage(
                        context: context,
                        message: "Please enter account number",
                        duration: 3,
                        backColor: Colors.red,
                        position: StyledToastPosition.center,
                      );
                    } else if (confirmAccountNumberController.text.isEmpty) {
                      ToastMessage.showToastMessage(
                        context: context,
                        message: "Please confirm account number",
                        duration: 3,
                        backColor: Colors.red,
                        position: StyledToastPosition.center,
                      );
                    } else if (confirmAccountNumberController.text != accountNumberController.text) {
                      ToastMessage.showToastMessage(
                        context: context,
                        message: "Account numbers not match",
                        duration: 3,
                        backColor: Colors.red,
                        position: StyledToastPosition.center,
                      );
                    } else if (routingNumberController.text.isEmpty) {
                      ToastMessage.showToastMessage(
                        context: context,
                        message: "Please enter routing name(branch code)",
                        duration: 3,
                        backColor: Colors.red,
                        position: StyledToastPosition.center,
                      );
                    } else if (accountNameController.text.isEmpty) {
                      ToastMessage.showToastMessage(
                        context: context,
                        message: "Please enter account nickname",
                        duration: 3,
                        backColor: Colors.red,
                        position: StyledToastPosition.center,
                      );
                    } else {
                      _setAccountDetail(
                        apiToken!,
                        accountNumberController.text.toString(),
                        routingNumberController.text.toString(),
                        accountNameController.text.toString(),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    height: 36,
                    width: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.gradientBlue1, AppColors.gradientBlue2],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Register Account",
                        style: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

    _profileImage = (sharedPreferences.getString("ProfilePicture")) ?? "";

    _getAccountDetail(apiToken!, true);
    setState(() {});
  }

  _getAccountDetail(String token, bool isShow) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    isShow ? AnimDialog.showLoadingDialog(context, _key, "Loading...") : null;
    final url = AppConstants.specialistGetAccountDetail;
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
      log('getAccountDetail response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          var data = jsonData['data'] as List;

          if (data.length > 0) {
            var item = data[0];

            accountNumberController.text = item['account_number'] != null ? item['account_number'] : "";
            confirmAccountNumberController.text = item['account_number'] != null ? item['account_number'] : "";
            routingNumberController.text = item['branch_code'] != null ? item['branch_code'] : "";
            accountNameController.text = item['account_name'] != null ? item['account_name'] : "";
          }

          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getAccountDetail Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  _setAccountDetail(String token, String accountNumber, String routingName, String accountName) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    final url = AppConstants.specialistSetAccountDetail;
    log('url--> $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "account_number": accountNumber,
          "branch_code": routingName,
          "account_name": accountName,
        }),
      );
      log('getAccountDetail response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black,
            position: StyledToastPosition.center,
          );

          Navigator.pop(context);

          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("getAccountDetail Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }
}
