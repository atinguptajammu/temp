

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';
import '../utils/assets.dart';

class CommonQuestionHeader extends StatelessWidget{

  CommonQuestionHeader({
    Key? key,
   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerColor,
      child: Container(
        margin: EdgeInsets.only(top: 49, bottom: 20),
        child: Row(
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
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(right: 40),
                child: Text(
                  "Questionnaire",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Colors.white, fontSize: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}