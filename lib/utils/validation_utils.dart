import 'package:vsod_flutter/utils/app_string.dart';

class AppValidator {
  static String? emailValidator(String? value) {
    const Pattern pattern = AppStrings.emailPattern;
    final RegExp regex = RegExp(pattern.toString());
    if (value!.isEmpty) {
      return AppStrings.emailAddress;
    } else if (!regex.hasMatch(value)) {
      return AppStrings.emailAddress;
    }
    return null;
  }

  static String? phoneValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.enterNumber;
    } else if (value.length < AppStrings.phoneNumberLength) {
      return AppStrings.mustDigits;
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.enterPassword;
    } else if (value.length <= AppStrings.passwordLength) {
      return AppStrings.digitsPassword;
    } else {
      return null;
    }
  }

  static String? confirmPasswordValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.reEnterPassword;
    } else if (value.length <= AppStrings.passwordLength) {
      return AppStrings.digitsPassword;
    } else {
      return null;
    }
  }

  static String? nameValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.enterName;
    } else if (value.length < AppStrings.nameLength) {
      return AppStrings.digitsName;
    } else {
      return null;
    }
  }

  static String? emptyValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.emptyValidator;
    } else {
      return null;
    }
  }

  static String? yearValidator(String? value) {
    if (value!.isEmpty) {
      return AppStrings.emptyValidator;
    } else if (value.length < 4) {
      return "Year must be of 4 digits";
    }else {
      return null;
    }
  }

  ///Specialist
  static String? emptyValidatorSpecialist(String? value) {
    if (value!.isEmpty) {
      return AppStrings.emptyValidator;
    } else {
      return null;
    }
  }
}
