import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

//agora upgrade
//import 'package:agora_rtc_engine/rtc_engine.dart';
//import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
//import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vsod_flutter/screens/specialist/home/specialist_home_screen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';

import '../../utils/camera.dart';
import '../Doctor/model/GetAnswerModel.dart';

class SpecialistChatScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SpecialistChatScreenState();
  String channelName;
  String firstName;
  String lastName;
  String degree;
  String specialistProfile;
  String caseId;
  String specialistId;
  String caseSeconds;

  SpecialistChatScreen({
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

class _SpecialistChatScreenState extends State<SpecialistChatScreen>
    with SingleTickerProviderStateMixin {
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
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

  //#GCW 18-01-2023
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

  TextEditingController sendMessageController = new TextEditingController();

  late SharedPreferences sharedPreferences;

  //var _profileImage;

  //late String _localPath;

  List<GetAnswerModel> _getAnswerList = <GetAnswerModel>[];

  List docList = [];

  late String _localPath;

  late String clinicAddress = "";
  late String clinicState = "";
  late String creationDate = "";

  //#GCW 27-01-2023
  String recordingUid = "";
  String recordingRid = "";
  String recordingSid = "";
  String recordingToken = "";

  Timer? countdownTimer;
  Duration myDuration = Duration(minutes: 20);

  void startTimer() {
    myDuration = Duration(seconds: int.parse(widget.caseSeconds));
    _init();
    //#GCW 28-12-2022 AUTO END CASE REMOVAL
    // if (widget.caseSeconds != "" &&
    //     !widget.caseSeconds.contains("-") &&
    //     widget.caseSeconds != "0") {
    //   print("Time remaining == ${widget.caseSeconds}");
    //   myDuration = Duration(seconds: int.parse(widget.caseSeconds));
    //   _init();
    // } else {
    //   //print("Time is over. Call the end case API");
    //   myDuration = Duration(seconds: 0);
    //   Future.delayed(Duration.zero, () {
    //    _endCase(widget.caseId, context);
    //   });
    // }

    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds =
          myDuration.inSeconds > 0 ? myDuration.inSeconds - reduceSecondsBy : 0;
      if (seconds <= 0) {
        countdownTimer!.cancel();
      }
      myDuration = Duration(seconds: seconds);
      //#GCW 28-12-2022 AUTO CASE END REMOVAL
      // if (seconds <= 0) {
      //   countdownTimer!.cancel();
      //   _endCase(widget.caseId, context);
      // } else {
      //   myDuration = Duration(seconds: seconds);
      // }
    });
  }

  @override
  @override
  void initState() {
    super.initState();
    startTimer();
    FlutterDownloader.registerCallback(downloadCallback);
    //#GCW 24-01-2023
    joinVideoCallLister = ref.onValue;
    _initVideoCallListener();
    //#GCW 04-01-2023
    // WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
    //   _showMyDialog();
    // });
  }

  @override
  void dispose() {
    //print("Adding");
    super.dispose();
    _logoutEndCase();
    engine.leaveChannel();
    countdownTimer!.cancel();
    if (_joined) {
      _leave(context);
    }
    //#GCW 24-01-2023
    closeAgora();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  //#GCW 22-12-2022
  Future<void> _showMyDialog() async {
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
                  Container(
                    height: 40,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        Text(
                          'Case Time: ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '$minutes:$seconds',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        /*ElevatedButton(
                          onPressed: () {
                            myDuration = myDuration + Duration(seconds: 30);
                          },
                          child: Text(
                            'Start',
                            style: TextStyle(
                              fontSize: 30,
                            ),
                          ),
                        ),*/
                        //
                        //#GCW 27-10-2023
                        InkWell(
                          onTap: () {
                            if (_joined) {
                              //#GCW 15-01-2023
                              joinPopupShown = false;
                              _leave(context);
                            } else {
                              //#GCW 18-10-2023

                              //#GCW 27-10-2023
                              _expandVideoCall = true;
                              //Navigator.pop(context);
                              _setVideoCallStatus();
                              _getAgoraRtcToken(this.widget.channelName);
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
                          //controller: _controller,
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
                                                      /*PermissionStatus permissionStatus = await Permission.storage.request();
                                                if (permissionStatus != PermissionStatus.granted) return;

                                                _localPath = (await _findLocalPath())!;
                                                final savedDir = Directory(_localPath);
                                                bool hasExisted1 = savedDir.existsSync();
                                                if (!hasExisted1) {
                                                  savedDir.create();
                                                }
                                                String fileAppend = DateTime.now().millisecondsSinceEpoch.toString();
                                                String fileName = _infoStrings[index].msg.trim().substring(_infoStrings[index].msg.trim().lastIndexOf("/") + 1);

                                                await FlutterDownloader.enqueue(
                                                  url: _infoStrings[index].msg.trim(),
                                                  savedDir: _localPath,
                                                  fileName: fileAppend + fileName,
                                                  showNotification: true,
                                                  openFileFromNotification: false,
                                                );*/
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
                                                          /*PermissionStatus permissionStatus = await Permission.storage.request();
                                                        if (permissionStatus != PermissionStatus.granted) return;

                                                        _localPath = (await _findLocalPath())!;
                                                        final savedDir = Directory(_localPath);
                                                        bool hasExisted1 = savedDir.existsSync();
                                                        if (!hasExisted1) {
                                                          savedDir.create();
                                                        }
                                                        String fileAppend = DateTime.now().millisecondsSinceEpoch.toString();
                                                        String fileName = _infoStrings[index].msg.trim().substring(_infoStrings[index].msg.trim().lastIndexOf("/") + 1);

                                                        await FlutterDownloader.enqueue(
                                                          url: _infoStrings[index].msg.trim(),
                                                          savedDir: _localPath,
                                                          fileName: fileAppend + fileName,
                                                          showNotification: true,
                                                          openFileFromNotification: false,
                                                        );*/
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
                                              //#GCW 20-12-2022
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
                                                      /*PermissionStatus permissionStatus = await Permission.storage.request();
                                                if (permissionStatus != PermissionStatus.granted) return;

                                                _localPath = (await _findLocalPath())!;
                                                final savedDir = Directory(_localPath);
                                                bool hasExisted1 = savedDir.existsSync();
                                                if (!hasExisted1) {
                                                  savedDir.create();
                                                }
                                                String fileAppend = DateTime.now().millisecondsSinceEpoch.toString();
                                                String fileName = _infoStrings[index].msg.trim().substring(_infoStrings[index].msg.trim().lastIndexOf("/") + 1);

                                                await FlutterDownloader.enqueue(
                                                  url: _infoStrings[index].msg.trim(),
                                                  savedDir: _localPath,
                                                  fileName: fileAppend + fileName,
                                                  showNotification: true,
                                                  openFileFromNotification: false,
                                                );*/
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
                                                          /* PermissionStatus permissionStatus = await Permission.storage.request();
                                                        if (permissionStatus != PermissionStatus.granted) return;

                                                        _localPath = (await _findLocalPath())!;
                                                        final savedDir = Directory(_localPath);
                                                        bool hasExisted1 = savedDir.existsSync();
                                                        if (!hasExisted1) {
                                                          savedDir.create();
                                                        }
                                                        String fileAppend = DateTime.now().millisecondsSinceEpoch.toString();
                                                        String fileName = _infoStrings[index].msg.trim().substring(_infoStrings[index].msg.trim().lastIndexOf("/") + 1);

                                                        await FlutterDownloader.enqueue(
                                                          url: _infoStrings[index].msg.trim(),
                                                          savedDir: _localPath,
                                                          fileName: fileAppend + fileName,
                                                          showNotification: true,
                                                          openFileFromNotification: false,
                                                        );*/
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
                                                            'Open file',
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
                                              //#GCW 20-12-2022
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
                                    peerUid: '${this.widget.caseId}',
                                    message: "Message : " +
                                        sendMessageController.text.toString());

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
                  )
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
                                                      child:
                                                          _renderLocalPreview(),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //#GCW 31-12-2022 Remove profile pic
                                    // Stack(
                                    //   children: [
                                    //     Container(
                                    //       alignment: Alignment.center,
                                    //       child: !_connectVideoCall ||
                                    //           !isOtherUserJoined
                                    //           ? Container(
                                    //         child: this
                                    //             .widget
                                    //             .specialistProfile !=
                                    //             ''
                                    //             ? ClipRRect(
                                    //           borderRadius:
                                    //           BorderRadius
                                    //               .circular(0),
                                    //           child: FadeInImage
                                    //               .assetNetwork(
                                    //             placeholder: '',
                                    //             image: AppConstants
                                    //                 .publicImage +
                                    //                 this
                                    //                     .widget
                                    //                     .specialistProfile,
                                    //             width:
                                    //             double.infinity,
                                    //             fit:
                                    //             BoxFit.fitWidth,
                                    //           ),
                                    //         )
                                    //             : Image.asset(
                                    //           AppImages
                                    //               .defaultProfile,
                                    //           height: _expandVideoCall
                                    //               ? MediaQuery.of(
                                    //               context)
                                    //               .size
                                    //               .height -
                                    //               155
                                    //               : 202,
                                    //           width:
                                    //           double.infinity,
                                    //           fit: BoxFit.fitWidth,
                                    //         ),
                                    //       )
                                    //           : Center(
                                    //         child: isOtherVideoMuted
                                    //             ? Container(
                                    //           alignment:
                                    //           Alignment.center,
                                    //           color: Colors.black,
                                    //           height: _expandVideoCall
                                    //               ? MediaQuery.of(
                                    //               context)
                                    //               .size
                                    //               .height -
                                    //               155
                                    //               : 202,
                                    //           width:
                                    //           double.infinity,
                                    //           child: Text(
                                    //             "${widget.firstName} ${widget.lastName}",
                                    //             style: GoogleFonts
                                    //                 .roboto(
                                    //               color:
                                    //               Colors.white,
                                    //               fontSize: 15,
                                    //               fontWeight:
                                    //               FontWeight
                                    //                   .bold,
                                    //             ),
                                    //           ),
                                    //         )
                                    //             : _renderRemoteVideo(),
                                    //       ),
                                    //     ),
                                    //     Align(
                                    //       alignment: Alignment.topLeft,
                                    //       child: Container(
                                    //         width: _expandVideoCall ? 100 : 75,
                                    //         height:
                                    //         _expandVideoCall ? 150 : 100,
                                    //         color: !disableCamera
                                    //             ? Colors.black
                                    //             : Colors.transparent,
                                    //         child: !disableCamera
                                    //             ? Center(
                                    //           child: Icon(
                                    //             Icons.videocam_off,
                                    //             color: Colors.white,
                                    //             size: 24,
                                    //           ),
                                    //         )
                                    //             : GestureDetector(
                                    //           onTap: () {
                                    //             setState(() {
                                    //               // _switch = !_switch;
                                    //             });
                                    //           },
                                    //           child: Center(
                                    //             child:
                                    //             _renderLocalPreview(),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
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
                                          _getAnswer(widget.caseId);
                                        },
                                        child: Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: Image.asset(
                                            AppImages.fileIcon,
                                            width: 19,
                                            height: 19,
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
                                            //#GCW 15-01-2023
                                            joinPopupShown = false;
                                            _leave(context);
                                          } else {
                                            //#GCW 18-10-2023
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
                                    _toggleSendPeerMessage(
                                        peerUid: '${this.widget.caseId}',
                                        message: "User has left");
                                    _logoutEndCase();
                                    if (_joined) {
                                      _leave(context);
                                    }
                                    AppConstants.pusher
                                        .unsubscribe(channelName: "CaseStatus");
                                    AppConstants.pusher.unsubscribe(
                                        channelName: "TimeExtended");
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            SpecialistHomeScreen(),
                                      ),
                                      ModalRoute.withName("/Home"),
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
                                    margin: EdgeInsets.only(top: 54, left: 15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                      TextSpan(
                                                        text:
                                                            ' ${this.widget.degree}',
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Color(
                                                                    0xFFEFF7FF),
                                                                fontSize: 12,
                                                                letterSpacing:
                                                                    0.15),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: _fullScreenChat,
                                                child: Container(
                                                  child: InkWell(
                                                    onTap: () {
                                                      controller.reverse();
                                                      Future.delayed(
                                                          Duration(
                                                              milliseconds:
                                                                  200), () {
                                                        setState(() {
                                                          _fullScreenChat =
                                                              false;
                                                          _expandVideoCall =
                                                              true;
                                                        });
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          left: 10, top: 5),
                                                      child: Image.asset(
                                                        AppImages.downArrowIcon,
                                                        width: 29,
                                                        height: 29,
                                                      ),
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
                                InkWell(
                                  onTap: () {
                                    print("ATIN END CASE PRESSED");
                                    _showCloseCaseConfirmDialog(
                                        this.widget.caseId, context);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 40),
                                    child: Card(
                                      color: AppColors.boxRedColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      elevation: 5,
                                      shadowColor:
                                          Colors.black.withOpacity(0.45),
                                      child: Container(
                                        height: 34,
                                        width: 89,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "End Case",
                                          style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: -0.17,
                                              color: AppColors.whiteColor,
                                              fontSize: 14),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 5),
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
            peerUid: '${this.widget.caseId}', message: "User has left");
        _logoutEndCase();
        if (_joined) {
          _leave(context);
        }
        AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
        AppConstants.pusher.unsubscribe(channelName: "TimeExtended");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SpecialistHomeScreen(),
          ),
          ModalRoute.withName("/Home"),
        );
        return Future.value(false);
      },
    );
  }

  void _leave(BuildContext context) async {
    print("ATIN await engine.leaveChannel();closeAgora(); ");
    setState(() {
      _connectVideoCall = false;
      disableCamera = true;
      _joined = false;
      muted = false;
      _expandVideoCall = false;
      //#GCW 27-01-2023
      _fullScreenChat = true;
    });

    await engine.leaveChannel();
    closeAgora();
    // Navigator.pop(context);
  }

  Future<void> initPlatformState() async {
    await [Permission.camera, Permission.microphone].request();

    //agora update
    // RtcEngineContext context = RtcEngineContext(AppConstants.AGORA_APP_ID);
    // engine = await RtcEngine.createWithContext(context);
    // engine.setEventHandler(
    //   RtcEngineEventHandler(
    //     joinChannelSuccess: (String channel, int uid, int elapsed) {
    //       print('joinChannelSuccess $channel $uid');
    //       setState(() {
    //         _joined = true;
    //       });
    //     },
    //     rejoinChannelSuccess: (String channel, int uid, int elapsed) {
    //       print('joinChannelSuccess $channel $uid');
    //       _joined = true;
    //       //_agoraAcquire(channel);
    //
    //       setState(() {});
    //     },
    //     userJoined: (int uid, int elapsed) {
    //       print('userJoined $uid');
    //       setState(() {
    //         _remoteUid = uid;
    //         isOtherUserJoined = true;
    //         // _agoraAcquire(this.widget.channelName);
    //       });
    //     },
    //     userOffline: (int uid, UserOfflineReason reason) {
    //       print('userOffline $uid');
    //       setState(() {
    //         _remoteUid = 0;
    //         isOtherUserJoined = false;
    //         /*_connectVideoCall = false;
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
    //);

    //create an instance of the Agora engine
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: AppConstants.AGORA_APP_ID));
    await engine.enableVideo();
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          //  log("Local user uid:${connection.localUid} joined the channel");
          //  //#GCW 15-01-203
          // // _setVideoCallStatus();
          //  setState(() {
          //    _joined = true;
          //  });
          //#GCW 27-01-2023
          log("Local user uid:${connection.localUid} joined the channel");
          _joined = true;
          //#GCW 15-01-203
          //_setVideoCallStatus();
          String agoraRID =
              sharedPreferences.getString("DoctorAgoraRID${widget.caseId}") ??
                  "";
          String agoraUID =
              sharedPreferences.getString("DoctorAgoraUID${widget.caseId}") ??
                  "";

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
        },
        onRejoinChannelSuccess: (RtcConnection connection, int elapsed) {
          log('joinChannelSuccess ${connection.channelId} ${connection.localUid}');
          _joined = true;
          //_agoraAcquire(channel);
          setState(() {});
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          log("Remote user uid:$remoteUid joined the channel");
          print('userJoined ${connection.localUid}');
          setState(() {
            _remoteUid = remoteUid;
            isOtherUserJoined = true;
            // _agoraAcquire(this.widget.channelName);
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          log("Remote user uid:$remoteUid left the channel");
          setState(() {
            _remoteUid = 0;
            _leave(context);
          });
        },
      ),
    );

    if (agoraRtcToken != null && this.widget.channelName != null) {
      //agora update
      //await engine.joinChannel(agoraRtcToken, this.widget.channelName, null, 0);
      // Set channel options including the client role and channel profile

      await engine.startPreview();

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
    } else {
      print("Channel and Token Not Available.");
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
      //agora update
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
      //agora update
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
      return Container(
        color: Colors.black,
        height:
            _expandVideoCall ? MediaQuery.of(context).size.height - 155 : 202,
        width: double.infinity,
      );
    }
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    String? userId = sharedPreferences.getString("UserId");

    //_profileImage = (sharedPreferences.getString("ProfilePicture"));

    print("My user Id == $userId");

    Future.delayed(Duration.zero, () {
      _getAgoraRtmToken(this.widget.caseId, userId!);
    });

    //_log("Hi,i'm Dr. " + this.widget.firstName + ".\nHappy to assist you.\nWould you like to continue via\nchat or start a phone/video call?", 0);
    //_log("Hi,i'm Dr. ${this.widget.firstName} ${this.widget.lastName}\nHow are you?", 0);

    _getMessage();

    await AppConstants.pusher.subscribe(
      channelName: "CaseStatus",
      onEvent: (event) {
        log("onEventChat: $event");

        if (event.eventName.toString().contains('CaseClosed')) {
          _logoutEndCase();
          if (_joined) {
            _leave(context);
          }
          AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
          AppConstants.pusher.unsubscribe(channelName: "TimeExtended");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistHomeScreen(),
            ),
            ModalRoute.withName("/Home"),
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

    await AppConstants.pusher.subscribe(
      channelName: "TimeExtended",
      onEvent: (event) {
        log("onEventChat: $event");

        if (event.eventName.toString().contains('TimeExtended')) {
          print("time extended");
          var data = jsonDecode(event.data.toString());

          print("data == $data");
          int minutes = data['minutes'];
          print("Extended == " + minutes.toString());
          myDuration = myDuration + Duration(minutes: minutes);
          //#GCW 07-02-2023 Restart Timer from 00:00
          countdownTimer =
              Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
        }
      },
      onSubscriptionError: (String message, dynamic e) {
        log("onSubscriptionError: $message Exception: $e");
      },
      onSubscriptionSucceeded: (data) {
        log("onSubscriptionSucceeded: data: $data");
      },
    );

    await AppConstants.pusher.connect();
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
          //06-11-2022 | Task - 8 change welcome message | gwc
          //17-12-2022 | Task - 8 change welcome message | gwc
          Message msg = Message(
              "Hi, I'm Dr. ${this.widget.firstName} ${this.widget.lastName}.\nI’m reviewing the case details. How do you prefer to communicate?\n\n-audio/video call\n\nor\n\n-chat",
              1,
              DateTime.now().toString());

          // _pushMessage(
          //     this.widget.caseId, 'Message', "Hi, I'm Dr. ${this.widget.firstName} ${this.widget.lastName}.\nI’m reviewing the case details. How do you prefer to communicate?\n\n-audio/video call\n\nor\n\n-chat");
          _infoStrings.add(msg); //#GCW 16-12-2022 Welcome message specialist

          setState(() {});
        } else {}
      } else {}
    } catch (e, s) {
      log("getPendingCases Error--> Error:-$e stackTrace:-$s");
    }
  }

  _getAgoraRtmToken(String caseId, String myId) async {
    //AnimDialog.showLoadingDialog1(context);

    final url = AppConstants.agoraRtmTokenGenerate;

    log('url--> $url');

    var body = {"user": '$myId-$caseId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('doctorAgoraRtmToken response status--> ${response.statusCode}');
      log('doctorAgoraRtmToken response body--> ${response.body}');

      if (response.statusCode == 200) {
        //AnimDialog.dismissLoadingDialog(context);

        var jsonData = jsonDecode(response.body);
        agoraRtmToken = jsonData['token'].toString();

        print("RtmToken ==> $agoraRtmToken");
        print("RtmFullName ==> $myId-$caseId");

        _initRtmClient(agoraRtmToken, '$myId-$caseId');

        setState(() {});
      } else {
        //AnimDialog.dismissLoadingDialog(context);
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
      //AnimDialog.dismissLoadingDialog(context);
    }
  }

  void _initRtmClient(String agoraRtmToken, String caseId) async {
    _createClient(agoraRtmToken, caseId);
  }

  void _createClient(String _token, String fullName) async {
    _client = await AgoraRtmClient.createInstance(AppConstants.AGORA_APP_ID);

    _client.onMessageReceived = (AgoraRtmMessage message, String peerId) {
      if (message.text == "VideoStopped") {
        setState(() {
          isOtherVideoMuted = true;
        });
      } else if (message.text == "VideoResume") {
        setState(() {
          isOtherVideoMuted = false;
        });
      } else if (message.text == "User joined successfully") {
        //#GCW 15-01-2023
        //_joined?null:_showMyDialog();
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
        peerUid: '${this.widget.caseId}', message: "User joined successfully");
  }

  _toggleSendPeerMessage(
      {required String peerUid, required String message}) async {
    print("Peer UID == $peerUid");

    print("ChannelName == ${widget.channelName}");

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
      print("ATIN RTM CLIENT LOGOUT");
      await _client.logout();
      //#GCW 15-01-2023
      _joined = false;
      //_log("Peer msg: Logout");
    } catch (errorCode) {
      //_log(info: 'Logout error: ' + errorCode.toString(), type: 'error');
    }
  }

  void _logout() async {
    //_toggleSendPeerMessage(peerUid: '${this.widget.caseId}', message: "CaseClosedMessageReceived");
    try {
      await _client.logout();
      AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
      AppConstants.pusher.unsubscribe(channelName: "TimeExtended");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SpecialistHomeScreen(),
        ),
        ModalRoute.withName("/Home"),
      );
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
        setState(() {});
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

  Future<File?> takePicture() async {
    try {
      // Get the available cameras
      List<CameraDescription> cameras = Cameras.cameras;

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

  _imgFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = File(pickedFile.path).readAsBytesSync().lengthInBytes;
      final kb = bytes / 1024;
      final mb = kb / 1024;

      print("FileSize == $mb mb");
      //#GCW 20-12-2022
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
                      peerUid: '${this.widget.caseId}',
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
                      peerUid: '${this.widget.caseId}',
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
    final url = AppConstants.agoraAcquire;

    log('url--> $url');

    var body = {"cname": '$channelName'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);

      log('agoraAcquire response status--> ${response.statusCode}');
      log('agoraAcquire response body--> ${response.body}');
      //#GCW 27-01-2023
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
      log("agoraAcquire Error--> Error:-$e stackTrace:-$s");
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

    //#GCW 26-01-2023
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
                          //#GCW 27-01-2023
                          _agoraStopRecording(widget.channelName, recordingRid,
                              recordingUid, recordingSid);
                          _endCase(caseId, context);
                          //_removeCaseFromFirebaseVideoCallStatusList();
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
    //_toggleSendPeerMessage(peerUid: '${this.widget.caseId}', message: "CaseClosedMessageReceived");
    print("ATIN END CASE");
    sharedPreferences = await SharedPreferences.getInstance();
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.specialistEndCase;

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

      log('specialistEndCase response status--> ${response.statusCode}');
      log('specialistEndCase response body--> ${response.body}');

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
          AppConstants.pusher.unsubscribe(channelName: "TimeExtended");
          _logoutEndCase();
          if (_joined) {
            _leave(context);
          }
          //Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistHomeScreen(),
            ),
            ModalRoute.withName("/Home"),
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

          AppConstants.pusher.unsubscribe(channelName: "CaseStatus");
          AppConstants.pusher.unsubscribe(channelName: "TimeExtended");
          _logoutEndCase();
          if (_joined) {
            _leave(context);
          }
          //Navigator.pop(context);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistHomeScreen(),
            ),
            ModalRoute.withName("/Home"),
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
      log("specialistEndCase Error--> Error:-$e stackTrace:-$s");
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

  _getAnswer(String caseId) async {
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");

    final url = AppConstants.doctorGetAnswer;

    log('url--> $url');

    var body = {"case_id": '$caseId'};

    log('body--> $body');

    try {
      final response = await http.post(Uri.parse(url), body: body);
      log('specialistSubmitAnswer response status--> ${response.statusCode}');
      log('specialistSubmitAnswer response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData['status']['error'] == false) {
          Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
          _getAnswerList.clear();
          docList.clear();
          if (jsonData['data']['answers'].length != 0) {
            log("Answer Length ==> " +
                jsonData['data']['answers'].length.toString());
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

            _showSheet();
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
      log("specialistSubmitAnswer Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_keyDialog.currentContext!, rootNavigator: true).pop();
    }
  }

  void _showSheet() async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10.0),
          topRight: Radius.circular(10.0),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 550,
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(top: 20, bottom: 10),
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
                                      _getAnswerList.length > 0
                                          ? _getAnswerList[0].answers
                                          : '',
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
                                      _getAnswerList.length > 0
                                          ? _getAnswerList[1].answers
                                          : '',
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
                          "Attach Files",
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
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int docIndex) {
                              return InkWell(
                                onTap: () async {
                                  PermissionStatus permissionStatus =
                                      await Permission.storage.request();
                                  if (permissionStatus !=
                                      PermissionStatus.granted) return;

                                  _localPath = (await _findLocalPath())!;
                                  final savedDir = Directory(_localPath);
                                  bool hasExisted1 = savedDir.existsSync();
                                  if (!hasExisted1) {
                                    savedDir.create();
                                  }
                                  String fileAppend = DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString();
                                  String fileName = docList[docIndex]
                                      .trim()
                                      .substring(docList[docIndex]
                                              .trim()
                                              .lastIndexOf("/") +
                                          1);

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
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          child: docList[docIndex]
                                                      .split(".")
                                                      .last ==
                                                  "jpg"
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(0),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder: AppImages
                                                        .defaultPlaceHolder,
                                                    image: docList[docIndex]
                                                        .trim(),
                                                    height: 70,
                                                    width: 70,
                                                    fit: BoxFit.contain,
                                                  ),
                                                )
                                              : docList[docIndex]
                                                          .split(".")
                                                          .last ==
                                                      "png"
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              0),
                                                      child: FadeInImage
                                                          .assetNetwork(
                                                        placeholder: AppImages
                                                            .defaultPlaceHolder,
                                                        image: docList[docIndex]
                                                            .trim(),
                                                        height: 70,
                                                        width: 70,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    )
                                                  : docList[docIndex]
                                                              .split(".")
                                                              .last ==
                                                          "pdf"
                                                      ? Image.asset(
                                                          AppImages
                                                              .textDocument,
                                                          height: 50,
                                                          width: 50,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : docList[docIndex]
                                                                  .split(".")
                                                                  .last ==
                                                              "doc"
                                                          ? Image.asset(
                                                              AppImages
                                                                  .textDocument,
                                                              height: 50,
                                                              width: 50,
                                                              fit: BoxFit
                                                                  .contain,
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
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  //#GCW 14-01-2023
  _setVideoCallStatus() async {
    await ref.equalTo("${this.widget.caseId}").once().then((value) async {
      DataSnapshot snapshot = value.snapshot;
      if (snapshot.exists) {
        await ref.update({
          //#GCW 24-01-2023
          "${this.widget.caseId}": {
            //"${AppConstants.firebaseVideoCallStatus}": _joined
            "${AppConstants.firebaseDoctorStatus}": false,
            "${AppConstants.firebaseSpecialistStatus}": true,
            "${AppConstants.firebaseVideoCallStatus}": true
          }
        }).then((value) {
          Future.delayed(const Duration(seconds: 5), () {
            _removeCaseFromFirebaseVideoCallStatusList();
          });
        });
      } else {
        await ref.update({
          // "${this.widget.caseId}": {
          //   "${AppConstants.firebaseVideoCallStatus}": _joined
          // }
          //#GCW 24-01-2023
          "${this.widget.caseId}": {
            "${AppConstants.firebaseDoctorStatus}": false,
            "${AppConstants.firebaseSpecialistStatus}": true,
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
            ['${AppConstants.firebaseDoctorStatus}'];
        if (value == true && !joinPopupShown) {
          joinPopupShown = true;
          _showMyDialog();
        }
      }
    });
  }

  //#GCW 24-01-2023
  Future<void> closeAgora() async {
    print("calling release");
    await engine.release();
    print("release..");
  }

  void _removeCaseFromFirebaseVideoCallStatusList() {
    //print("remvoing");
    ref.child("${this.widget.caseId}").remove();
  }
}

class Message {
  String msg;
  int myMsg;
  String dateTime;

  Message(this.msg, this.myMsg, this.dateTime);
}
