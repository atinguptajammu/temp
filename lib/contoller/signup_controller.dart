import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import "package:http/http.dart" as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/model/clinic_register_model.dart';
import 'package:vsod_flutter/model/specialist_register_model.dart';
import 'package:vsod_flutter/model/specialization_model.dart';
import 'package:vsod_flutter/model/timezone_model.dart';
import 'package:vsod_flutter/utils/app_constants.dart';

import '../utils/app_string.dart';
import '../utils/navigation_utils/routes.dart';

class SignUpController extends GetxController {
  RxString selectSpecialistStateId = ''.obs;
  RxString selectClientStateId = ''.obs;
  RxString selectSpecialization = ''.obs;
  RxString selectTimeZoneClient = ''.obs;
  RxString selectTimeZoneSpecialist = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isSpecialistSelected = false.obs;
  RxBool isCheckedTermCondition = true.obs;

  Rx<SpecializationsModel> specializationModel = SpecializationsModel().obs;
  Rx<ClinicRegisterModel> clinicRegisterModel = ClinicRegisterModel().obs;
  Rx<SpecialistRegisterModel> specialistRegisterModel = SpecialistRegisterModel().obs;
  Rx<TimezoneModel> timezoneModel = TimezoneModel().obs;

  RxList<String> timezoneList = <String>[].obs;

  TextEditingController createPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  ///Clinic Controllers
  TextEditingController clinicMyPetClinicController = TextEditingController();
  TextEditingController clinicMobileNumberController = TextEditingController();
  TextEditingController clinicFirstNameController = TextEditingController();
  TextEditingController clinicLastNameController = TextEditingController();
  TextEditingController clinicEmailController = TextEditingController();
  TextEditingController clinicAddressController = TextEditingController();

  ///Specialist Controller
  TextEditingController specialistFirstNameController = TextEditingController();
  TextEditingController specialistLastNameController = TextEditingController();
  TextEditingController specialistEmailController = TextEditingController();
  TextEditingController specialistMobileNumberController = TextEditingController();
  TextEditingController specialistAddressController = TextEditingController();
  TextEditingController specialistCreateController = TextEditingController();
  TextEditingController specialistConfirmController = TextEditingController();
  TextEditingController specialistEducationConfirmController = TextEditingController();
  TextEditingController specialistDegreeConfirmController = TextEditingController();
  TextEditingController specialistLicenceController = TextEditingController();

