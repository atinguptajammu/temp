import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/contoller/login_controller.dart';
import 'package:vsod_flutter/contoller/signup_controller.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/validation_utils.dart';
import 'package:vsod_flutter/widgets/drop_down_decoration.dart';
import 'package:vsod_flutter/widgets/widget.dart';

class SignUpSpecialListWidget extends StatelessWidget {
  final LoginController _loginController = Get.find();
  final SignUpController _signUpController = Get.find();
  final GlobalKey<FormState> registerScreenKey1 = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          child: Row(
            children: [
              Expanded(
                child: commonTextFormField(
                    hintText: AppStrings.firstName,
                    labelText: AppStrings.firstName,
                    rightPadding: 25.0,
                    validator: AppValidator.emptyValidator,
                    textFieldController: _signUpController.specialistFirstNameController),
                flex: 1,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.lastName,
                  labelText: AppStrings.lastName,
                  leftPadding: 25.0,
                  rightPadding: 0.0,
                  textFieldController: _signUpController.specialistLastNameController,
                  validator: AppValidator.emptyValidator,
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(right: 25),
                child: SizedBox(
                  child: commonTextFormField(
                    textFieldController: _signUpController.specialistEmailController,
                    hintText: AppStrings.emailHint,
                    labelText: AppStrings.email,
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
                      decoration: commonDropDownDecoration(lableText: AppStrings.timeZone),
                      hint: Text(
                        '---TimeZone---',
                        style: TextStyle(color: AppColors.halfWhite),
                      ),
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 13.5,
                      ),
                      onChanged: (value) {
                        _signUpController.selectTimeZoneSpecialist.value = value.toString();
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
                )),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 50,
          child: Row(
            children: [
              _mobileNumberWidget(
                controller: _signUpController.specialistMobileNumberController,
                leftPadding: 0.0,
                rightPadding: 25.0,
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 25, top: 0),
                  child: Obx(
                    () => DropdownButtonFormField(
                      isExpanded: true,
                      validator: (value) => value == null ? AppStrings.selectValue : null,
                      decoration: commonDropDownDecoration(lableText: AppStrings.specializationIn),
                      hint: Text(
                        '---Specialization---',
                        style: TextStyle(color: AppColors.halfWhite),
                      ),
                      style: const TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 13.5,
                      ),
                      onChanged: (value) {
                        _signUpController.selectSpecialization.value = value.toString();
                        print("Vallll---> ${_signUpController.selectSpecialization.value}");
                      },
                      selectedItemBuilder: (_) {
                        return _signUpController.specializationModel.value.data!.map((e) {
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
                      items: _signUpController.specializationModel.value.data?.map((map) {
                        return DropdownMenuItem<String>(
                          value: map.id.toString(),
                          child: Text(map.name ?? "", style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 45,
          child: Row(
            children: [
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.addressHint,
                  labelText: AppStrings.addressHint,
                  rightPadding: 25.0,
                  textFieldController: _signUpController.specialistAddressController,
                  validator: AppValidator.emptyValidator,
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
                        decoration: commonDropDownDecoration(
                          lableText: AppStrings.state,
                        ),
                        hint: Text(
                          '---State---',
                          style: TextStyle(color: AppColors.halfWhite),
                        ),
                        style: const TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 13.5,
                        ),
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
                        onChanged: (value) {
                          _signUpController.selectSpecialistStateId.value = value.toString();

                          print("value.toString()---> ${value.toString()}");
                        },
                        items: _loginController.stateModel.value.data?.map((map) {
                          return DropdownMenuItem<String>(
                            value: map.id.toString(),
                            child: Text(map.name ?? "", style: const TextStyle(color: Colors.black)),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          child: Row(
            children: [
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.credentialsDegree,
                  labelText: AppStrings.credentialsDegree,
                  rightPadding: 25.0,
                  textFieldController: _signUpController.specialistDegreeConfirmController,
                  validator: AppValidator.emptyValidator,
                ),
                flex: 1,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.education,
                  labelText: AppStrings.education,
                  textFieldController: _signUpController.specialistEducationConfirmController,
                  leftPadding: 25.0,
                  rightPadding: 0.0,
                  validator: AppValidator.emptyValidator,
                ),
                flex: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _passwordField(
                _signUpController.createPasswordController,
              ),
              flex: 1,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: _confPasswordField(
                _signUpController.confirmPasswordController,
              ),
              flex: 1,
            )
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          child: Row(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: commonTextFormField(
                  hintText: AppStrings.licenceNumber,
                  labelText: AppStrings.licNumber,
                  textFieldController: _signUpController.specialistLicenceController,
                  leftPadding: 0.0,
                  rightPadding: 25.0,
                  validator: AppValidator.emptyValidatorSpecialist,
                ),
                flex: 1,
              ),
              const SizedBox(height: 10),
              const Expanded(
                flex: 1,
                child: const SizedBox(),
              )
            ],
          ),
        ),
      ],
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
        prefixText: const Text("+1 "),
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
