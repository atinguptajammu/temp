import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'notification_utils.dart';

class FirebaseMessagingUtils {
  static void init() async {
    await Firebase.initializeApp();
    subscribeTopic("all");

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        final dynamic data = message.data;

        print('Message title data: ${data['title']}, body: ${data['body']}');
// #GWC
        // createNotification(
        //     title: data['title'],
        //     body: data['body'],
        //     onSelectNotification: onSelectNotification);

        print(message);
      } else if (message.notification != null) {
        print(
            'Message title notification: ${message.notification!.title}, body: ${message.notification!.body}');
// #GWC
        // createNotification(
        //     title: message.notification!.title ?? "",
        //     body: message.notification!.body ?? "",
        //     onSelectNotification: onSelectNotification);

        print(message);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("On Notification ==> onMessageOpenedApp ");
      print('A new onMessageOpenedApp event was published!');
    });

    FirebaseMessaging.instance.getToken().then((token) {
      log('Firebase TOKEN : $token');
    });
  }

  static void subscribeTopic(String topic) {
    FirebaseMessaging.instance.subscribeToTopic(topic);
    print("Subscribed to $topic");
  }

  static void unSubscribeTopic(String topic) {
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    print("UnSubscribed to $topic");
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  if (message.data.isNotEmpty) {
    final dynamic data = message.data;

    print('Message title data: ${data['title']}, body: ${data['body']}');
// #GWC
    // createNotification(
    //     title: data['title'],
    //     body: data['body'],
    //     onSelectNotification: onSelectNotification);

    print(message);
  } else if (message.notification != null) {
    print(
        'Message title notification: ${message.notification!.title}, body: ${message.notification!.body}');

    //createNotification(title: message.notification!.title ?? "", body: message.notification!.body ?? "", onSelectNotification: onSelectNotification);

    print(message);
  }
}

Future onSelectNotification(String payload) async {}
