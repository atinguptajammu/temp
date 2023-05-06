import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/time_convert.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../Doctor/model/GetAnswerModel.dart';
import '../../../Doctor/model/SpecialistScheduledCaseModel.dart';

class ScheduledTabBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScheduledTabBarState();
}

class _ScheduledTabBarState extends State<ScheduledTabBar> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late String apiToken;
  late String timeZone;
  ChangeTimeZone changeTimeZone = ChangeTimeZone();

  late SharedPreferences sharedPreferences;

  int? isOpen;

  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];

  List docList = [];

  late String _localPath;

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";

  @override
  void initState() {
    super.initState();
    _init(false);

    FlutterDownloader.registerCallback(downloadCallback);
  }

  //#GCW 31-01-2023
  // void timezoneHelperSetup() async {
  //   var byteData =
  //       await rootBundle.load('packages/timezone/data/latest_all.tzf');
  //   initializeDatabase(byteData.buffer.asUint8List());
  // }

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

  // //#GCW 31-01-2023
  // DateTime convertToUtc(DateTime date, int offset) {
  //   return date.add(Duration(hours: offset));
  // }
  //
  // //#GCW 31-01-2023
  // String convertTime(String date) {
  //   print("ATTIN:$date $timeZone");
  //   if (date == "") {
  //     return "";
  //   }
  //   var s = date.split(" ");
  //   //yyyy-MM-ddTHH:mm:ss.mmm
  //   var hour = int.parse(s[1].split(":")[0]);
  //   if (s[2] == "pm") {
  //     hour += 12;
  //     //print(hour);
  //   }
  //   var hourStr = hour > 9 ? "$hour" : "0$hour";
  //   var d =
  //       "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T${hourStr}:${s[1].split(":")[1]}:00.000";
  //   //var d = "${s[0].split("/")[2]}-${s[0].split("/")[0]}-${s[0].split("/")[1]}T$hour${s[1].split(":")[1]}:00.000" ;
  //   var dd = DateTime.parse(d);
  //   int offSet;
  //   if (timeZone == "Pacific/Honolulu") {
  //     offSet = 5;
  //   } else if (timeZone == "America/Anchorage") {
  //     offSet = 4;
  //   } else if (timeZone == "America/Los_Angeles") {
  //     offSet = 3;
  //   } else if (timeZone == "America/Denver") {
  //     offSet = 2;
  //   } else if (timeZone == "America/Chicago") {
  //     offSet = 1;
  //   } else {
  //     offSet = 0;
  //   }
  //   var finalDate = convertToUtc(dd, offSet);
  //   var datee = DateFormat("MM/dd/yyyy h:mm a").format(finalDate);
  //   print("$datee");
  //   //var finalDateStr = DateFormat("MM/dd/yyyy HH:mm a").format(finalDate);
  //   return datee.toString();
  // }

  @override
  Widget build(BuildContext context) {
    final _scheduledCaseModel = Provider.of<ScheduledDataProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () {
            return _init(true);
          },
          //#GCW 18-12-2022
          child: _scheduledCaseModel.post.data != null &&
                  _scheduledCaseModel.post.data!.length > 0
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: _scheduledCaseModel.post.data != null &&
                            _scheduledCaseModel.post.data!.length > 0
                        ? ListView.builder(
                            itemCount: _scheduledCaseModel.post.data != null
                                ? _scheduledCaseModel.post.data!.length
                                : 0,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(
                                left: 15, right: 15, top: 5),
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: Material(
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        bottom: 10,
                                        top: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  commonTextView(
                                                      title:
                                                          '#${_scheduledCaseModel.post.data![index].id}',
                                                      fontWeight:
                                                          FontWeight.w600),
                                                  /* Text(
                                            '${DateFormat('dd MMM yyyy|kk:mm').format(DateTime.parse(_scheduledCaseModel.post.data![index].createdAt!))}',
                                            style: TextStyle(color: AppColors.descriptionTextColor),
                                          ),*/
                                                ],
                                              ),
                                            ),
                                            //#GCW 05-02-2023
                                            InkWell(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (ctx) => AlertDialog(
                                                    content:InkWell(
                                                      onTap: (){
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text("This case has already been scheduled for you at ${_scheduledCaseModel.post.data![index].schedule!.selectedOption.toString()} . When the scheduled time arrives, the case will move from \"Scheduled\" to \"Open Cases\" and a resume button will appear. Click the resume button to begin the case."),
                                                    )

                                                  ),
                                                );
                                              },
                                              child: Row(
                                                children: [commonTextView(
                                                    title:
                                                    //#GCW 02-02-2023
                                                    _scheduledCaseModel.post.data![index].schedule!.selectedOption.toString(),
                                                    //changeTimeZone.convertTime(_scheduledCaseModel.post.data![index].schedule!.selectedOption.toString(), timeZone),
                                                    //'${convertTime(_scheduledCaseModel.post.data![index].schedule!.selectedOption.toString())}',
                                                    //'${_scheduledCaseModel.post.data![index].schedule!.selectedOption}',
                                                    fontWeight: FontWeight.w500),
                                                  Container(
                                                    height: 20,
                                                    width: 30,
                                                    child: Icon(
                                                      Icons.calendar_month,
                                                      size: 22,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(100),
                                                  ),
                                                ),
                                                child: _scheduledCaseModel
                                                            .post
                                                            .data![index]
                                                            .specialist!
                                                            .profilePicture !=
                                                        null
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          placeholder: AppImages
                                                              .profilePlaceHolder,
                                                          image: AppConstants
                                                                  .publicImage +
                                                              _scheduledCaseModel
                                                                  .post
                                                                  .data![index]
                                                                  .specialist!
                                                                  .profilePicture!,
                                                          height: 70,
                                                          width: 70,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
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
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    commonTextView(
                                                      title:
                                                          'Dr. ${_scheduledCaseModel.post.data![index].specialist!.firstName} ${_scheduledCaseModel.post.data![index].specialist!.lastName}',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    SizedBox(
                                                      height: 25,
                                                    ),
                                                    //#GCW 31-01-2023 Remove Pet Clinic
                                                    // commonTextView(
                                                    //   title: 'Pet Clinic',
                                                    //   fontWeight:
                                                    //       FontWeight.w400,
                                                    //   fontSize: 14,
                                                    // ),
                                                    SizedBox(height: 6),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        /*Spacer(),
                                                HomeCommonGradientBottom(
                                                  onTap: () {},
                                                  title: "Start Chat",
                                                  gradiantColor1: Colors.grey,
                                                  gradiantColor2: Colors.grey,
                                                ),*/
                                                        Spacer(),
                                                        //#GCW 28-12-2022 Remove Cancel button
                                                        // HomeCommonGradientBottom(
                                                        //   onTap: () {
                                                        //     //_showCloseCaseConfirmDialog(token, caseId, index);
                                                        //     //_showCloseDialog(context, apiToken, _scheduledCaseList[index].id.toString(), index);
                                                        //     _cancelCase(
                                                        //         apiToken,
                                                        //         _scheduledCaseModel
                                                        //             .post
                                                        //             .data![
                                                        //                 index]
                                                        //             .id
                                                        //             .toString(),
                                                        //         index);
                                                        //   },
                                                        //   title: "Cancel",
                                                        // ),
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
                                            setState(() {
                                              if (isOpen == index) {
                                                isOpen = null;
                                              } else {
                                                isOpen = index;
                                                _getAnswer(_scheduledCaseModel
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
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF747474),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "$clinicAddress",
                                                          style: GoogleFonts
                                                              .roboto(
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
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF747474),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          "$clinicState",
                                                          style: GoogleFonts
                                                              .roboto(
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
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(top: 3),
                                                              child: Text(
                                                                _getAnswerList
                                                                            .length >
                                                                        0
                                                                    ? _getAnswerList[
                                                                            0]
                                                                        .answers
                                                                    : '',
                                                                style:
                                                                    GoogleFonts
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
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                            Container(
                                                              margin: EdgeInsets
                                                                  .only(top: 3),
                                                              child: Text(
                                                                _getAnswerList
                                                                            .length >
                                                                        0
                                                                    ? _getAnswerList[
                                                                            1]
                                                                        .answers
                                                                    : '',
                                                                style:
                                                                    GoogleFonts
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
                                                  margin:
                                                      EdgeInsets.only(left: 18),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "What do you need help with?",
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 18, top: 3),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    _getAnswerList.length > 0
                                                        ? _getAnswerList[2]
                                                            .answers
                                                        : '',
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      color: Color(0xFF747474),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 15,
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 18),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Attached Files",
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 18,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 18),
                                                  alignment:
                                                      Alignment.centerLeft,
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
                                                              url: docList[
                                                                      docIndex]
                                                                  .trim(),
                                                              savedDir:
                                                                  _localPath,
                                                              fileName:
                                                                  fileAppend +
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
                                                                    child: docList[docIndex].split(".").last ==
                                                                            "jpg"
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
                                                                                "png"
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
                          )
                        : Visibility(
                            child: Container(
                              height: MediaQuery.of(context).size.height - 200,
                              width: double.infinity,
                            ),
                          ),
                  ),
                )
              : SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    //height:double.infinity,
                    height: 800,
                    child: Text(
                      "You have no Scheduled Cases\n Pull down to refresh",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.25,
                          color: AppColors.textPrussianBlueColor),
                    ),
                  ))),
      // Container(
      //   height: double.infinity,
      //   width: double.infinity,
      //   child: Column(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       Text(
      //         "You have no Scheduled Cases\n Pull down to refresh",
      //         textAlign: TextAlign.center,
      //         style: GoogleFonts.roboto(
      //             fontWeight: FontWeight.w400,
      //             fontSize: 16,
      //             letterSpacing: 0.25,
      //             color: AppColors.textPrussianBlueColor),
      //       ),
      //     ],
      //   ),
    );
  }

  _init(bool isRefresh) async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");
    //#GCW 31-01-2023 save time Zone
    timeZone = (sharedPreferences.getString("TimeZone") ?? "");
    //timezoneHelperSetup();
    Future.delayed(Duration(milliseconds: isRefresh ? 0 : 400), () async {
      var isInternetAvailable = await Utils.isInternetAvailable(context);
      if (!isInternetAvailable) {
        return;
      }
      AnimDialog.showLoadingDialog(context, _key, "");

      Provider.of<ScheduledDataProvider>(context, listen: false)
          .getPostData(context, apiToken);
    });

    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    });

    setState(() {});
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

  _cancelCase(String token, String caseId, int i) async {
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

          Provider.of<ScheduledDataProvider>(context, listen: false)
              .getPostData(context, apiToken);
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
}

Future<SpecialistScheduledCaseModel> getScheduledCase(context, token) async {
  //AnimDialog.showLoadingDialog1(context);

  final url = AppConstants.specialistGetScheduledCase;
  log('url--> $url');

  SpecialistScheduledCaseModel? result;
  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    log('getOpenCase response body--> ${response.body}');
    if (response.statusCode == 200) {
      //AnimDialog.dismissLoadingDialog(context);

      final item = json.decode(response.body);
      result = SpecialistScheduledCaseModel.fromJson(item);
    } else {
      //AnimDialog.dismissLoadingDialog(context);
      log("Something bad happened,try again after some time.");
    }
  } catch (e) {
    //AnimDialog.dismissLoadingDialog(context);
    log(e.toString());
  }
  return result!;
}

class ScheduledDataProvider with ChangeNotifier {
  SpecialistScheduledCaseModel post = SpecialistScheduledCaseModel();
  bool loading = false;

  getPostData(context, token) async {
    loading = true;
    post = await getScheduledCase(context, token);
    loading = false;

    notifyListeners();
  }
}
