import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Repository/userRepository.dart';
import 'package:sixtyseconds/Services/auth_base.dart';
import 'package:sixtyseconds/locator.dart';

enum ViewState { Idle, Busy }

class UserModel with ChangeNotifier implements AuthBase {
  ViewState _state = ViewState.Idle;
  UserRepository _userRepository = locator<UserRepository>();
  MyUserClass _user;
  String emailHataMesaji,
      sifreHataMesaji,
      yasHataMesaji,
      cinsiyetHataMesaji,
      ilgiHataMesaji,
      usernameHataMesaji;

  MyUserClass get user => _user;

  ViewState get state => _state;

  set state(ViewState value) {
    _state = value;
    notifyListeners();
  }

  UserModel() {
    currentUser();
  }
  @override
  Future<MyUserClass> currentUser() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.currentUser();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("viewmodel current user hatası: $e");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  Future<List<MyUserClass>> getAllUser(UserModel currentUser) async {
    var tumKullaniciListesi = await _userRepository.getAllUsers(currentUser);
    return tumKullaniciListesi;
  }

  @override
  Future<MyUserClass> signInAnonymously() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInAnonymously();
      return _user;
    } catch (e) {
      debugPrint("viewmodel anonim user hatası: $e");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      state = ViewState.Busy;
      bool sonuc = await _userRepository.signOut();
      _user = null;
      return sonuc;
    } catch (e) {
      debugPrint("viewmodel signout hatası: $e");
      return false;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<MyUserClass> signInWithGoogle() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithGoogle();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("viewmodel signInWithGoogle user hatası: $e");
      return null;
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<MyUserClass> signInWithFaceBook() async {
    try {
      state = ViewState.Busy;
      _user = await _userRepository.signInWithFaceBook();
      if (_user != null) {
        return _user;
      } else {
        return null;
      }
    } finally {
      state = ViewState.Idle;
    }
  }

  @override
  Future<MyUserClass> createUserWithEmailandPassword(String email, String sifre,
      String yas, String cinsiyet, String ilgi, String username) async {
    if (_emaiLSifreKontrol(email, sifre) &&
        _emptyFieldControl(email, sifre, yas, cinsiyet, ilgi, username)) {
      try {
        state = ViewState.Busy;
        bool isUsernameAvalible = await checkUserName(username);
        if (isUsernameAvalible) {
          _user = await _userRepository.createUserWithEmailandPassword(
              email, sifre, yas, cinsiyet, ilgi, username);
          return _user;
        } else {
          return null;
        }
      } finally {
        state = ViewState.Idle;
      }
    } else {
      return null;
    }
  }

  @override
  Future<MyUserClass> signInWithEmailandPassword(
      String email, String sifre) async {
    if (_emaiLSifreKontrol(email, sifre)) {
      try {
        state = ViewState.Busy;
        _user = await _userRepository.signInWithEmailandPassword(email, sifre);
        return _user;
      } finally {
        state = ViewState.Idle;
      }
    } else {
      return null;
    }
  }

  bool _emptyFieldControl(String email, String sifre, String yas,
      String cinsiyet, String ilgi, String username) {
    var sonuc = true;
    print("yaş: " +
        yas +
        " cinsitet: " +
        cinsiyet +
        " ilgi: " +
        ilgi +
        " username: " +
        username);
    if (yas == '') {
      print("yas is empty? = true " + yas);
    } else {
      print("yas is empty? = false " + yas);
    }
    if (yas.isEmpty) {
      yasHataMesaji = "Lütfen yaşınızı giriniz.";
      sonuc = false;
    } else {
      yasHataMesaji = null;
    }

    if (cinsiyet == "empty") {
      cinsiyetHataMesaji = "Lütfen cinsiyet seçiniz.";
      sonuc = false;
    } else {
      cinsiyet = null;
    }

    if (ilgi == "empty") {
      ilgiHataMesaji = "Lütfen ilgi alanı seçiniz.";
      sonuc = false;
    } else {
      ilgi = null;
    }
    if (username.isEmpty) {
      usernameHataMesaji = "Lütfen kullanıcı adınızı giriniz.";
      sonuc = false;
    } else {
      usernameHataMesaji = null;
    }
    return sonuc;
  }

  bool _emaiLSifreKontrol(String email, String sifre) {
    var sonuc = true;
    if (sifre.length < 6) {
      sifreHataMesaji = "En az 6 Karakter Olmalı.";
      sonuc = false;
    } else {
      sifreHataMesaji = null;
    }
    if (!email.contains('@')) {
      emailHataMesaji = "Geçersiz email adresi";
      sonuc = false;
    } else {
      emailHataMesaji = null;
    }

    return sonuc;
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var sonuc = await _userRepository.updateUserName(userID, yeniUserName);
    if (sonuc) {
      user.userName = yeniUserName;
    }

    return sonuc;
  }

  Future<bool> checkUserName(String yeniUserName) async {
    var sonuc = await _userRepository.checkUserName(yeniUserName);
    if (sonuc) {
      return true;
    } else {
      return false;
    }
  }

  Future<dynamic> uploadFile(
      String userID, String fileType, File profilPhoto) async {
    var indirmeLinki =
        await _userRepository.uploadFile(userID, fileType, profilPhoto);
    return indirmeLinki;
  }

  Stream<List<Message>> getMessages(
      String currentUserID, String chattingUserID) {
    return _userRepository.getMessages(currentUserID, chattingUserID);
  }

  Future<bool> saveMessage(
      Message saveMessage, MyUserClass currentUser, bool isMatch) async {
    return await _userRepository.saveMessage(saveMessage, currentUser, isMatch);
  }

  // Future<List<Chat>> getAllChats(String userID) async {
  //   return await _userRepository.getAllChats(userID);
  // }

  Future<List<Chat>> getAllChatsWithPagination(
      UserModel userID, Chat lastFetchedChat, int itemsPerFetch) async {
    return await _userRepository.getAllChatsWithPagination(
        userID, lastFetchedChat, itemsPerFetch);
  }

  Future<bool> matchWith(
      MyUserClass chattingUser, MyUserClass currentUser, bool isMatch) async {
    return await _userRepository.matchWith(chattingUser, currentUser, isMatch);
  }

  Future<bool> removeMatch(String talkingTo, String chatOwner) async {
    return await _userRepository.removeMatch(talkingTo, chatOwner);
  }
}
