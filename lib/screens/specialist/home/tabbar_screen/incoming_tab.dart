import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';
import 'package:vsod_flutter/widgets/home_income_tab_widget/common_gradient_button.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/app_string.dart';
import '../../../../utils/assets.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../../widgets/common_button/common_gradientButton.dart';
import '../../../Doctor/model/GetAnswerModel.dart';
import '../../../Doctor/model/SlotModel.dart';
import '../../../Doctor/model/SpecialistPendingCaseModel.dart';
import '../../../Doctor/model/SpecialistScheduleCaseModel.dart';
import '../../SpecialistChatScreen.dart';

class IncomeListview extends StatefulWidget {
  IncomeListview({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => IncomeListViewState();
}

class IncomeListViewState extends State<IncomeListview> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  late String apiToken;
  late String timeZone;
  var zones = new Map();

  late SharedPreferences sharedPreferences;

  int? isOpen;
  int? isOpen1;

  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];

  List docList = [];

  late String _localPath;

  String specialization = "";

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";

  //late Timer timer;

  @override
  void initState() {
    super.initState();
    _init(false);
    //#GCW 31-01-2023
    setTimeZones();
    FlutterDownloader.registerCallback(downloadCallback);
  }

  //#GCW 31-01-2023
  void setTimeZones() {
    zones["Pacific/Honolulu"] = "UTC-10: Hawaii-Aleutian Standard Time (HAT)";
    zones["America/Anchorage"] = "UTC-9: Alaska Standard Time (AKT)";
    zones["America/Los_Angeles"] = "UTC-8: Pacific Standard Time (PT)";
    zones["America/Denver"] = "UTC-7: Mountain Standard Time (MT)";
    zones["America/Chicago"] = "UTC-6: Central Standard Time (CT)";
    zones["America/New_York"] = "UTC-5: Eastern Standard Time (ET)";
  }

