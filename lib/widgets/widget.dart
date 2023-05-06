import 'package:flutter/material.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/widgets/common_button.dart';
import 'package:vsod_flutter/widgets/common_text.dart';

///LoginScreen Logo
loginLogo(height, width) {
  return Container(
    height: height * 0.22,
    width: width * 0.8,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.topLinearColor, AppColors.bottomLinearColor])),
  );
}

commonTextFormField({
  textFieldController,
  bool obscureText = false,
  hintText,
  labelText,
  leftPadding = 0.0,
  rightPadding = 0.0,
  topPadding = 0.0,
  validator,
  prefixText,
  bottomPadding = 0.0,
  bool enable = true,
}) {
  return Padding(
    padding: EdgeInsets.only(left: leftPadding, right: rightPadding, top: topPadding, bottom: bottomPadding),
    child: TextFormField(
      enabled: enable,
      obscureText: obscureText,
      validator: validator,
      controller: textFieldController,
      cursorHeight: 20,
      cursorRadius: const Radius.circular(10),
      style: TextStyle(
        color: AppColors.white04Color,
      ),
      decoration: InputDecoration(
        labelText: labelText ?? "",
        prefix: prefixText,
        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 12, height: 2),
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white04Color,
        ),
        errorStyle: TextStyle(
          fontSize: 11,
          color: AppColors.redColor,
        ),
        errorMaxLines: 2,
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
        hintText: hintText,
      ),
    ),
  );
}

commonTextFormFieldPasswordChange({
  textFieldController,
  bool obscureText = false,
  hintText,
  labelText,
  leftPadding = 0.0,
  rightPadding = 0.0,
  topPadding = 0.0,
  validator,
  prefixText,
  bottomPadding = 0.0,
}) {
  return Padding(
    padding: EdgeInsets.only(left: leftPadding, right: rightPadding, top: topPadding, bottom: bottomPadding),
    child: TextFormField(
      obscureText: obscureText,
      validator: validator,
      enabled: false,
      controller: textFieldController,
      cursorHeight: 20,
      cursorRadius: const Radius.circular(10),
      style: TextStyle(
        color: AppColors.white04Color,
      ),
      decoration: InputDecoration(
        labelText: labelText ?? "",
        prefix: prefixText,
        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 12, height: 2),
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.white04Color,
        ),
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
        hintText: hintText,
      ),
    ),
  );
}

commonTextFormFieldAffiliate({
  textFieldController,
  bool obscureText = false,
  hintText,
  labelText,
  leftPadding = 0.0,
  rightPadding = 0.0,
  topPadding = 0.0,
  validator,
  prefixText,
  bottomPadding = 0.0,
}) {
  return Padding(
    padding: EdgeInsets.only(left: leftPadding, right: rightPadding, top: topPadding, bottom: bottomPadding),
    child: TextFormField(
      obscureText: obscureText,
      validator: validator,
      controller: textFieldController,
      cursorHeight: 20,
      cursorRadius: const Radius.circular(10),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF141414),
      ),
      decoration: InputDecoration(
        labelText: labelText ?? "",
        prefix: prefixText,
        contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
        labelStyle: const TextStyle(fontWeight: FontWeight.w400, color: Color(0xFF141414), fontSize: 12, height: 2),
        hintStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF141414).withOpacity(0.40),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF141414), width: 1.7),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF141414), width: 1.7),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textFieldDisableUnderLineColor, width: 1.7),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.textFieldErrorUnderLineColor, width: 1.7),
        ),
        hintText: hintText,
      ),
    ),
  );
}

titleText({@required text, fontWeight, fontSize = 16.0}) {
  return Padding(
    padding: const EdgeInsets.only(left: 12.0, right: 12, bottom: 15),
    child: Text(
      text,
      style: TextStyle(fontWeight: fontWeight, fontSize: fontSize),
      textAlign: TextAlign.center,
    ),
  );
}

showVerifyDialog(context) {
  AlertDialog alertDialog = AlertDialog(
    contentPadding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      side: const BorderSide(
        color: AppColors.topLinearColor,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    content: Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(width: 2, color: AppColors.topLinearColor),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 20, bottom: 10),
        child: Column(
          children: [
            const CommonText(
              titleText: "passwordResetSuccessful",
              fontSize: 17,
            ),
            const SizedBox(height: 20),
            const Text(
              "Reset Password Dialog",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            ),
            const Spacer(),
            CommonButton(
              height: 60,
              buttonName: AppStrings.returnToLogin,
            ),
          ],
        ),
      ),
    ),
  );
  showDialog(builder: (BuildContext context) => alertDialog, context: context);
}
