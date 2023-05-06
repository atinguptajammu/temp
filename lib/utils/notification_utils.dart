import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

Future<void> createNotification(
    {required String title,
    required String body,
    required Function onSelectNotification}) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: createUniqueId(),
      channelKey: 'basic_channel_new',
      title: '$title',
      body: '$body',
      //payload: {'rtcToken': rtcToken, 'channelName': channelName},
      icon: 'resource://drawable/ic_launcher',
      notificationLayout: NotificationLayout.BigText,
      autoDismissible: true,
      //customSound: 'resource://raw/soundlong',
      //largeIcon: '$image',
      roundedLargeIcon: true,
      wakeUpScreen: true,
      displayOnForeground: true,
    ),
    /*actionButtons: [
      NotificationActionButton(
        key: 'ACCEPT',
        label: 'View',
      ),
       NotificationActionButton(
        key: 'REJECT',
        label: 'Reject',
        buttonType: ActionButtonType.DisabledAction,
      ),
    ],*/
  );
}

int createUniqueId() {
  return UniqueKey().hashCode;
}
