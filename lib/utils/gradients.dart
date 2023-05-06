import 'package:flutter/material.dart';
import 'package:vsod_flutter/utils/app_colors.dart';

class Gradients {
  static LinearGradient primary() {
    return const LinearGradient(
        colors: [
          AppColors.topLinearColor,
          AppColors.bottomLinearColor,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.2, 1.0]);
  }
}
