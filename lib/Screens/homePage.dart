import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/BottomNavigation/customBottomNavigation.dart';
import 'package:sixtyseconds/Screens/BottomNavigation/tab_items.dart';
import 'package:sixtyseconds/Screens/konusmalarim.dart';
import 'package:sixtyseconds/Screens/kullanicilar.dart';
import 'package:sixtyseconds/Screens/profil.dart';
import 'package:sixtyseconds/notificationHandler.dart';

class HomePage extends StatefulWidget {
  final MyUserClass user;
  HomePage({Key key, @required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  TabItem _currentTab = TabItem.Kullanicilar;
  Map<TabItem, GlobalKey<NavigatorState>> navigatorKeys = {
    TabItem.Kullanicilar: GlobalKey<NavigatorState>(),
    TabItem.Konusmalarim: GlobalKey<NavigatorState>(),
    TabItem.Profil: GlobalKey<NavigatorState>(),
  };
  Map<TabItem, Widget> allPages() {
    return {
      TabItem.Kullanicilar: KullanicilarTab(),
      TabItem.Konusmalarim: KonusmalarimTab(),
      TabItem.Profil: ProfilTab(),
    };
  }

  @override
  void initState() {
    super.initState();
    NotificationHandler().initializeFCMNotification(context);
    // _firebaseMessaging.requestNotificationPermissions(
    //     const IosNotificationSettings(
    //         sound: true, badge: true, alert: true, provisional: true));
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    // _firebaseMessaging.getToken().then((String token) {
    //   assert(token != null);
    //   setState(() {
    //     _homeScreenText = "Push Messaging token: $token";
    //   });
    //   print(_homeScreenText);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async =>
          !await navigatorKeys[_currentTab].currentState.maybePop(),
      child: CustomBottomNavigation(
        navigatorsKeys: navigatorKeys,
        pageGenerator: allPages(),
        currentTab: _currentTab,
        onSelectedTab: (secilenTab) {
          if (secilenTab == _currentTab) {
            navigatorKeys[secilenTab]
                .currentState
                .popUntil((route) => route.isFirst);
          } else {
            setState(() {
              _currentTab = secilenTab;
              // if (_currentTab == TabItem.Konusmalarim) {
              //   (context as Element).reassemble();
              // }
            });
          }
        },
      ),
    );
  }
}
