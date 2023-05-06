import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../utils/app_colors.dart';
import '../utils/assets.dart';


class WebViewScreen extends StatefulWidget {
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();

  String? url;
  String? type;

  WebViewScreen({this.url, this.type});
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Container(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            height: 50,
            color: AppColors.appBackGroundColor,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      AppImages.backArrow,
                      height: 22,
                      width: 22,
                    ),
                  ),
                ),
                Text(
                  "${widget.type}",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: AppColors.appBackGroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          child: WebView(
            initialUrl: '${widget.url}',
            javascriptMode: JavascriptMode.unrestricted,
          ),
        ),
      ),
    );
  }
}
