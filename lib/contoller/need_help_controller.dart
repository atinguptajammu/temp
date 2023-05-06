import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/model/need_help_model.dart';
import 'package:vsod_flutter/utils/app_constants.dart';

import '../utils/utils.dart';

class NeedHelpController extends GetxController {
  RxString selectStateID = ''.obs;
  RxBool isLoading = false.obs;
  final formKeyNeedHelp = GlobalKey<FormState>();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController clinicNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController issueController = TextEditingController();

  Future<void> getNeedHelp({
    required String emailAddress,
    required String name,
    required String mobileNumber,
    required String type,
    required String issue,
    required BuildContext context,
  }) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    isLoading.value = true;
    final url = AppConstants.needHelpApi;

    final body = {
      'email': emailAddress,
      'name': name,
      'mobile': mobileNumber,
      'type': type,
      'issue': issue,
    };

    log('url--> $url');
    log('body--> ${body}');
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getNeedHelp response status--> ${response.statusCode}');
      log('getNeedHelp response body--> ${response.body}');
      if (response.statusCode == 200) {
        final result = NeedHelpModel.fromJson(json.decode(response.body));
        if (result.status?.error == false) {
          Fluttertoast.showToast(msg: result.status?.message?.first ?? "");
          clearController();
          Get.back();
          return;
        }

        Fluttertoast.showToast(msg: result.status?.message?.first ?? "");
      }
      Fluttertoast.showToast(msg: "Something Went Wrong");
    } catch (e, s) {
      log("getNeedHelp Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  void clearController() {
    firstNameController.clear();
    lastNameController.clear();
    clinicNameController.clear();
    emailController.clear();
    mobileController.clear();
    issueController.clear();
  }
}
