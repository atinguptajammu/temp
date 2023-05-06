import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/model/StateModel.dart';
import 'package:vsod_flutter/model/doctor_login_model.dart';
import 'package:vsod_flutter/model/forget_passwod_model.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/navigation_utils/routes.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';

import '../utils/utils.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSpecialistSelected = false.obs;
  Rx<StateModel> stateModel = StateModel().obs;
  final formLoginKey = GlobalKey<FormState>();
  final formForgetPasswordKey = GlobalKey<FormState>();
  Rx<DoctorLoginModel> doctorLoginModel = DoctorLoginModel().obs;

  TextEditingController emailController = TextEditingController();
  TextEditingController forgetEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late SharedPreferences sharedPreferences;
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    getState();
    getPreFilledData();
  }

  Future<void> getDoctorLogin(
      {required BuildContext context,
      required String email,
      required String password,
      required String type}) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    sharedPreferences.setString("PreFilledEmail", email);
    sharedPreferences.setString("PreFilledPassword", password);
    sharedPreferences.setString("PreFilledType", type.toLowerCase());

    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    isLoading.value = true;
    final url = AppConstants.loginApi;

    final body = {
      "email": email,
      "password": password,
      "type": type.toLowerCase(),
    };

    log('url--> $url');
    log('body--> $body');
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getDoctorLogin response status--> ${response.statusCode}');
      log('getDoctorLogin response body--> ${response.body}');

      if (response.statusCode == 200) {
        final result = DoctorLoginModel.fromJson(json.decode(response.body));
        if (result.status?.error == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          doctorLoginModel.value = result;
          if (type == AppStrings.doctor) {
            sharedPreferences.setBool("isLogin", true);
            sharedPreferences.setString("LoginType", type.toString());
            sharedPreferences.setString(
                "Bearer Token", result.data!.first.token!.toString());
            sharedPreferences.setString(
                "UserId", result.data!.first.user!.id!.toString());
            sharedPreferences.setString(
                "FirstName", result.data!.first.user!.firstName!.toString());
            sharedPreferences.setString(
                "LastName", result.data!.first.user!.lastName!.toString());
            sharedPreferences.setString(
                "Email", result.data!.first.user!.email!.toString());
            sharedPreferences.setString(
                "MobileNo", result.data!.first.user!.mobile!.toString());
            sharedPreferences.setString(
                "TimeZone", result.data!.first.user!.timezone!.toString());
            sharedPreferences.setString(
                "ClinicName", result.data!.first.user!.clinicName!.toString());
            sharedPreferences.setString(
                "ProfilePicture",
                result.data!.first.user!.profilePicture != null
                    ? result.data!.first.user!.profilePicture!.toString()
                    : '');
            Get.offNamed(Routes.doctorDashboard);
          } else {
            sharedPreferences.setBool("isLogin", true);
            sharedPreferences.setString("LoginType", type.toString());
            sharedPreferences.setString(
                "Bearer Token", result.data!.first.token!.toString());
            sharedPreferences.setString(
                "UserId", result.data!.first.user!.id!.toString());
            sharedPreferences.setString(
                "FirstName", result.data!.first.user!.firstName!.toString());
            sharedPreferences.setString(
                "LastName", result.data!.first.user!.lastName!.toString());
            sharedPreferences.setString(
                "Email", result.data!.first.user!.email!.toString());
            sharedPreferences.setString(
                "TimeZone", result.data!.first.user!.timezone!.toString());
            sharedPreferences.setBool(
                "Eligible", result.data!.first.user!.eligible!);
            if (result.data!.first.user!.specialization != null) {
              sharedPreferences.setString("Specialization",
                  result.data!.first.user!.specialization!.name!);
            } else {
              sharedPreferences.setString("Specialization", "");
            }

            Get.offNamed(Routes.specialistHomepage);
          }
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Fluttertoast.showToast(
              msg: result.status?.message?.first.toString() ?? "");
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      }
    } catch (e, s) {
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("getDoctorLogin Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  Future<void> getForgetPasswordService(
      {required BuildContext context, required String email}) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    final url = AppConstants.forgetPassword;
    final body = {
      "email": email,
    };
    log('url--> $url');
    log('body--> $body');
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getForgetPasswordService response status--> ${response.statusCode}');
      log('getForgetPasswordService response body--> ${response.body}');
      if (response.statusCode == 200) {
        final result = ForgetPassword.fromJson(json.decode(response.body));
        if (result.status?.error == false) {
          Get.toNamed(Routes.login);
          Get.snackbar("Successful", "Check Email",
              snackPosition: SnackPosition.BOTTOM);
        } else {
          Get.offNamed(Routes.login);
          Get.snackbar("Faield", "Something Wrong",
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {}
    } catch (e, s) {
      log("getForgetPasswordService Error--> Error:-$e stackTrace:-$s");
    }
  }

  Future<void> getState() async {
    isLoading.value = true;
    final url = AppConstants.getStates;
    log('State getItemSave url--> $url');
    try {
      final response = await http.get(Uri.parse(url));
      log('State response--> $response');
      log('State response--> statusCode:-${response.statusCode}');
      log('State response--> body:-${response.body}');
      if (response.statusCode == 200) {
        final result = StateModel.fromJson(json.decode(response.body));
        if (result.status?.error == false) {
          stateModel.value = result;
        } else {}
      } else {}
    } catch (e, s) {
      log("Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  Future<void> getPreFilledData() async {
    emailController.text =
        (sharedPreferences.getString("PreFilledEmail") ?? "");
    passwordController.text =
        (sharedPreferences.getString("PreFilledPassword")) ?? "";
    isSpecialistSelected.value =
        sharedPreferences.getString("PreFilledType") == "specialist"
            ? true
            : false;
  }
}
