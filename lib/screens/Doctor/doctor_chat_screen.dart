import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

// agora update
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsod_flutter/screens/Doctor/DoctorDashBoardScreen.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_helpushelpyou_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../utils/camera.dart';

class DoctorChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DoctorChatScreenState();
  String channelName;
  String firstName;
  String lastName;
  String degree;
  String specialistProfile;
  String caseId;
  String specialistId;
  String caseSeconds;

  DoctorChatScreen({
    required this.channelName,
    required this.firstName,
    required this.lastName,
    required this.degree,
    required this.specialistProfile,
    required this.caseId,
    required this.specialistId,
    required this.caseSeconds,
  });
}

class _DoctorChatScreenState extends State<DoctorChatScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  //#GCW 15-01-2023
  late bool joinPopupShown = false;
  late Stream<DatabaseEvent> joinVideoCallLister;

  //#GCW 14-01-2023
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref("cases");

  late AgoraRtmClient _client;
  bool _sendButton = false;
  List<Message> _infoStrings = <Message>[];

  late AnimationController controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: 700));
  late Animation<Offset> offset =
      Tween<Offset>(begin: Offset.zero, end: Offset(0.0, -1.0))
          .animate(controller);

  //#GCW 20-12-2022 by default full chat screen
  bool _fullScreenChat = true;

  bool _expandVideoCall = false;

  //Agora Video Calling
  bool _joined = false;
  bool _connectVideoCall = false;
  late RtcEngine engine;
  int _remoteUid = 0;

  //bool _switch = false;
  late String agoraRtcToken;
  late String agoraRtmToken;

  bool muted = false;
  bool isOtherVideoMuted = false;
  bool isOtherUserJoined = false;

  bool disableCamera = true;
  bool showExtendButton = false;

  TextEditingController sendMessageController = new TextEditingController();

  late SharedPreferences sharedPreferences;

  //late String _localPath;

  String recordingUid = "";
  String recordingRid = "";
  String recordingSid = "";
  String recordingToken = "";

  Timer? countdownTimer;
  Duration myDuration = Duration(minutes: 20);

  void startTimer() {
    //#GCW 31-12-2022 App seconds not available for scheduled cases, fixed below
    if (widget.caseSeconds != "") {
      myDuration = Duration(seconds: int.parse(widget.caseSeconds));
    } else {
      myDuration = Duration(seconds: 0);
    }
    _init();
    //#GCW 28-12-2022 AUTO CASE END REMOVAL
    // if (widget.caseSeconds != "" &&
    //     !widget.caseSeconds.contains("-") &&
    //     widget.caseSeconds != "0") {
    //   print("Time remaining == ${widget.caseSeconds}");
    //   myDuration = Duration(seconds: int.parse(widget.caseSeconds));
    //   _init();
    // } else {
    //   print("Time is over. Call the end case API");
    //   myDuration = Duration(seconds: 0);
    //   Future.delayed(Duration.zero, () {
    //     _endCase(widget.caseId, context);
    //   });
    // }

    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds >= 1
          ? myDuration.inSeconds - reduceSecondsBy
          : 0;
      //#GCW 28-12-022 AUTO CASE END REMOVAL
      // if (seconds <= 0) {
      //   countdownTimer!.cancel();
      //   showExtendButton = false;
      //   _endCase(widget.caseId, context);
      // } else {
      //   myDuration = Duration(seconds: seconds);
      //   if (seconds <= 180) {
      //     showExtendButton = true;
      //   } else {
      //     showExtendButton = false;
      //   }
      //
      //   if (seconds == 180) {
      //     _showTimeExtendSheet(widget.caseId);
      //   }
      // }
      myDuration = Duration(seconds: seconds);
      if (seconds <= 0) {
        countdownTimer!.cancel();
        showExtendButton = false;
      } else if (seconds <= 180) {
        showExtendButton = true;
      } else {
        showExtendButton = false;
      }

      if (seconds == 180) {
        _showTimeExtendSheet(widget.caseId);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    //_log("Hi,i'm Dr. ${this.widget.firstName} ${this.widget.lastName}\nHow are you?", 0);
    //_init();
    startTimer();
    //#GCW 24-01-2023 join call popup listener
    joinVideoCallLister = ref.onValue;
    _initVideoCallListener();
    //#GCW 28-12-2022 join call pop up as soon as you open chat
    // FlutterDownloader.registerCallback(downloadCallback);
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _showMyDialog();
    // });
  }

  @override
  void dispose() {
    super.dispose();
    //await engine.leaveChannel();
    _logoutEndCase();
    _leave(context);
    countdownTimer!.cancel();
    //#GCW 24-01-2023 release resources
    closeAgora();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  //#GCW 22-12-2022
  _showMyDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 30),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            title: Center(child: Text("Join Call?")),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        joinPopupShown = false;
                        Navigator.pop(context);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.red,
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    MaterialButton(
                      onPressed: () {
                        _expandVideoCall = true;
                        joinPopupShown = false;
                        Navigator.pop(context);
                        _getAgoraRtcToken(this.widget.channelName);
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      color: Colors.green,
                      child: Text(
                        "Continue",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');

    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFEFF7FF),
        body: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: !_fullScreenChat ? 360 : 106,
                  ),
                  //case time
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: 10),
                        Text(
                          'Case Time:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '$minutes:$seconds',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // SizedBox(width: 10),
                        //#GCW 20-12-2022

                        //Extend Time
                        MaterialButton(
                          onPressed: () {
                            // _showTimeExtendSheet(widget.caseId);
                            // print("TIMER: ${myDuration.inSeconds}");
                            // myDuration = Duration(minutes: 1);
                            // print("TIMER: ${myDuration.inSeconds}");
                            _addTime(widget.caseId, context);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          color: Colors.red,
                          height: 30,
                          elevation: 0,
                          child: Text(
                            'Extend Time',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        //#GCW 20-12-2022 change join call button position
                        InkWell(
                          onTap: () {
                            if (_joined) {
                              //#GCW 15-01-2023
                              joinPopupShown = false;
                              _leave(context);
                            } else {
                              _expandVideoCall = true;
                              //Navigator.pop(context);
                              _setVideoCallStatus();
                              _getAgoraRtcToken(this.widget.channelName);
                              //#GCW 18-01-2023 directly join call
                              // showDialog(
                              //   context: context,
                              //   barrierDismissible: false,
                              //   builder: (BuildContext context) {
                              //     return BackdropFilter(
                              //       filter:
                              //           ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                              //       child: AlertDialog(
                              //         shape: RoundedRectangleBorder(
                              //             borderRadius:
                              //                 BorderRadius.circular(20.0)),
                              //         backgroundColor: Colors.white,
                              //         insetPadding:
                              //             EdgeInsets.symmetric(horizontal: 30),
                              //         clipBehavior: Clip.antiAliasWithSaveLayer,
                              //         title: Center(child: Text("Join Call?")),
                              //         content: Column(
                              //           mainAxisSize: MainAxisSize.min,
                              //           children: [
                              //             SizedBox(
                              //               height: 20,
                              //             ),
                              //             Row(
                              //               mainAxisAlignment:
                              //                   MainAxisAlignment.spaceEvenly,
                              //               children: [
                              //                 MaterialButton(
                              //                   onPressed: () {
                              //                     Navigator.pop(context);
                              //                   },
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(5),
                              //                   ),
                              //                   color: Colors.red,
                              //                   child: Text(
                              //                     "Cancel",
                              //                     style: GoogleFonts.roboto(
                              //                       fontWeight: FontWeight.w600,
                              //                       color: AppColors.whiteColor,
                              //                       fontSize: 14,
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 SizedBox(
                              //                   width: 20,
                              //                 ),
                              //                 MaterialButton(
                              //                   onPressed: () {
                              //                     _expandVideoCall = true;
                              //                     Navigator.pop(context);
                              //                     _getAgoraRtcToken(
                              //                         this.widget.channelName);
                              //                   },
                              //                   shape: RoundedRectangleBorder(
                              //                     borderRadius:
                              //                         BorderRadius.circular(5),
                              //                   ),
                              //                   color: Colors.green,
                              //                   child: Text(
                              //                     "Continue",
                              //                     style: GoogleFonts.roboto(
                              //                       fontWeight: FontWeight.w600,
                              //                       color: AppColors.whiteColor,
                              //                       fontSize: 14,
                              //                     ),
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            child: Card(
                              color: _joined
                                  ? AppColors.boxRedColor
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              elevation: 5,
                              shadowColor: Colors.black.withOpacity(0.45),
                              child: Container(
                                height: 34,
                                width: 65,
                                alignment: Alignment.center,
                                child: Text(
                                  _joined ? "End Call" : "Join Call",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.17,
                                    color: AppColors.whiteColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      margin: EdgeInsets.only(bottom: 15, left: 28, right: 45),
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: _infoStrings.length,
                          shrinkWrap: true,
                          reverse: true,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible: _infoStrings[index].myMsg == 0,
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            child: _infoStrings[index]
                                                        .msg
                                                        .split(" ")
                                                        .first ==
                                                    "Image"
                                                ? InkWell(
                                                    onTap: () async {
                                                      await launch(
                                                          _infoStrings[index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Image : ",
                                                                  "")
                                                              .trim());
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          placeholder: AppImages
                                                              .defaultPlaceHolder,
                                                          image: _infoStrings[
                                                                  index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Image : ",
                                                                  ""),
                                                          height: 150,
                                                          width: 80,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : _infoStrings[index]
                                                            .msg
                                                            .split(" ")
                                                            .first ==
                                                        "Doc"
                                                    ? InkWell(
                                                        onTap: () async {
                                                          await launch(
                                                              _infoStrings[
                                                                      index]
                                                                  .msg
                                                                  .replaceAll(
                                                                      "Doc : ",
                                                                      "")
                                                                  .trim());
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            'Open File',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts.roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .textDarkBlue),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(21),
                                                        ),
                                                        child: Text(
                                                          _infoStrings[index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Message : ",
                                                                  ""),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: GoogleFonts.roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .textDarkBlue),
                                                        ),
                                                      ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text(
                                              //#GCW 20-12-2022 change date format
                                              DateFormat('h:mm a').format(
                                                  DateTime.parse(
                                                      _infoStrings[index]
                                                          .dateTime)),
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  letterSpacing: 0.4,
                                                  color:
                                                      AppColors.textBlackColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _infoStrings[index].myMsg == 1,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Visibility(
                                            visible: _infoStrings[index].msg ==
                                                'User Join Successfully',
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 10),
                                              decoration: BoxDecoration(
                                                color: Color(0xff348FF8)
                                                    .withOpacity(0.14),
                                                borderRadius:
                                                    BorderRadius.circular(21),
                                              ),
                                              child: Text(
                                                _infoStrings[index].msg,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.roboto(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color:
                                                        AppColors.textDarkBlue),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child: _infoStrings[index]
                                                        .msg
                                                        .split(" ")
                                                        .first ==
                                                    "Image"
                                                ? InkWell(
                                                    onTap: () async {
                                                      await launch(
                                                          _infoStrings[index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Image : ",
                                                                  "")
                                                              .trim());
                                                    },
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5),
                                                      margin:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xff348FF8)
                                                            .withOpacity(0.14),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        child: FadeInImage
                                                            .assetNetwork(
                                                          placeholder: AppImages
                                                              .defaultPlaceHolder,
                                                          image: _infoStrings[
                                                                  index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Image : ",
                                                                  ""),
                                                          height: 150,
                                                          width: 80,
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : _infoStrings[index]
                                                            .msg
                                                            .split(" ")
                                                            .first ==
                                                        "Doc"
                                                    ? InkWell(
                                                        onTap: () async {
                                                          await launch(
                                                              _infoStrings[
                                                                      index]
                                                                  .msg
                                                                  .replaceAll(
                                                                      "Doc : ",
                                                                      "")
                                                                  .trim());
                                                        },
                                                        child: Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                    0xff348FF8)
                                                                .withOpacity(
                                                                    0.14),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            'Open File',
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts.roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 14,
                                                                color: AppColors
                                                                    .textDarkBlue),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xff348FF8)
                                                                  .withOpacity(
                                                                      0.14),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(21),
                                                        ),
                                                        child: Text(
                                                          _infoStrings[index]
                                                              .msg
                                                              .replaceAll(
                                                                  "Message : ",
                                                                  ""),
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: GoogleFonts.roboto(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              color: AppColors
                                                                  .textDarkBlue),
                                                        ),
                                                      ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 5),
                                            child: Text(
                                              DateFormat('h:mm a').format(
                                                  DateTime.parse(
                                                      _infoStrings[index]
                                                          .dateTime)),
                                              textAlign: TextAlign.right,
                                              style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14,
                                                  letterSpacing: 0.4,
                                                  color:
                                                      AppColors.textBlackColor),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.only(left: 20, right: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: AppColors.blackColor.withOpacity(0.25),
                          width: 0.5),
                      borderRadius: BorderRadius.circular(23.0),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: TextField(
                            enabled: true,
                            controller: sendMessageController,
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              letterSpacing: 0.75,
                              color: AppColors.textDarkBlue,
                            ),
                            maxLines: 4,
                            minLines: 1,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 3),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              filled: false,
                              fillColor: Colors.transparent,
                              hintText: 'Type a Message...',
                              hintStyle: GoogleFonts.roboto(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.75,
                                color: Color(0xffB4B4B4),
                              ),
                            ),
                            onChanged: (value) {
                              if (value.length > 0) {
                                setState(() {
                                  _sendButton = true;
                                });
                              } else {
                                setState(() {
                                  _sendButton = false;
                                });
                              }
                            },
                          ),
                        ),
                        Visibility(
                          visible: !_sendButton,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        type: FileType.custom,
                                        allowedExtensions: ['pdf'],
                                      );
                                      if (result != null) {
                                        String? filepath =
                                            result.files.single.path;
                                        String? filetype =
                                            result.files.single.extension;
                                        print("FileType ==> $filetype");
                                        print("FilePath ==> $filepath");
                                        File _selectedFile = File(filepath!);

                                        if (_selectedFile != null) {
                                          final bytes = _selectedFile
                                              .readAsBytesSync()
                                              .lengthInBytes;
                                          final kb = bytes / 1024;
                                          final mb = kb / 1024;

                                          print("FileSize == $mb mb");

                                          if (mb > 10) {
                                            ToastMessage.showToastMessage(
                                              context: context,
                                              message:
                                                  "Maximum 10 MB of file size limit has reached",
                                              duration: 3,
                                              backColor: Colors.red,
                                              position:
                                                  StyledToastPosition.center,
                                            );
                                          } else {
                                            if (filetype == "pdf" ||
                                                filetype == "doc") {
                                              _uploadDocument(_selectedFile);
                                            } else {
                                              _uploadImage(_selectedFile);
                                            }
                                          }
                                        }
                                        setState(() {});
                                      } else {
                                        // User canceled the picker
                                      }
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 15),
                                      child: Image.asset(
                                        AppImages.attachmentIcon,
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.contain,
                                        color: AppColors.textDarkGrey1,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _showImagePicker(context);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(right: 15),
                                      child: Image.asset(
                                        AppImages.cameraWhiteIcon,
                                        height: 24,
                                        width: 24,
                                        fit: BoxFit.contain,
                                        color: AppColors.textDarkGrey1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _sendButton,
                          child: InkWell(
                            onTap: () {
                              if (sendMessageController.text.isNotEmpty) {
                                _toggleSendPeerMessage(
                                    peerUid:
                                        '${this.widget.specialistId}-${this.widget.caseId}',
                                    message: "Message : " +
                                        sendMessageController.text.toString());
                                //_pushMessage(this.widget.caseId, 'Message', sendMessageController.text.toString());
                                setState(() {
                                  sendMessageController.text = "";
                                  _sendButton = false;
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 15),
                              child: Image.asset(
                                AppImages.sendMessageIcon,
                                height: 24,
                                width: 24,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    height: _expandVideoCall
                        ? MediaQuery.of(context).size.height
                        : !_fullScreenChat
                            ? 360
                            : 106,
                    child: Stack(
                      children: [
                        SlideTransition(
                          position: offset,
                          child: Container(
                            margin: EdgeInsets.only(top: 106),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: _expandVideoCall
                                        ? MediaQuery.of(context).size.height -
                                            155
                                        : 202,
                                    //#GCW 31-12-2022 Remove profile picture and add black bg with specialist name on it
                                    // child: Stack(
                                    //   children: [
                                    //     Container(
                                    //       alignment: Alignment.center,
                                    //       child: !_connectVideoCall ||
                                    //               !isOtherUserJoined
                                    //           ? Container(
                                    //               child: this
                                    //                           .widget
                                    //                           .specialistProfile !=
                                    //                       ''
                                    //                   ? ClipRRect(
                                    //                       borderRadius:
                                    //                           BorderRadius
                                    //                               .circular(0),
                                    //                       child:
                                    //                   Image.asset(AppImages
                                    //                       .profilePlaceHolder,)
                                    //                       // FadeInImage
                                    //                       //     .assetNetwork(
                                    //                       //   placeholder: AppImages
                                    //                       //       .profilePlaceHolder,
                                    //                       //   image: AppConstants
                                    //                       //           .publicImage +
                                    //                       //       this
                                    //                       //           .widget
                                    //                       //           .specialistProfile,
                                    //                       //   width:
                                    //                       //       double.infinity,
                                    //                       //   fit:
                                    //                       //       BoxFit.fitWidth,
                                    //                       // ),
                                    //                     )
                                    //                   : Image.asset(
                                    //                       AppImages
                                    //                           .profilePlaceHolder,
                                    //                       height: _expandVideoCall
                                    //                           ? MediaQuery.of(
                                    //                                       context)
                                    //                                   .size
                                    //                                   .height -
                                    //                               155
                                    //                           : 202,
                                    //                       width:
                                    //                           double.infinity,
                                    //                       fit: BoxFit.fitWidth,
                                    //                     ),
                                    //             )
                                    //           : Center(
                                    //               child: isOtherVideoMuted
                                    //                   ? Container(
                                    //                       alignment:
                                    //                           Alignment.center,
                                    //                       color: Colors.black,
                                    //                       height: _expandVideoCall
                                    //                           ? MediaQuery.of(
                                    //                                       context)
                                    //                                   .size
                                    //                                   .height -
                                    //                               155
                                    //                           : 202,
                                    //                       width:
                                    //                           double.infinity,
                                    //                       child: Text(
                                    //                         "${widget.firstName} ${widget.lastName}",
                                    //                         style: GoogleFonts
                                    //                             .roboto(
                                    //                           color:
                                    //                               Colors.white,
                                    //                           fontSize: 15,
                                    //                           fontWeight:
                                    //                               FontWeight
                                    //                                   .bold,
                                    //                         ),
                                    //                       ),
                                    //                     )
                                    //                   : _renderRemoteVideo(),
                                    //             ),
                                    //     ),
                                    //     Align(
                                    //       alignment: Alignment.topLeft,
                                    //       child: Container(
                                    //         width: _expandVideoCall ? 100 : 75,
                                    //         height:
                                    //             _expandVideoCall ? 150 : 100,
                                    //         color: !disableCamera
                                    //             ? Colors.black
                                    //             : Colors.transparent,
                                    //         child: !disableCamera
                                    //             ? Center(
                                    //                 child: Icon(
                                    //                   Icons.videocam_off,
                                    //                   color: Colors.white,
                                    //                   size: 24,
                                    //                 ),
                                    //               )
                                    //             : GestureDetector(
                                    //                 onTap: () {
                                    //                   setState(() {
                                    //                     // _switch = !_switch;
                                    //                   });
                                    //                 },
                                    //                 child: Center(
                                    //                   //child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                                    //                   child:
                                    //                       _renderLocalPreview(),
                                    //                 ),
                                    //               ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    child: Stack(
                                      children: [
                                        Container(
                                          alignment: Alignment.center,
                                          child: !_connectVideoCall ||
                                                  !isOtherUserJoined ||
                                                  isOtherVideoMuted
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  color: Colors.black,
                                                  height: _expandVideoCall
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .height -
                                                          155
                                                      : 202,
                                                  width: double.infinity,
                                                  child: Text(
                                                    "${widget.firstName} ${widget.lastName}",
                                                    style: GoogleFonts.roboto(
                                                      color: Colors.white,
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )
                                              : _renderRemoteVideo(),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Container(
                                            width: _expandVideoCall ? 100 : 75,
                                            height:
                                                _expandVideoCall ? 150 : 100,
                                            color: !disableCamera
                                                ? Colors.black
                                                : Colors.transparent,
                                            child: !disableCamera
                                                ? Center(
                                                    child: Icon(
                                                      Icons.videocam_off,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                  )
                                                : GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // _switch = !_switch;
                                                      });
                                                    },
                                                    child: Center(
                                                      //child: _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                                                      child:
                                                          _renderLocalPreview(),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  color: AppColors.headerColor,
                                  height: 52,
                                  child: Row(
                                    children: [
                                      Visibility(
                                        visible: _joined,
                                        child: InkWell(
                                          onTap: () {
                                            //_getAgoraRtcToken(this.widget.channelName);
                                            //_agoraAcquire(widget.channelName);
                                            _onToggleCamera();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: Icon(
                                              disableCamera
                                                  ? Icons.videocam_rounded
                                                  : Icons.videocam_off,
                                              color: disableCamera
                                                  ? Colors.white
                                                  : Colors.red,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _joined,
                                        child: InkWell(
                                          onTap: () async {
                                            _onToggleMute();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: Icon(
                                              muted ? Icons.mic_off : Icons.mic,
                                              color: muted
                                                  ? Colors.red
                                                  : Colors.white,
                                              size: 24.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _joined,
                                        child: InkWell(
                                          onTap: () async {
                                            _onSwitchCamera();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: Icon(
                                              Icons.switch_camera,
                                              color: Colors.white,
                                              size: 22.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _joined,
                                        child: InkWell(
                                          onTap: () async {
                                            setState(() {
                                              _expandVideoCall =
                                                  !_expandVideoCall;
                                            });
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: Icon(
                                              _expandVideoCall
                                                  ? Icons.fullscreen_exit
                                                  : Icons.fullscreen,
                                              color: Colors.white,
                                              size: 22.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          switch (controller.status) {
                                            case AnimationStatus.completed:
                                              controller.reverse();
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
                                                  () {
                                                setState(() {
                                                  _fullScreenChat = true;
                                                });
                                              });
                                              break;
                                            case AnimationStatus.dismissed:
                                              controller.forward();
                                              Future.delayed(
                                                  Duration(milliseconds: 600),
                                                  () {
                                                setState(() {
                                                  _fullScreenChat = true;
                                                });
                                              });
                                              break;
                                            default:
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 28),
                                          child: Image.asset(
                                            AppImages.upArrowIcon,
                                            width: 29,
                                            height: 29,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          if (_joined) {
                                            //#GCW 15-01-2023 one time popup shown
                                            joinPopupShown = false;
                                            _leave(context);
                                          } else {
                                            //#GCW 18-10-2023
                                            //#GCW 27-10-2023 by default full screen
                                            _expandVideoCall = true;
                                            //Navigator.pop(context);
                                            _setVideoCallStatus();
                                            _getAgoraRtcToken(
                                                this.widget.channelName);
                                            // showDialog(
                                            //   context: context,
                                            //   barrierDismissible: false,
                                            //   builder: (BuildContext context) {
                                            //     return BackdropFilter(
                                            //       filter: ImageFilter.blur(
                                            //           sigmaX: 5, sigmaY: 5),
                                            //       child: AlertDialog(
                                            //         shape:
                                            //         RoundedRectangleBorder(
                                            //             borderRadius:
                                            //             BorderRadius
                                            //                 .circular(
                                            //                 20.0)),
                                            //         backgroundColor:
                                            //         Colors.white,
                                            //         insetPadding:
                                            //         EdgeInsets.symmetric(
                                            //             horizontal: 30),
                                            //         clipBehavior: Clip
                                            //             .antiAliasWithSaveLayer,
                                            //         title: Center(
                                            //             child:
                                            //             Text("Join Call?")),
                                            //         content: Column(
                                            //           mainAxisSize:
                                            //           MainAxisSize.min,
                                            //           children: [
                                            //             SizedBox(
                                            //               height: 20,
                                            //             ),
                                            //             Row(
                                            //               mainAxisAlignment:
                                            //               MainAxisAlignment
                                            //                   .spaceEvenly,
                                            //               children: [
                                            //                 MaterialButton(
                                            //                   onPressed: () {
                                            //                     Navigator.pop(
                                            //                         context);
                                            //                   },
                                            //                   shape:
                                            //                   RoundedRectangleBorder(
                                            //                     borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                         5),
                                            //                   ),
                                            //                   color: Colors.red,
                                            //                   child: Text(
                                            //                     "Cancel",
                                            //                     style:
                                            //                     GoogleFonts
                                            //                         .roboto(
                                            //                       fontWeight:
                                            //                       FontWeight
                                            //                           .w600,
                                            //                       color: AppColors
                                            //                           .whiteColor,
                                            //                       fontSize: 14,
                                            //                     ),
                                            //                   ),
                                            //                 ),
                                            //                 SizedBox(
                                            //                   width: 20,
                                            //                 ),
                                            //                 MaterialButton(
                                            //                   onPressed: () {
                                            //                     //#GCW 20-12-2022
                                            //                     _expandVideoCall =
                                            //                     true;
                                            //                     Navigator.pop(
                                            //                         context);
                                            //                     _getAgoraRtcToken(this
                                            //                         .widget
                                            //                         .channelName);
                                            //                   },
                                            //                   shape:
                                            //                   RoundedRectangleBorder(
                                            //                     borderRadius:
                                            //                     BorderRadius
                                            //                         .circular(
                                            //                         5),
                                            //                   ),
                                            //                   color:
                                            //                   Colors.green,
                                            //                   child: Text(
                                            //                     "Continue",
                                            //                     style:
                                            //                     GoogleFonts
                                            //                         .roboto(
                                            //                       fontWeight:
                                            //                       FontWeight
                                            //                           .w600,
                                            //                       color: AppColors
                                            //                           .whiteColor,
                                            //                       fontSize: 14,
                                            //                     ),
                                            //                   ),
                                            //                 ),
                                            //               ],
                                            //             ),
                                            //           ],
                                            //         ),
                                            //       ),
                                            //     );
                                            //   },
                                            // );
                                          }
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(right: 8),
                                          child: Card(
                                            color: _joined
                                                ? AppColors.boxRedColor
                                                : Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            elevation: 5,
                                            shadowColor:
                                                Colors.black.withOpacity(0.45),
                                            child: Container(
                                              height: 34,
                                              width: 65,
                                              alignment: Alignment.center,
                                              child: Text(
                                                _joined
                                                    ? "End Call"
                                                    : "Join Call",
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: -0.17,
                                                  color: AppColors.whiteColor,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      //#GCW 26-01-2023 Add end call button when full screen
                                      // (_joined && _expandVideoCall)
                                      //     ? InkWell(
                                      //   onTap: () {
                                      //     _leave(context);
                                      //   },
                                      //   child: Container(
                                      //     margin:
                                      //     EdgeInsets.only(right: 8),
                                      //     //#GCW 31-12-2022 remove upper end button
                                      //     child: Card(
                                      //       color:  AppColors.boxRedColor,
                                      //       shape: RoundedRectangleBorder(
                                      //         borderRadius:
                                      //         BorderRadius.circular(4),
                                      //       ),
                                      //       elevation: 5,
                                      //       shadowColor:
                                      //       Colors.black.withOpacity(0.45),
                                      //       child: Container(
                                      //         height: 34,
                                      //         width: 65,
                                      //         alignment: Alignment.center,
                                      //         child: Text("End Call",
                                      //           style: GoogleFonts.roboto(
                                      //             fontWeight: FontWeight.w500,
                                      //             letterSpacing: -0.17,
                                      //             color: AppColors.whiteColor,
                                      //             fontSize: 14,
                                      //           ),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // )
                                      //     : SizedBox(),

                                      //#GCW 26-01-2023 remove end call button when full screen
                                      //#GCW 20-12-2022
                                      //Join Button
                                      // _joined
                                      //     ? InkWell(
                                      //         onTap: () {
                                      //           if (_joined) {
                                      //             _leave(context);
                                      //           } else {
                                      //             showDialog(
                                      //               context: context,
                                      //               barrierDismissible: false,
                                      //               builder:
                                      //                   (BuildContext context) {
                                      //                 return BackdropFilter(
                                      //                   filter:
                                      //                       ImageFilter.blur(
                                      //                           sigmaX: 5,
                                      //                           sigmaY: 5),
                                      //                   child: AlertDialog(
                                      //                     shape: RoundedRectangleBorder(
                                      //                         borderRadius:
                                      //                             BorderRadius
                                      //                                 .circular(
                                      //                                     20.0)),
                                      //                     backgroundColor:
                                      //                         Colors.white,
                                      //                     insetPadding:
                                      //                         EdgeInsets
                                      //                             .symmetric(
                                      //                                 horizontal:
                                      //                                     30),
                                      //                     clipBehavior: Clip
                                      //                         .antiAliasWithSaveLayer,
                                      //                     title: Center(
                                      //                         child: Text(
                                      //                             "Join Call?")),
                                      //                     content: Column(
                                      //                       mainAxisSize:
                                      //                           MainAxisSize
                                      //                               .min,
                                      //                       children: [
                                      //                         SizedBox(
                                      //                           height: 20,
                                      //                         ),
                                      //                         Row(
                                      //                           mainAxisAlignment:
                                      //                               MainAxisAlignment
                                      //                                   .spaceEvenly,
                                      //                           children: [
                                      //                             MaterialButton(
                                      //                               onPressed:
                                      //                                   () {
                                      //                                 Navigator.pop(
                                      //                                     context);
                                      //                               },
                                      //                               shape:
                                      //                                   RoundedRectangleBorder(
                                      //                                 borderRadius:
                                      //                                     BorderRadius.circular(
                                      //                                         5),
                                      //                               ),
                                      //                               color: Colors
                                      //                                   .red,
                                      //                               child: Text(
                                      //                                 "Cancel",
                                      //                                 style: GoogleFonts
                                      //                                     .roboto(
                                      //                                   fontWeight:
                                      //                                       FontWeight.w600,
                                      //                                   color: AppColors
                                      //                                       .whiteColor,
                                      //                                   fontSize:
                                      //                                       14,
                                      //                                 ),
                                      //                               ),
                                      //                             ),
                                      //                             SizedBox(
                                      //                               width: 20,
                                      //                             ),
                                      //                             MaterialButton(
                                      //                               onPressed:
                                      //                                   () {
                                      //                                 Navigator.pop(
                                      //                                     context);
                                      //                                 _getAgoraRtcToken(this
                                      //                                     .widget
                                      //                                     .channelName);
                                      //                               },
                                      //                               shape:
                                      //                                   RoundedRectangleBorder(
                                      //                                 borderRadius:
                                      //                                     BorderRadius.circular(
                                      //                                         5),
                                      //                               ),
                                      //                               color: Colors
                                      //                                   .green,
                                      //                               child: Text(
                                      //                                 "Continue",
                                      //                                 style: GoogleFonts
                                      //                                     .roboto(
                                      //                                   fontWeight:
                                      //                                       FontWeight.w600,
                                      //                                   color: AppColors
                                      //                                       .whiteColor,
                                      //                                   fontSize:
                                      //                                       14,
                                      //                                 ),
                                      //                               ),
                                      //                             ),
                                      //                           ],
                                      //                         ),
                                      //                       ],
                                      //                     ),
                                      //                   ),
                                      //                 );
                                      //               },
                                      //             );
                                      //           }
                                      //         },
                                      //         child: Container(
                                      //           margin:
                                      //               EdgeInsets.only(right: 8),
                                      //           //#GCW 31-12-2022 remove upper end button
                                      //           //   child: Card(
                                      //           //     color: _joined
                                      //           //         ? AppColors.boxRedColor
                                      //           //         : Colors.green,
                                      //           //     shape: RoundedRectangleBorder(
                                      //           //       borderRadius:
                                      //           //       BorderRadius.circular(4),
                                      //           //     ),
                                      //           //     elevation: 5,
                                      //           //     shadowColor:
                                      //           //     Colors.black.withOpacity(0.45),
                                      //           //     child: Container(
                                      //           //       height: 34,
                                      //           //       width: 65,
                                      //           //       alignment: Alignment.center,
                                      //           //       child: Text(
                                      //           //         _joined
                                      //           //             ? "Ended Call"
                                      //           //             : "Join Call",
                                      //           //         style: GoogleFonts.roboto(
                                      //           //           fontWeight: FontWeight.w500,
                                      //           //           letterSpacing: -0.17,
                                      //           //           color: AppColors.whiteColor,
                                      //           //           fontSize: 14,
                                      //           //         ),
                                      //           //       ),
                                      //           //     ),
                                      //           //   ),
                                      //           // ),
                                      //         ))
                                      //     : SizedBox(),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: AppColors.headerColor,
                            height: 106,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    /*setState(() {
                                      _expandVideoCall = !_expandVideoCall;
                                    });*/
                                    _toggleSendPeerMessage(
                                        peerUid:
                                            '${this.widget.specialistId}-${this.widget.caseId}',
                                        message: "User has left");
                                    _logoutEndCase();
                                    _leave(context);
                                    AppConstants.pusher
                                        .unsubscribe(channelName: "CaseStatus");
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              DoctorDashBoardScreen()),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: 15, top: 35),
                                    child: Image.asset(
                                      AppImages.backArrow,
                                      height: 22,
                                      width: 22,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 55, left: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                child: RichText(
                                                  text: TextSpan(
                                                    text:
                                                        'Dr. ${this.widget.firstName} ${this.widget.lastName}',
                                                    style: GoogleFonts.roboto(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            Color(0xFFEFF7FF),
                                                        fontSize: 20,
                                                        letterSpacing: 0.15),
                                                    children: <TextSpan>[
                                                      /*TextSpan(
                                                        text: '\n${this.widget.degree}',
                                                        style: GoogleFonts.roboto(fontWeight: FontWeight.w400, color: Color(0xFFEFF7FF), fontSize: 12, letterSpacing: 0.15),
                                                      ),*/
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: _fullScreenChat,
                                                child: InkWell(
                                                  onTap: () {
                                                    controller.reverse();
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 200),
                                                        () {
                                                      setState(() {
                                                        _fullScreenChat = false;
                                                        _expandVideoCall = true;
                                                      });
                                                    });
                                                  },
                                                  child: Container(
                                                    margin: EdgeInsets.only(
                                                        left: 5, top: 3),
                                                    child: Image.asset(
                                                      AppImages.downArrowIcon,
                                                      width: 29,
                                                      height: 29,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                //#GCW 27-01-2023 Remove End Case Button
                                // InkWell(
                                //   onTap: () {
                                //     _showCloseCaseConfirmDialog(
                                //         this.widget.caseId, context);
                                //   },
                                //   child: Container(
                                //     margin: EdgeInsets.only(top: 45, right: 5),
                                //     child: Card(
                                //       color: AppColors.boxRedColor,
                                //       shape: RoundedRectangleBorder(
                                //         borderRadius: BorderRadius.circular(4),
                                //       ),
                                //       elevation: 5,
                                //       shadowColor:
                                //           Colors.black.withOpacity(0.45),
                                //       //Task: Remove End Case button
                                //       //Date: 23-10-2022
                                //       //#GWC
                                //       child: Container(
                                //         height: 34,
                                //         width: 89,
                                //         alignment: Alignment.center,
                                //         child: Text(
                                //           "End Case",
                                //           style: GoogleFonts.roboto(
                                //               fontWeight: FontWeight.w500,
                                //               letterSpacing: -0.17,
                                //               color: AppColors.whiteColor,
                                //               fontSize: 14),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        _toggleSendPeerMessage(
            peerUid: '${this.widget.specialistId}-${this.widget.caseId}',
            message: "User has left");
        _logoutEndCase();
        _leave(context);
        AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => DoctorDashBoardScreen()),
          (Route<dynamic> route) => false,
        );
        return Future.value(false);
      },
    );
  }

  void _leave(BuildContext context) async {
    if (_connectVideoCall) {
      _connectVideoCall = false;
      disableCamera = true;
      _joined = false;
      muted = false;
      _expandVideoCall = false;
      _fullScreenChat = true;
      // #GCW 19-01-2023 stop recording bug
      // _agoraStopRecording(
      //     widget.channelName, recordingRid, recordingUid, recordingSid);
    }

    setState(() {});
    print("ATIN engine.leaveChannel() & closeAgora()");
    await engine.leaveChannel();

    closeAgora();
    // Navigator.pop(context);
  }

  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();

    // agora update
    // RtcEngineContext context = RtcEngineContext(AppConstants.AGORA_APP_ID);
    // engine = await RtcEngine.createWithContext(context);
    //
    // engine.setEventHandler(
    //   RtcEngineEventHandler(
    //     joinChannelSuccess: (String channel, int uid, int elapsed) {
    //       print('joinChannelSuccess $channel $uid');
    //       _joined = true;
    //       String agoraRID =
    //           sharedPreferences.getString("DoctorAgoraRID${widget.caseId}") ??
    //               "";
    //       String agoraUID =
    //           sharedPreferences.getString("DoctorAgoraUID${widget.caseId}") ??
    //               "";
    //
    //       log("agora == SavedRID : $agoraRID");
    //       log("agora == SavedUID : $agoraUID");
    //
    //       if (agoraRID != "" && agoraUID != "") {
    //         log("agora == ContinueRecording");
    //         _agoraStartRecording(
    //             widget.channelName, agoraRID, agoraUID, agoraRtcToken);
    //       } else {
    //         log("agora == NewRecording");
    //         _agoraAcquire(channel);
    //       }
    //
    //       setState(() {});
    //     },
    //     /*rejoinChannelSuccess: (String channel, int uid, int elapsed) {
    //       print('joinChannelSuccess $channel $uid');
    //       _joined = true;
    //       String agoraRID = sharedPreferences.getString("DoctorAgoraRID${widget.caseId}") ?? "";
    //       String agoraUID = sharedPreferences.getString("DoctorAgoraUID${widget.caseId}") ?? "";
    //
    //       if (agoraRID != "" && agoraUID != "") {
    //         _agoraStartRecording(widget.channelName, agoraRID, agoraUID, agoraRtcToken);
    //       } else {
    //         _agoraAcquire(channel);
    //       }
    //
    //       setState(() {});
    //     },*/
    //     userJoined: (int uid, int elapsed) {
    //       print('userJoined $uid');
    //       setState(() {
    //         _remoteUid = uid;
    //         isOtherUserJoined = true;
    //       });
    //     },
    //     userOffline: (int uid, UserOfflineReason reason) {
    //       print('userOffline $uid');
    //       setState(() {
    //         _remoteUid = 0;
    //         isOtherUserJoined = false;
    //         /*if (_connectVideoCall) {
    //           _connectVideoCall = false;
    //           disableCamera = true;
    //           //_agoraStopRecording(widget.channelName, recordingRid, recordingUid, recordingSid);
    //         }
    //         engine.leaveChannel();*/
    //       });
    //     },
    //     error: (reason) {
    //       print('error ${reason.toString()}');
    //     },
    //     userMuteVideo: (i, val) {
    //       setState(() {
    //         isOtherVideoMuted = val;
    //       });
    //     },
    //   ),
    // );

    //create an instance of the Agora engine
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: AppConstants.AGORA_APP_ID));

    await engine.enableVideo();

    // Register the event handler
    engine.registerEventHandler(
      RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        log("Local user uid:${connection.localUid} joined the channel");
        _joined = true;
        //#GCW 15-01-203
        //_setVideoCallStatus();
        String agoraRID =
            sharedPreferences.getString("DoctorAgoraRID${widget.caseId}") ?? "";
        String agoraUID =
            sharedPreferences.getString("DoctorAgoraUID${widget.caseId}") ?? "";

        log("agora == SavedRID : $agoraRID");
        log("agora == SavedUID : $agoraUID");

        if (agoraRID != "" && agoraUID != "") {
          log("agora == ContinueRecording");
          print("ATIN Continue Recording");
          //#GCW 26-01-2023
          // // agora test
          _agoraStartRecording(
              widget.channelName, agoraRID, agoraUID, agoraRtcToken);
          // _agoraStartRecording(widget.channelName, agoraRID, agoraUID,
          //     '00634901eefd3634abbaacf3b988b609f00IABlwPkXFSKdHwttbLKxhIj4zH3ghM9UdhEfUDKSIWJYMAwTazIAAAAAIgATLQEAQaXTYwQAAQDRYdJjAwDRYdJjAgDRYdJjBADRYdJj');
        } else {
          log("agora == NewRecording");
          print("ATIN New Recording");
          _agoraAcquire(this.widget.channelName);
        }

        setState(() {});
      }, onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        log("Remote user uid:$remoteUid joined the channel");
        setState(() {
          _remoteUid = remoteUid;
          isOtherUserJoined = true;
        });
      }, onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
        log("Remote user uid:$remoteUid left the channel");
        setState(() {
          _remoteUid = 0;
          isOtherUserJoined = false;
          _leave(context);
        });
      }, onError: (errorType, reason) {
        log('error ${reason.toString()}');
      }, onUserMuteVideo: (connection, i, val) {
        setState(() {
          isOtherVideoMuted = val;
        });
      }),
    );

    // agora update
    //await engine.enableVideo();
    // _addRenderView(client.uid, (viewId) {
    //   engine.loc(viewId, VideoRenderMode.Fit);
    //   engine.startPreview();
    // });
    // await engine.disableVideo();
    // VideoEncoderConfiguration config = VideoEncoderConfiguration(
    //   orientationMode: VideoOutputOrientationMode.Adaptative);
    // engine.setVideoEncoderConfiguration(config);
    // await engine.enableVideo();

    if (agoraRtcToken != null && this.widget.channelName != null) {
      await engine.startPreview();

      // Set channel options including the client role and channel profile
      ChannelMediaOptions options = const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      );

      await engine.joinChannel(
        token: agoraRtcToken,
        channelId: this.widget.channelName,
        options: options,
        uid: 0,
      );
      //   await engine.joinChannel(
      //       agoraRtcToken, this.widget.channelName.toString(), null, 0);
      //   print("Channel and Token Not Available.");
    }
  }

  void _onToggleMute() async {
    if (muted) {
      await engine.muteLocalAudioStream(false);
      muted = false;
    } else {
      await engine.muteLocalAudioStream(true);
      muted = true;
    }

    setState(() {});
  }

  void _onToggleCamera() async {
    if (disableCamera) {
      await engine.muteLocalVideoStream(true);
      disableCamera = false;
    } else {
      await engine.muteLocalVideoStream(false);
      disableCamera = true;
    }

    setState(() {});
  }

  void _onSwitchCamera() async {
    await engine.switchCamera();
  }

  //Local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      // agora update
      //return RtcLocalView.SurfaceView();
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: 0),
        ),
      );
    } else {
      return Text(
        '',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0) {
      // agora update
      // return RtcRemoteView.SurfaceView(
      //   uid: _remoteUid,
      //   channelId: this.widget.channelName,
      // );
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: RtcConnection(channelId: this.widget.channelName),
        ),
      );
    } else {
      return Expanded(
          child: Container(
        color: Colors.black,
      ));
    }
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _getAgoraRtmToken(this.widget.caseId, this.widget.specialistId);
    });

    _getMessage();
    //_agoraAcquire(this.widget.channelName);
    AppConstants.pusher.subscribe(
      channelName: "CaseStatus",
      onEvent: (event) {
        log("onEvent: $event");

        /*if (event.eventName.toString().contains('CaseAcceptedBySpecialist')) {
          _log("User Join Successfully", 1);
        }*/

        if (event.eventName.toString().contains('CaseClosed')) {
          //#GCW 18-01-2023
          print("ATIN CASE CLOSED");

          _agoraStopRecording(
              widget.channelName, recordingRid, recordingUid, recordingSid);
          _logoutEndCase();
          _leave(context);
          print(
              "ATIN PusherChannelsFlutter.getInstance().unsubscribe(channelName:\"CaseStatus\")");
          AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HelpUsScreen(caseId: this.widget.caseId),
            ),
          );
        }
      },
      onSubscriptionError: (String message, dynamic e) {
        log("onSubscriptionError: $message Exception: $e");
      },
      onSubscriptionSucceeded: (data) {
        log("onSubscriptionSucceeded: data: $data");
      },
    );
    AppConstants.pusher.connect();
  }

  _getMessage() async {
    String userid = (sharedPreferences.getString("UserId") ?? "");
    final url = AppConstants.doctorGetMessage;
    var body = {"case_id": this.widget.caseId};
    log('url--> $url');
    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('getPendingCases response status--> ${response.statusCode}');
      log('getPendingCases response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          var data = jsonData['data'] as List;

          var reversedList = data.reversed.toList();

          for (Map array in reversedList) {
            Message message = Message(
                array['message'],
                array['sender_id'].toString() == userid ? 1 : 0,
                array['created_at']);
            _infoStrings.add(message);
          }

          Message msg = Message(
              "Hi, I'm Dr. ${this.widget.firstName} ${this.widget.lastName}.\nI'm reviewing the case details. \nHow do you prefer to communicate?\n\n-audio/video call\n\nor\n\n-chat",
              0,
              DateTime.now().toString());
          _infoStrings.add(msg);

          setState(() {});
        } else {}
      } else {}
    } catch (e, s) {
      log("getPendingCases Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getAgoraRtmToken(String caseId, String specialistId) async {
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.agoraRtmTokenGenerate;

    log('url--> $url');

    var body = {"user": '$caseId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('doctorAgoraRtmToken response status--> ${response.statusCode}');
      log('doctorAgoraRtmToken response body--> ${response.body}');

      if (response.statusCode == 200) {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        var jsonData = jsonDecode(response.body);
        agoraRtmToken = jsonData['token'].toString();
        setState(() {});

        _initRtmClient(agoraRtmToken, caseId);

        setState(() {});
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
      log("doctorAgoraRtmToken Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  void _initRtmClient(String agoraRtmToken, String caseId) async {
    _createClient(agoraRtmToken, caseId);
  }

  void _createClient(String _token, String fullName) async {
    _client = await AgoraRtmClient.createInstance(AppConstants.AGORA_APP_ID);

    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      /*if (event.eventName.toString().contains('CaseAcceptedBySpecialist')) {
        _log("User Join Successfully", 1);
      }*/

      print("Agora Message received == ${message.text}");

      if (message.text == "VideoStopped") {
        setState(() {
          isOtherVideoMuted = true;
        });
      } else if (message.text == "VideoResume") {
        setState(() {
          isOtherVideoMuted = false;
        });
      } else if (message.text == "User joined successfully") {
        //#GCW 15-01-2023 remove by default join call pop up
        //_joined ? null : _showMyDialog();
        _log(message.text, 0);
      } else {
        _log(message.text, 0);
      }
    };

    _client.onConnectionStateChanged = (int state, int reason) {
      if (state == 5) {
        _client.logout();
      }
    };

    await _client.login(
      _token,
      fullName,
    );

    _toggleSendPeerMessage(
        peerUid: '${this.widget.specialistId}-${this.widget.caseId}',
        message: "User joined successfully");
  }

  _toggleSendPeerMessage(
      {required String peerUid, required String message}) async {
    if (peerUid.isEmpty) {
      print('Please input peer user id to send message.');
      return;
    }

    String text = message;
    if (text.isEmpty) {
      print('Please input text to send.');
      return;
    }

    try {
      AgoraRtmMessage message = AgoraRtmMessage.fromText(text);
      print(message.text);
      await _client.sendMessageToPeer('$peerUid', message, false);
      print('Send peer message success.');
      if (text == "User joined successfully") {
        print("Not Text");
      } else if (text == "User has left") {
        print("Not Text1");
      } else if (text == "VideoResume") {
        print("Not Text1");
      } else if (text == "VideoStopped") {
        print("Not Text1");
      } else {
        _log(text, 1);
        if (text.contains("Message : ")) {
          _pushMessage(
              this.widget.caseId, 'Message', text.replaceAll("Message : ", ""));
        } else if (text.contains("Image : ")) {
          _pushMessage(
              this.widget.caseId, 'Image', text.replaceAll("Image : ", ""));
        } else if (text.contains("Doc : ")) {
          _pushMessage(
              this.widget.caseId, 'Doc', text.replaceAll("Doc : ", ""));
        }
      }
    } catch (errorCode) {
      print('Send peer message error: ' + errorCode.toString());
    }
  }

  void _log(String info, int myMsg) {
    print(info);

    Message message = Message(info, myMsg, DateTime.now().toString());
    setState(() {
      _infoStrings.insert(0, message);
    });
  }

  void _logoutEndCase() async {
    try {
      print("ATIN AGORA RTM CLIENT LOGOUT");
      await _client.logout();
      _joined = false;
      //_log("Peer msg: Logout");
    } catch (errorCode) {
      //_log(info: 'Logout error: ' + errorCode.toString(), type: 'error');
    }
  }

  void _logout() async {
    //_toggleSendPeerMessage(peerUid: '${this.widget.specialistId}-${this.widget.caseId}', message: "CaseClosedMessageReceived");
    try {
      await _client.logout();
      Navigator.pop(context);
      //_log("Peer msg: Logout");
    } catch (errorCode) {
      //_log(info: 'Logout error: ' + errorCode.toString(), type: 'error');
    }
  }

  _getAgoraRtcToken(String channelName) async {
    String email = sharedPreferences.getString("Email") ?? "";
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.agoraRtcTokenGenerate;

    log('url--> $url');

    var body = {"channel": '$channelName', "user": "$email"};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('doctorAgoraRtcToken response status--> ${response.statusCode}');
      log('doctorAgoraRtcToken response body--> ${response.body}');

      if (response.statusCode == 200) {
        Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
        var jsonData = jsonDecode(response.body);
        agoraRtcToken = jsonData['token'].toString();

        _connectVideoCall = true;

        initPlatformState();

        setState(() {});
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
      log("doctorAgoraRtcToken Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  void _showImagePicker(context) {
    showGeneralDialog(
      barrierLabel: "Upload Image",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 200),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Wrap(
              children: <Widget>[
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        color: Theme.of(context).primaryColor.withAlpha(5),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 5,
                              child: Container(
                                child: MaterialButton(
                                  minWidth: double.maxFinite,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _imgFromCamera();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Camera",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 16),
                                        ),
                                        Icon(
                                          Icons.linked_camera_outlined,
                                          color: AppColors.headerColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              color: Colors.black,
                              width: 1,
                              height: 50,
                            ),
                            Flexible(
                              flex: 5,
                              child: Container(
                                child: MaterialButton(
                                  minWidth: double.maxFinite,
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _imgFromGallery();
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Gallery",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 16),
                                        ),
                                        Icon(
                                          Icons.photo_camera_back,
                                          color: AppColors.headerColor,
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
                    ),
                    SizedBox(height: 15),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Container(
                        color: Theme.of(context).primaryColor.withAlpha(5),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          minWidth: double.maxFinite,
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrussianBlueColor,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
              sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
          child: SlideTransition(
            position:
                Tween(begin: Offset(0, 1), end: Offset(0, 0)).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  _imgFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print("FileSize == $mb mb");

      if (mb > 10) {
        ToastMessage.showToastMessage(
          context: context,
          message: "Maximum 10 MB of file size limit has reached",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      } else {
        _cropImage(pickedFile.path);
      }

      print(pickedFile.path);
    }
  }

  _imgFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print("FileSize == $mb mb");

      if (mb > 10) {
        ToastMessage.showToastMessage(
          context: context,
          message: "Maximum 10 MB of file size limit has reached",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      } else {
        _cropImage(pickedFile.path);
      }

      print(pickedFile.path);
    }
  }

  Future<File?> takePicture() async {
    try {
      // Get the available cameras
      List<CameraDescription> cameras = Cameras.cameras;
      print("CAMERA $cameras");

      // Initialize the first camera in the list
      CameraController controller =
          CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();

      // Get a temporary directory for the image
      // Directory directory = await getTemporaryDirectory();
      // String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      // String filePath = directory.path + '$fileName.jpg';

      // Take the picture
      XFile picture = await controller.takePicture();

      // Return the image as a File object
      return File(picture.path);
    } catch (e) {
      print(e);
      return null;
    }
  }

  _cropImage(filePath) async {
    File? _croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
    );
    if (_croppedImage != null) {
      print(_croppedImage);
      _uploadImage(_croppedImage);
      setState(() {});
    }
  }

  _uploadImage(File selectFile) async {
    print("Upload Image");
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.publicUpload;
    log('url--> $url');

    var response = new http.MultipartRequest("POST", Uri.parse(url));

    if (selectFile != null) {
      response.files.addAll([
        await http.MultipartFile.fromPath('file', selectFile.path),
      ]);
    }
    response.send().then(
      (response) {
        http.Response.fromStream(response).then(
          (onValue) {
            try {
              print(onValue.body);
              if (onValue.statusCode == 200) {
                var jsonData = jsonDecode(onValue.body);

                if (jsonData['status']['error'] == false) {
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  String path = jsonData['data']['path'] != null
                      ? jsonData['data']['path']
                      : '';
                  _toggleSendPeerMessage(
                      peerUid:
                          '${this.widget.specialistId}-${this.widget.caseId}',
                      message: "Image : " + path);
                  //_pushMessage(this.widget.caseId, 'Image', path);
                } else {
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.red,
                    position: StyledToastPosition.center,
                  );
                }
              } else {
                Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                    .pop();
                ToastMessage.showToastMessage(
                  context: context,
                  message: "Something bad happened,try again after some time.",
                  duration: 3,
                  backColor: Colors.red,
                  position: StyledToastPosition.center,
                );
              }
            } catch (e, s) {
              log("doctorChatUploadImage Error--> Error:-$e stackTrace:-$s");
              Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                  .pop();
            }
          },
        );
      },
    );
  }

  _uploadDocument(File selectFile) async {
    print("Upload Document");
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.publicUpload;
    log('url--> $url');

    var response = new http.MultipartRequest("POST", Uri.parse(url));

    if (selectFile != null) {
      response.files.addAll([
        await http.MultipartFile.fromPath('file', selectFile.path),
      ]);
    }
    response.send().then(
      (response) {
        http.Response.fromStream(response).then(
          (onValue) {
            try {
              print(onValue.body);
              if (onValue.statusCode == 200) {
                var jsonData = jsonDecode(onValue.body);

                if (jsonData['status']['error'] == false) {
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  String path = jsonData['data']['path'] != null
                      ? jsonData['data']['path']
                      : '';
                  _toggleSendPeerMessage(
                      peerUid:
                          '${this.widget.specialistId}-${this.widget.caseId}',
                      message: "Doc : " + path);
                  //_pushMessage(this.widget.caseId, 'Doc', path);
                } else {
                  Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                      .pop();
                  ToastMessage.showToastMessage(
                    context: context,
                    message: jsonData['status']['message'][0].toString(),
                    duration: 3,
                    backColor: Colors.red,
                    position: StyledToastPosition.center,
                  );
                }
              } else {
                Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                    .pop();
                ToastMessage.showToastMessage(
                  context: context,
                  message: "Something bad happened,try again after some time.",
                  duration: 3,
                  backColor: Colors.red,
                  position: StyledToastPosition.center,
                );
              }
            } catch (e, s) {
              log("doctorUploadDocument Error--> Error:-$e stackTrace:-$s");
              Navigator.of(_keyDialog.currentContext!, rootNavigator: true)
                  .pop();
            }
          },
        );
      },
    );
  }

  _agoraAcquire(String channelName) async {
    log("agora == Agora Acquire");
    //AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");

    final url = AppConstants.agoraAcquire;

    log('url--> $url');

    var body = {"cname": '$channelName'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('agora == agoraAcquire response body--> ${response.body}');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          recordingRid = data['resourceid'];
          recordingUid = data['uid'];
        });

        sharedPreferences.setString(
            "DoctorAgoraRID${widget.caseId}", "${data['resourceid']}");
        sharedPreferences.setString(
            "DoctorAgoraUID${widget.caseId}", "${data['uid']}");

        _agoraStartRecording(
            widget.channelName, recordingRid, recordingUid, agoraRtcToken);
      }
    } catch (e, s) {
      log("agora == agoraAcquire Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  _agoraStartRecording(
      String channelName, String rId, String uId, String token) async {
    log("agora ==  Agora Start Recording");
    final url = AppConstants.agoraStartRecording;

    log('url--> $url');

    var body = {
      "cname": '$channelName',
      'rid': '$rId',
      'token': '$token',
      'uid': '$uId',
    };

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        setState(() {
          recordingSid = data['data'][0]['sid'];
        });
      }

      log('agora == agoraRecording Start response body--> ${response.body}');
    } catch (e, s) {
      log("agora == agoraRecording Start Error--> Error:-$e stackTrace:-$s");
    }
  }

  _agoraStopRecording(
      String channelName, String rId, String uId, String sId) async {
    final url = AppConstants.agoraStopRecording;

    //#GCW 26-01-2023 Load RID and UID from storage
    if (rId == "" || uId == "") {
      rId = sharedPreferences.getString("DoctorAgoraRID${widget.caseId}") ?? "";
      uId = sharedPreferences.getString("DoctorAgoraUID${widget.caseId}") ?? "";
    }

    print("ATIN RID: $rId && UID:$uId");
    log('url--> $url');
    print("ATIN AGORA STOP RECORDING");
    var body = {
      "cname": '$channelName',
      'rid': '$rId',
      'sid': '$sId',
      'uid': '$uId',
    };

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('agoraRecording Stop response status--> ${response.statusCode}');
      log('agoraRecording Stop response body--> ${response.body}');
    } catch (e, s) {
      log("agoraRecording Stop Error--> Error:-$e stackTrace:-$s");
    }
  }

  _showCloseCaseConfirmDialog(String caseId, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 8, bottom: 8),
                child: Text(
                  "Are you sure you want to end case?",
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
                          //#GCW 18-01-2023
                          _agoraStopRecording(widget.channelName, recordingRid,
                              recordingUid, recordingSid);
                          _endCase(caseId, context);
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

  _endCase(String caseId, BuildContext context) async {
    print("Atin End Case function called");
    sharedPreferences = await SharedPreferences.getInstance();
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

      log('doctorEndCase response status--> ${response.statusCode}');
      log('doctorEndCase response body--> ${response.body}');

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

          AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
          _logoutEndCase();
          _leave(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HelpUsScreen(caseId: caseId),
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
      log("doctorEndCase Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  _pushMessage(String caseId, String type, String messsage) async {
    String userid = (sharedPreferences.getString("UserId") ?? "");
    final url = AppConstants.doctorPushMessage;
    log('url--> $url');

    var body = {
      "case_id": '$caseId',
      "sender_id": '$userid',
      "type": '$type',
      "message": '$type : $messsage'
    };

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('doctorAgoraRtcToken response status--> ${response.statusCode}');
      log('doctorAgoraRtcToken response body--> ${response.body}');

      if (response.statusCode == 200) {
        setState(() {});
      } else {
        ToastMessage.showToastMessage(
          context: context,
          message: "Something bad happened,try again after some time.",
          duration: 3,
          backColor: Colors.red,
          position: StyledToastPosition.center,
        );
      }
    } catch (e, s) {
      log("doctorAgoraRtcToken Error--> Error:-$e stackTrace:-$s");
    }
  }

  _showTimeExtendSheet(String caseId) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  color: Colors.white),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Would you like to add an additional 20 minutes to your case?",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "An additional case fee of \$75 per will be charged if you'd like to add an additional 20 minutes block.",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: Colors.red,
                          //minWidth: double.infinity,
                          child: Text(
                            "Close",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 10),
                        MaterialButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _addTime(caseId, context);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          color: Colors.green,
                          //minWidth: double.infinity,
                          child: Text(
                            "Continue",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  _addTime(String caseId, BuildContext context) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorAddTime + '/$caseId';

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      log('doctorAddTime response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          /*ToastMessage.showToastMessage(
            context: context,
            message: jsonData['status']['message'][0].toString(),
            duration: 3,
            backColor: Colors.black.withOpacity(0.7),
            position: StyledToastPosition.center,
          );*/
          if (jsonData['data'] != null) {
            //#GCW 07-02-2023 Restart Timer from 00:00
            if (jsonData['data']['minutes'] != null) {
              myDuration =
                  myDuration + Duration(minutes: jsonData['data']['minutes']);
              if (!(countdownTimer!.isActive)) {
                countdownTimer =
                    Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
              }
            }
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
      log("doctorAddTime Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  //#GCW 14-01-2023
  _setVideoCallStatus() async {
    await ref.equalTo("${this.widget.caseId}").once().then((value) async {
      DataSnapshot snapshot = value.snapshot;
      if (snapshot.exists) {
        await ref.update({
          //#GCW 24-01-2023
          "${this.widget.caseId}": {
            "${AppConstants.firebaseDoctorStatus}": true,
            "${AppConstants.firebaseSpecialistStatus}": false,
            "${AppConstants.firebaseVideoCallStatus}": true
          }
        }).then((value) {
          Future.delayed(const Duration(seconds: 5), () {
            _removeCaseFromFirebaseVideoCallStatusList();
          });
        });
      } else {
        await ref.update({
          //#GCW 24-01-2023
          "${this.widget.caseId}": {
            "${AppConstants.firebaseDoctorStatus}": true,
            "${AppConstants.firebaseSpecialistStatus}": false,
            "${AppConstants.firebaseVideoCallStatus}": true
          }
        }).then((value) {
          Future.delayed(const Duration(seconds: 5), () {
            _removeCaseFromFirebaseVideoCallStatusList();
          });
        });
      }
    });
  }

  //#GCW 15-01-2022
  _initVideoCallListener() {
    joinVideoCallLister.listen((event) {
      if (event.snapshot.exists && !_joined) {
        var data = event.snapshot.value as Map;
        //#GCW 24-01-2023
        var value = data['${this.widget.caseId}']
            ['${AppConstants.firebaseSpecialistStatus}'];
        if (value == true && !joinPopupShown) {
          joinPopupShown = true;
          _showMyDialog();
        }
      }
    });
  }

  //#GCW 15-01-2023
  _removeCaseFromFirebaseVideoCallStatusList() {
    ref.child("${this.widget.caseId}").remove();
  }

  //#GCW 24-01-2023
  Future<void> closeAgora() async {
    print("calling release");
    await engine.release();
    print("release..");
  }
}

class Message {
  String msg;
  int myMsg;
  String dateTime;

  Message(this.msg, this.myMsg, this.dateTime);
}
