import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CountDownTimer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CountDownTimerState();

  Function onFinish;
  int count;

  CountDownTimer({required this.onFinish,required this.count});
}

class _CountDownTimerState extends State<CountDownTimer> {

  void _startTimer() {
    Timer.periodic(Duration(seconds: 59), (timer) {
      if (widget.count == 0) {
        widget.onFinish();
        timer.cancel();
      } else {
        setState(() {
          widget.count--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      child: Text(
        '00:${widget.count}',
        style: GoogleFonts.roboto(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}
