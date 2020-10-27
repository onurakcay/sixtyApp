import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/chat.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class KullanicilarTab extends StatefulWidget {
  @override
  _KullanicilarTabState createState() => _KullanicilarTabState();
}

class _KullanicilarTabState extends State<KullanicilarTab> {
  var _isSearching = false;

  startSearch(bool status) {
    setState(() {
      _isSearching = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(primaryColor),
      // appBar: AppBar(
      //   backgroundColor: Color(primaryColor),
      //   title: Image(
      //     image: AssetImage("mainLogo.png"),
      //     width: 50,
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        // color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _isSearching == false
                ? Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: Text(
                      "Yeni insanlarla tanışmak için tıkla",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : Container(),
            _isSearching == true
                ? AvatarGlow(
                    glowColor: Colors.indigo,
                    endRadius: 200.0,
                    duration: Duration(milliseconds: 2000),
                    repeat: true,
                    showTwoGlows: true,
                    repeatPauseDuration: Duration(milliseconds: 100),
                    child: Material(
                      elevation: 2.0,
                      shape: CircleBorder(),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[800],
                        child: RawMaterialButton(
                          onPressed: () async {},
                          elevation: 0.0,
                          fillColor: Colors.white,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Image(
                              image: AssetImage("mainLogo.png"),
                            ),
                          ),
                          // child: Icon(
                          //   Icons.album_outlined,
                          //   size: MediaQuery.of(context).size.width * 0.5,
                          // ),
                          padding: EdgeInsets.all(15.0),
                          shape: CircleBorder(),
                        ),
                        radius: 100,
                      ),
                    ),
                  )
                : RawMaterialButton(
                    onPressed: () async {
                      startSearch(true);
                      Future.delayed(const Duration(seconds: 5), () {
                        matchUser(_userModel);
                      });
                    },
                    elevation: 2.0,
                    fillColor: Colors.white,
                    child: Container(
                      width: 170,
                      child: Image(
                        image: AssetImage("mainLogo.png"),
                      ),
                    ),
                    // child: Icon(
                    //   Icons.album_outlined,
                    //   size: MediaQuery.of(context).size.width * 0.5,
                    // ),
                    padding: EdgeInsets.all(15.0),
                    shape: CircleBorder(),
                  ),
            _isSearching == true
                ? Container(
                    margin: EdgeInsets.only(top: 24),
                    child: SizedBox(
                      child: FadeAnimatedTextKit(
                          // speed: Duration(milliseconds: 120),
                          totalRepeatCount: 4,
                          repeatForever:
                              true, //this will ignore [totalRepeatCount]
                          pause: Duration(milliseconds: 200),
                          text: [
                            "Hazır Ol!",
                            "60 saniye süren var!",
                            "Başlıyoruz!!!"
                          ],
                          textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<Null> _refreshUsers() async {
    setState(() {});

    return null;
  }

  void matchUser(UserModel _userModel) async {
    var randomlyPickedUser = await _userModel.getAllUser(_userModel);
    startSearch(false);
    if (randomlyPickedUser.isEmpty) {
      PlatformBasedAlertDialog(
        title: "Üzgünüz",
        content:
            "Eşlebileceğin kimse bulunamadı. Lütfen daha sonra tekrar dene.",
        okButtonText: "Kapat",
      ).goster(context);
    } else {
      var pickedUser = randomlyPickedUser[0];

      Navigator.of(context, rootNavigator: true).push(CupertinoPageRoute(
          builder: (context) => Sohbet(
                currentUser: _userModel.user,
                chattingUser: pickedUser,
              )));
    }
  }
}
