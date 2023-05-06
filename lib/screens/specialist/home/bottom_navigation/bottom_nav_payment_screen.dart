import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../Doctor/model/SpecialistPaymentListModel.dart';

class PaymentTabScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _paymentTabScreenState();
}

class _paymentTabScreenState extends State<PaymentTabScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late SharedPreferences sharedPreferences;

  String? apiToken;
  bool eligible = false;
  bool isMessageVisible = true;

  List<SpecialistPaymentListModel> _list = [];
  List<SpecialistPaymentListModel> _listTemp = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () {
          return _init();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              isMessageVisible ? paymentMessage() : Container(),
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
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
                    InkWell(
                      onTap: () {},
                      child: Container(
                        height: 40,
                        width: 45,
                        child: Icon(
                          Icons.filter_alt,
                          color: AppColors.appBackGroundColor,
                          size: 40,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                child: ListView.builder(
                  itemCount: _list.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: EdgeInsets.only(
                          bottom: 5, top: 5, left: 10, right: 10),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                              color: AppColors.appBackGroundColor
                                  .withOpacity(0.2)),
                        ),
                        elevation: 10,
                        shadowColor:
                            AppColors.appBackGroundColor.withOpacity(0.3),
                        child: ExpansionTile(
                          trailing: SizedBox.shrink(),
                          tilePadding: EdgeInsets.zero,
                          title: Container(
                            padding:
                                EdgeInsets.only(left: 15, bottom: 10, top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                commonTextView(
                                  title: '#${_list[index].caseId}',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  textColor: AppColors.darkDescriptionColor,
                                ),
                                SizedBox(height: 5),
                                Container(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 43,
                                        width: 43,
                                        child: _list[index].profile != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder: AppImages
                                                      .profilePlaceHolder,
                                                  image: _list[index].profile,
                                                  height: 43,
                                                  width: 43,
                                                  fit: BoxFit.fill,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.asset(
                                                  AppImages.profilePlaceHolder,
                                                  height: 43,
                                                  width: 43,
                                                ),
                                              ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            commonTextView(
                                              title:
                                                  "Dr. ${_list[index].firstName} ${_list[index].lastName}",
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            SizedBox(height: 6),
                                            commonTextView(
                                              //#GCW 02-02-2023
                                              title:
                                                  '${DateFormat("MM/dd/yyyy, h:mm a").format(DateFormat("yyyy-MM-dd hh:mm:ss").parse(_list[index].createdDate))}',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              textColor: AppColors
                                                  .darkDescriptionColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        child: RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: "\$${_list[index].amount} ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppColors.gradientGreen2,
                                              ),
                                            ),
                                            TextSpan(
                                              //#GCW 02-01-2023
                                              text: _list[index].status == "0"
                                                  ? "Pending"
                                                  : "Paid",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: AppColors.gradientGreen2,
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                //#GCW 01-02-2023
                                // Container(
                                //   alignment: Alignment.center,
                                //   child: commonTextView(
                                //     title: 'View More',
                                //     fontWeight: FontWeight.w400,
                                //     fontSize: 14,
                                //     textColor: Color(0xff00305a),
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          children: <Widget>[
                            SizedBox(
                              height: 0,
                            ),
                            //#GCW 01-02-2023
                            // Container(
                            //   padding: EdgeInsets.only(left: 15,right: 15,bottom: 10),
                            //   alignment: Alignment.centerLeft,
                            //   child: commonTextView(
                            //     title: '${_list[index].description}',
                            //     fontWeight: FontWeight.w500,
                            //     fontSize: 14,
                            //     textColor: Colors.black,
                            //   ),
                            //),
                          ],
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
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");
    eligible = (sharedPreferences.getBool("Eligible") ?? false);
    print("ELIGIBLE:$eligible");

    _getRatings(apiToken!, true);

    setState(() {});
  }

  _getRatings(String token, bool isShow) async {
    var isInternetAvailable = await Utils.isInternetAvailable(context);
    if (!isInternetAvailable) {
      return;
    }
    log('Bearer Token ==>  $token');
    isShow ? AnimDialog.showLoadingDialog(context, _key, "Loading...") : null;
    final url = AppConstants.specialistPayment;
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

      log('getSpecialistRating response body--> ${jsonDecode(response.body)}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          _list.clear();
          _listTemp.clear();

          var data = jsonData['data'] as List;

          for (Map array in data) {
            SpecialistPaymentListModel specialistPaymentListModel =
                SpecialistPaymentListModel(
              array['case_id'].toString(),
              array['first_name'] ?? "",
              array['last_name'] ?? "",
              array['profile_picture'] ?? "",
              array['description'] ?? "",
              array['amount'].toString(),
              array['created_at'] ?? "",
              array['status'].toString(),
              array['eligible'],
            );

            _listTemp.add(specialistPaymentListModel);
          }

          _list = _listTemp;

          setState(() {});
        } else {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();
          setState(() {
            _list.clear();
            _listTemp.clear();
          });
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
          _list.clear();
          _listTemp.clear();
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
      log("getSpecialistRating Error--> Error:-$e stackTrace:-$s");
      setState(() {
        _list.clear();
        _listTemp.clear();
      });
      Navigator.of(_key.currentContext!, rootNavigator: true).pop();
    }
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      _list = _listTemp;
    } else {
      List<SpecialistPaymentListModel> tempList =
          <SpecialistPaymentListModel>[];

      for (SpecialistPaymentListModel model in _listTemp) {
        if (model.firstName.toLowerCase().contains(query.toLowerCase()) ||
            model.lastName.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(model);
        }
      }
      _list = tempList;
    }
    setState(() {});
  }

  paymentMessage() {
    return Column(
      children: [
        SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                Card(
                    margin: EdgeInsets.fromLTRB(8, 10, 8, 4),
                    color: Colors.white70,
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(8, 4, 8, 4),
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          decoration: BoxDecoration(
                            color: !eligible ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(24.0),
                          ),
                          child: Text(
                            !eligible
                                ? "Your account is not eligible for payments"
                                : "Your account is ready to receive payments",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: Text(
                            !eligible
                                ? "To setup or update your account to receive payments, login via desktop and visit vsod.io/specialist/profile"
                                : "To update or make changes to the connected account, login via desktop and visit vsod.io/specialist/profile",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )),
                Positioned(
                    right: 0,
                    child: GestureDetector(
                        onTap: () {
                          isMessageVisible = false;
                          setState(() {});
                        },
                        child: Icon(Icons.clear)))
              ],
            )),
      ],
    );
  }
}
