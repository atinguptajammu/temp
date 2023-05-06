import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

class CommonTitleLogo extends StatelessWidget {
  final String title;
  final bool showBackButton;
  CommonTitleLogo({Key? key, required this.title, this.showBackButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        // SizedBox(width: width, height: height * 0.1),
        // SizedBox(
        //   height: 100,
        //   width: 100,
        //   child: Image.asset(
        //     AppImages.appLogo,
        //   ),
        // ),
        // SizedBox(height: height * 0.01),
        // commonTextView(title: AppStrings.appName, fontWeight: FontWeight.bold, fontSize: 33, textColor: AppColors.whiteColor),
        // commonTextView(title: AppStrings.appFullName, fontWeight: FontWeight.w400, fontSize: 10.0, textColor: AppColors.whiteColor),
        // SizedBox(height: height * 0.04),
        // commonTextView(title: title, fontWeight: FontWeight.w300, fontSize: 30.0, textColor: AppColors.whiteColor),

        SizedBox(
          width: width,
          height: height * 0.07,
        ),

        showBackButton == true
            ? Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ],
              )
            : const SizedBox(),
        SizedBox(
          height: 100,
          width: 100,
          child: Image.asset(
            AppImages.appLogo,
          ),
        ),
        SizedBox(height: height * 0.01),
        commonTextView(title: AppStrings.appName, fontWeight: FontWeight.bold, fontSize: 33, textColor: AppColors.whiteColor),
        commonTextView(title: AppStrings.appFullName, fontWeight: FontWeight.w400, fontSize: 10.0, textColor: AppColors.whiteColor),
        SizedBox(height: height * 0.04),
        commonTextView(title: AppStrings.passwordReset, fontWeight: FontWeight.w300, fontSize: 25.0, textColor: AppColors.whiteColor),
      ],
    );
  }
}
