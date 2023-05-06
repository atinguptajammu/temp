import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsod_flutter/model/SpecialistHistoryModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/time_convert.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../Doctor/model/GetAnswerModel.dart';

class BottomNavHistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BottomNavHistoryScreenState();
}

class _BottomNavHistoryScreenState extends State<BottomNavHistoryScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late String apiToken;
  late String timeZone;
  ChangeTimeZone changeTimeZone = ChangeTimeZone();

  late SharedPreferences sharedPreferences;

  List<SpecialistHistoryModel> _activityHistoryList = <SpecialistHistoryModel>[];
  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];

  List<String> docList = [];
  int? isOpen;
  List<SpecialistHistoryModel> _activityHistoryListTemp = [];

  late String _localPath;

  CustomPopupMenuController _controller = CustomPopupMenuController();

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";


  // //#GCW 31-01-2023
  // void timezoneHelperSetup() async {
  //   var byteData = await rootBundle.load('packages/timezone/data/latest_all.tzf');
  //   initializeDatabase(byteData.buffer.asUint8List());
  // }

  @override
  void initState() {
    super.initState();
    _init();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      _activityHistoryList = _activityHistoryListTemp;
    } else {
      List<SpecialistHistoryModel> tempList = <SpecialistHistoryModel>[];

      for (SpecialistHistoryModel model in _activityHistoryListTemp) {
        if (model.firstName.toLowerCase().contains(query.toLowerCase()) || model.lastName.toLowerCase().contains(query.toLowerCase()) || model.status.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(model);
        }
      }
      _activityHistoryList = tempList;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: AppColors.borderLinearColor,
                        ),
                      ),
                      padding: EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        children: [
                          Flexible(
                            child: TextField(
                              autofocus: false,
                              cursorHeight: 25,
                              style: TextStyle(color: Colors.black87, fontSize: 16),
                              decoration: InputDecoration.collapsed(
                                hintText: "Search",
                                border: InputBorder.none,
                              ),
                              maxLines: 1,
                              onChanged: _filterSearch,
                            ),
                          ),
                          Icon(
                            Icons.search,
                            color: AppColors.blackColor.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: CustomPopupMenu(
                      arrowColor: Colors.transparent,
                      child: Container(
                        margin: EdgeInsets.only(right: 12, left: 10),
                        child: Image.asset(
                          AppImages.filterIcon,
                          height: 25,
                          width: 25,
                          fit: BoxFit.contain,
                        ),
                      ),
                      menuBuilder: () => ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: IntrinsicWidth(
                          child: Container(
                            decoration: BoxDecoration(border: Border.all(color: Color(0xFF000000).withOpacity(0.3), width: 0.5), borderRadius: BorderRadius.circular(5.0), color: Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: ["All", "Closed", "Disputed"]
                                  .map(
                                    (item) => GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      onTap: () {
                                        print("onTap = ${item}");
                                        _controller.hideMenu();
                                        if (item.toLowerCase() == "all") {
                                          _filterSearch("");
                                        }else if (item.toLowerCase() == "disputed") {
                                          _filterSearch("dispute");
                                        } else {
                                          _filterSearch(item.toLowerCase());
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(width: 0.5, color: Color(0xFF000000).withOpacity(0.3)),
                                          ),
                                          color: Colors.white,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                margin: EdgeInsets.only(left: 10),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  item,
                                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 12, color: AppColors.textPrussianBlueColor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      pressType: PressType.singleClick,
                      verticalMargin: -5,
                      controller: _controller,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return _init();
                },
                child: _activityHistoryList.length > 0
                    ? ListView.builder(
                        itemCount: _activityHistoryList.length,
                        shrinkWrap: true,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: AppColors.appBackGroundColor.withOpacity(0.2)),
                              ),
                              elevation: 10,
                              shadowColor: AppColors.appBackGroundColor.withOpacity(0.3),
                              child: InkWell(
                                onTap: () {
                                  if (_activityHistoryList[index].isOpen == "1") {
                                    setState(() {
                                      _activityHistoryList[index].isOpen = "0";
                                    });
                                  } else {
                                    setState(() {
                                      for (int i = 0; i < _activityHistoryList.length; i++) {
                                        _activityHistoryList[i].isOpen = "0";
                                      }
                                      _getAnswerList.clear();
                                      _activityHistoryList[index].isOpen = "1";
                                      _getAnswer(_activityHistoryList[index].id.toString(), index);
                                    });
                                  }
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              child: _activityHistoryList[index].profileImage != ""
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: FadeInImage.assetNetwork(
                                                        placeholder: AppImages.profilePlaceHolder,
                                                        image: AppConstants.publicImage + _activityHistoryList[index].profileImage,
                                                        height: 50,
                                                        width: 50,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: Image.asset(
                                                        AppImages.profilePlaceHolder,
                                                        height: 50,
                                                        width: 50,
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  commonTextView(
                                                    title: "Dr. ${_activityHistoryList[index].firstName} ${_activityHistoryList[index].lastName}",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  SizedBox(height: 6),
                                                  commonTextView(
                                                    //#GCW 31-01-2023 convert time Zone
                                                    title: changeTimeZone.convertTimeDT(DateTime.parse(_activityHistoryList[index].date), timeZone),//'${DateFormat('MM/dd/yyyy,').add_jm().format(convertUtcToUser(DateTime.parse(_activityHistoryList[index].date), timeZone))}',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    textColor: AppColors.darkDescriptionColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                          //#GCW 31-01-2023 Remove $49
                                          //   Container(
                                          //     child: Center(
                                          //       child: Text(
                                          //         "${_activityHistoryList[index].status == "disputed" ? "-" : ""}${'\$' + _activityHistoryList[index].amount}",
                                          //         style: TextStyle(
                                          //           fontWeight: FontWeight.w500,
                                          //           fontSize: 16,
                                          //           color: _activityHistoryList[index].status == "disputed" ? Colors.red : Colors.green,
                                          //         ),
                                          //       ),
                                          //     ),
                                          //   ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Visibility(
                                        // visible: isOpen == index,
                                        visible: _activityHistoryList[index].isOpen == "1",
                                        child: Container(
                                          child: Column(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(left: 18, right: 15),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        "Clinic Address: ",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Color(0xFF747474),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "$clinicAddress",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18, right: 15),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        "Clinic State: ",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Color(0xFF747474),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "$clinicState",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18, right: 15),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        "Creation date: ",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Color(0xFF747474),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "${creationDate != "" ? DateFormat('dd/MM/yyyy KK:mm a').format(DateTime.parse(creationDate)) : ""}",
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w500,
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18, right: 15),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              "Med. Record No.",
                                                              style: GoogleFonts.roboto(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 18,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(top: 3),
                                                            child: Text(
                                                              _getAnswerList.length > 0 ? _getAnswerList[0].answers : '',
                                                              style: GoogleFonts.roboto(
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 14,
                                                                color: Color(0xFF747474),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              "Patient Species",
                                                              style: GoogleFonts.roboto(
                                                                fontWeight: FontWeight.w500,
                                                                fontSize: 18,
                                                                color: Colors.black,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(top: 3),
                                                            child: Text(
                                                              _getAnswerList.length > 0 ? _getAnswerList[1].answers : '',
                                                              style: GoogleFonts.roboto(
                                                                fontWeight: FontWeight.w400,
                                                                fontSize: 14,
                                                                color: Color(0xFF747474),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),

                                              Container(
                                                margin: EdgeInsets.only(left: 18),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "What do you need help with?",
                                                  style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18, top: 3),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  _getAnswerList.length > 0 ? _getAnswerList[2].answers : '',
                                                  style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: Color(0xFF747474),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 15,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18),
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Attached Files",
                                                  style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18),
                                                alignment: Alignment.centerLeft,
                                                child: Container(
                                                  height: 80,
                                                  child: ListView.builder(
                                                      itemCount: docList.length,
                                                      scrollDirection: Axis.horizontal,
                                                      shrinkWrap: true,
                                                      itemBuilder: (BuildContext context, int docIndex) {
                                                        return InkWell(
                                                          onTap: () async {
                                                            PermissionStatus permissionStatus = await Permission.storage.request();
                                                            if (permissionStatus != PermissionStatus.granted) return;

                                                            _localPath = (await _findLocalPath())!;
                                                            final savedDir = Directory(_localPath);
                                                            bool hasExisted1 = savedDir.existsSync();
                                                            if (!hasExisted1) {
                                                              savedDir.create();
                                                            }
                                                            String fileAppend = DateTime.now().millisecondsSinceEpoch.toString();
                                                            String fileName = docList[docIndex].trim().substring(docList[docIndex].trim().lastIndexOf("/") + 1);

                                                            await FlutterDownloader.enqueue(
                                                              url: docList[docIndex].trim(),
                                                              savedDir: _localPath,
                                                              fileName: fileAppend + fileName,
                                                              showNotification: true,
                                                              openFileFromNotification: false,
                                                            );
                                                          },
                                                          child: Container(
                                                            child: _getAnswerList.length > 0
                                                                ? Container(
                                                              height: 70,
                                                              width: 70,
                                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                                              child: docList[docIndex].split(".").last == "jpg"
                                                                  ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(0),
                                                                child: FadeInImage.assetNetwork(
                                                                  placeholder: AppImages.defaultPlaceHolder,
                                                                  image: docList[docIndex].trim(),
                                                                  height: 70,
                                                                  width: 70,
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              )
                                                                  : docList[docIndex].split(".").last == "png"
                                                                  ? ClipRRect(
                                                                borderRadius: BorderRadius.circular(0),
                                                                child: FadeInImage.assetNetwork(
                                                                  placeholder: AppImages.defaultPlaceHolder,
                                                                  image: docList[docIndex].trim(),
                                                                  height: 70,
                                                                  width: 70,
                                                                  fit: BoxFit.contain,
                                                                ),
                                                              )
                                                                  : docList[docIndex].split(".").last == "pdf"
                                                                  ? Image.asset(
                                                                AppImages.textDocument,
                                                                height: 50,
                                                                width: 50,
                                                                fit: BoxFit.contain,
                                                              )
                                                                  : docList[docIndex].split(".").last == "doc"
                                                                  ? Image.asset(
                                                                AppImages.textDocument,
                                                                height: 50,
                                                                width: 50,
                                                                fit: BoxFit.contain,
                                                              )
                                                                  : Container(),
                                                            )
                                                                : Container(),
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(left: 18, right: 15),
                                                child: Row(
                                                  children: [
                                                    Visibility(
                                                      visible: _activityHistoryList[index].chat != "",
                                                      child: Expanded(
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              await launch(_activityHistoryList[index].chat);
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  child: Text(
                                                                    "chat",
                                                                    style: GoogleFonts.roboto(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 18,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.only(top: 3),
                                                                  child: Image.asset(
                                                                    AppImages.chatIcon,
                                                                    height: 25,
                                                                    width: 35,
                                                                    color: Colors.black,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: _activityHistoryList[index].video != '',
                                                      child: Expanded(
                                                        child: Material(
                                                          color: Colors.transparent,
                                                          child: InkWell(
                                                            onTap: () async {
                                                              await launch(_activityHistoryList[index].video);
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  child: Text(
                                                                    "Video",
                                                                    style: GoogleFonts.roboto(
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 18,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  child: Container(
                                                                    margin: EdgeInsets.only(top: 5),
                                                                    child: Image.asset(
                                                                      AppImages.videoCallIcon,
                                                                      height: 25,
                                                                      width: 35,
                                                                      color: Colors.black,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Text(
                          "No data found",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }
  // //#GCW 31-01-2023
  // DateTime convertUtcToUser(DateTime time, String zone) {
  //     return TZDateTime.from(time, getLocation(zone));
  // }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");
    //#GCW 31-01-2023 save time Zone
    timeZone = (sharedPreferences.getString("TimeZone") ?? "");
    //timezoneHelperSetup();
    _getData(apiToken, true);

    setState(() {});
  }

  _getData(String token, bool isShow) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    final url = AppConstants.specialistActivityHistory;

    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getActivityHistory response status--> ${response.statusCode}');
      log('getActivityHistory response body--> ${response.body}');

      if (response.statusCode == 200) {
        //come here
        print("ATIM $timeZone");
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          _activityHistoryList.clear();
          _activityHistoryListTemp.clear();

          for (Map array in jsonData['data'] as List) {
            print("ATIN $timeZone");
            SpecialistHistoryModel specialistHistoryModel = SpecialistHistoryModel(
              array['id'],
              array['doctor'] != null ? array['doctor']['profile_picture'] != null ? array['doctor']['profile_picture'] : "" : "",
              array['doctor'] != null ? array['doctor']['first_name'] : "",
              array['doctor'] != null ? array['doctor']['last_name'] : "",
              array['created_at'],
              array['status'],
              "0",
              array['video'] != null ? array['video'] : '',
              array['chat'] != null ? array['chat'] : '',
              array['amount'] != null ? array['amount'] : '',
            );

            _activityHistoryListTemp.add(specialistHistoryModel);
          }

          _activityHistoryList = _activityHistoryListTemp;

          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        setState(() {
          _activityHistoryList.clear();
          _activityHistoryListTemp.clear();
        });
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
      setState(() {
        _activityHistoryList.clear();
        _activityHistoryListTemp.clear();
      });
      log("getActivityHistory Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getAnswer(String caseId, int index) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    AnimDialog.showLoadingDialog(context, _key, "Loading...");
    final url = AppConstants.doctorGetAnswer;

    log('url--> $url');

    var body = {"case_id": '$caseId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          _getAnswerList.clear();
          docList.clear();
          if (jsonData['data'].length != 0) {
            log("Answer Length ==> " + jsonData['data']['answers'].length.toString());
            for (Map array in jsonData['data']['answers'] as List) {
              GetAnswerModel getAnswerModel = GetAnswerModel(array['id'].toString(), array['question'], array['answers'].toString());
              _getAnswerList.add(getAnswerModel);
            }

            docList = _getAnswerList[3].answers.substring(1, _getAnswerList[3].answers.length - 1).toString().split(",");
            log("Select File Type -->" + docList[0].toString());
            isOpen = index;

            clinicAddress = jsonData['data']['clinic_address'] ?? "";
            clinicState = jsonData['data']['clinic_state'] ?? "";
            creationDate = jsonData['data']['creation_date'] ?? "";

            setState(() {});
          } else {
            log("Answer Length Else ==> " + jsonData['data'].length.toString());
            ToastMessage.showToastMessage(
              context: context,
              message: 'Answers not found',
              duration: 3,
              backColor: Colors.red,
              position: StyledToastPosition.center,
            );
          }

          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_key.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("doctorSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  Future<String?> _findLocalPath() async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }
}
