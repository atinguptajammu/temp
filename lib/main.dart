import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/incoming_tab.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/open_tabbar.dart';
import 'package:vsod_flutter/screens/specialist/home/tabbar_screen/shaeduled_tabbar.dart';
import 'package:vsod_flutter/screens/vosd_screen_main.dart';
import 'package:vsod_flutter/utils/app_constants.dart';
import 'package:vsod_flutter/utils/app_preferences.dart';
import 'package:vsod_flutter/utils/camera.dart';

 Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  await AppPreference.initMySharedPreferences();
  await AppConstants.pusher
      .init(apiKey: "d79dc069dad8d83f1c1e", cluster: "mt1");

  AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher',
    [
      NotificationChannel(
          channelKey: 'basic_channel_new',
          channelName: 'Basic Notification',
          channelDescription: "Basic Description",
          defaultRingtoneType: DefaultRingtoneType.Notification,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          enableVibration: true,
          playSound: true),
    ],
  );
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Platform.isAndroid ? Brightness.dark : Brightness.light,
    ),
  );

  Cameras.cameras = await availableCameras();
  print("CAMERA ${Cameras.cameras}");

  runApp(
    MultiProvider(
      providers: providers,
      child: VSODApp(),
    ),
  );
}

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<PendingDataProvider>(
      create: (_) => PendingDataProvider()),
  ChangeNotifierProvider<OpenDataProvider>(create: (_) => OpenDataProvider()),
  ChangeNotifierProvider<ScheduledDataProvider>(
      create: (_) => ScheduledDataProvider()),
  ChangeNotifierProvider<ScheduleDataProvider>(
      create: (_) => ScheduleDataProvider()),
];
