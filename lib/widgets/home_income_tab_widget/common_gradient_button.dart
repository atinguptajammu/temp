import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class HomeCommonGradientBottom extends StatelessWidget {
  HomeCommonGradientBottom({
    Key? key,
    required this.title,
    required this.onTap,
    this.gradiantColor1 = AppColors.gradientRed1,
    this.gradiantColor2 = AppColors.gradientRed2,
  }) : super(key: key);

  Color gradiantColor1;
  Color gradiantColor2;
  String title;
  VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [gradiantColor1, gradiantColor2],
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
