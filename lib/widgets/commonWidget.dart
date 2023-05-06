import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

commonTextView({title, textColor = Colors.black, fontSize = 16, fontWeight = FontWeight.w600, textAlign = TextAlign.start}) {
  return Text(
    title,
    textAlign: textAlign,
    style: GoogleFonts.roboto(
      color: textColor,
      fontSize: double.parse(fontSize.toString()),
      fontWeight: fontWeight,
    ),
  );
}

commonTextView2({title, textColor = Colors.black, fontSize = 16, fontWeight = FontWeight.w600, textAlign = TextAlign.start}) {
  return Text(
    title,
    textAlign: textAlign,
    style: GoogleFonts.roboto(
      color: textColor,
      fontSize: double.parse(fontSize.toString()),
      fontWeight: fontWeight,
      decoration: TextDecoration.underline,
    ),
  );
}
