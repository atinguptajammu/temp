import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

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
import 'package:vsod_flutter/screens/Doctor/model/ActivityHistoryModel.dart';
import 'package:vsod_flutter/screens/Doctor/model/GetAnswerModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';

import '../../utils/utils.dart';

class ActivityHistoryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  CustomPopupMenuController _controller = CustomPopupMenuController();

  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;

  List<ActivityHistoryModel> _activityHistoryList = <ActivityHistoryModel>[];
  List<ActivityHistoryModel> _activityHistoryListTemp = <ActivityHistoryModel>[];
  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];

  List<String> docList = [];
  int? isOpen;

  late String _localPath;

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";

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
      List<ActivityHistoryModel> tempList = <ActivityHistoryModel>[];

      for (ActivityHistoryModel model in _activityHistoryListTemp) {
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
      body: RefreshIndicator(
        onRefresh: () {
          return _init();
        },
        child: Container(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 36),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        height: 34,
                        margin: EdgeInsets.only(left: 15, right: 15),
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF000000).withOpacity(0.3), width: 0.5),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: TextField(
                                enabled: true,
                                keyboardType: TextInputType.name,
                                onChanged: _filterSearch,
                                style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, color: AppColors.textPrussianBlueColor),
                                decoration: InputDecoration(
                                  isDense: true,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  filled: false,
                                  fillColor: Colors.transparent,
                                  hintText: 'Search',
                                  hintStyle: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 15),
                              child: Image.asset(
                                AppImages.searchIcon,
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomPopupMenu(
                      arrowColor: Colors.transparent,
                      child: Container(
                        margin: EdgeInsets.only(right: 12),
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
                  ],
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Container(
                    child: ListView.builder(
                      itemCount: _activityHistoryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          child: InkWell(
                            onTap: () {
                              setState(() {
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
                              });
                            },
                            child: Card(
                              margin: EdgeInsets.only(left: 15, right: 15, bottom: 15),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.45),
                              child: Container(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: _activityHistoryList[index].status.toLowerCase() == 'active'
                                                  ? Color(0xFFFFA12F)
                                                  : _activityHistoryList[index].status.toLowerCase() == 'dispute'
                                                      ? Color(0xFFFC6969)
                                                      : Color(0xFF018D10),
                                              width: 0.5),
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                        child: Text(
                                          _activityHistoryList[index].status,
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 10,
                                            color: _activityHistoryList[index].status.toLowerCase() == 'active'
                                                ? Color(0xFFFFA12F)
                                                : _activityHistoryList[index].status.toLowerCase() == 'dispute'
                                                    ? Color(0xFFFC6969)
                                                    : Color(0xFF018D10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 18),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(100),
                                              ),
                                            ),
                                            child: _activityHistoryList[index].profilePicture != ''
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: FadeInImage.assetNetwork(
                                                      placeholder: AppImages.defaultProfile,
                                                      image: _activityHistoryList[index].profilePicture,
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: Image.asset(
                                                      AppImages.defaultProfile,
                                                      height: 50,
                                                      width: 50,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 14,
                                          ),
                                          Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  child: Text(
                                                    "Dr. " + _activityHistoryList[index].firstName + " " + _activityHistoryList[index].lastName,
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
                                                    //#GCW 31-02-2024 change date format
                                                    DateFormat('MM/dd/yyyy,').add_jm().format(DateTime.parse(_activityHistoryList[index].createdDate)),
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
                                      height: 12,
                                    ),
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
                                                // gcw 01-02-2023 Attach to Attached
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
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
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

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _getActivityHistory();
    });
  }

  _getActivityHistory() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorHistory;

    log('url--> $url');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getActivityHistory response status--> ${response.statusCode}');
      log('getActivityHistory response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _activityHistoryList.clear();
          for (Map array in jsonData['data'] as List) {
            ActivityHistoryModel activityHistoryModel = ActivityHistoryModel(
                array['id'].toString(),
                array['profile_picture'] != null ? array['profile_picture'] : '',
                array['first_name'] != null ? array['first_name'] : '',
                array["last_name"] != null ? array['last_name'] : '',
                array["specialization"] != null ? array["specialization"] : '',
                array["medical_number"] != null ? array["medical_number"] : '',
                array["created_at"] != null ? array["created_at"] : '',
                array["status"],
                '0',
                array['video'] != null ? array['video'] : '',
                array['chat'] != null ? array['chat'] : '');
            _activityHistoryListTemp.add(activityHistoryModel);
          }

          _activityHistoryList = _activityHistoryListTemp;
          setState(() {});
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("getActivityHistory Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getAnswer(String caseId, int index) async {
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
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
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
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
              message: 'Answer not found',
              duration: 3,
              backColor: Colors.red,
              position: StyledToastPosition.center,
            );
          }

          setState(() {});
        } else {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
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
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }
}

class ItemModel {
  String title;

  ItemModel(this.title);
}
