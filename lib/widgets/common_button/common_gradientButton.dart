import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class CommonButtonGradient extends StatelessWidget {
  final double height;
  final double width;
  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;
  final String? buttonName;
  final VoidCallback? onTap;
  final Color textColor;
  final Color iconColor;
  final Color backgroundColor;
  final Color colorGradient1;
  final Color colorGradient2;
  final double fontSize;
  final FontWeight fontWeight;

  const CommonButtonGradient({
    Key? key,
    this.height = 55,
    this.width = double.maxFinite,
    this.buttonName,
    this.onTap,
    this.iconColor = Colors.black,
    this.topPadding = 8.0,
    this.bottomPadding = 8.0,
    this.textColor = Colors.black,
    this.backgroundColor = AppColors.whiteColor,
    this.leftPadding = 8.0,
    this.rightPadding = 8.0,
    this.colorGradient1 = Colors.transparent,
    this.colorGradient2 = Colors.transparent,
    this.fontSize = 10.0,
    this.fontWeight = FontWeight.w500
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.only(left: leftPadding, right: rightPadding, bottom: bottomPadding, top: topPadding),
      child: SizedBox(
        height: height,
        width: width,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorGradient1,
                  colorGradient2,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blackColor.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 5), // Shadow position
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Spacer(),
                Text(
                  buttonName ?? "",
                  style: GoogleFonts.roboto(
                    fontWeight: fontWeight,
                    fontSize: fontSize,
                    color: Colors.white,
                    letterSpacing: -0.17
                  ),
                ),


                const Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
