import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/incoming_tab.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/open_tabbar.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/shaeduled_tabbar.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:http/http.dart' as http;

import '../../../../utils/app_constants.dart';

class SpecializationHomeTab extends StatefulWidget {
  SpecializationHomeTab({Key? key}) : super(key: key);

  @override
  SpecializationHomeTabState createState() => SpecializationHomeTabState();
}

class SpecializationHomeTabState extends State<SpecializationHomeTab> {

  bool _isIncomingVisible = true;

  late SharedPreferences sharedPreferences;
  late String apiToken;


  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");


    _getStatus(apiToken);
    setState(() {});
  }


  _getStatus(String token) async {
    log('Bearer Token ==>  $token');
    final url = AppConstants.specialistGetStatus;
    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('setStatus response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          var data = jsonData['data'] as List;
          _isIncomingVisible = data[0]['status'] == true ? false : true;

          setState(() {});
        }
      } else {

        log("Something bad happened,try again after some time.");
      }
    } catch (e, s) {
      log("setStatus Error--> Error:-$e stackTrace:-$s");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.appBackGroundColor,
              ),
              height: 50,
              child: TabBar(
                indicatorColor: Colors.white,
                unselectedLabelColor: AppColors.halfWhite,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _textWidget(title: "Incoming"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _textWidget(title: "Open"),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _textWidget(title: "Scheduled"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _isIncomingVisible ? Container(height: MediaQuery.of(context).size.height - 250,width: double.infinity,) : IncomeListview(),
                  OpenTabBar(),
                  ScheduledTabBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  methodChange(bool isShow) {
    print(isShow);
    setState(() {
      _isIncomingVisible = isShow;
    });
  }

  _textWidget({required String title}) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
