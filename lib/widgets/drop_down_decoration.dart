import 'package:flutter/material.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

commonDropDownDecoration({required lableText}) {
  return InputDecoration(
    contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 6),
    labelStyle: const TextStyle(color: Colors.white, fontSize: 13.3, height: 1.6),
    labelText: lableText,
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldEnableUnderLineColor, width: 1.7),
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldFocusUnderLineColor, width: 1.7),
    ),
    disabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldDisableUnderLineColor, width: 1.7),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
    ),
  );
}
