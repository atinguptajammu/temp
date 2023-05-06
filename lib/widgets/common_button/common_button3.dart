import 'package:flutter/material.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class CommonButton3 extends StatelessWidget {
  final double height;
  final double width;
  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;
  IconData iconData;
  final String? buttonName;
  final VoidCallback? onTap;
  Color textColor;
  Color iconColor;
  Color backgroundColor;

  CommonButton3({
    Key? key,
    this.height = 55,
    this.width = double.maxFinite,
    this.buttonName,
    this.onTap,
    this.iconColor = Colors.black,
    this.iconData = Icons.arrow_forward,
    this.topPadding = 8.0,
    this.bottomPadding = 8.0,
    this.textColor = Colors.black,
    this.backgroundColor = AppColors.whiteColor,
    this.leftPadding = 8.0,
    this.rightPadding = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding, bottom: bottomPadding, top: topPadding),
      child: SizedBox(
        height: 40,
        width: width * 0.6,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 6), // Shadow position
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  buttonName ?? "",
                  style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
                ),
              )),
        ),
      ),
    );
  }
}
