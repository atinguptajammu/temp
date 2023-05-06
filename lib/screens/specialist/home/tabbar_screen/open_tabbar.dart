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
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/specialist/SpecialistPaymentStatusScreen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';
import 'package:vsod_flutter/widgets/home_income_tab_widget/common_gradient_button.dart';

import '../../../../model/SpecialistOpenCaseModel.dart';
import '../../../../utils/app_constants.dart';
import '../../../../utils/app_string.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../../widgets/common_button/common_gradientButton.dart';
import '../../../Doctor/model/GetAnswerModel.dart';
import '../../SpecialistChatScreen.dart';

class OpenTabBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OpenTabBarState();
}

class _OpenTabBarState extends State<OpenTabBar> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late String apiToken;

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
    final _openCaseModel = Provider.of<OpenDataProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
          onRefresh: () {
            return _init(true);
          },
          //#GCW 18-12-2022
          child: _openCaseModel.post.data != null &&
                  _openCaseModel.post.data!.length > 0
              ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: _openCaseModel.post.data != null &&
                                  _openCaseModel.post.data!.length > 0
                              ? ListView.builder(
                                  itemCount: _openCaseModel.post.data != null
                                      ? _openCaseModel.post.data!.length
                                      : 0,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15, top: 5),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 20),
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
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      commonTextView(
                                                          title:
                                                              '#${_openCaseModel.post.data![index].id}',
                                                          fontWeight:
                                                              FontWeight.w600),
                                                      /*Text(
                                                '${DateFormat('dd MMM yyyy|kk:mm').format(DateTime.parse(_openCaseModel.post.data![index].createdAt!))}',
                                                style: TextStyle(color: AppColors.descriptionTextColor),
                                              ),*/
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Container(
                                                height: 100,
                                                color: Colors.white
                                                    .withOpacity(0.7),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 70,
                                                      height: 70,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: Colors
                                                              .transparent,
                                                          width: 1,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.all(
                                                          Radius.circular(100),
                                                        ),
                                                      ),
                                                      child: _openCaseModel
                                                                  .post
                                                                  .data![index]
                                                                  .doctor!
                                                                  .profilePicture !=
                                                              null
                                                          ? ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child: FadeInImage
                                                                  .assetNetwork(
                                                                placeholder:
                                                                    AppImages
                                                                        .profilePlaceHolder,
                                                                image: AppConstants
                                                                        .publicImage +
                                                                    _openCaseModel
                                                                        .post
                                                                        .data![
                                                                            index]
                                                                        .doctor!
                                                                        .profilePicture!,
                                                                height: 70,
                                                                width: 70,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            )
                                                          : ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              child:
                                                                  Image.asset(
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
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        children: [
                                                          commonTextView(
                                                            title:
                                                                'Dr. ${_openCaseModel.post.data![index].doctor!.firstName} ${_openCaseModel.post.data![index].doctor!.lastName}',
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                                MainAxisSize
                                                                    .max,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Spacer(),
                                                              HomeCommonGradientBottom(
                                                                onTap: () {
                                                                  Navigator
                                                                      .push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              SpecialistChatScreen(
                                                                        degree:
                                                                            "",
                                                                        lastName: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .doctor!
                                                                            .lastName!,
                                                                        firstName: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .doctor!
                                                                            .firstName!,
                                                                        caseId: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .id
                                                                            .toString(),
                                                                        channelName: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .channelName!,
                                                                        specialistId: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .doctor!
                                                                            .id
                                                                            .toString(),
                                                                        specialistProfile:
                                                                            _openCaseModel.post.data![index].doctor!.profilePicture ??
                                                                                "",
                                                                        caseSeconds: _openCaseModel
                                                                            .post
                                                                            .data![index]
                                                                            .seconds!,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                title: "Resume",
                                                                gradiantColor1:
                                                                    AppColors
                                                                        .gradientBlue1,
                                                                gradiantColor2:
                                                                    AppColors
                                                                        .gradientBlue2,
                                                              ),
                                                              Spacer(),
                                                              HomeCommonGradientBottom(
                                                                onTap: () {
                                                                  //_showCloseCaseConfirmDialog(token, caseId, index);
                                                                  _showCloseDialog(
                                                                      context,
                                                                      apiToken,
                                                                      _openCaseModel
                                                                          .post
                                                                          .data![
                                                                              index]
                                                                          .id
                                                                          .toString(),
                                                                      index);
                                                                },
                                                                title:
                                                                    "End Case",
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
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
                                                      _getAnswer(_openCaseModel
                                                          .post.data![index].id
                                                          .toString());
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Text(
                                                    isOpen == index
                                                        ? 'Hide Details'
                                                        : 'View Details',
                                                    style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w700,
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
                                                            left: 18,
                                                            right: 15),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                "Clinic Address: ",
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0xFF747474),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                "$clinicAddress",
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
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
                                                            left: 18,
                                                            right: 15),
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                "Clinic State: ",
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 15,
                                                                  color: Color(
                                                                      0xFF747474),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                "$clinicState",
                                                                style:
                                                                    GoogleFonts
                                                                        .roboto(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),

                                                      /*Container(
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
                                                            left: 18,
                                                            right: 15),
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
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                3),
                                                                    child: Text(
                                                                      _getAnswerList.length >
                                                                              0
                                                                          ? _getAnswerList[0]
                                                                              .answers
                                                                          : '',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            14,
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
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                3),
                                                                    child: Text(
                                                                      _getAnswerList.length >
                                                                              0
                                                                          ? _getAnswerList[1]
                                                                              .answers
                                                                          : '',
                                                                      style: GoogleFonts
                                                                          .roboto(
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontSize:
                                                                            14,
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
                                                        margin: EdgeInsets.only(
                                                            left: 18),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "What do you need help with?",
                                                          style: GoogleFonts
                                                              .roboto(
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
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          _getAnswerList
                                                                      .length >
                                                                  0
                                                              ? _getAnswerList[
                                                                      2]
                                                                  .answers
                                                              : '',
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF747474),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 18),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          "Attached Files",
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize: 18,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 18),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Container(
                                                          height: 80,
                                                          child:
                                                              ListView.builder(
                                                            itemCount:
                                                                docList.length,
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            shrinkWrap: true,
                                                            itemBuilder:
                                                                (BuildContext
                                                                        context,
                                                                    int docIndex) {
                                                              print(
                                                                  "Len${docList.length}");
                                                              print(
                                                                  "FORMAT:${docList[docIndex].split(".").last}");
                                                              return InkWell(
                                                                onTap:
                                                                    () async {
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
                                                                  bool
                                                                      hasExisted1 =
                                                                      savedDir
                                                                          .existsSync();
                                                                  if (!hasExisted1) {
                                                                    savedDir
                                                                        .create();
                                                                  }
                                                                  String
                                                                      fileAppend =
                                                                      DateTime.now()
                                                                          .millisecondsSinceEpoch
                                                                          .toString();
                                                                  String fileName = docList[
                                                                          docIndex]
                                                                      .trim()
                                                                      .substring(
                                                                          docList[docIndex].trim().lastIndexOf("/") +
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
                                                                child:
                                                                    Container(
                                                                  child: _getAnswerList
                                                                              .length >
                                                                          0
                                                                      ? Container(
                                                                          margin:
                                                                              EdgeInsets.symmetric(horizontal: 5),
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
                                                                          //#GCW 14-02-2023
                                                                                  : docList[docIndex].split(".").last == "heic"
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
                                                                          ):
                                                                          docList[docIndex].split(".").last == "heif"
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
                                  })
                              : Container(
                                  height:
                                      MediaQuery.of(context).size.height - 200,
                                  width: double.infinity,
                                ),
                        ),
                      ],
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
                      "You have no open cases\n Pull down to Refresh",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          letterSpacing: 0.25,
                          color: AppColors.textPrussianBlueColor),
                    ),
                  ))),
      // Container(
      //         height: double.infinity,
      //         width: double.infinity,
      //         child: Column(
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           crossAxisAlignment: CrossAxisAlignment.center,
      //           children: [
      //             Text(
      //               "You have no Open Cases",
      //               textAlign: TextAlign.center,
      //               style: GoogleFonts.roboto(
      //                   fontWeight: FontWeight.w400,
      //                   fontSize: 16,
      //                   letterSpacing: 0.25,
      //                   color: AppColors.textPrussianBlueColor),
      //             ),
      //           ],
      //         ),
      //       ),
    );
  }

  _init(bool isRefresh) async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

    Future.delayed(Duration(milliseconds: isRefresh ? 0 : 400), () async {
      var isInternetAvailable = await Utils.isInternetAvailable(context);
      if (!isInternetAvailable) {
        return;
      }

      AnimDialog.showLoadingDialog(context, _key, "");

      Provider.of<OpenDataProvider>(context, listen: false)
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

  _endCase(BuildContext context, String token, String caseId, int i) async {
    AnimDialog.showLoadingDialog(context, _key, "Loading...");

    final url = AppConstants.specialistEndCase;

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

      log('specialistEndCase response body--> ${response.body}');

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

          //Provider.of<OpenDataProvider>(context, listen: false).getPostData(context, apiToken);
          Navigator.pop(context);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialistPaymentStatusScreen(),
            ),
          );

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
      log("specialistEndCase Error--> Error:-$e stackTrace:-$s");
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  _showCloseCaseConfirmDialog(String token, String caseId, int index) {
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
                  "Are you sure you want to close this case?",
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
                          //_endCase(token, caseId, index);
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

  _showCloseDialog(
      BuildContext context, String token, String caseId, int index) {
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
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Close Case",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            letterSpacing: 0.25,
                            color: AppColors.textPrussianBlueColor),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: EdgeInsets.only(top: 5),
                    alignment: Alignment.center,
                    child: Text(
                      "I have completed this case",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          letterSpacing: 0.25,
                          color: AppColors.textDarkBlue),
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: CommonButtonGradient(
                      height: 40,
                      width: 148,
                      fontSize: 14,
                      //#GCW 05-02-2023
                      buttonName: "Close Case",
                      //buttonName: "Confirm Payment",
                      colorGradient1: AppColors.gradientGreen1,
                      colorGradient2: AppColors.gradientGreen2,
                      fontWeight: FontWeight.w500,
                      onTap: () {
                        _endCase(context, token, caseId, index);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Future<SpecialistOpenCaseModel> getOpenCase(context, token) async {
  //AnimDialog.showLoadingDialog1(context);

  final url = AppConstants.specialistGetOpenCase;
  log('url--> $url');

  SpecialistOpenCaseModel? result;
  try {
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    log('getOpenCase response body--> ${response.body}');
    if (response.statusCode == 200) {
      //AnimDialog.dismissLoadingDialog(context);

      final item = json.decode(response.body);
      result = SpecialistOpenCaseModel.fromJson(item);
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

class OpenDataProvider with ChangeNotifier {
  SpecialistOpenCaseModel post = SpecialistOpenCaseModel();
  bool loading = false;

  getPostData(context, token) async {
    loading = true;
    post = await getOpenCase(context, token);
    loading = false;

    notifyListeners();
  }
}
