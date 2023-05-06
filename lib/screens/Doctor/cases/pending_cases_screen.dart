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
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_connecting_screen.dart';
import 'package:vsod_flutter/screens/Doctor/model/GetAnswerModel.dart';
import 'package:vsod_flutter/screens/Doctor/model/PendingCasesModel.dart';
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

class PendingCasesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PendingCasesScreenState();
}

class _PendingCasesScreenState extends State<PendingCasesScreen> {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();
  late SharedPreferences sharedPreferences;
  List<PendingCasesModel> _pendingCaseList = <PendingCasesModel>[];
  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];
  var _profileImage;
  late String timeZone;
  ChangeTimeZone changeTimeZone = ChangeTimeZone();

  int? isOpen;
  List<String> docList = [];

  late List<ScheduleTimeModel> _timeList;
  bool _setTimeVisible = false;
  var _selectedDate;
  List<SlotModel> _slotList = <SlotModel>[];

  late String _localPath;

  List<String> slotTimeList = [];

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
    _timeList = [
      ScheduleTimeModel('0', '7:00 am', '7:00'),
      ScheduleTimeModel('0', '7:20 am', '7:20'),
      ScheduleTimeModel('0', '7:40 am', '7:40'),
      ScheduleTimeModel('0', '8:00 am', '8:00'),
      ScheduleTimeModel('0', '8:20 am', '8:20'),
      ScheduleTimeModel('0', '8:40 am', '8:40'),
      ScheduleTimeModel('0', '9:00 am', '9:00'),
      ScheduleTimeModel('0', '9:20 am', '9:20'),
      ScheduleTimeModel('0', '9:40 am', '9:40'),
      ScheduleTimeModel('0', '10:00 am', '10:00'),
      ScheduleTimeModel('0', '10:20 am', '10:20'),
      ScheduleTimeModel('0', '10:40 am', '10:40'),
      ScheduleTimeModel('0', '11:00 am', '11:00'),
      ScheduleTimeModel('0', '11:20 am', '11:20'),
      ScheduleTimeModel('0', '11:40 am', '11:40'),
      ScheduleTimeModel('0', '12:00 pm', '12:00'),
      ScheduleTimeModel('0', '12:20 pm', '12:20'),
      ScheduleTimeModel('0', '12:40 pm', '12:40'),
      ScheduleTimeModel('0', '1:00 pm', '13:00'),
      ScheduleTimeModel('0', '1:20 pm', '13:20'),
      ScheduleTimeModel('0', '1:40 pm', '13:40'),
      ScheduleTimeModel('0', '2:00 pm', '14:00'),
      ScheduleTimeModel('0', '2:20 pm', '14:20'),
      ScheduleTimeModel('0', '2:40 pm', '14:40'),
      ScheduleTimeModel('0', '3:00 pm', '15:00'),
      ScheduleTimeModel('0', '3:20 pm', '15:20'),
      ScheduleTimeModel('0', '3:40 pm', '15:40'),
      ScheduleTimeModel('0', '4:00 pm', '16:00'),
      ScheduleTimeModel('0', '4:20 pm', '16:20'),
      ScheduleTimeModel('0', '4:40 pm', '16:40'),
      ScheduleTimeModel('0', '5:00 pm', '17:00'),
      ScheduleTimeModel('0', '5:20 pm', '17:20'),
      ScheduleTimeModel('0', '5:40 pm', '17:40'),
      ScheduleTimeModel('0', '6:00 pm', '18:00'),
      ScheduleTimeModel('0', '6:20 pm', '18:20'),
      ScheduleTimeModel('0', '6:40 pm', '18:40')
    ];

    FlutterDownloader.registerCallback(downloadCallback);
  }

  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
              SizedBox(
                height: 8,
              ),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Container(
                    child: ListView.builder(
                        itemCount: _pendingCaseList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            child: Card(
                              margin: EdgeInsets.only(left: 15, right: 15, bottom: 30),
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
                                      margin: EdgeInsets.only(left: 18, right: 15),
                                      child: Row(
                                        children: [
                                          Container(
                                            child: Text(
                                              "#" + _pendingCaseList[index].id,
                                              style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.black),
                                            ),
                                          ),
                                          Spacer(),
                                          Container(
                                            margin: EdgeInsets.only(top: 3),
                                            child: Text(
                                              //#GCW 31-01-2023 change time format
                                              changeTimeZone.convertTimeDT(DateTime.parse(_pendingCaseList[index].updatedDate), timeZone),
                                              //DateFormat('MM/dd/yyyy|hh:mm a').format(convertUtcToUser(DateTime.parse(_pendingCaseList[index].updatedDate),timeZone)),
                                              style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFF747474)),
                                            ),
                                          ),
                                          SizedBox(width: 10,),
                                          Visibility(
                                            visible: _pendingCaseList[index].status == 'schedule',
                                            child: InkWell(
                                              onTap: () {
                                                _setTimeVisible = false;
                                                _slotList.clear();
                                                slotTimeList.clear();

                                                print("Schedule Option: " + _pendingCaseList[index].scheduleOption);

                                                slotTimeList = _pendingCaseList[index].scheduleOption.split(",");

                                                for (int i = 0; i < slotTimeList.length; i++) {

                                                  //print("ATIN TIME: ${slotTimeList[i].split(" ").last}");
                                                  SlotModel slotModel = SlotModel(DateFormat('MM/dd/yyyy').parse(slotTimeList[i].split(" ").first).toString(), slotTimeList[i].split(" ").last);
                                                  _slotList.add(slotModel);
                                                }

                                                _showScheduleDetailDialog(context, _pendingCaseList[index].id);
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
                                          /*Container(
                                            width: 60,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(Radius.circular(3.0)),
                                              color: Color(0xFFDFF3F0),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  height: 5,
                                                  width: 5,
                                                  margin: EdgeInsets.only(left: 8),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: const Color(0xFF018D10),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xFF018D10),
                                                        blurRadius: 8.0,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      "Active",
                                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 10, color: Color(0xFF018D10), letterSpacing: -0.17),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),*/
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 18, top: 14),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                                Radius.circular(100),
                                              ),
                                            ),
                                            child: _profileImage != ''
                                                ? ClipRRect(
                                                    borderRadius: BorderRadius.circular(100),
                                                    child: FadeInImage.assetNetwork(
                                                      placeholder: AppImages.defaultProfile,
                                                      image: AppConstants.publicImage + _profileImage,
                                                      height: 70,
                                                      width: 70,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  )
                                                : Image.asset(
                                                    AppImages.defaultProfile,
                                                    height: 70,
                                                    width: 70,
                                                  ),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    child: Text(
                                                      "Dr." + (sharedPreferences.getString("FirstName") ?? "") + " " + (sharedPreferences.getString("LastName") ?? ""),
                                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 18, color: Color(0xFF002045)),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: 3),
                                                    child: Text(
                                                      " ",
                                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 1.5, color: Color(0xFF747474)),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 15),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: CommonButtonGradient(
                                                            height: 36,
                                                            fontSize: 10,
                                                            buttonName: _pendingCaseList[index].status == 'schedule' ? AppStrings.reschedule : AppStrings.resubmit,
                                                            colorGradient1: AppColors.gradientBlue1,
                                                            colorGradient2: AppColors.gradientBlue2,
                                                            fontWeight: FontWeight.w500,
                                                            onTap: () {
                                                              if (_pendingCaseList[index].status == 'schedule') {
                                                                _setTimeVisible = false;
                                                                _slotList.clear();
                                                                slotTimeList.clear();
                                                                print("Schedule Option: " + _pendingCaseList[index].scheduleOption);

                                                                //print("ATIN TIME: ${slotTimeList[index].split(" ").last}");
                                                                slotTimeList = _pendingCaseList[index].scheduleOption.split(",");

                                                                for (int i = 0; i < slotTimeList.length; i++) {
                                                                  SlotModel slotModel =
                                                                      SlotModel(DateFormat('MM/dd/yyyy').parse(slotTimeList[i].split(" ").first).toString(), slotTimeList[i].split(" ").last);
                                                                  _slotList.add(slotModel);
                                                                }
                                                                _showScheduleDialog(context, _pendingCaseList[index].id);
                                                              } else {
                                                                _updateTime(_pendingCaseList[index].id, _pendingCaseList[index].channelName);
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: CommonButtonGradient(
                                                            height: 36,
                                                            fontSize: 10,
                                                            buttonName: AppStrings.cancel,
                                                            colorGradient1: AppColors.gradientRed1,
                                                            colorGradient2: AppColors.gradientRed1,
                                                            fontWeight: FontWeight.w500,
                                                            onTap: () {
                                                              _showCancelCasesConfirmDialog(_pendingCaseList[index].id, index);
                                                            },
                                                          ),
                                                        )
                                                      ],
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
                                      margin: EdgeInsets.only(left: 30, right: 30, top: 13),
                                      child: Divider(
                                        height: 1,
                                        color: Color(0xFFD6D6D6),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_pendingCaseList[index].isOpen == "1") {
                                          setState(() {
                                            _pendingCaseList[index].isOpen = "0";
                                          });
                                        } else {
                                          setState(() {
                                            for (int i = 0; i < _pendingCaseList.length; i++) {
                                              _pendingCaseList[i].isOpen = "0";
                                            }
                                            _pendingCaseList[index].isOpen = "1";
                                            _getAnswerList.clear();
                                            _getAnswer(_pendingCaseList[index].id.toString());
                                          });
                                        }
                                        setState(() {
                                          isOpen = index;
                                        });
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 5),
                                        child: Text(
                                          _pendingCaseList[index].isOpen == "0" ? 'View Details' : 'Hide Details',
                                          style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF6189ED)),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Visibility(
                                      visible: _pendingCaseList[index].isOpen == "1",
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
                                              margin: EdgeInsets.only(left: 18, right: 15),
                                              child: Row(
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
                        },),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
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

  //#GCW 31-01-2023
  // DateTime convertUtcToUser(DateTime time, String zone) {
  //   return TZDateTime.from(time, getLocation(zone));
  // }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    //#GCW 31-01-2023 save time Zone
    timeZone = (sharedPreferences.getString("TimeZone") ?? "");

    //timezoneHelperSetup();
    Future.delayed(Duration.zero, () {
      _profileImage = (sharedPreferences.getString("ProfilePicture") ?? '');
      _pendingCases();
    });
  }

  _pendingCases() async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorPendingCases;

    log('url--> $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      log('getPendingCases response status--> ${response.statusCode}');
      log('getPendingCases response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _pendingCaseList.clear();
          for (Map array in jsonData['data'] as List) {
            PendingCasesModel pendingCasesModel = PendingCasesModel(
              array['id'].toString(),
              array['status'],
              array['updated_at'],
              "0",
              array['channel_name'],
              array['schedule'] != null ? array['schedule']['schedule_options'] : '',
            );
            _pendingCaseList.add(pendingCasesModel);
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
      log("getPendingCases Error--> Error:-$e stackTrace:-$s");
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
              GetAnswerModel getAnswerModel = GetAnswerModel(array['id'].toString(), array['question'], array['answers'].toString());
              _getAnswerList.add(getAnswerModel);
            }



            docList = _getAnswerList[3].answers.substring(1, _getAnswerList[3].answers.length - 1).toString().split(",");
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

  _deleteCase(String caseId, int index) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorCancelCase;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

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
          _pendingCaseList.removeAt(index);
          Navigator.pop(context);

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

  _showCancelCasesConfirmDialog(String caseId, int index) async {

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
                child: Text(
                  "Are you sure you want to delete?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 16, color: AppColors.textPrussianBlueColor),
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
                          _deleteCase(caseId, index);
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

  _showScheduleDetailDialog(BuildContext context, String caseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                            "Schedule Request",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor),
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
                  child: Text(
                    //#GCW 05-02-2023
                    //"Every slot is of 20 minutes",
                    "You have requested this case for the times below. If case is not accepted, click \"re-schedule\" to submit different times or to resubmit as a live case",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
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
                          onTap: () {},
                          child: Column(
                            children: [
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  // "Jan, 2022",
                                  DateFormat('MMM,yyyy').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10, color: AppColors.textLightGrayColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('dd').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.2, color: AppColors.whiteColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('EEE').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.whiteColor),
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
                                      //#GCW 04-02-2023
                                      getScheduleTime(_slotList[index].slotTime),
                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.15, color: AppColors.textPrussianBlueColor, fontSize: 12),
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

  _showScheduleDialog(BuildContext context, String caseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                            "Schedule Request",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.25, color: AppColors.textPrussianBlueColor),
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
                  margin: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(
                    //#GCW 04-02-2023
                    "You have requested this case for the times below. If case is not accepted, click \"re-schedule\" to submit different times or to resubmit as a live case",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "You can choose 5 slots",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.25, color: AppColors.textDarkBlue),
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
                            _slotList.removeAt(index);
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
                                  DateFormat('MMM,yyyy').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 10, color: AppColors.textLightGrayColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('dd').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.2, color: AppColors.whiteColor),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child: Text(
                                  DateFormat('EEE').format(DateTime.parse(_slotList[index].date)),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.whiteColor),
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
                                      //_slotList[index].slotTime,
                                      //#GCW 04-02-2023
                                      getScheduleTime(_slotList[index].slotTime),
                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.15, color: AppColors.textPrussianBlueColor, fontSize: 12),
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
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          child: SfDateRangePicker(
                            view: DateRangePickerView.month,
                            selectionColor: AppColors.textPrussianBlueColor,
                            selectionMode: DateRangePickerSelectionMode.single,
                            minDate: DateTime.now(),
                            maxDate: DateTime(2100),
                            // initialSelectedDate: _selectedDate,
                            onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                              print(args.value);
                              _selectedDate = args.value;
                              _setTimeVisible = true;
                              setState(() {});

                              // Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _setTimeVisible,
                        child: Container(
                          width: 92,
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                  "Set Time",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.roboto(fontWeight: FontWeight.w400, fontSize: 12, letterSpacing: 0.2, color: AppColors.textDarkBlue),
                                ),
                              ),
                              Container(
                                height: 250,
                                margin: EdgeInsets.only(top: 5),
                                child: ListView.builder(
                                  itemCount: _timeList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      child: InkWell(
                                        onTap: () {
                                          if (_slotList.length == 5) {
                                            ToastMessage.showToastMessage(
                                              context: context,
                                              message: 'Max 5 Slot Select',
                                              duration: 3,
                                              backColor: Colors.red,
                                              position: StyledToastPosition.center,
                                            );
                                          } else {
                                            for (int i = 0; i < _slotList.length; i++) {
                                              if (_slotList[i].date == _selectedDate.toString()) {
                                                log("SLot Date ==> " + _slotList[i].date.toString());
                                                if (_slotList[i].slotTime == _timeList[index]._time1) {
                                                  ToastMessage.showToastMessage(
                                                    context: context,
                                                    message: 'Already Select',
                                                    duration: 3,
                                                    backColor: Colors.red,
                                                    position: StyledToastPosition.center,
                                                  );
                                                  return;
                                                }
                                              }
                                            }
                                            SlotModel slotModel = SlotModel(_selectedDate.toString(), _timeList[index]._time1);
                                            _slotList.add(slotModel);
                                          }
                                          setState(() {});
                                        },
                                        child: Card(
                                          color: AppColors.lightGreyColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          elevation: 0,
                                          child: Container(
                                            height: 28,
                                            width: 82,
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      _timeList[index]._time,
                                                      style: GoogleFonts.roboto(fontWeight: FontWeight.w700, letterSpacing: 0.15, color: AppColors.textPrussianBlueColor, fontSize: 12),
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
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                      String? slotTime = '';
                      for (int j = 0; j < _slotList.length; j++) {
                        slotTime = slotTime! + (DateFormat('MM/dd/yyyy').format(DateTime.parse(_slotList[j].date))).toString() + " " + _slotList[j].slotTime.toString() + ",";
                      }
                      if (slotTime != null && slotTime.length > 0) {
                        slotTime = slotTime.substring(0, slotTime.length - 1);
                      }
                      print("Slot Time ==> " + slotTime.toString());

                      if (slotTime != null && slotTime.length > 0) {
                        _startCase('schedule', caseId, slotTime);
                      } else {
                        ToastMessage.showToastMessage(
                          context: context,
                          message: 'Please select slot',
                          duration: 3,
                          backColor: Colors.red,
                          position: StyledToastPosition.center,
                        );
                      }
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

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"case_type": '$caseType', "case_id": '$caseId', "slots": '$slotTime'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

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

  _updateTime(String caseId, String channelName) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorUpdateTime;

    log('url--> $url');

    Map<String, String> headers = {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $token'};
    var body = json.encode({"case_id": '$caseId'});

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      log('doctorSubmitAnswer response status--> ${response.statusCode}');
      log('doctorSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorConnectingScreen(
                caseId: caseId,
                channelName: channelName,
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
