import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
import 'package:vsod_flutter/contoller/signup_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/drop_down_decoration.dart';
import 'package:vsod_flutter/widgets/widget.dart';

class SignUpClinicWidget extends StatelessWidget {
  final LoginController _loginController = Get.find();
  final SignUpController _signUpController = Get.find();
  GlobalKey<FormState> registerScreenKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Expanded(
                child: commonTextFormField(
                    hintText: "My Pet Clinic",
                    labelText: "Clinic Name",
                    leftPadding: 0.0,
                    rightPadding: 25.0,
                    validator: AppValidator.emptyValidator,
                    textFieldController: _signUpController.clinicMyPetClinicController),
                flex: 1,
              ),
              const SizedBox(height: 10),
              _mobileNumberWidget(
                controller: _signUpController.clinicMobileNumberController,
                leftPadding: 25.0,
                rightPadding: 0.0,
              ),
            ],
          ),
        ),
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _commonTextField(
                controller: _signUpController.clinicFirstNameController,
                leftPadding: 0.0,
                rightPadding: 25.0,
                hintText: AppStrings.firstName,
                labelText: AppStrings.firstName,
              ),
              const SizedBox(height: 10),
              _commonTextField(
                controller: _signUpController.clinicLastNameController,
                leftPadding: 25.0,
                rightPadding: 0.0,
                hintText: AppStrings.lastName,
                labelText: AppStrings.lastName,
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(right: 25),
                child: SizedBox(
                  child: commonTextFormField(
                    hintText: AppStrings.emailAddress,
                    labelText: AppStrings.email,
                    textFieldController: _signUpController.clinicEmailController,
                    validator: AppValidator.emailValidator,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(left: 25, top: 0),
                child: Obx(
                  () => DropdownButtonFormField(
                    isExpanded: true,
                    validator: (value) => value == null ? AppStrings.selectValue : null,
                    decoration: commonDropDownDecoration(
                      lableText: AppStrings.timeZone,
                    ),
                    hint: Text(
                      '---TimeZone---',
                      style: TextStyle(color: AppColors.halfWhite),
                    ),
                    style: const TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 13.5,
                    ),
                    onChanged: (value) {
                      _signUpController.selectTimeZoneClient.value = value.toString();
                    },
                    selectedItemBuilder: (_) {
                      return _signUpController.timezoneList.map((e) {
                        return Container(
                          child: Text(
                            e,
                            style: TextStyle(
                              color: AppColors.white04Color,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList();
                    },
                    items: _signUpController.timezoneList.map((map) {
                      return DropdownMenuItem<String>(
                        value: map,
                        child: Text(
                          map,
                          style: const TextStyle(color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 45,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.addressHint,
                  labelText: AppStrings.addressHint,
                  textFieldController: _signUpController.clinicAddressController,
                  validator: AppValidator.emptyValidator,
                  rightPadding: 25.0,
                ),
                flex: 1,
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, top: 0),
                  child: Obx(
                    () => DropdownButtonFormField(
                      isExpanded: true,
                      validator: (value) => value == null ? AppStrings.selectValue : null,
                      decoration: commonDropDownDecoration(lableText: AppStrings.state),
                      hint: Text(
                        '---State---',
                        style: TextStyle(color: AppColors.halfWhite),
                      ),
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 13.5,
                      ),
                      onChanged: (value) {
                        _signUpController.selectClientStateId.value = value.toString();
                      },
                      selectedItemBuilder: (_) {
                        return _loginController.stateModel.value.data!.map((e) {
                          return Container(
                            child: Text(
                              e.name ?? "",
                              style: TextStyle(
                                color: AppColors.white04Color,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList();
                      },
                      items: _loginController.stateModel.value.data?.map(
                        (map) {
                          return DropdownMenuItem<String>(
                            value: map.id.toString(),
                            child: Text(map.name ?? "", style: const TextStyle(color: Colors.black)),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _passwordField(
          _signUpController.createPasswordController,
        ),
        const SizedBox(height: 10),
        _confPasswordField(
          _signUpController.confirmPasswordController,
        ),
      ],
    );
  }

  _commonTextField({hintText, labelText, leftPadding, rightPadding, controller}) {
    return Expanded(
      child: commonTextFormField(
        hintText: hintText,
        labelText: labelText,
        leftPadding: leftPadding,
        rightPadding: rightPadding,
        textFieldController: controller,
        validator: AppValidator.emptyValidator,
      ),
      flex: 1,
    );
  }

  _mobileNumberWidget({controller, rightPadding = 0.0, leftPadding = 0.0}) {
    return Expanded(
      child: commonTextFormField(
        hintText: AppStrings.mobileNumberHint,
        labelText: AppStrings.mobileNo,
        textFieldController: controller,
        leftPadding: leftPadding,
        rightPadding: rightPadding,
        prefixText: const Text("+1  "),
        validator: AppValidator.phoneValidator,
      ),
      flex: 1,
    );
  }

  _passwordField(controller) {
    return SizedBox(
      child: commonTextFormField(
        hintText: AppStrings.password,
        labelText: AppStrings.password,
        obscureText: true,
        textFieldController: controller,
        validator: AppValidator.passwordValidator,
      ),
    );
  }

  _confPasswordField(controller) {
    return SizedBox(
      child: commonTextFormField(
        hintText: AppStrings.confrimPassword,
        labelText: AppStrings.confrimPassword,
        obscureText: true,
        textFieldController: controller,
        validator: AppValidator.passwordValidator,
      ),
    );
  }
}
