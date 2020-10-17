import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Color/colors.dart';
import 'package:sixtyseconds/CommonWidgets/platform_based_alert_dialog.dart';
import 'package:sixtyseconds/CommonWidgets/social_log_in_button.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class ProfilTab extends StatefulWidget {
  @override
  _ProfilTabState createState() => _ProfilTabState();
}

class _ProfilTabState extends State<ProfilTab> {
  TextEditingController _controllerUserName;

  File _profilPhoto;
  final picker = ImagePicker();

  BuildContext scaffoldContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controllerUserName = TextEditingController();
  }

  @override
  void dispose() {
    _controllerUserName.dispose();
    super.dispose();
  }

  Future _galeridenSec() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _profilPhoto = File(pickedFile.path);
        Navigator.of(context).pop();
        _profilFotoGuncelle(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future _kameradanCek() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _profilPhoto = File(pickedFile.path);
        Navigator.of(context).pop();
        _profilFotoGuncelle(context);
      } else {
        print('No image selected.');
      }
    });
  }

  Future _profilFotoGuncelle(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_profilPhoto != null) {
      var url = await _userModel.uploadFile(
          _userModel.user.userID, "profilPicture", _profilPhoto);
      if (url != null) {
        setState(() {
          _userModel.user.profileURL = url;
          _profilPhoto = null;
          createSnackBar("Profil Fotoğrafın Başarıyla Güncellendi");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel _userModel = Provider.of<UserModel>(context);
    _controllerUserName.text = _userModel.user.userName;

    return Scaffold(
        appBar: AppBar(
          title: Text("Profil"),
          actions: [
            FlatButton(
              onPressed: () {
                _showLogOutDialog(context);
              },
              child: Text(
                "Çıkış",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            )
          ],
        ),
        body: Builder(builder: (context) {
          scaffoldContext = context;
          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.27,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.camera),
                                          title: Text("Kamerayı Kullan"),
                                          onTap: () {
                                            _kameradanCek();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.image_rounded),
                                          title: Text("Galeriden Seç"),
                                          onTap: () {
                                            _galeridenSec();
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.search_rounded),
                                          title: Text("Fotoğrafı Görüntüle"),
                                          onTap: () {
                                            _galeridenSec();
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: _profilPhoto == null
                              ? CircleAvatar(
                                  radius: 65,
                                  backgroundImage:
                                      NetworkImage(_userModel.user.profileURL),
                                  backgroundColor: Colors.white,
                                )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: CircularProgressIndicator(),
                                  )),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _userModel.user.userName +
                                  " • " +
                                  _userModel.user.age.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _userModel.user.gender == "male"
                                  ? "Erkek"
                                  : _userModel.user.gender == "female"
                                      ? "Kadın"
                                      : "Diğer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _userModel.user.email,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TextFormField(
                      controller: _controllerUserName,
                      decoration: InputDecoration(
                        labelText: "Kullanıcı Adı",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SocialLoginButton(
                      buttonText: "Değişiklikleri Kaydet",
                      buttonColor: Color(primaryColor),
                      buttonHeight: 16,
                      textColor: Colors.white,
                      onPressed: () {
                        _userNameGuncelle(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }));
  }

  Future<bool> logOut(context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);

    bool sonuc = await _userModel.signOut();

    return sonuc;
  }

  Future _showLogOutDialog(BuildContext context) async {
    final sonuc = await PlatformBasedAlertDialog(
      title: "Emin misin ?",
      content: "Uygulamadan çıkış yapmak üzeresin",
      okButtonText: "Çıkış Yap",
      cancelText: "Kapat",
    ).goster(context);
    if (sonuc == true) {
      logOut(context);
    }
  }

  void createSnackBar(String message) {
    final snackBar = new SnackBar(
      content: Text(message),
    );
    Scaffold.of(scaffoldContext).showSnackBar(snackBar);
  }

  void _userNameGuncelle(BuildContext context) async {
    final _userModel = Provider.of<UserModel>(context, listen: false);
    if (_userModel.user.userName != _controllerUserName.text) {
      var updateResult = await _userModel.updateUserName(
          _userModel.user.userID, _controllerUserName.text);

      if (updateResult == true) {
        setState(() {
          _userModel.user.userName = _controllerUserName.text;
        });
        PlatformBasedAlertDialog(
          title: "Kullanıcı Adın Başarıyla Güncellendi!",
          content: "Yeni Kullanıcı Adın ${_controllerUserName.text}",
          okButtonText: "Tamam",
        ).goster(context);
      } else {
        _controllerUserName.text = _userModel.user.userName;
        PlatformBasedAlertDialog(
          title: "Hata!",
          content: "Kullanıcı adı zaten kullanımda!",
          okButtonText: "Tamam",
        ).goster(context);
      }
    } else {
      PlatformBasedAlertDialog(
        title: "Uyarı!",
        content: "Lütfen farklı bir kullanıcı adı giriniz.",
        okButtonText: "Tamam",
      ).goster(context);
    }
  }
}
