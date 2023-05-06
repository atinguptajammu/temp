import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_string.dart';
import '../../utils/assets.dart';
import '../../utils/validation_utils.dart';
import '../../widgets/widget.dart';
import '../Doctor/doctor_notification_screen.dart';

class OtherProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OtherProfileScreenState();

  String? firstName = "";
  String? lastName = "";
  String? profileImage = "";
  String? email = "";
  String? address = "";
  String? mobile = "";
  String? specialization = "";
  String? education = "";
  String? degree = "";
  String? bio = "";
  String? timeZone = "";

  OtherProfileScreen({
    this.firstName,
    this.lastName,
    this.profileImage,
    this.email,
    this.address,
    this.mobile,
    this.specialization,
    this.timeZone,
    this.bio,
    this.education,
    this.degree,
  });
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController specializationController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController educationController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController degreeController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    emailController.text = widget.email!;
    specializationController.text = widget.specialization!;
    addressController.text = widget.address!;
    educationController.text = widget.education!;
    mobileNoController.text = widget.mobile!;
    degreeController.text = widget.degree!;
    bioController.text = widget.bio!;

    return Scaffold(
      backgroundColor: AppColors.headerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 365,
              child: Stack(
                children: [
                  Container(
                    height: 330,
                    width: double.infinity,
                    child: widget.profileImage != ""
                        ? Container(
                            child: FadeInImage.assetNetwork(
                              placeholder: AppImages.profilePlaceHolder,
                              image: AppConstants.publicImage + widget.profileImage!,
                              height: 330,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            child: Image.asset(
                              AppImages.profilePlaceHolder,
                              height: 330,
                              width: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(top: 50, bottom: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                "Profile",
                                style: GoogleFonts.roboto(fontWeight: FontWeight.w400, letterSpacing: 0.15, color: Colors.white, fontSize: 20),
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
                                height: 28,
                                width: 28,
                              ),
                            ),
                          ),
                          Container(
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
                            child: widget.profileImage != ""
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AppImages.profilePlaceHolder,
                                      image: AppConstants.publicImage + widget.profileImage!,
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
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 74,
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 14),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black.withOpacity(0.45),
                        child: Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Text(
                                  "Dr. ${widget.firstName} ${widget.lastName}",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.15,
                                    color: AppColors.textPrussianBlueColor,
                                    fontSize: 26,
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 15),
              child: Container(
                child: Column(
                  children: [
                    Container(
                      child: commonTextFormField(
                        hintText: AppStrings.emailHint,
                        labelText: AppStrings.email,
                        textFieldController: emailController,
                        leftPadding: 25.0,
                        rightPadding: 25.0,
                        enable: false,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                          hintText: AppStrings.specializationIn,
                          labelText: AppStrings.specializationIn,
                          textFieldController: specializationController,
                          leftPadding: 25.0,
                          rightPadding: 25.0,
                          validator: AppValidator.emptyValidator,
                          enable: false),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10,left: 25,right: 25),
                      child: TextFormField(
                        enabled: false,
                        obscureText: false,
                        controller: addressController,
                        maxLines: null,
                        cursorRadius: const Radius.circular(10),
                        style: TextStyle(
                          color: AppColors.white04Color,
                        ),
                        decoration: InputDecoration(
                          labelText: AppStrings.addressHint,
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
                          hintText: AppStrings.addressHint,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: Container(
                              child: commonTextFormField(
                                hintText: AppStrings.education,
                                labelText: AppStrings.education,
                                textFieldController: educationController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.emptyValidator,
                                enable: false,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Container(
                              child: commonTextFormField(
                                hintText: AppStrings.hintMobileNo,
                                labelText: AppStrings.mobileNo,
                                textFieldController: mobileNoController,
                                leftPadding: 25.0,
                                rightPadding: 25.0,
                                validator: AppValidator.emptyValidator,
                                enable: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: commonTextFormField(
                        hintText: AppStrings.degreeHint,
                        labelText: AppStrings.degreeHint,
                        textFieldController: degreeController,
                        leftPadding: 25.0,
                        rightPadding: 25.0,
                        validator: AppValidator.emptyValidator,
                        enable: false,
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 10, left: 25),
                      child: Text(
                        "Timezone",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 12,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.textFieldFocusUnderLineColor, width: 1.7)),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 25),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "${widget.timeZone != null ? widget.timeZone : ""}",
                        style: TextStyle(
                          color: AppColors.white04Color,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 10, left: 25),
                      child: Text(
                        "Biography",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontSize: 12,
                          height: 2,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(top: 5, left: 25, right: 25),
                      child: TextFormField(
                        controller: bioController,
                        readOnly: true,
                        maxLines: 3,
                        style: TextStyle(color: AppColors.white04Color),
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          hintStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white04Color,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldEnableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldFocusUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldDisableUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          errorBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.textFieldErrorUnderLineColor,
                              width: 1.7,
                            ),
                          ),
                          hintText: "Type here",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
