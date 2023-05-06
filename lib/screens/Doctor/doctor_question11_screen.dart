import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:vsod_flutter/screens/Doctor/doctor_payment_Screen.dart';
import 'package:vsod_flutter/screens/Doctor/model/SlotModel.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_string.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/AnimDialog.dart';
import 'package:vsod_flutter/widgets/ToastMessage.dart';
import 'package:vsod_flutter/widgets/common_button/common_gradientButton.dart';
import 'package:vsod_flutter/widgets/common_quetionheader.dart';

import '../../utils/utils.dart';
import 'doctor_question10_screen.dart';

class Question11Screen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Question11ScreenState();
  String caseId;

  Question11Screen({required this.caseId});
}

class _Question11ScreenState extends State<Question11Screen> {
  late SharedPreferences sharedPreferences;
  final GlobalKey<State> _keyDialog = new GlobalKey<State>();

  var val = 1;

  late List<ScheduleTimeModel> _timeList;
  bool _setTimeVisible = false;
  var _selectedDate;
  List<SlotModel> _slotList = <SlotModel>[];

  List<File> files = [];

  List multipleFile = [];
  List uploadedMultipleFile = [];
  String addPath = "";
  List<String> docList = [];

  @override
  void initState() {
    super.initState();
    _init();
    _timeList = [
      ScheduleTimeModel('0', '7:00 am'),
      ScheduleTimeModel('0', '7:20 am'),
      ScheduleTimeModel('0', '7:40 am'),
      ScheduleTimeModel('0', '8:00 am'),
      ScheduleTimeModel('0', '8:20 am'),
      ScheduleTimeModel('0', '8:40 am'),
      ScheduleTimeModel('0', '9:00 am'),
      ScheduleTimeModel('0', '9:20 am'),
      ScheduleTimeModel('0', '9:40 am'),
      ScheduleTimeModel('0', '10:00 am'),
      ScheduleTimeModel('0', '10:20 am'),
      ScheduleTimeModel('0', '10:40 am'),
      ScheduleTimeModel('0', '11:00 am'),
      ScheduleTimeModel('0', '11:20 am'),
      ScheduleTimeModel('0', '11:40 am'),
      ScheduleTimeModel('0', '12:00 pm'),
      ScheduleTimeModel('0', '12:20 pm'),
      ScheduleTimeModel('0', '12:40 pm'),
      ScheduleTimeModel('0', '1:00 pm'),
      ScheduleTimeModel('0', '1:20 pm'),
      ScheduleTimeModel('0', '1:40 pm'),
      ScheduleTimeModel('0', '2:00 pm'),
      ScheduleTimeModel('0', '2:20 pm'),
      ScheduleTimeModel('0', '2:40 pm'),
      ScheduleTimeModel('0', '3:00 pm'),
      ScheduleTimeModel('0', '3:20 pm'),
      ScheduleTimeModel('0', '3:40 pm'),
      ScheduleTimeModel('0', '4:00 pm'),
      ScheduleTimeModel('0', '4:20 pm'),
      ScheduleTimeModel('0', '4:40 pm'),
      ScheduleTimeModel('0', '5:00 pm'),
      ScheduleTimeModel('0', '5:20 pm'),
      ScheduleTimeModel('0', '5:40 pm'),
      ScheduleTimeModel('0', '6:00 pm'),
      ScheduleTimeModel('0', '6:20 pm'),
      ScheduleTimeModel('0', '6:40 pm')
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Column(
              children: [
                CommonQuestionHeader(),
                Container(
                  height: 14,
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Colors.white,
                    color: Color(0xFF31D9F8),
                  ),
                ),
                SizedBox(
                  height: 18,
                ),
                Container(
                  child: Text(
                    "4 of 4",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.44,
                        color: Colors.black,
                        fontSize: 18),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Image.asset(
                    AppImages.attachMent,
                    height: 184,
                    width: 253,
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: Column(
                    children: [
                      Text(
                        "Attach files",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.4,
                            color: Colors.black,
                            fontSize: 16),
                      ),
                      Text(
                        '(Tap on images to delete)',
                        style: TextStyle(
                          color: Colors.black45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    List<XFile>? result = await ImagePicker().pickMultiImage();
                    if (result != null) {
                      List<File> temp =
                          result.map((path) => File(path.path)).toList();
                      for (int i = 0; i < temp.length; i++) {
                        if ((temp[i].path.toString().split('.').last) ==
                            'heif') {
                          List<int> bytes = await File(temp[i].path!.toString())
                              .readAsBytes();
                          var filePath = temp.first.path!.toString();
                          var paths = temp.first.path!.split('/');
                          var finalPath =
                              filePath.replaceAll("${paths.last}", "");
                          var fileName =
                              temp.first.path!.split('/').last.split('.').first;
                          var _imageFile =
                              await File("${finalPath}$fileName.jpeg")
                                  .writeAsBytes(bytes);
                          log("Image $_imageFile");
                          temp[i] = _imageFile;
                        }
                        log("Temp[i] ${temp[i]}");
                        final bytes =
                            File(temp[i].path).readAsBytesSync().lengthInBytes;
                        final kb = bytes / 1024;
                        final mb = kb / 1024;
                        print("LISTFileSize == $mb mb");

                        //#GCW 19-02-2023 Remove file size limit
                        if (mb < 10) {
                          //#GCW 16-12-2022 Change file size from 2 to 10
                          files.add(temp[i]);
                          print("LISTFile Length : " + temp.length.toString());
                        }
                      }
                      setState(() {});
                    } else {
                      // User canceled the picker
                    }
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Color(0xFF348FF8).withOpacity(0.40), width: 1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.45),
                    margin: EdgeInsets.symmetric(horizontal: 45),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      height: 155,
                      child: files == null
                          ? Container(
                              height: 120,
                              child: ListView.builder(
                                itemCount: docList.length,
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: (docList[index].split(".").last ==
                                                "jpg" ||
                                            docList[index].split(".").last ==
                                                "png")
                                        ? Container(
                                            width: 120,
                                            child: ListTile(
                                              onTap: () async {
                                                bool? deletePic =
                                                    await _showDeleteConfirmationDialog(
                                                        context);
                                                if (deletePic != null) {
                                                  deletePic
                                                      ? files.removeAt(index)
                                                      : null;
                                                }
                                                setState(() {});
                                                print("VALUES$index");
                                              },
                                              leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder: AppImages
                                                      .defaultPlaceHolder,
                                                  image: docList[index].trim(),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          )
                                        : docList[index].split(".").last ==
                                                "pdf"
                                            ? Container(
                                                width: 120,
                                                child: ListTile(
                                                  onTap: () async {
                                                    bool? deletePic =
                                                        await _showDeleteConfirmationDialog(
                                                            context);
                                                    if (deletePic != null) {
                                                      deletePic
                                                          ? files
                                                              .removeAt(index)
                                                          : null;
                                                    }
                                                    setState(() {});
                                                    print("VALUES$index");
                                                  },
                                                  leading: Image.asset(
                                                    AppImages.textDocument,
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              )
                                            : docList[index].split(".").last ==
                                                    "doc"
                                                ? Image.asset(
                                                    AppImages.textDocument,
                                                    height: 100,
                                                    width: 100,
                                                    fit: BoxFit.contain,
                                                  )
                                                : Text(
                                                    "attach file here",
                                                    style: GoogleFonts.roboto(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                  );
                                },
                              ),
                            )
                          : files != null
                              ? Container(
                                  height: 120,
                                  child: ListView.builder(
                                    itemCount: files.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        alignment: Alignment.center,
                                        child: files[index]
                                                    .path
                                                    .split(".")
                                                    .last ==
                                                "jpg"
                                            ? Container(
                                                width: 120,
                                                child: ListTile(
                                                  onTap: () async {
                                                    bool? deletePic =
                                                        await _showDeleteConfirmationDialog(
                                                            context);
                                                    if (deletePic != null) {
                                                      deletePic
                                                          ? files
                                                              .removeAt(index)
                                                          : null;
                                                    }
                                                    setState(() {});
                                                    print("VALUES$index");
                                                  },
                                                  leading: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0),
                                                    child: Image.file(
                                                      File(files[index].path),
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : files[index]
                                                        .path
                                                        .split(".")
                                                        .last ==
                                                    "png"
                                                ? Container(
                                                    width: 120,
                                                    child: ListTile(
                                                      onTap: () async {
                                                        bool? deletePic =
                                                            await _showDeleteConfirmationDialog(
                                                                context);
                                                        if (deletePic != null) {
                                                          deletePic
                                                              ? files.removeAt(
                                                                  index)
                                                              : null;
                                                        }
                                                        setState(() {});
                                                        print("VALUES$index");
                                                      },
                                                      subtitle: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(0),
                                                        child: Image.file(
                                                          File(files[index]
                                                              .path
                                                              .toString()),
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    height: 120,
                                                    width: 120,
                                                    child: ListTile(
                                                      onTap: () async {
                                                        bool? deletePic =
                                                            await _showDeleteConfirmationDialog(
                                                                context);
                                                        if (deletePic != null) {
                                                          deletePic
                                                              ? files.removeAt(
                                                                  index)
                                                              : null;
                                                        }
                                                        setState(() {});
                                                        print("VALUES$index");
                                                      },
                                                      subtitle: Image.asset(
                                                        AppImages.textDocument,
                                                        height: 120,
                                                        width: 120,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  ),
                                      );
                                    },
                                  ),
                                )
                              : Text(
                                  "attach file here",
                                  style: GoogleFonts.roboto(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          List<XFile>? result = await ImagePicker()
                              .pickMultiImage(requestFullMetadata: true);
                          if (result != null) {
                            List<File> temp =
                                result.map((path) => File(path.path)).toList();
                            for (int i = 0; i < temp.length; i++) {
                              if ((temp[i].path.toString().split('.').last) ==
                                  'heif') {
                                List<int> bytes =
                                    await File(temp[i].path!.toString())
                                        .readAsBytes();
                                var filePath = temp.first.path!.toString();
                                var paths = temp.first.path!.split('/');
                                var finalPath =
                                    filePath.replaceAll("${paths.last}", "");
                                var fileName = temp.first.path!
                                    .split('/')
                                    .last
                                    .split('.')
                                    .first;
                                var _imageFile =
                                    await File("${finalPath}$fileName.jpeg")
                                        .writeAsBytes(bytes);
                                log("Image $_imageFile");
                                temp[i] = _imageFile;
                              }
                              log("Temp[i] ${temp[i]}");
                              final bytes = File(temp[i].path)
                                  .readAsBytesSync()
                                  .lengthInBytes;
                              final kb = bytes / 1024;
                              final mb = kb / 1024;
                              print("LISTFileSize == $mb mb");

                              //#GCW 19-02-2023 Remove file size limit
                              if (mb < 10) {
                                //#GCW 16-12-2022 Change file size from 2 to 10
                                files.add(temp[i]);
                                print("LISTFile Length : " +
                                    temp.length.toString());
                              }
                            }
                            setState(() {});
                          } else {
                            // User canceled the picker
                          }
                        },
                        child: Row(
                          children: [
                            Text(
                              'Images',
                              textAlign: TextAlign.left,
                              style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.4,
                                  color: Colors.black,
                                  fontSize: 16),
                            ),
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          _submitAnswer("[]", "4", this.widget.caseId, context);
                        },
                        child: Row(
                          children: [
                            Container(
                              child: Text(
                                "Skip",
                                textAlign: TextAlign.left,
                                style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.4,
                                    color: Colors.black,
                                    fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 15),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 46, bottom: 27),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageTransition(
                            child: Question10Screen(
                              caseId: this.widget.caseId,
                            ),
                            type: PageTransitionType.leftToRight,
                          ),
                        );
                      },
                      child: Container(
                        height: 34,
                        width: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF4AA16),
                              const Color(0xFFA16C00),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 17),
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Previous",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: -0.17),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                  Container(
                    margin: EdgeInsets.only(right: 46, bottom: 27),
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        //#GCW 16-02-2023 image delete options
                        if (files.length > 0) {
                          AnimDialog.showLoadingDialog(
                              context, _keyDialog, "Loading...");
                          List<Future> futures = [];
                          for (int i = 0; i < files.length; i++) {
                            final bytes = File(files[i].path)
                                .readAsBytesSync()
                                .lengthInBytes;
                            final kb = bytes / 1024;
                            final mb = kb / 1024;
                            print("FileSize == $mb mb");

                            //#GCW 19-02-2023
                            //if (mb < 10) {
                            print("File Length : " + files.length.toString());
                            final url = AppConstants.publicUpload;
                            log('url--> $url');

                            var response = new http.MultipartRequest(
                                "POST", Uri.parse(url));

                            response.files.addAll([
                              await http.MultipartFile.fromPath(
                                  'file', files[i].path),
                            ]);
                            print("SENDING FILE");
                            futures.add(response.send().then(
                              (response) {
                                return http.Response.fromStream(response);
                              },
                            ).then((onValue) {
                              try {
                                print(onValue.body);
                                if (onValue.statusCode == 200) {
                                  var jsonData = jsonDecode(onValue.body);

                                  if (jsonData['status']['error'] == false) {
                                    String path =
                                        jsonData['data']['path'] != null
                                            ? jsonData['data']['path']
                                            : '';
                                    String path1 = path.replaceAll(
                                        "https://elasticbeanstalk-us-east-1-290452992164.s3.amazonaws.com/",
                                        '');
                                    print("ATIN ADD $i");
                                    multipleFile.add("${'"'}${path1}${'"'}");

                                    log("Multiple File Length:" +
                                        multipleFile.length.toString());

                                    log("Index == $i");
                                    log("Files.length == ${files.length - 1}");
                                  } else {
                                    Navigator.of(_keyDialog.currentContext!,
                                            rootNavigator: true)
                                        .pop();
                                    ToastMessage.showToastMessage(
                                      context: context,
                                      message: jsonData['status']['message'][0]
                                          .toString(),
                                      duration: 3,
                                      backColor: Colors.red,
                                      position: StyledToastPosition.center,
                                    );
                                  }
                                } else {
                                  Navigator.of(_keyDialog.currentContext!,
                                          rootNavigator: true)
                                      .pop();
                                  ToastMessage.showToastMessage(
                                    context: context,
                                    message:
                                        "Something bad happened,try again after some time.",
                                    duration: 3,
                                    backColor: Colors.red,
                                    position: StyledToastPosition.center,
                                  );
                                }
                              } catch (e, s) {
                                Navigator.of(_keyDialog.currentContext!,
                                        rootNavigator: true)
                                    .pop();
                                log("doctorPhotoChange Error--> Error:-$e stackTrace:-$s");
                              }
                            }));
                            // } else {
                            //   ToastMessage.showToastMessage(
                            //     context: context,
                            //     message: "Maximum 10 MB of file size limit has reached",
                            //     duration: 3,
                            //     backColor: Colors.red,
                            //     position: StyledToastPosition.center,
                            //   );
                            // }
                          }

                          // wait for all HTTP requests to complete
                          await Future.wait(futures);
                          Navigator.of(_keyDialog.currentContext!,
                                  rootNavigator: true)
                              .pop();
                          log("Multiple File Path:" + "${multipleFile.length}");
                          await _submitAnswer(multipleFile.toString(), "4",
                              this.widget.caseId, context);
                        } else {
                          _submitAnswer("[]", "4", this.widget.caseId, context);
                          log("Submit answer [] blank");
                        }
                      },
                      child: Container(
                        height: 34,
                        width: 130,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4BD863),
                              const Color(0xFF038F12),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 1.0],
                            tileMode: TileMode.clamp,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Connect a Call",
                                  style: GoogleFonts.roboto(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: -0.17),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 5),
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Future.delayed(Duration.zero, () {
      _getAnswer(this.widget.caseId);
    });
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Image?'),
          content: Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
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
          // _uploadFile = jsonData['data'][10]['answers'] != null ? jsonData['data'][10]['answers'].toString().substring(1, jsonData['data'][10]['answers'].toString().length - 1) : null;
          // print("Path ==> " + _uploadFile);
          // if (jsonData['data'][10]['answers'] != null) {
          //   _selectFileType = _uploadFile.split(".").last.toString();
          // }
          docList.clear();
          if (jsonData['data']['answers'][3]['answers'] != null) {
            docList = jsonData['data']['answers'][3]['answers']
                .toString()
                .substring(
                    1,
                    jsonData['data']['answers'][3]['answers']
                            .toString()
                            .length -
                        1)
                .toString()
                .split(",");
            log("Select File Type -->" + docList[0].toString());
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

  _submitAnswer(String path, String questionId, String caseId,
      BuildContext context) async {
    print("ATINSUBMITANSWER");
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorSubmitAnswer;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({
      "answer": '$path',
      "questionnaire_id": '$questionId',
      "case_id": '$caseId'
    });

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
          _showCaseTypeDialog(context, caseId);
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

  _submitAnswer1(String path, String questionId, String caseId,
      BuildContext context) async {
    String token = (sharedPreferences.getString("Bearer Token") ?? "");
    log('Bearer Token ==>  $token');
    AnimDialog.showLoadingDialog(context, _keyDialog, "Loading...");
    final url = AppConstants.doctorSubmitAnswer;

    log('url--> $url');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };
    var body = json.encode({
      "answer": '$path',
      "questionnaire_id": '$questionId',
      "case_id": '$caseId'
    });

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
          _showCaseTypeDialog(context, caseId);
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

  void _showCaseTypeDialog(BuildContext context, String caseId) {
    print("ATIN SHOW CASE DIALOG");
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
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Please Confirm",
                      style: GoogleFonts.roboto(
                          color: AppColors.textPrussianBlueColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          letterSpacing: 0.4),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      "Ready to be create an active case.",
                      style: GoogleFonts.roboto(
                          color: AppColors.textBlackColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          letterSpacing: 0.4),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.black,
                            ),
                            child: Radio(
                              value: 1,
                              groupValue: val,
                              onChanged: (value) {
                                setState(() {
                                  val = int.parse(value.toString());
                                  print("Val : " + val.toString());
                                });
                              },
                              activeColor: AppColors.textPrussianBlueColor,
                            ),
                          ),
                          Text(
                            'Live Consultation',
                            style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrussianBlueColor),
                          ),
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: Colors.black,
                            ),
                            child: Radio(
                              value: 2,
                              groupValue: val,
                              onChanged: (value) {
                                setState(() {
                                  val = int.parse(value.toString());
                                  print("Val : " + val.toString());
                                });
                              },
                              activeColor: AppColors.textPrussianBlueColor,
                            ),
                          ),
                          Text(
                            'Schedule Consultation',
                            style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textPrussianBlueColor),
                          ),
                        ],
                      )),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: CommonButtonGradient(
                            height: 40,
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
                            height: 40,
                            fontSize: 14,
                            buttonName: AppStrings.yes,
                            colorGradient1: AppColors.gradientGreen1,
                            colorGradient2: AppColors.gradientGreen2,
                            onTap: () {
                              Navigator.pop(context);

                              if (val == 1) {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                        caseId: caseId,
                                        channelName: '',
                                        caseType: 'live'),
                                  ),
                                );
                                //_startLiveCase('live', caseId);
                              } else {
                                // _setTimeVisible = false;
                                // _slotList.clear();
                                // _showScheduleDialog(context, caseId);
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(
                                        caseId: caseId,
                                        channelName: '',
                                        caseType: 'schedule'),
                                  ),
                                );
                              }
                            },
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
            );
          },
        );
      },
    );
  }

  void _showScheduleDialog(BuildContext context, String caseId) {
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
                  child: Text(
                    //#GCW 14-02-2023
                    "You have requested this case for the times below. If case is not accepted, click \"re-schedule\" to submit different times or to resubmit as a live case",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w400,
                        fontSize: 12,
                        letterSpacing: 0.25,
                        color: AppColors.textDarkBlue),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: Text(
                    "You can choose 5 slots",
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
                            minDate: DateTime.now().add(Duration(days: 1)),
                            maxDate: DateTime(2100),
                            // initialSelectedDate: _selectedDate,
                            onSelectionChanged:
                                (DateRangePickerSelectionChangedArgs args) {
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
                                  style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      letterSpacing: 0.2,
                                      color: AppColors.textDarkBlue),
                                ),
                              ),
                              Container(
                                height: 250,
                                margin: EdgeInsets.only(top: 5),
                                child: ListView.builder(
                                  itemCount: _timeList.length,
                                  shrinkWrap: true,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      child: InkWell(
                                        onTap: () {
                                          if (_slotList.length == 5) {
                                            ToastMessage.showToastMessage(
                                              context: context,
                                              message: 'Max 5 Slot Select',
                                              duration: 3,
                                              backColor: Colors.red,
                                              position:
                                                  StyledToastPosition.center,
                                            );
                                          } else {
                                            for (int i = 0;
                                                i < _slotList.length;
                                                i++) {
                                              if (_slotList[i].date ==
                                                  _selectedDate.toString()) {
                                                log("SLot Date ==> " +
                                                    _slotList[i]
                                                        .date
                                                        .toString());
                                                if (_slotList[i].slotTime ==
                                                    _timeList[index]._time) {
                                                  ToastMessage.showToastMessage(
                                                    context: context,
                                                    message: 'Already Select',
                                                    duration: 3,
                                                    backColor: Colors.red,
                                                    position:
                                                        StyledToastPosition
                                                            .center,
                                                  );
                                                  return;
                                                }
                                              }
                                            }
                                            SlotModel slotModel = SlotModel(
                                                _selectedDate.toString(),
                                                _timeList[index]._time);
                                            _slotList.add(slotModel);
                                          }
                                          setState(() {});
                                        },
                                        child: Card(
                                          color: AppColors.lightGreyColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
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
                                                      style: GoogleFonts.roboto(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.15,
                                                          color: AppColors
                                                              .textPrussianBlueColor,
                                                          fontSize: 12),
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
                        slotTime = slotTime! +
                            (DateFormat('dd/MM/yyyy')
                                    .format(DateTime.parse(_slotList[j].date)))
                                .toString() +
                            " " +
                            _slotList[j].slotTime.split(" ").first +
                            ",";
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

  _startLiveCase(String caseType, String caseId) async {
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
    var body = json.encode({"case_type": '$caseType', "case_id": '$caseId'});

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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentScreen(
                  caseId: caseId,
                  channelName: jsonData['data'][0]!['channel_name'],
                  caseType: 'live'),
            ),
          );
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

  ScheduleTimeModel(this._selected, this._time);

  String get time => _time;

  set time(String value) {
    _time = value;
  }

  String get selected => _selected;

  set selected(String value) {
    _selected = value;
  }
}

class AddFile {
  String _filePath;

  AddFile(this._filePath);

  String get filePath => _filePath;

  set filePath(String value) {
    _filePath = value;
  }
}
