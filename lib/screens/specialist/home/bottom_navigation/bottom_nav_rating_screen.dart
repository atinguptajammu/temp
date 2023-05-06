import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vsod_flutter/screens/Doctor/model/SpecialistRatingModel.dart';
import 'package:vsod_flutter/screens/specialist/OtherProfileScreen.dart';
import 'package:vsod_flutter/utils/app_colors.dart';
import 'package:vsod_flutter/utils/assets.dart';
import 'package:vsod_flutter/widgets/commonWidget.dart';

import '../../../../utils/app_constants.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/AnimDialog.dart';
import '../../../../widgets/ToastMessage.dart';
import '../../../../widgets/home_income_tab_widget/common_gradient_button.dart';

class RatingTabScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RatingTabScreenState();
}

class _RatingTabScreenState extends State<RatingTabScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  late SharedPreferences sharedPreferences;

  String? apiToken;

  List<SpecialistRatingModel> _list = <SpecialistRatingModel>[];
  List<SpecialistRatingModel> _listTemp = <SpecialistRatingModel>[];

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: RefreshIndicator(
          onRefresh: () {
            return _init();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
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
                                  style: TextStyle(color: Colors.black, fontSize: 16),
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
                  child: _list.length > 0
                      ? ListView.builder(
                          itemCount: _list.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              padding: EdgeInsets.only(bottom: 5, top: 5, left: 10, right: 10),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: AppColors.appBackGroundColor.withOpacity(0.2)),
                                ),
                                elevation: 10,
                                shadowColor: AppColors.appBackGroundColor.withOpacity(0.3),
                                child: Container(
                                  padding: EdgeInsets.only(left: 15, bottom: 10, top: 10, right: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            RatingBar(
                                              initialRating: double.parse(_list[index].rating),
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              ignoreGestures: true,
                                              itemCount: 5,
                                              itemSize: 20,
                                              unratedColor: Colors.grey,
                                              itemPadding: EdgeInsets.symmetric(horizontal: 3.0),
                                              ratingWidget: RatingWidget(
                                                full: Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                                half: Icon(
                                                  Icons.star_half,
                                                  color: Colors.amber,
                                                ),
                                                empty: Icon(
                                                  Icons.star,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              onRatingUpdate: (rating) {
                                                print(rating);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              height: 70,
                                              width: 70,
                                              child: _list[index].profileImage != ""
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: FadeInImage.assetNetwork(
                                                        placeholder: AppImages.profilePlaceHolder,
                                                        image: AppConstants.publicImage + _list[index].profileImage,
                                                        height: 70,
                                                        width: 70,
                                                        fit: BoxFit.fill,
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius: BorderRadius.circular(100),
                                                      child: Image.asset(
                                                        AppImages.profilePlaceHolder,
                                                        height: 70,
                                                        width: 70,
                                                      ),
                                                    ),
                                            ),
                                            SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  commonTextView(
                                                    title: "Dr. ${_list[index].firstName != null ? _list[index].firstName : ""} ${_list[index].lastName != null ? _list[index].lastName : ""}",
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  SizedBox(height: 5),
                                                  commonTextView(
                                                    title: '${_list[index].specialization != null ? _list[index].specialization : ""}',
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    textColor: AppColors.darkDescriptionColor,
                                                  ),
                                                  SizedBox(height: 15),
                                                ],
                                              ),
                                            ),
                                            HomeCommonGradientBottom(
                                              onTap: () {
                                                print(_list[index].email);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => OtherProfileScreen(
                                                      address: _list[index].address,
                                                      email: _list[index].email,
                                                      firstName: _list[index].firstName,
                                                      lastName: _list[index].lastName,
                                                      mobile: _list[index].mobile,
                                                      profileImage: _list[index].profileImage,
                                                      specialization: _list[index].specialization,
                                                      timeZone: _list[index].timeZone,
                                                      bio: _list[index].bio,
                                                      degree: _list[index].degree,
                                                      education: _list[index].education,
                                                    ),
                                                  ),
                                                );
                                              },
                                              title: "View Profile",
                                              gradiantColor1: AppColors.gradientBlue1,
                                              gradiantColor2: AppColors.gradientBlue2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 300,
                          alignment: Alignment.center,
                          child: Text(
                            "No data found",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _init() async {
    sharedPreferences = await SharedPreferences.getInstance();

    apiToken = (sharedPreferences.getString("Bearer Token") ?? "");

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
    final url = AppConstants.specialistRating;
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

      log('getSpecialistRating response body--> ${response.body}');

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);

        if (jsonData['status']['error'] == false) {
          Navigator.of(_key.currentContext!, rootNavigator: true).pop();

          _list.clear();
          _listTemp.clear();

          var data = jsonData['data'] as List;

          for (Map array in data) {
            SpecialistRatingModel specialistRatingModel = SpecialistRatingModel(
              array['id'],
              array['user_id'].toString(),
              array['user'] != null ? array['user']['first_name'] : "",
              array['user'] != null ? array['user']['last_name'] : "",
              "${array['user'] != null ? array['user']['profile_picture'] != null ? array['user']['profile_picture'] : "" : ""}",
              array['specialization'] != null ? array['specialization']['name'] : "",
              array['rating'].toString(),
              array['bio'] != null ? array['bio'] : "",
              array['degree'] != null ? array['degree'] : "",
              array['education'] != null ? array['education'] : "",
              array['timezone'] != null ? array['timezone'] : "",
              "${array['user'] != null ? array['user']['address'] != null ? array['user']['address'] : "" : ""}",
              "${array['user'] != null ? array['user']['email'] != null ? array['user']['email'] : "" : ""}",
              "${array['user'] != null ? array['user']['mobile'] != null ? array['user']['mobile'] : "" : ""}",
            );

            _listTemp.add(specialistRatingModel);
          }

          _list = _listTemp;

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
      List<SpecialistRatingModel> tempList = <SpecialistRatingModel>[];

      for (SpecialistRatingModel model in _listTemp) {
        if (model.firstName.toLowerCase().contains(query.toLowerCase()) ||
            model.lastName.toLowerCase().contains(query.toLowerCase()) ||
            model.specialization.toLowerCase().contains(query.toLowerCase())) {
          tempList.add(model);
        }
      }
      _list = tempList;
    }
    setState(() {});
  }
}