  late SharedPreferences sharedPreferences;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    isLoading.value = true;
    await getSpecialization();
    await getTimeZone();
    isLoading.value = false;
  }

  ///Specialization Api Call
  Future<void> getSpecialization() async {
    isLoading.value = true;
    final url = AppConstants.specializationAPI;
    log('State getItemSave url--> $url');
    try {
      final response = await http.get(Uri.parse(url));
      log('State response--> $response');
      log('State response--> statusCode:-${response.statusCode}');
      log('State response--> body:-${response.body}');
      if (response.statusCode == 200) {
        final result = SpecializationsModel.fromJson(json.decode(response.body));
        if (result.status?.error == false) {
          specializationModel.value = result;
          specializationModel.refresh();
        } else {}
      } else {}
    } catch (e, s) {
      log("Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  ///Timezone Api Call
  Future<void> getTimeZone() async {
    final url = AppConstants.timezone;
    log('TimeZone getItemSave url--> $url');
    try {
      final response = await http.get(Uri.parse(url));
      log('TimeZone response--> ${response}');
      log('TimeZone response--> statusCode:-${response.statusCode}');
      log('TimeZone response--> body:-${response.body}');
      if (response.statusCode == 200) {
        final TimezoneModel result = TimezoneModel.fromJson(json.decode(response.body));

        if (result.status?.error == false) {
          timezoneModel.value = result;

          final data = timezoneModel.value.data?.americaNewYork ?? "Something wrong";

          print("dataaa--->> ${data}");
          timezoneList.add(
            result.data?.americaAnchorage ?? "",
          );
          timezoneList.add(
            result.data?.americaChicago ?? "",
          );
          timezoneList.add(
            result.data?.americaDenver ?? "",
          );
          timezoneList.add(
            result.data?.americaLosAngeles ?? "",
          );
          timezoneList.add(
            result.data?.pacificHonolulu ?? "",
          );
          timezoneList.add(
            result.data?.americaNewYork ?? "",
          );

          print("timezoneList.length--> ${timezoneList.length}");
          timezoneList.refresh();
          timezoneModel.refresh();
        } else {
          Fluttertoast.showToast(msg: result.status?.message?.first.toString() ?? "");
        }
      } else {}
    } catch (e, s) {
      print("Error--> Error:-$e stackTrace:-$s");
    }
  }

  ///Clinic Register Api Call
  Future<void> getRegisterClinic({
    required String firstNameClinic,
    required String lastNameClinic,
    required String passwordClinic,
    required String mobileClinic,
    required String stateIdClinic,
    required String cityNameClinic,
    required String emailClinic,
    required String typeClinic,
    required String clinicName,
    required String clinicAddress,
  }) async {
    isLoading.value = true;
    final url = AppConstants.registerApi;

    final body = {
      'first_name': firstNameClinic,
      'last_name': lastNameClinic,
      'password': passwordClinic,
      'mobile': mobileClinic,
      'state_id': stateIdClinic,
      'city_name': cityNameClinic,
      'email': emailClinic,
      'type': typeClinic,
      'clinic_name': clinicName,
      'address': clinicAddress
    };

    log('url--> $url');
    log('body--> $body');

    print("Boddyyyy---> ${body}");
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getRegisterClinic response status--> ${response.statusCode}');
      log('getRegisterClinic response body--> ${response.body}');
      if (response.statusCode == 200) {
        final result = ClinicRegisterModel.fromJson(json.decode(response.body));

        if (result.status?.error == false) {
          clinicRegisterModel.value = result;
          clearClinicController();

          Fluttertoast.showToast(msg: 'You are successfully registered.');
          clinicRegisterModel.refresh();
        } else {
          Fluttertoast.showToast(msg: clinicRegisterModel.value.status?.message.toString() ?? "");
        }
      } else {}
    } catch (e, s) {
      log("getRegisterClinic Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  ///Specialist Register Api Call
  Future<void> getRegisterSpecialist({
    required String firstNameSpecialization,
    required String lastNameSpecialization,
    required String specializationId,
    required String passwordSpecialization,
    required String mobileSpecialization,
    required String stateIdSpecialization,
    required String cityNameSpecialization,
    required String emailSpecialization,
    required String typeSpecialization,
    required String educationSpecialization,
    required String degreeSpecialization,
    required String licenseSpecialization,
    required String addressSpecialization,
  }) async {
    isLoading.value = true;
    final url = AppConstants.registerApi;

    final body = {
      'first_name': firstNameSpecialization,
      'last_name': lastNameSpecialization,
      'specialization_id': specializationId,
      'password': passwordSpecialization,
      'mobile': mobileSpecialization,
      'state_id': stateIdSpecialization,
      'city_name': cityNameSpecialization,
      'email': emailSpecialization,
      'type': typeSpecialization,
      'education': educationSpecialization,
      'degree': degreeSpecialization,
      'license': licenseSpecialization,
      'address': addressSpecialization,
    };

    log('url--> $url');
    log('body--> $body');
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getRegisterClinic response status--> ${response.statusCode}');
      log('getRegisterClinic response body--> ${response.body}');
      if (response.statusCode == 200) {
        final result = SpecialistRegisterModel.fromJson(json.decode(response.body));

        if (result.status?.error == false) {
          specialistRegisterModel.value = result;
          clearSpecialistController();
          // Get.showSnackbar(GetSnackBar(
          //   title: 'Welcome ${clinicRegisterModel.value.data?.first.user?.firstName ?? ""}',
          // ));

          sharedPreferences.setBool("isLogin", true);
          sharedPreferences.setString("LoginType", AppStrings.specialist);
          sharedPreferences.setString("Bearer Token", result.data!.first.token!.toString());
          sharedPreferences.setString("UserId", result.data!.first.user!.id!.toString());
          sharedPreferences.setString("FirstName", result.data!.first.user!.firstName!.toString());
          sharedPreferences.setString("LastName", result.data!.first.user!.lastName!.toString());
          sharedPreferences.setString("Email", result.data!.first.user!.email!.toString());
          sharedPreferences.setString("MobileNo", result.data!.first.user!.mobile!.toString());

          Get.offNamed(Routes.specialistHomepage);

          specialistRegisterModel.refresh();
        } else {
          Get.showSnackbar(GetSnackBar(
            title: clinicRegisterModel.value.status?.message![0].toString() ?? "",
          ));
          Fluttertoast.showToast(msg: clinicRegisterModel.value.status?.message.toString() ?? "");
        }
      } else {}
    } catch (e, s) {
      log("getRegisterClinic Error--> Error:-$e stackTrace:-$s");
    }

    isLoading.value = false;
  }

  ///Clear Clinic TextForm Field Controllers
  clearClinicController() {
    clinicMyPetClinicController.clear();
    clinicMobileNumberController.clear();
    clinicFirstNameController.clear();
    clinicLastNameController.clear();
    clinicEmailController.clear();
    clinicAddressController.clear();
    createPasswordController.clear();
    confirmPasswordController.clear();
  }

  ///Clear Specialist TextForm Field Controllers
  clearSpecialistController() {
    specialistFirstNameController.clear();
    specialistLastNameController.clear();
    specialistEmailController.clear();
    specialistMobileNumberController.clear();
    specialistAddressController.clear();
    specialistCreateController.clear();
    specialistConfirmController.clear();
    specialistEducationConfirmController.clear();
    specialistDegreeConfirmController.clear();
    specialistLicenceController.clear();
  }
}
