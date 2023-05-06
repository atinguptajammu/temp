import 'package:flutter/material.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class CommonText extends StatelessWidget {
  final String titleText;
  final double fontSize;

  const CommonText({Key? key, required this.titleText, this.fontSize = 13.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      titleText,
      style: TextStyle(color: AppColors.topLinearColor, fontWeight: FontWeight.w600, fontSize: fontSize),
    );
  }
}
