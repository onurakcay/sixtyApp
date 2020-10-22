import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/chat.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print("Arka planda getirilen data" + message['data'].toString());
    NotificationHandler.showNotification(message);
  }

  // if (message.containsKey('notification')) {
  //   // Handle notification message
  //   final dynamic notification = message['notification'];
  // }

  return Future<void>.value();
}

class NotificationHandler {
  FirebaseMessaging _fcm = FirebaseMessaging();

  static final NotificationHandler _singleton = NotificationHandler._internal();
  factory NotificationHandler() {
    return _singleton;
  }

  NotificationHandler._internal();
  BuildContext myContext;

  initializeFCMNotification(BuildContext context) async {
    myContext = context;
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onselectNotification);

    // _fcm.subscribeToTopic("all");
    // String token = await _fcm.getToken();

    _fcm.onTokenRefresh.listen((newToken) async {
      User _currentUser = await FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .doc("tokens/" + _currentUser.uid)
          .set({"token": newToken});
    });

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage Tetiklendi: $message");
        // PlatformBasedAlertDialog(
        //   content: message.toString(),
        //   title: message.toString(),
        //   okButtonText: "Tamam",
        // ).goster(context);
        showNotification(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch Tetiklendi: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume Tetiklendi: $message");
      },
    );
  }

  static void showNotification(Map<String, dynamic> message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            '1234', '1 yeni mesaj', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message["data"]["title"],
        message["data"]["message"], platformChannelSpecifics,
        payload: jsonEncode(message));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) {}

  Future onselectNotification(String payload) async {
    final _userModel = Provider.of<UserModel>(myContext, listen: false);
    if (payload != null) {
      debugPrint('notification payload: $payload');
      Map<String, dynamic> gelenBildirim = await jsonDecode(payload);

      Navigator.of(myContext, rootNavigator: true).push(
        CupertinoPageRoute(
          builder: (context) => Sohbet(
            currentUser: _userModel.user,
            chattingUser: MyUserClass.idveResim(
                userID: gelenBildirim['data']['gonderenUserID'],
                profileURL: gelenBildirim['data']['profilUrl'],
                userName: gelenBildirim['data']['gonderenUserID']),
          ),
        ),
      );
    }
  }
}
