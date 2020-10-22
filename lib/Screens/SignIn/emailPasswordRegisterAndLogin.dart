import 'package:cupertino_tabbar/cupertino_tabbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
import 'package:sixtyseconds/CommonWidgets/social_log_in_button.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Screens/Errors/hata_exception.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';
import 'package:smart_select/smart_select.dart';
import 'package:sticky_headers/sticky_headers.dart';

enum FormType { Register, Login }

class EmailveSifreLogin extends StatefulWidget {
  @override
  _EmailveSifreLoginState createState() => _EmailveSifreLoginState();
}

class _EmailveSifreLoginState extends State<EmailveSifreLogin> {
  int cupertinoTabBarIValue = 0;
  int cupertinoTabBarIValueGetter() => cupertinoTabBarIValue;
  String _email, _sifre, _yas, _username;
  String _buttonText;
  String _myActivity;

  String genderValuevalue = 'empty';
  String interestValue = 'empty';
  List<S2Choice<String>> options = [
    S2Choice<String>(value: 'male', title: 'Erkek'),
    S2Choice<String>(value: 'female', title: 'Kadın'),
    S2Choice<String>(value: 'other', title: 'Diğer'),
  ];
  List<S2Choice<String>> interests = [
    S2Choice<String>(value: 'male', title: 'Erkek'),
    S2Choice<String>(value: 'female', title: 'Kadın'),
  ];

  var _formType = FormType.Login;
  final _formKey = GlobalKey<FormState>();
  _formSubmit(BuildContext context) async {
    _formKey.currentState.save();
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_formType == FormType.Login) {
      try {
        MyUserClass _girisYapanUser =
            await _userModel.signInWithEmailandPassword(_email, _sifre);
        if (_girisYapanUser != null) {
          print("oturum açan user id : ${_girisYapanUser.userID}");
        }
      } on FirebaseAuthException catch (e) {
        debugPrint("widget oturumaçma hata yakalandı : " + e.toString());
        return PlatformBasedAlertDialog(
          title: "Hata",
          content: Hatalar.goster(e.code.toString()),
          okButtonText: "Tamam",
        ).goster(context);
      }
    } else {
      try {
        MyUserClass _kayitOlanUser =
            await _userModel.createUserWithEmailandPassword(_email, _sifre,
                _yas, genderValuevalue, interestValue, _username);
        if (_kayitOlanUser != null) {
          print("Kayıt Olan User user id : ${_kayitOlanUser.userID}");
        } else {
          // PlatformBasedAlertDialog(
          //   title: "Üzgünüz",
          //   content:
          //       "'$_username' kullanıcı adı zaten kullanımda. Lütfen farklı bir kullanıcı adı ile tekrar deneyiniz.",
          //   okButtonText: "Tamam",
          // ).goster(context);

          PlatformBasedAlertDialog(
            title: "Üzgünüz",
            content: "Lütfen Tüm Alanları Doldurduğunuzdan Emin Olun",
            okButtonText: "Tamam",
          ).goster(context);
        }
      } on FirebaseAuthException catch (e) {
        debugPrint("widget kullanıcıoluşturma hata yakalandı : " +
            Hatalar.goster(e.code.toString()));
        return PlatformBasedAlertDialog(
          title: "Hata",
          content: Hatalar.goster(e.code.toString()),
          okButtonText: "Tamam",
        ).goster(context);
      }
    }
  }

  // if(_formKey.currentState.save())

  void _degistir() {
    setState(() {
      _formType =
          _formType == FormType.Login ? FormType.Register : FormType.Login;
    });
  }

  @override
  Widget build(BuildContext context) {
    _buttonText = _formType == FormType.Login ? "Giriş Yap" : "Kayıt Ol";

    final _userModel = Provider.of<UserModel>(context);

    if (_userModel.user != null) {
      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.of(context).popUntil(ModalRoute.withName("/"));
      });
    }
    return Scaffold(
      appBar: AppBar(title: Text("Merhaba,")),
      body: _userModel.state == ViewState.Idle
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CupertinoTabBar(
                        cupertinoTabBarIValue == 0
                            ? Color(primaryColor)
                            : Color(primaryColor),
                        cupertinoTabBarIValue == 0
                            ? Color(0xFFc40030)
                            : Color(0xFFc40030),
                        [
                          Text(
                            " Giriş Yap ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: "SFProRounded",
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            " Kayıt Ol ",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: "SFProRounded",
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        cupertinoTabBarIValueGetter,
                        (int index) {
                          setState(() {
                            if (cupertinoTabBarIValue != index) {
                              _degistir();
                            }
                            cupertinoTabBarIValue = index;
                          });
                        },
                      ),
                      SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        initialValue: "ahmet@gmail.com",
                        onSaved: (String girilenEmail) {
                          _email = girilenEmail;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          errorText: _userModel.emailHataMesaji != null
                              ? _userModel.emailHataMesaji
                              : null,
                          prefixIcon: Icon(Icons.mail),
                          hintText: "E-Mail",
                          labelText: "E-Mail",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      TextFormField(
                        initialValue: "ahmet123",
                        onSaved: (String girilenSifre) {
                          _sifre = girilenSifre;
                        },
                        obscureText: true,
                        decoration: InputDecoration(
                          errorText: _userModel.sifreHataMesaji != null
                              ? _userModel.sifreHataMesaji
                              : null,
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Şifre",
                          labelText: "Şifre",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: _formType == FormType.Login ? 24 : 8,
                      ),
                      _formType == FormType.Register
                          ? Column(
                              children: [
                                TextFormField(
                                  onSaved: (String girilenYas) {
                                    _yas = girilenYas;
                                  },
                                  keyboardType: TextInputType.number,
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person_rounded),
                                    hintText: "Yaş",
                                    labelText: "Yaş",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  onSaved: (String girilenKullaniciAdi) {
                                    _username = girilenKullaniciAdi;
                                  },
                                  obscureText: false,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.person_rounded),
                                    hintText: "Kullanıcı Adı",
                                    labelText: "Kullanıcı Adı",
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SmartSelect<String>.single(
                                  modalType: S2ModalType.bottomSheet,
                                  title: 'Cinsiyet',
                                  placeholder: "Cinsiyet",
                                  value: genderValuevalue,
                                  choiceItems: options,
                                  onChange: (state) => setState(
                                      () => genderValuevalue = state.value),
                                ),
                                SizedBox(
                                  height: 8,
                                ),
                                SmartSelect<String>.single(
                                    modalType: S2ModalType.bottomSheet,
                                    title: 'İlgi Alanı',
                                    placeholder: "İlgi Alanı",
                                    value: interestValue,
                                    choiceItems: interests,
                                    onChange: (state) => setState(
                                        () => interestValue = state.value)),
                                SizedBox(
                                  height: 24,
                                ),
                              ],
                            )
                          : Container(),
                      SocialLoginButton(
                        buttonText: _buttonText,
                        buttonColor: Color(primaryColor),
                        radius: 28,
                        onPressed: () => _formSubmit(context),
                        textColor: Colors.white,
                        buttonHeight: 14,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