  @override
  void dispose() {
    super.dispose();
    AppConstants.pusher.unsubscribe(channelName: "$specialization");
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
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
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  @override
  Widget build(BuildContext context) {
    final _pendingCaseModel = Provider.of<PendingDataProvider>(context);
    final _scheduleCaseModel = Provider.of<ScheduleDataProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
          key: _refreshIndicatorKey,
          onRefresh: () {
            AppConstants.pusher.unsubscribe(channelName: "$specialization");
            return _init(true);
          },
          //#GCW 18-12-2022 Message
          child: (_pendingCaseModel.post.data != null &&
                      _pendingCaseModel.post.data!.length != 0 ||
                  _scheduleCaseModel.post.data != null &&
                      _scheduleCaseModel.post.data!.length != 0)
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                      child: Column(
                    children: [
                      ListView.builder(
                        itemCount: _pendingCaseModel.post.data != null
                            ? _pendingCaseModel.post.data!.length
                            : 0,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 5),
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Material(
                              elevation: 10,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10, top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                commonTextView(
                                                    title:
                                                        '#${_pendingCaseModel.post.data![index].id}',
                                                    fontWeight:
                                                        FontWeight.w600),
                                                /*CountDownTimer(
                                            onFinish: () {
                                              _pendingCaseModel.post.data!.removeAt(index);
                                              setState(() {});
                                            },
                                            count: 60,
                                          ),*/
                                              ],
                                            ),
                                            /*  Text(
                                        '${DateFormat('dd MMM yyyy|kk:mm').format(DateTime.parse(_pendingCaseModel.post.data![index].updatedAt!))}',
                                        style: TextStyle(color: AppColors.descriptionTextColor),
                                      ),*/
                                          ],
                                        ),
                                        /* Container(
                                    color: AppColors.greenBGColor,
                                    height: 20,
                                    width: 60,
                                    child: Row(
                                      children: [
                                        Icon(Icons.library_add_check, size: 10),
                                        SizedBox(width: 10),
                                        Text("Live"),
                                      ],
                                    ),
                                  )*/
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      color: Colors.white.withOpacity(0.7),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(100),
                                              ),
                                            ),
                                            child: _pendingCaseModel
                                                        .post
                                                        .data![index]
                                                        .doctor!
                                                        .profilePicture !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder: AppImages
                                                          .profilePlaceHolder,
                                                      image: AppConstants
                                                              .publicImage +
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctor!
                                                              .profilePicture!,
                                                      height: 70,
                                                      width: 70,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.asset(
                                                      AppImages
                                                          .profilePlaceHolder,
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                commonTextView(
                                                  title:
                                                      'Dr. ${_pendingCaseModel.post.data![index].doctor!.firstName} ${_pendingCaseModel.post.data![index].doctor!.lastName}',
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 18,
                                                ),
                                                commonTextView(
                                                  title: ' ',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Spacer(),
                                                    HomeCommonGradientBottom(
                                                      onTap: () {
                                                        /*AppConstants.pusher.subscribe(
                                                    channelName: "CaseStatus",
                                                    onEvent: (event) {
                                                      log("onEvent: $event");

                                                      if (event.eventName.toString().contains('CaseAcceptedBySpecialist')) {
                                                        print("Case Accepted by specialist");

                                                        if (event.data != null) {
                                                          var data = jsonDecode(event.data);

                                                          if (data['case'] != null) {

                                                            print("StartDateTime == ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(data['start_time']))}");
                                                            print("EndDateTime == ${DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.parse(data['end_time']))}");
                                                            print("Seconds == ${data['seconds']}");

                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => SpecialistChatScreen(
                                                                  degree: "",
                                                                  lastName: _pendingCaseModel.post.data![index].doctor!.lastName!,
                                                                  firstName: _pendingCaseModel.post.data![index].doctor!.firstName!,
                                                                  caseId: _pendingCaseModel.post.data![index].id!.toString(),
                                                                  channelName: _pendingCaseModel.post.data![index].channelName!,
                                                                  specialistId: _pendingCaseModel.post.data![index].doctorId.toString(),
                                                                  specialistProfile: _pendingCaseModel.post.data![index].doctor!.profilePicture ?? "",
                                                                  caseSeconds: "${data['seconds']}",
                                                                ),
                                                              ),
                                                            ).then((value) {
                                                              _init(false);
                                                            });
                                                            AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
                                                          }
                                                        }
                                                      }
                                                    },
                                                    onSubscriptionError: (String message, dynamic e) {
                                                      log("onSubscriptionError: $message Exception: $e");
                                                    },
                                                    onSubscriptionSucceeded: (data) {
                                                      log("onSubscriptionSucceeded: data: $data");
                                                    },
                                                  );*/
                                                        AppConstants.pusher
                                                            .unsubscribe(
                                                                channelName:
                                                                    "$specialization");
                                                        _acceptCase(
                                                          apiToken,
                                                          _pendingCaseModel.post
                                                              .data![index].id!
                                                              .toString(),
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctor!
                                                              .email!,
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .channelName!,
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctorId
                                                              .toString(),
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctor!
                                                              .firstName!,
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctor!
                                                              .lastName!,
                                                          _pendingCaseModel
                                                                  .post
                                                                  .data![index]
                                                                  .doctor!
                                                                  .profilePicture ??
                                                              "",
                                                          _pendingCaseModel
                                                              .post
                                                              .data![index]
                                                              .baseTime!,
                                                        );
                                                      },
                                                      title: "Accept",
                                                      gradiantColor1: AppColors
                                                          .gradientBlue1,
                                                      gradiantColor2: AppColors
                                                          .gradientBlue2,
                                                    ),
                                                    //Spacer(),
                                                    /*HomeCommonGradientBottom(
                                                onTap: () {
                                                  _cancelPendingCase(apiToken, _pendingCaseModel.post.data![index].id.toString(), index);
                                                },
                                                title: "Cancel",
                                                gradiantColor1: AppColors.gradientRed1,
                                                gradiantColor2: AppColors.gradientRed2,
                                              ),*/
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 10,
                                      color: AppColors.dividerColor,
                                      thickness: 2,
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        /*if (_pendingCaseList[index].isOpen == "1") {
                                    setState(() {
                                      _pendingCaseList[index].isOpen = "0";
                                    });

                                  } else {

                                    setState(() {

                                      for (int i = 0; i < _pendingCaseList.length; i++) {
                                        _pendingCaseList[i].isOpen = "0";
                                      }
                                      for (int i = 0; i < _scheduleCaseList.length; i++) {
                                        _scheduleCaseList[i].isOpen = "0";
                                      }
                                      _pendingCaseList[index].isOpen = "1";
                                      _getAnswerList.clear();
                                      _getAnswer(_pendingCaseList[index].id.toString());
                                    });
                                  }*/
                                        setState(() {
                                          if (isOpen == index) {
                                            isOpen = null;
                                            isOpen1 = null;
                                          } else {
                                            isOpen = index;
                                            isOpen1 = null;
                                            _getAnswerList.clear();
                                            _getAnswer(_pendingCaseModel
                                                .post.data![index].id
                                                .toString());
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          isOpen == index
                                              ? 'Hide Details'
                                              : 'View Details',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF6189ED),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: isOpen == index,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Clinic Address: ",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF747474),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "$clinicAddress",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Clinic State: ",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF747474),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "$clinicState",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                            /* Container(
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
                                      ),*/
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "Med. Record No.",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3),
                                                          child: Text(
                                                            _getAnswerList
                                                                        .length >
                                                                    0
                                                                ? _getAnswerList[
                                                                        0]
                                                                    .answers
                                                                : '',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF747474),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "Patient Species",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3),
                                                          child: Text(
                                                            _getAnswerList
                                                                        .length >
                                                                    0
                                                                ? _getAnswerList[
                                                                        1]
                                                                    .answers
                                                                : '',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF747474),
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
                                              margin: EdgeInsets.only(
                                                  left: 18, top: 3),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _getAnswerList.length > 0
                                                    ? _getAnswerList[2].answers
                                                    : '',
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
                                                //#GCW 31-01-2023 change 'attach files' to 'attached files'
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int docIndex) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        PermissionStatus
                                                            permissionStatus =
                                                            await Permission
                                                                .storage
                                                                .request();
                                                        if (permissionStatus !=
                                                            PermissionStatus
                                                                .granted)
                                                          return;

                                                        _localPath =
                                                            (await _findLocalPath())!;
                                                        final savedDir =
                                                            Directory(
                                                                _localPath);
                                                        bool hasExisted1 =
                                                            savedDir
                                                                .existsSync();
                                                        if (!hasExisted1) {
                                                          savedDir.create();
                                                        }
                                                        String fileAppend =
                                                            DateTime.now()
                                                                .millisecondsSinceEpoch
                                                                .toString();
                                                        String fileName = docList[
                                                                docIndex]
                                                            .trim()
                                                            .substring(docList[
                                                                        docIndex]
                                                                    .trim()
                                                                    .lastIndexOf(
                                                                        "/") +
                                                                1);

                                                        await FlutterDownloader
                                                            .enqueue(
                                                          url: docList[docIndex]
                                                              .trim(),
                                                          savedDir: _localPath,
                                                          fileName: fileAppend +
                                                              fileName,
                                                          showNotification:
                                                              true,
                                                          openFileFromNotification:
                                                              false,
                                                        );
                                                      },
                                                      child: Container(
                                                        child: _getAnswerList
                                                                    .length >
                                                                0
                                                            ? Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                child: docList[docIndex]
                                                                            .split(".")
                                                                            .last ==
                                                                        "jpg"
                                                                    ? ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(0),
                                                                        child: FadeInImage
                                                                            .assetNetwork(
                                                                          placeholder:
                                                                              AppImages.defaultPlaceHolder,
                                                                          image:
                                                                              docList[docIndex].trim(),
                                                                          height:
                                                                              70,
                                                                          width:
                                                                              70,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      )
                                                                    : Container(
                                                                        margin: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                5),
                                                                        child: docList[docIndex].split(".").last == "heic"
                                                                            ? ClipRRect(
                                                                          borderRadius:
                                                                          BorderRadius.circular(0),
                                                                          child: FadeInImage
                                                                              .assetNetwork(
                                                                            placeholder:
                                                                            AppImages.defaultPlaceHolder,
                                                                            image:
                                                                            docList[docIndex].trim(),
                                                                            height:
                                                                            70,
                                                                            width:
                                                                            70,
                                                                            fit: BoxFit
                                                                                .contain,
                                                                          ),
                                                                        ):docList[docIndex].split(".").last ==
                                                                                "heif"
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
                                                                      ))
                                                            : Container(),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      ListView.builder(
                        itemCount: _scheduleCaseModel.post.data != null
                            ? _scheduleCaseModel.post.data!.length
                            : 0,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding:
                            const EdgeInsets.only(left: 15, right: 15, top: 5),
                        itemBuilder: (BuildContext context, int index) {
                          //print("ATIN TEST: ${(_scheduleCaseModel.post.data).to}")
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Material(
                              elevation: 10,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10, top: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            commonTextView(
                                                title:
                                                    '#${_scheduleCaseModel.post.data![index].id}',
                                                fontWeight: FontWeight.w600),
                                            /* Text(
                                        '${DateFormat('dd MMM yyyy|kk:mm').format(DateTime.parse(_scheduleCaseModel.post.data![index].createdAt!))}',
                                        style: TextStyle(color: AppColors.descriptionTextColor),
                                      ),*/
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () {
                                            List slots = _scheduleCaseModel
                                                .post
                                                .data![index]
                                                .schedule!
                                                .convertedOptions!
                                                .values
                                                .toList();

                                            //#GCW
                                            List<dynamic> keys =
                                                _scheduleCaseModel
                                                    .post
                                                    .data![index]
                                                    .schedule!
                                                    .convertedOptions!
                                                    .keys
                                                    .toList();

                                            print(slots.length);
                                            print(slots.toString());

                                            List<SlotModel> slotDates = [];

                                            for (int i = 0;
                                                i < slots.length;
                                                i++) {
                                              SlotModel slotModel = SlotModel(
                                                  DateFormat('MM/dd/yyyy')
                                                      .parse(slots[i]
                                                          .split(" ")
                                                          .first)
                                                      .toString(),
                                                  slots[i].split(" ")[1] +
                                                      " " +
                                                      slots[i].split(" ").last);
                                              slotDates.add(slotModel);
                                            }

                                            _showScheduleDialog(
                                                context,
                                                slotDates,
                                                keys,
                                                _scheduleCaseModel
                                                    .post.data![index].id
                                                    .toString(),
                                                index);
                                          },
                                          child: Container(
                                            height: 30,
                                            width: 60,
                                            child: Icon(
                                              Icons.calendar_month,
                                              size: 22,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 100,
                                      color: Colors.white.withOpacity(0.7),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: 70,
                                            height: 70,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(100),
                                              ),
                                            ),
                                            child: _scheduleCaseModel
                                                        .post
                                                        .data![index]
                                                        .doctor!
                                                        .profilePicture !=
                                                    null
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder: AppImages
                                                          .profilePlaceHolder,
                                                      image: AppConstants
                                                              .publicImage +
                                                          _scheduleCaseModel
                                                              .post
                                                              .data![index]
                                                              .doctor!
                                                              .profilePicture!,
                                                      height: 70,
                                                      width: 70,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.asset(
                                                      AppImages
                                                          .profilePlaceHolder,
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(width: 5),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                commonTextView(
                                                  title:
                                                      'Dr. ${_scheduleCaseModel.post.data![index].doctor!.firstName} ${_scheduleCaseModel.post.data![index].doctor!.lastName}',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                commonTextView(
                                                  title: ' ',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                ),
                                                SizedBox(height: 6),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Spacer(),
                                                    HomeCommonGradientBottom(
                                                      onTap: () {
                                                        List slots =
                                                            _scheduleCaseModel
                                                                .post
                                                                .data![index]
                                                                .schedule!
                                                                .convertedOptions!
                                                                .values
                                                                .toList();

                                                        //#GCW
                                                        List<dynamic> keys =
                                                            _scheduleCaseModel
                                                                .post
                                                                .data![index]
                                                                .schedule!
                                                                .convertedOptions!
                                                                .keys
                                                                .toList();

                                                        print(slots.length);
                                                        print(slots.toString());

                                                        List<SlotModel>
                                                            slotDates = [];

                                                        for (int i = 0;
                                                            i < slots.length;
                                                            i++) {
                                                          SlotModel slotModel = SlotModel(
                                                              DateFormat(
                                                                      'MM/dd/yyyy')
                                                                  .parse(slots[
                                                                          i]
                                                                      .split(
                                                                          " ")
                                                                      .first)
                                                                  .toString(),
                                                              slots[i].split(
                                                                      " ")[1] +
                                                                  " " +
                                                                  slots[i]
                                                                      .split(
                                                                          " ")
                                                                      .last);
                                                          slotDates
                                                              .add(slotModel);
                                                        }

                                                        _showScheduleDialog(
                                                            context,
                                                            slotDates,
                                                            keys,
                                                            _scheduleCaseModel
                                                                .post
                                                                .data![index]
                                                                .id
                                                                .toString(),
                                                            index);
                                                      },
                                                      title: "Schedule",
                                                      gradiantColor1: AppColors
                                                          .gradientGreen1,
                                                      gradiantColor2: AppColors
                                                          .gradientGreen2,
                                                    ),
                                                    //Spacer(),
                                                    /*HomeCommonGradientBottom(
                                                onTap: () {
                                                  _cancelScheduleCase(apiToken, _scheduleCaseModel.post.data![index].id.toString(), index);
                                                },
                                                title: "Cancel",
                                                gradiantColor1: AppColors.gradientRed1,
                                                gradiantColor2: AppColors.gradientRed2,
                                              ),*/
                                                  ],
                                                )
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 10,
                                      color: AppColors.dividerColor,
                                      thickness: 2,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        /*if (_scheduleCaseList[index].isOpen == "1") {
                                    setState(() {
                                      _scheduleCaseList[index].isOpen = "0";
                                    });
                                  } else {
                                    setState(() {
                                      for (int i = 0; i < _scheduleCaseList.length; i++) {
                                        _scheduleCaseList[i].isOpen = "0";
                                      }
                                      for (int i = 0; i < _pendingCaseList.length; i++) {
                                        _pendingCaseList[i].isOpen = "0";
                                      }
                                      _scheduleCaseList[index].isOpen = "1";
                                      _getAnswerList.clear();
                                      _getAnswer(_scheduleCaseList[index].id.toString());
                                    });
                                  }*/
                                        setState(() {
                                          if (isOpen1 == index) {
                                            isOpen = null;
                                            isOpen1 = null;
                                          } else {
                                            isOpen1 = index;
                                            isOpen = null;
                                            _getAnswerList.clear();
                                            _getAnswer(_scheduleCaseModel
                                                .post.data![index].id
                                                .toString());
                                          }
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          isOpen1 == index
                                              ? 'Hide Details'
                                              : 'View Details',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Color(0xFF6189ED),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: isOpen1 == index,
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Clinic Address: ",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF747474),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "$clinicAddress",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Clinic State: ",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15,
                                                        color:
                                                            Color(0xFF747474),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "$clinicState",
                                                      style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
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
                                            /* Container(
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
                                      ),*/
                                            SizedBox(
                                              height: 15,
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 18, right: 15),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "Med. Record No.",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3),
                                                          child: Text(
                                                            _getAnswerList
                                                                        .length >
                                                                    0
                                                                ? _getAnswerList[
                                                                        0]
                                                                    .answers
                                                                : '',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF747474),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          child: Text(
                                                            "Patient Species",
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 18,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 3),
                                                          child: Text(
                                                            _getAnswerList
                                                                        .length >
                                                                    0
                                                                ? _getAnswerList[
                                                                        1]
                                                                    .answers
                                                                : '',
                                                            style: GoogleFonts
                                                                .roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF747474),
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
                                              margin: EdgeInsets.only(
                                                  left: 18, top: 3),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _getAnswerList.length > 0
                                                    ? _getAnswerList[2].answers
                                                    : '',
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
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int docIndex) {
                                                    return InkWell(
                                                      onTap: () async {
                                                        PermissionStatus
                                                            permissionStatus =
                                                            await Permission
                                                                .storage
                                                                .request();
                                                        if (permissionStatus !=
                                                            PermissionStatus
                                                                .granted)
                                                          return;

                                                        _localPath =
                                                            (await _findLocalPath())!;
                                                        final savedDir =
                                                            Directory(
                                                                _localPath);
                                                        bool hasExisted1 =
                                                            savedDir
                                                                .existsSync();
                                                        if (!hasExisted1) {
                                                          savedDir.create();
                                                        }
                                                        String fileAppend =
                                                            DateTime.now()
                                                                .millisecondsSinceEpoch
                                                                .toString();
                                                        String fileName = docList[
                                                                docIndex]
                                                            .trim()
                                                            .substring(docList[
                                                                        docIndex]
                                                                    .trim()
                                                                    .lastIndexOf(
                                                                        "/") +
                                                                1);

                                                        await FlutterDownloader
                                                            .enqueue(
                                                          url: docList[docIndex]
                                                              .trim(),
                                                          savedDir: _localPath,
                                                          fileName: fileAppend +
                                                              fileName,
                                                          showNotification:
                                                              true,
                                                          openFileFromNotification:
                                                              false,
                                                        );
                                                      },
                                                      child: Container(
                                                        child: _getAnswerList
                                                                    .length >
                                                                0
                                                            ? Container(
                                                                margin: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                child: docList[docIndex].split(".").last == "heic"
                                                                    ? ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius.circular(0),
                                                                  child: FadeInImage
                                                                      .assetNetwork(
                                                                    placeholder:
                                                                    AppImages.defaultPlaceHolder,
                                                                    image:
                                                                    docList[docIndex].trim(),
                                                                    height:
                                                                    70,
                                                                    width:
                                                                    70,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ):docList[docIndex].split(".").last == "heif"
                                                                    ? ClipRRect(
                                                                  borderRadius:
                                                                  BorderRadius.circular(0),
                                                                  child: FadeInImage
                                                                      .assetNetwork(
                                                                    placeholder:
                                                                    AppImages.defaultPlaceHolder,
                                                                    image:
                                                                    docList[docIndex].trim(),
                                                                    height:
                                                                    70,
                                                                    width:
                                                                    70,
                                                                    fit: BoxFit
                                                                        .contain,
                                                                  ),
                                                                ):docList[docIndex]
                                                                            .split(
                                                                                ".")
                                                                            .last ==
                                                                        "jpg"
                                                                    ? ClipRRect(
                                                                        borderRadius:
                                                                            BorderRadius.circular(0),
                                                                        child: FadeInImage
                                                                            .assetNetwork(
                                                                          placeholder:
                                                                              AppImages.defaultPlaceHolder,
                                                                          image:
                                                                              docList[docIndex].trim(),
                                                                          height:
                                                                              70,
                                                                          width:
                                                                              70,
                                                                          fit: BoxFit
                                                                              .contain,
                                                                        ),
                                                                      )
                                                                    : docList[docIndex].split(".").last ==
                                                                            "png"
                                                                        ? ClipRRect(
                                                                            borderRadius:
                                                                                BorderRadius.circular(0),
                                                                            child:
                                                                                FadeInImage.assetNetwork(
                                                                              placeholder: AppImages.defaultPlaceHolder,
                                                                              image: docList[docIndex].trim(),
                                                                              height: 70,
                                                                              width: 70,
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          )
                                                                        : docList[docIndex].split(".").last ==
                                                                                "pdf"
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
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      Visibility(
                        visible: (_pendingCaseModel.post.data != null &&
                                _pendingCaseModel.post.data!.length == 0) &&
                            (_scheduleCaseModel.post.data != null &&
                                _scheduleCaseModel.post.data!.length == 0),
                        child: Container(
                          height: MediaQuery.of(context).size.height - 200,
                          width: double.infinity,
                        ),
                      ),
                    ],
                  )),
                )
              //GCW 19-12-2022
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    //height:double.infinity,
                    height: 800,
                    child: Text(
                      "No new Cases, Pull down to Refresh\n${FormattedAPIResponseMessage((_pendingCaseModel.post.status?.message).toString())}",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.25,
                          color: AppColors.textPrussianBlueColor),
                    ),
                  ))),
    );
  }

  _init(bool isRefresh) async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

    //#GCW 31-01-2023
    timeZone = (sharedPreferences.getString("TimeZone") ?? "");
    print("ATIN:$timeZone");

    specialization = (sharedPreferences.getString("Specialization") ?? "")
        .replaceAll(" ", "-")
        .toLowerCase();

    Future.delayed(Duration(milliseconds: isRefresh ? 0 : 400), () {
      AnimDialog.showLoadingDialog(context, _key, "");
      _getSpecialistProfile(apiToken);
      specialization = (sharedPreferences.getString("Specialization") ?? "")
          .replaceAll(" ", "-")
          .toLowerCase();
      Provider.of<PendingDataProvider>(context, listen: false)
          .getPostData(context, apiToken);
      Provider.of<ScheduleDataProvider>(context, listen: false)
          .getPostData(context, apiToken);
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    });

    setState(() {});
  }

  _getSpecialistProfile(String token) async {
    log('Bearer Token ==>  $token');
    final url = AppConstants.specialistProfile;
    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      log('getSpecialistProfile response body--> ${response.body}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          var data = jsonData['data'] as List;
          if (data.length > 0) {
            var item = data[0];
            setState(() {
              specialization =
                  item['specialization'].replaceAll(" ", "-").toLowerCase();
              sharedPreferences.setString(
                  "Specialization", item['specialization']);
            });

            _subscribe(specialization);
          }
        }
      }
    } catch (e, s) {
      log("getSpecialistProfile Error--> Error:-$e stackTrace:-$s");
    }
  }

  void _subscribe(String specialization) {
    AppConstants.pusher.subscribe(
      channelName: "$specialization",
      onEvent: onEvent,
      onSubscriptionError: (String message, dynamic e) {
        log("onSubscriptionError: $message Exception: $e");
      },
      onSubscriptionSucceeded: (data) {
        log("onSubscriptionSucceeded: data: $data");
      },
    );
    AppConstants.pusher.connect();

    print("Specialization == $specialization");
  }

  onEvent(event) {
    log("onEventChat: $event");

    if (event.eventName.toString().contains('CaseCreatedNotification')) {
      log("CaseCreatedNotification");

      Provider.of<PendingDataProvider>(context, listen: false)
          .getPostData(context, apiToken);
    }
  }

  _getAnswer(String caseId) async {
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
            log("Answer Length ==> " +
                jsonData['data']['answers'].length.toString());
            for (Map array in jsonData['data']['answers'] as List) {
              GetAnswerModel getAnswerModel = GetAnswerModel(
                  array['id'].toString(),
                  array['question'],
                  array['answers'].toString());
              _getAnswerList.add(getAnswerModel);
            }

            docList = _getAnswerList[3]
                .answers
                .substring(1, _getAnswerList[3].answers.length - 1)
                .toString()
                .split(",");
            log("Select File Type -->" + docList[0].toString());

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

  _acceptCase(
      String token,
      String caseId,
      String email,
      String channelName,
      String doctorId,
      String firstName,
      String lastName,
      String doctorProfile,
      String baseTime) async {
    AnimDialog.showLoadingDialog1(context);

    final url = AppConstants.specialistAcceptCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body = jsonEncode({"caseid": '$caseId', "user": '$email'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistAcceptCase response body--> ${response.body}');

      if (response.statusCode == 200) {
        AnimDialog.dismissLoadingDialog(context);

        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Duration duration = Duration(minutes: int.parse(baseTime));
          print("Duration == ${duration.inSeconds}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistChatScreen(
                degree: "",
                lastName: lastName,
                firstName: firstName,
                caseId: caseId,
                channelName: channelName,
                specialistId: doctorId,
                specialistProfile: doctorProfile,
                caseSeconds: duration.inSeconds.toString(),
              ),
            ),
          ).then((value) {
            _init(false);
          });

          setState(() {});
        } else {
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.red,
            position: StyledToastPosition.center,
          );
        }
      } else {
        AnimDialog.dismissLoadingDialog(context);
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("specialistAcceptCase Error--> Error:-$e stackTrace:-$s");
      AnimDialog.dismissLoadingDialog(context);
    }
  }

  _cancelPendingCase(String token, String caseId, int i) async {
    AnimDialog.showLoadingDialog(context, _key, "Loading...");

    final url = AppConstants.specialistCancelCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body = jsonEncode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistCancelCase response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black,
            position: StyledToastPosition.center,
          );

          Provider.of<PendingDataProvider>(context, listen: false)
              .getPostData(context, apiToken);

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
      log("specialistCancelCase Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  _cancelScheduleCase(String token, String caseId, int i) async {
    AnimDialog.showLoadingDialog(context, _key, "Loading...");

    final url = AppConstants.specialistCancelCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body = jsonEncode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistCancelCase response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black,
            position: StyledToastPosition.center,
          );

          Provider.of<ScheduleDataProvider>(context, listen: false)
              .getPostData(context, apiToken);

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
      log("specialistCancelCase Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  _showScheduleDialog(BuildContext context, List<SlotModel> slotDates,
      List<dynamic> keys, String caseId, int i) {
    int? selected;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  width: 1,
                  color: AppColors.dialogBorderColor.withOpacity(0.40),
                ),
              ),
              elevation: 0,
              backgroundColor: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 20),
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: 35),
                            alignment: Alignment.center,
                            child: Text(
                              "Schedule Request",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  letterSpacing: 0.25,
                                  color: AppColors.textPrussianBlueColor),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            child: Image.asset(
                              AppImages.scheduleClose,
                              height: 21,
                              width: 25,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    alignment: Alignment.center,
                    //todo
                    child: Text(
                      //#GCW 31-01-2023 Show timezone
                      zones[timeZone] == null
                          ? "Timezone not available"
                          : "Time is displayed in:\n${zones[timeZone]}",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          letterSpacing: 0.25,
                          color: AppColors.textDarkBlue),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 103,
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: ListView.builder(
                      itemCount: slotDates.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2),
                          width: 65,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: selected == index
                                  ? [Colors.green, Colors.green]
                                  : [
                                      AppColors.gradientScheduleRectangle1,
                                      AppColors.gradientScheduleRectangle2
                                    ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0.0, 1.0],
                              tileMode: TileMode.clamp,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.blackColor.withOpacity(0.25),
                                blurRadius: 2,
                                offset: const Offset(0, 5), // Shadow position
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: () {
                              selected = index;
                              setState(() {});
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                    //"Jan, 2022",
                                    "${DateFormat('MMM,yyyy').format(DateTime.parse(slotDates[index].date))}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 10,
                                        color: AppColors.textLightGrayColor),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                    //"21",
                                    "${DateFormat('dd').format(DateTime.parse(slotDates[index].date))}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                        letterSpacing: 0.2,
                                        color: AppColors.whiteColor),
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                    //"Mon",
                                    "${DateFormat('EEE').format(DateTime.parse(slotDates[index].date))}",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.roboto(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        letterSpacing: 0.2,
                                        color: AppColors.whiteColor),
                                  ),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Container(
                                  child: Card(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    elevation: 5,
                                    shadowColor: Colors.black.withOpacity(0.45),
                                    child: Container(
                                      height: 28,
                                      width: 55,
                                      alignment: Alignment.center,
                                      child: Text(
                                        //"09:00",
                                        "${slotDates[index].slotTime}",
                                        style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.15,
                                            color:
                                                AppColors.textPrussianBlueColor,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: CommonButtonGradient(
                      height: 48,
                      width: 148,
                      fontSize: 14,
                      buttonName: AppStrings.submit,
                      colorGradient1: AppColors.gradientGreen1,
                      colorGradient2: AppColors.gradientGreen2,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        if (selected != null) {
                          DateTime selectedSlotDate =
                              DateTime.parse(slotDates[selected!].date);
                          String selectedSlotTime =
                              slotDates[selected!].slotTime;

                          print("SELECTED: ${keys[selected!]}");
                          print(
                              "Selected == ${DateFormat('MM/dd/yyyy').format(selectedSlotDate)} $selectedSlotTime");

                          _selectSchedule(
                              context,
                              apiToken,
                              caseId,
                              keys[selected!],
                              //"${DateFormat('MM/dd/yyyy').format(selectedSlotDate)} $selectedSlotTime",
                              i);
                        }
                      },
                    ),
                  ),
                  //#GCW 02-02-2023
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    alignment: Alignment.center,
                    child: Text(
                      //#GCW 31-01-2023 Show timezone
                      "You must choose a time slot",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          letterSpacing: 0.25,
                          color: AppColors.textDarkBlue),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _selectSchedule(BuildContext context, String token, String caseId,
      String selectedOption, int i) async {
    AnimDialog.showLoadingDialog(context, _key, "Loading...");

    final url = AppConstants.specialistSelectSchedule;

    log('token--> $token');

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    var body = jsonEncode(
        {"case_id": '$caseId', "selected_option": '$selectedOption'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('specialistSelectSchedule response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black,
            position: StyledToastPosition.center,
          );

          Navigator.pop(context);

          Provider.of<ScheduleDataProvider>(context, listen: false)
              .getPostData(context, apiToken);

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
      log("specialistSelectSchedule Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  FormattedAPIResponseMessage(String string) {
    try {
      return "Last accepted at ${string.substring(58, 77)}";
    } catch (e) {
      return " ";
    }
  }
}

Future<SpecialistPendingCaseModel> getPendingCase(context, token) async {
  final url = AppConstants.specialistGetPendingCase;
  log('url--> $url');

  SpecialistPendingCaseModel? result;
  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    log('getPendingCase response body--> ${response.body}');
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      result = SpecialistPendingCaseModel.fromJson(item);
    } else {
      log("Something bad happened,try again after some time.");
    }
  } catch (e) {
    log(e.toString());
  }
  return result!;
}

class PendingDataProvider with ChangeNotifier {
  SpecialistPendingCaseModel post = SpecialistPendingCaseModel();
  bool loading = false;

  getPostData(context, token) async {
    loading = true;
    post = await getPendingCase(context, token);
    loading = false;

    notifyListeners();
  }
}

Future<SpecialistScheduleCaseModel> getScheduleCase(context, token) async {
  final url = AppConstants.specialistGetScheduleCase;
  log('url--> $url');

  SpecialistScheduleCaseModel? result;
  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    log('getScheduleCase response body--> ${response.body}');
    if (response.statusCode == 200) {
      final item = json.decode(response.body);
      result = SpecialistScheduleCaseModel.fromJson(item);
    } else {
      log("Something bad happened,try again after some time.");
    }
  } catch (e) {
    log(e.toString());
  }
  return result!;
}

class ScheduleDataProvider with ChangeNotifier {
  SpecialistScheduleCaseModel post = SpecialistScheduleCaseModel();
  bool loading = false;

  getPostData(context, token) async {
    loading = true;
    post = await getScheduleCase(context, token);
    loading = false;

    notifyListeners();
  }
}
