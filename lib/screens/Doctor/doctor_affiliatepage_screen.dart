import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_notification_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';
import 'package:vsod_flutter/widgets/widget.dart';

import '../../utils/utils.dart';
import 'doctor_profile_screen.dart';

class AffiliatePageScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AffiliatePageScreenState();
}

class _AffiliatePageScreenState extends State<AffiliatePageScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  List<String> listOfValue = ['Clinic', 'Specialist'];
  var _selectedValue;
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;

  var _profileImage;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.headerColor,
              child: Container(
                margin: EdgeInsets.only(top: 49, bottom: 20),
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
                          height: 22,
                          width: 22,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          "Affiliate",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.15, color: Colors.white, fontSize: 24),
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
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorProfileScreen(),
                          ),
                        ).then((value){_init();});
                      },
                      child: Container(
                        height: 34,
                        width: 34,
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
                        child: _profileImage != 'null'
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
              height: 55,
            ),
            Container(
              child: Text(
                "Fill Detail",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w300, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor, fontSize: 40),
              ),
            ),
            Container(
              child: Text(
                "Complete the form below to refer a friend",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w300, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor, fontSize: 20),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: commonTextFormFieldAffiliate(
                                hintText: AppStrings.firstName,
                                labelText: AppStrings.firstName,
                                textFieldController: firstNameController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.nameValidator,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: commonTextFormFieldAffiliate(
                                hintText: AppStrings.lastName,
                                labelText: AppStrings.lastName,
                                textFieldController: lastNameController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.nameValidator,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 25),
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: commonTextFormFieldAffiliate(
                                hintText: AppStrings.emailHint,
                                labelText: AppStrings.email,
                                textFieldController: emailController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.emailValidator,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: commonTextFormFieldAffiliate(
                                hintText: AppStrings.hintMobileNo,
                                labelText: AppStrings.mobileNo,
                                textFieldController: mobileController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.phoneValidator,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 25, right: 25, top: 0),
                              child: DropdownButtonFormField<String>(
                                  isExpanded: true,
                                  isDense: true,
                                  validator: (value) => value == null ? AppStrings.selectValue : null,
                                  decoration: InputDecoration(
                                    labelStyle: const TextStyle(color: Color(0xFF141414), fontSize: 16, height: 1.6),
                                    labelText: 'Referral Type',
                                    contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 6),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                                    ),
                                    disabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFF141414), width: 2),
                                    ),
                                    errorBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 2),
                                    ),
                                  ),
                                  value: _selectedValue,
                                  hint: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '-------Select-------',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF141414).withOpacity(0.37),
                                      ),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedValue = value.toString();
                                      log(_selectedValue);
                                    });
                                  },
                                  items: listOfValue.map((String val) {
                                    return DropdownMenuItem(
                                      value: val,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          val,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  }).toList()),
                            ),
                          ),
                          Expanded(
                            child: Container(),
                            flex: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 144,
                    ),
                    Container(
                      child: CommonButtonGradient(
                        height: 47,
                        width: 251,
                        fontSize: 14,
                        buttonName: AppStrings.sendDetail,
                        colorGradient1: AppColors.gradientBlue1,
                        colorGradient2: AppColors.gradientBlue2,
                        fontWeight: FontWeight.w500,
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            _submit(firstNameController.text, lastNameController.text, emailController.text, mobileController.text, _selectedValue.toString());
                          }
                        },
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

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');

    setState(() {});
  }

  _submit(String firstName, String lastName, String email, String mobileNo, String referralType) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorAffiliatePost;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"first_name": '$firstName', "last_name": '$lastName', "email": '$email', "mobile": '$mobileNo', "referral_type": '$referralType'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log('Affilliate response status--> ${response.statusCode}');
      log('Affilliate response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );
          Navigator.pop(context);
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
      log("Affilliate Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
}
