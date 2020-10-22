import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';

import 'package:sixtyseconds/CommonWidgets/social_log_in_button.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/Errors/hata_exception.dart';
import 'package:sixtyseconds/Screens/SignIn/emailPasswordRegisterAndLogin.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

FirebaseAuthException myHata;

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  void misafirGirisi(context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    MyUserClass _user = await _userModel.signInAnonymously();
  }

  void _googleIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    MyUserClass _user = await _userModel.signInWithGoogle();
  }

  void _facebookIleGiris(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    try {
      MyUserClass _user = await _userModel.signInWithFaceBook();

      if (_user != null) {
        print("Kayıt Olan User user id : ${_user.userID}");
      } else {
        PlatformBasedAlertDialog(
          title: "Üzgünüz",
          content: "Lütfen Tüm Alanları Doldurduğunuzdan Emin Olun",
          okButtonText: "Tamam",
        ).goster(context);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("widget kullanıcıoluşturma hata yakalandı : " +
          Hatalar.goster(e.code.toString()));
      myHata = e;
    }
  }

  void _emailVeSifreGiris(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        title: "form",
        settings: RouteSettings(
          name: "/FormSettings",
        ),
        fullscreenDialog: true,
        builder: (context) => EmailveSifreLogin(),
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (myHata != null) {
        PlatformBasedAlertDialog(
          title: "Hata",
          content: Hatalar.goster(myHata.code.toString()),
          okButtonText: "Tamam",
        ).goster(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: Stack(
          children: [
            _getVideoBackground(context),
            // _getBackgroundColor(),
            _getContent(context),
          ],
        ),
      ),
    );
  }

  _getVideoBackground(context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.asset("main.gif"),
      ),
    );
  }

  _getBackgroundColor() {
    return Container(
      color: Colors.black.withAlpha(120),
    );
  }

  _getContent(context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width * 0.5,
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.width * 0.2),
                child: Image(
                  image: AssetImage("mainLogo.png"),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 36),
            margin: EdgeInsets.only(bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SocialLoginButton(
                  buttonText: "Google İle Giriş Yap",
                  buttonColor: Colors.white,
                  buttonHeight: 12,
                  radius: 24,
                  onPressed: () => {
                    _googleIleGiris(context),
                  },
                  textColor: Colors.black87,
                  buttonIcon: FaIcon(FontAwesomeIcons.google),
                ),
                SocialLoginButton(
                  buttonText: "Facebook İle Giriş Yap",
                  buttonColor: Color(0xFF334D92),
                  buttonHeight: 12,
                  radius: 24,
                  onPressed: () => {
                    _facebookIleGiris(context),
                  },
                  textColor: Colors.white,
                  buttonIcon: FaIcon(
                    FontAwesomeIcons.facebook,
                    color: Colors.white,
                  ),
                ),
                SocialLoginButton(
                  buttonColor: Color(primaryColor),
                  buttonHeight: 12,
                  radius: 24,
                  buttonText: "Email ve Şifre ile Giriş Yap",
                  onPressed: () {
                    _emailVeSifreGiris(context);
                  },
                  textColor: Colors.white,
                  buttonIcon: FaIcon(
                    FontAwesomeIcons.solidEnvelopeOpen,
                    color: Colors.white,
                  ),
                ),
                // SocialLoginButton(
                //   buttonColor: Colors.green,
                //   buttonHeight: 12,
                //   radius: 24,
                //   buttonText: "Misafir Girişi",
                //   onPressed: () {
                //     misafirGirisi(context);
                //   },
                //   textColor: Colors.white,
                //   buttonIcon: FaIcon(
                //     FontAwesomeIcons.grinTongueSquint,
                //     color: Colors.white,
                //   ),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
