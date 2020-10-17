import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/social_log_in_button.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/SignIn/emailPasswordRegisterAndLogin.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class SignInPage extends StatelessWidget {
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
    MyUserClass _user = await _userModel.signInWithFaceBook();
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
