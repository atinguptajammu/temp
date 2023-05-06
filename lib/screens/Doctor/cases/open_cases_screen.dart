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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/model/OpenCasesModel.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_chat_screen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_helpushelpyou_screen.dart';
import 'package:vsod_flutter/screens/Doctor/model/GetAnswerModel.dart';
import 'package:vsod_flutter/screens/Doctor/model/SlotModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/utils/time_convert.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';

import '../../../utils/utils.dart';

class OpenCasesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OpenCasesScreenState();
}

class _OpenCasesScreenState extends State<OpenCasesScreen> {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;
  List<OpenCasesModel> _openCaseList = <OpenCasesModel>[];
  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];
  List<String> docList = [];

  List<String> slotTimeList = [];
  ChangeTimeZone changeTimeZone = ChangeTimeZone();

  int? isOpen;

  late String _localPath;

  List<SlotModel> _slotList = <SlotModel>[];

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";
  late String timeZone = "";

  @override
  void initState() {
    super.initState();
    _init();

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        strokeWidth: 3,
        displacement: 10.0,
        onRefresh: () {
          return _init();
        },
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Container(
                    child: ListView.builder(
                        itemCount: _openCaseList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Card(
                              margin: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 30),
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
                                      height: 10,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 18, right: 15),
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Text(
                                              "#" + _openCaseList[index].id,
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 16,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            margin: EdgeInsets.only(top: 3),
                                            // 06-11-22 | Task - 4 scheduler case time is wrong |gwc
                                            //todo
                                            child: Text(
                                              _openCaseList[index]
                                                  .selectedOption
                                                  .toString(),
                                              //#GCW 31-01-2023
                                              //changeTimeZone.convertTimeDT((DateTime.parse(_openCaseList[index].selectedOption.toString())),timeZone),
                                              // "${DateFormat('MM/dd/yyyy').add_jm().format(convertUtcToUser(DateTime.parse(_openCaseList[index].updatedDate.toString()), timeZone))}",
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  color: Color(0xFF747474)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Visibility(
                                            visible:
                                                _openCaseList[index].status ==
                                                    'scheduled',
                                            child: InkWell(
                                              onTap: () {
                                                _slotList.clear();
                                                slotTimeList.clear();
                                                print("ATIN Schedule Option: " +
                                                    _openCaseList[index]
                                                        .selectedSchedule);

                                                slotTimeList =
                                                    _openCaseList[index]
                                                        .selectedSchedule
                                                        .split(",");

                                                for (int i = 0; i < slotTimeList.length; i++) {
                                                  print("ATIN VAL: ${slotTimeList[i]}");
                                                  SlotModel slotModel =
                                                      SlotModel(
                                                          DateFormat('MM/dd/yyyy').parse(slotTimeList[i].split(" ").first).toString(),
                                                          slotTimeList[i].split(" ")[1]+" "+ slotTimeList[i].split(" ")[2]);
                                                  _slotList.add(slotModel);
                                                  for(int i=0;i<_slotList.length;i++){
                                                    print("${_slotList[i].slotTime}");
                                                  }
                                                }
                                                _showScheduleDialog(context,
                                                    _openCaseList[index].id);
                                              },
                                              child: Container(
                                                child: Image.asset(
                                                  AppImages.calenderIcon,
                                                  height: 22,
                                                  width: 22,
                                                  color: Color(0xFF003F5A),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 18, top: 14),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(100))),
                                            child: _openCaseList[index]
                                                        .profilePicture !=
                                                    ''
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder: AppImages
                                                          .defaultProfile,
                                                      image: AppConstants
                                                              .publicImage +
                                                          _openCaseList[index]
                                                              .profilePicture,
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
                                                      AppImages.defaultProfile,
                                                      height: 70,
                                                      width: 70,
                                                    ),
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Dr. " +
                                                          _openCaseList[index]
                                                              .specialistFirstName +
                                                          " " +
                                                          _openCaseList[index]
                                                              .specialistLastName,
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 18,
                                                          color: Color(
                                                              0xFF002045)),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        EdgeInsets.only(top: 3),
                                                    child: Text(
                                                      "${_openCaseList[index].specializationName}",
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14,
                                                          letterSpacing: 1.5,
                                                          color: Color(
                                                              0xFF747474)),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        _openCaseList[index]
                                                                    .status ==
                                                                'scheduled'
                                                            ? false
                                                            : true,
                                                    child: Container(
                                                      child: Row(
                                                        children: [
                                                          //25-10-2022 | Remove the close button in open cases for doctor | gwc
                                                          Expanded(
                                                              child: SizedBox(
                                                            height: 1,
                                                          )),
                                                          Expanded(
                                                            child:
                                                                CommonButtonGradient(
                                                              height: 36,
                                                              fontSize: 10,
                                                              buttonName: _openCaseList[
                                                                              index]
                                                                          .status ==
                                                                      'scheduled'
                                                                  ? AppStrings
                                                                      .reschedule
                                                                  : AppStrings
                                                                      .resume,
                                                              colorGradient1:
                                                                  AppColors
                                                                      .gradientBlue1,
                                                              colorGradient2:
                                                                  AppColors
                                                                      .gradientBlue2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              onTap: () {
                                                                if (_openCaseList[
                                                                            index]
                                                                        .status ==
                                                                    'scheduled') {
                                                                  // _setTimeVisible = false;
                                                                  // _slotList.clear();
                                                                  // slotTimeList.clear();
                                                                  // print("Schedule Option: " + _openCaseList[index].selectedSchedule);
                                                                  //
                                                                  // slotTimeList = _openCaseList[index].selectedSchedule.split(",");
                                                                  //
                                                                  // for (int i = 0; i < slotTimeList.length; i++) {
                                                                  //   SlotModel slotModel =
                                                                  //       SlotModel(DateFormat('MM/dd/yyyy').parse(slotTimeList[i].split(" ").first).toString(), slotTimeList[i].split(" ")[1]);
                                                                  //   _slotList.add(slotModel);
                                                                  // }
                                                                  // _showScheduleDialog(context, _openCaseList[index].id);
                                                                } else {
                                                                  _updateTime(
                                                                    _openCaseList[
                                                                            index]
                                                                        .id,
                                                                    _openCaseList[
                                                                            index]
                                                                        .channelName,
                                                                    _openCaseList[
                                                                            index]
                                                                        .specialistId,
                                                                    _openCaseList[
                                                                            index]
                                                                        .specialistFirstName,
                                                                    _openCaseList[
                                                                            index]
                                                                        .specialistLastName,
                                                                    _openCaseList[
                                                                            index]
                                                                        .profilePicture,
                                                                    _openCaseList[
                                                                            index]
                                                                        .seconds,
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ),
                                                          //
                                                          //25-10-2022 | Remove the close button in open cases for doctor | gwc
                                                          // Expanded(
                                                          //   child: CommonButtonGradient(
                                                          //     height: 36,
                                                          //     fontSize: 10,
                                                          //     buttonName: AppStrings.close,
                                                          //     colorGradient1: AppColors.gradientRed1,
                                                          //     colorGradient2: AppColors.gradientRed1,
                                                          //     fontWeight: FontWeight.w500,
                                                          //     onTap: () {
                                                          //       _showCloseCaseConfirmDialog(_openCaseList[index].id, index);
                                                          //     },
                                                          //   ),
                                                          // )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 30, right: 30, top: 13),
                                      child: Divider(
                                        height: 1,
                                        color: Color(0xFFD6D6D6),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_openCaseList[index].isOpen ==
                                            "1") {
                                          setState(() {
                                            _openCaseList[index].isOpen = "0";
                                          });
                                        } else {
                                          setState(() {
                                            for (int i = 0;
                                                i < _openCaseList.length;
                                                i++) {
                                              _openCaseList[i].isOpen = "0";
                                            }
                                            _openCaseList[index].isOpen = "1";
                                            _getAnswerList.clear();
                                            _getAnswer(_openCaseList[index]
                                                .id
                                                .toString());
                                          });
                                        }
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          _openCaseList[index].isOpen == "0"
                                              ? 'View Details'
                                              : 'Hide Details',
                                          style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              letterSpacing: 1,
                                              color: Color(0xFF6189ED)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible:
                                          _openCaseList[index].isOpen == "1",
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

                                            /*  Container(
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
                                                                child: docList[docIndex]
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
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // //#GCW 31-01-2023
  // DateTime convertUtcToUser(DateTime time, String zone) {
  //   return TZDateTime.from(time, getLocation(zone));
  // }
  //
  // //#GCW 31-01-2023
  // void timezoneHelperSetup() async {
  //   var byteData = await rootBundle.load('packages/timezone/data/latest_all.tzf');
  //   initializeDatabase(byteData.buffer.asUint8List());
  // }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    timeZone = (sharedPreferences.getString("TimeZone") ?? "");
    // timezoneHelperSetup();
    Future.delayed(Duration.zero, () {
      _getOpenCases();
    });
  }

  _getOpenCases() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorOpenCases;

    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getOpenCases response status--> ${response.statusCode}');
      log('getOpenCases response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _openCaseList.clear();
          for (Map array in jsonData['data'] as List) {
            print("HIMANSHU" + array.toString());
            OpenCasesModel openCasesModel = OpenCasesModel(
              array['id'].toString(),
              array['status'],
              array['updated_at'],
              array["specialist"] != null
                  ? array["specialist"]["first_name"]
                  : "",
              array["specialist"] != null
                  ? array["specialist"]["last_name"]
                  : "",
              //#GCW 27-12-2022
              array["specialist"] != null
                  ? array["specialist"]["profile_picture"] != null
                      ? array["specialist"]["profile_picture"]
                      : ""
                  : "",
              array['channel_name'],
              "0",
              array['status'] == 'active' ? '' : array['selected_option'] ?? "",
              array['specialist'] != null
                  ? array["specialist"]['id'].toString()
                  : "",
              array['specialization'] != null
                  ? array['specialization']['name']
                  : "",
              // 06-11-22 | Task - 4 scheduler case time is wrong |gwc
              array['selected_option'] != null ? array['selected_option'] : "",
              array['start_time'] ?? "",
              array['end_time'] ?? "",
              array['seconds'] != null ? array['seconds'].toString() : "",
            );
            _openCaseList.add(openCasesModel);
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
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
      log("getOpenCases Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getAnswer(String caseId) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
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
            log("Answer Length ==> " + jsonData['data'].length.toString());
            for (Map array in jsonData['data']['answers'] as List) {
              GetAnswerModel getAnswerModel = GetAnswerModel(
                  array['id'].toString(),
                  array['question'],
                  array['answers'].toString());
              _getAnswerList.add(getAnswerModel);
            }

            if (_getAnswerList[3].answers != null) {
              docList = _getAnswerList[3]
                  .answers
                  .substring(1, _getAnswerList[3].answers.length - 1)
                  .toString()
                  .split(",");
              log("Select File Type -->" + docList[0].toString());
            }

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

  _endCase(String caseId, int index) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorEndCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );
          _openCaseList.removeAt(index);
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HelpUsScreen(
                caseId: caseId,
              ),
            ),
          );

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

  _showCloseCaseConfirmDialog(String caseId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: Text(
                  "Are you sure you want to close case?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.textPrussianBlueColor),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: CommonButtonGradient(
                        height: 35,
                        fontSize: 14,
                        buttonName: AppStrings.cancel,
                        colorGradient1: AppColors.gradientRed1,
                        colorGradient2: AppColors.gradientRed2,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Expanded(
                      child: CommonButtonGradient(
                        height: 35,
                        fontSize: 14,
                        buttonName: AppStrings.yes,
                        colorGradient1: AppColors.gradientGreen1,
                        colorGradient2: AppColors.gradientGreen2,
                        onTap: () {
                          _endCase(caseId, index);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  _updateTime(
    String caseId,
    String channelName,
    String specialistId,
    String specialistFirstName,
    String specialistLastName,
    String specialistProfile,
    String seconds,
  ) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorUpdateTime;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorChatScreen(
                channelName: channelName,
                firstName: specialistFirstName,
                lastName: specialistLastName,
                degree: '',
                specialistProfile: specialistProfile,
                caseId: caseId,
                specialistId: specialistId,
                caseSeconds: seconds,
              ),
            ),
          );
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

  _findLocalPath() async {
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

  _showScheduleDialog(BuildContext context, String caseId) {
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
                )),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(left: 35),
                          alignment: Alignment.center,
                          child: Text(
                            "Scheduled Case",
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
                            height: 35,
                            width: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(5),
                  padding: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: Text(
                    "This case is scheduled for the time below. When the scheduled time occurs, a green “Join” button will appear. Refresh if the scheduled time has occurred and the “Join” button isn’t appearing.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 0.25,
                        color: AppColors.textDarkBlue),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Container(
                  height: _slotList.length > 0 ? 103 : 5,
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: ListView.builder(
                    itemCount: _slotList.length,
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        width: 65,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientScheduleRectangle1,
                              AppColors.gradientScheduleRectangle2,
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
                            setState(() {});
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  // "Jan, 2022",
                                  DateFormat('MMM,yyyy').format(
                                      DateTime.parse(_slotList[index].date)),
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
                                  DateFormat('dd').format(
                                      DateTime.parse(_slotList[index].date)),
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
                                  DateFormat('EEE').format(
                                      DateTime.parse(_slotList[index].date)),
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
                                      //#GCW 06-02-2022
                                      //_showScheduleDialogTime(_slotList[index].slotTime),
                                      //getScheduleTime(_slotList[index].slotTime),
                                        _slotList[index].slotTime,
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
                SizedBox(
                  height: 25,
                ),
              ],
            ),
          );
        });
      },
    );
  }

  //#GCW 05-02-2023
  String getScheduleTime(String slotTime) {
    int hour, min;
    final split_time = slotTime.split(":");
    hour = int.parse(split_time[0]);
    min = int.parse(split_time[1]);
    String am_pm = "am";
    if (hour >= 12) {
      am_pm = "pm";
    }
    if (hour > 12) {
      hour = hour - 12;
    }
    else if(hour == 0){
      hour = 12;
    }
    String result = "";
    if (hour < 10) {
      result += "0$hour:";
    }
    else{
      result += "$hour:";
    }
    if (min < 10) {
      result += "0$min ";
    }
    else{
      result += "$min ";
    }
    result += am_pm;
    return result;
  }

  _startCase(String caseType, String caseId, String slotTime) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorStartCase;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode(
        {"case_type": '$caseType', "case_id": '$caseId', "slots": '$slotTime'});

    log('body--> $body');

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.pop(context);
          ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );
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

class ScheduleTimeModel {
  String _selected;
  String _time;
  String _time1;

  ScheduleTimeModel(this._selected, this._time, this._time1);

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get selected => _selected;

  set selected(String value) {
    _selected = value;
  }

  String get time1 => _time1;

  set time1(String value) {
    _time1 = value;
  }
}
