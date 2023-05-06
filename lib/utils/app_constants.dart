import 'dart:core';

import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

class AppConstants {

  static PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

  /// Font Family
  static const String roboto = 'Roboto';
  static const String openSans = 'OpenSans';

  static const String publicImage = 'https://elasticbeanstalk-us-east-1-290452992164.s3.amazonaws.com/';

  static String keyToken = "keyToken";
  static String baseUrl = "https://vsod.io";
  static String secondaryUrl = "$baseUrl/api/vd1";

  static String STORE_FCM_TOKEN = '$secondaryUrl/update-fcm-token';

  /// Agora
  static String AGORA_APP_ID = '34901eefd3634abbaacf3b988b609f00';
  //static String AGORA_APP_ID = 'd6b675dc239844c8a0139deb64e03768';
  static String agoraRtcTokenGenerate = '$secondaryUrl/agora-rtc-token';
  static String agoraRtmTokenGenerate = '$secondaryUrl/agora-chat-token';
  static String agoraAcquire = '$secondaryUrl/agora/acquire';
  static String agoraStartRecording = '$secondaryUrl/agora/start-recording';
  static String agoraStopRecording = '$secondaryUrl/agora/stop-recording';
  // static final String AGORA_TEMP_CHANNEL_NAME = "6ca1e29e-1e6f-4c19-89eb-42d4687c79cd";

  // static final String AGORA_TEMP_RTC_TOKEN = "006d6b675dc239844c8a0139deb64e03768IAB0U9tq9tDO3a2zCl3eFUIVYjPLGRUMaYRsiyeQVhdP6+/vEJ4AAAAAIgCgqwAAczSHYgQAAQAD8YViAwAD8YViAgAD8YViBAAD8YVi";

  /// Constant API Value
  static const String specialist = 'specialist';
  static const String clinic = 'clinic';

  ///Apis
  static String timezone = '$secondaryUrl/timezones';
  static String loginApi = '$secondaryUrl/login';
  static String needHelpApi = '$secondaryUrl/support';
  static String registerApi = '$secondaryUrl/register';
  static String getStates = '$secondaryUrl/get_states';
  static String forgetPassword = '$secondaryUrl/forgot-password';
  static String specializationAPI = '$secondaryUrl/get_specializations';
  static String publicUpload = '$secondaryUrl/upload-image';
  static String notification = '$secondaryUrl/notifications';
  static String getSpecialistData = '$secondaryUrl/get_specialist_data';
  static String getCurrentTime = '$secondaryUrl/current-time';


  ///Doctor Api
  static String getSpecializations = '$secondaryUrl/get_specializations';
  static String doctorOpenCases = '$secondaryUrl/doctor/open-cases';
  static String doctorPendingCases = '$secondaryUrl/doctor/pending-cases';
  static String doctorProfile = '$secondaryUrl/doctor/profile';
  static String doctorChangePhoto = '$secondaryUrl/doctor/change-photo';
  static String doctorUpdatePassword = '$secondaryUrl/doctor/change-password';
  static String doctorCreateCase = '$secondaryUrl/doctor/start-case';
  static String doctorSubmitAnswer = '$secondaryUrl/doctor/submit-answers';
  static String doctorGetAnswer = '$secondaryUrl/get-answers';
  static String doctorHistory = '$secondaryUrl/doctor/get-activities';
  static String doctorCancelCase = '$secondaryUrl/doctor/cancel-case';
  static String doctorAffiliatePost = '$secondaryUrl/doctor/affiliate';
  static String doctorEndCase = '$secondaryUrl/doctor/end-case';
  static String doctorStartCase = '$secondaryUrl/doctor/case-active';
  static String doctorUpdateTime = '$secondaryUrl/doctor/update-time';
  static String doctorCaseStatus = '$secondaryUrl/doctor/case-status/';
  static String doctorSubmitReview = '$secondaryUrl/doctor/submit-review';
  static String doctorPushMessage = '$secondaryUrl/push-message';
  static String doctorGetMessage = '$secondaryUrl/get-message';
  static String doctorAddTime = '$secondaryUrl/doctor/add-time';


  ///Specialist Api
  static String specialistProfile = '$secondaryUrl/specialist/profile';
  static String specialistUpdatePassword = '$secondaryUrl/specialist/change-password';
  static String specialistChangePhoto = '$secondaryUrl/specialist/change-photo';
  static String specialistSetProfile = '$secondaryUrl/specialist/profile';
  static String specialistGetAccountDetail = '$secondaryUrl/specialist/account';
  static String specialistSetAccountDetail = '$secondaryUrl/specialist/account';
  static String specialistActivityHistory = '$secondaryUrl/specialist/closed-cases';
  static String specialistRating = '$secondaryUrl/specialist/ratings';
  static String specialistPayment = '$secondaryUrl/specialist/payments';
  static String specialistGetScheduleCase = '$secondaryUrl/specialist/schedule-cases';
  static String specialistGetPendingCase = '$secondaryUrl/specialist/pending-cases';
  static String specialistGetOpenCase = '$secondaryUrl/specialist/open-cases';
  static String specialistGetScheduledCase = '$secondaryUrl/specialist/scheduled-cases';
  static String specialistAcceptCase = '$secondaryUrl/specialist/accept-case';
  static String specialistCancelCase = '$secondaryUrl/specialist/cancel-case';
  static String specialistEndCase = '$secondaryUrl/specialist/end-case';
  static String specialistSelectSchedule = '$secondaryUrl/specialist/select-schedule';
  static String specialistGetStatus = '$secondaryUrl/specialist/status';
  static String specialistSetStatus = '$secondaryUrl/specialist/toggle-status';

  ///Firebase Realtime Database
  ///#GCW 24-01-2023
  static String firebaseVideoCallStatus = "is_videocall_connected";
  static String firebaseDoctorStatus = "from_doctor";
  static String firebaseSpecialistStatus="from_specialist";
}
