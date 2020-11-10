import 'dart:io';

import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Services/auth_base.dart';
import 'package:sixtyseconds/Services/fake_authentication_service.dart';
import 'package:sixtyseconds/Services/firebase_auth_service.dart';
import 'package:sixtyseconds/Services/firebase_storage_service.dart';
import 'package:sixtyseconds/Services/firestore_db_service.dart';
import 'package:sixtyseconds/Services/send_notification_service.dart';
import 'package:sixtyseconds/locator.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';
import 'package:timeago/timeago.dart' as timeago;

enum AppMode { DEBUG, RELEASE }

class UserRepository implements AuthBase {
  FirebaseAuthService _firebaseAuthService = locator<FirebaseAuthService>();
  FakeAuthenticationService _fakeAuthenticationService =
      locator<FakeAuthenticationService>();
  FireStoreDbService _fireStoreDbService = locator<FireStoreDbService>();
  FirebaseStorageService _firebaseStorageService =
      locator<FirebaseStorageService>();
  SendNotificationService _sendNotificationService =
      locator<SendNotificationService>();

  AppMode appmode = AppMode.RELEASE;
  List<MyUserClass> tumKullaniciListesi = [];
  Map<String, String> userToken = Map<String, String>();

  @override
  Future<MyUserClass> currentUser() async {
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.currentUser();
    } else {
      MyUserClass _user = await _firebaseAuthService.currentUser();
      if (_user != null) {
        return await _fireStoreDbService.readUser(_user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUserClass> signInAnonymously() async {
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInAnonymously();
    } else {
      return await _firebaseAuthService.signInAnonymously();
    }
  }

  @override
  Future<bool> signOut() async {
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signOut();
    } else {
      return await _firebaseAuthService.signOut();
    }
  }

  @override
  Future<MyUserClass> signInWithGoogle() async {
    String age = "11",
        gender = "male",
        interest = "female",
        username = "gigigl";
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithGoogle();
    } else {
      MyUserClass _user = await _firebaseAuthService.signInWithGoogle();
      if (_user != null) {
        bool _sonuc = await _fireStoreDbService.saveUser(
            _user, age, gender, interest, username);
        if (_sonuc == true) {
          return await _fireStoreDbService.readUser(_user.userID);
        } else {
          await _firebaseAuthService.signOut();
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUserClass> signInWithFaceBook() async {
    String age = "11",
        gender = "male",
        interest = "female",
        username = "gigigl";
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithFaceBook();
    } else {
      MyUserClass _user = await _firebaseAuthService.signInWithFaceBook();
      if (_user != null) {
        bool _sonuc = await _fireStoreDbService.saveUser(
            _user, age, gender, interest, username);
        if (_sonuc == true) {
          return await _fireStoreDbService.readUser(_user.userID);
        } else {
          return null;
        }
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUserClass> createUserWithEmailandPassword(String email, String sifre,
      String yas, String cinsiyet, String ilgi, String username) async {
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.createUserWithEmailandPassword(
          email, sifre, yas, cinsiyet, ilgi, username);
    } else {
      MyUserClass _user =
          await _firebaseAuthService.createUserWithEmailandPassword(
              email, sifre, yas, cinsiyet, ilgi, username);
      bool _sonuc = await _fireStoreDbService.saveUser(
          _user, yas, cinsiyet, ilgi, username);
      if (_sonuc == true) {
        return await _fireStoreDbService.readUser(_user.userID);
      } else {
        return null;
      }
    }
  }

  @override
  Future<MyUserClass> signInWithEmailandPassword(
      String email, String sifre) async {
    if (appmode == AppMode.DEBUG) {
      return await _fakeAuthenticationService.signInWithEmailandPassword(
          email, sifre);
    } else {
      MyUserClass _user =
          await _firebaseAuthService.signInWithEmailandPassword(email, sifre);

      return await _fireStoreDbService.readUser(_user.userID);
    }
  }

  Future<bool> updateUserName(String userID, String yeniUserName) async {
    if (appmode == AppMode.DEBUG) {
      return false;
    } else {
      return await _fireStoreDbService.updateUserName(userID, yeniUserName);
    }
  }

  Future<bool> checkUserName(String yeniUserName) async {
    if (appmode == AppMode.DEBUG) {
      return false;
    } else {
      return await _fireStoreDbService.checkUserName(yeniUserName);
    }
  }

  Future<dynamic> uploadFile(
      String userID, String fileType, File profilPhoto) async {
    if (appmode == AppMode.DEBUG) {
      return "dosya_indirme_linki";
    } else {
      var profilFotoURL = await _firebaseStorageService.uploadFile(
          userID, fileType, profilPhoto);
      await _fireStoreDbService.updateProfilePhoto(profilFotoURL, userID);
      return profilFotoURL;
    }
  }

  Future<List<MyUserClass>> getAllUsers(UserModel currentUser) async {
    if (appmode == AppMode.DEBUG) {
      return [];
    } else {
      tumKullaniciListesi = await _fireStoreDbService.getAllUsers(currentUser);
      return tumKullaniciListesi;
    }
  }

  Stream<List<Message>> getMessages(
      String currentUserID, String chattingUserID) {
    if (appmode == AppMode.DEBUG) {
      return Stream.empty();
    } else {
      return _fireStoreDbService.getMessages(currentUserID, chattingUserID);
    }
  }

  Future<bool> saveMessage(
      Message saveMessage, MyUserClass currentUser, bool isMatch) async {
    if (appmode == AppMode.DEBUG) {
      return true;
    } else {
      var dbYazmaIslemi =
          await _fireStoreDbService.saveMessage(saveMessage, isMatch);
      if (dbYazmaIslemi) {
        var token = "";
        if (userToken.containsKey(saveMessage.to)) {
          token = userToken[saveMessage.to];
          print("lokalden geldi");
        } else {
          token = await _fireStoreDbService.getToken(saveMessage.to);
          if (token != null) {
            userToken[saveMessage.to] = token;
          }
          print("veri  tabanından geldi");
        }
        if (token != null) {
          await _sendNotificationService.sendNotification(
              saveMessage, currentUser, token);
        }
        return true;
      } else {
        return false;
      }
    }
  }

  Future<bool> matchWith(
      MyUserClass chattingUser, MyUserClass currentUser, bool isMatch) async {
    var dbYazmaIslemi =
        await _fireStoreDbService.matchWith(chattingUser, currentUser, isMatch);
    if (dbYazmaIslemi) {
      return true;
    } else {
      return false;
    }
  }

  // Future<List<Chat>> getAllChats(String userID) async {
  //   if (appmode == AppMode.DEBUG) {
  //     return [];
  //   } else {
  //     DateTime _readTime = await _fireStoreDbService.showTime(userID);

  //     var chatList = await _fireStoreDbService.getAllChats(userID);
  //     for (var currentChat in chatList) {
  //       var userListesindekiKullanici = findUserOnList(currentChat.talking_to);

  //       if (userListesindekiKullanici != null) {
  //         print("Veriler Local CACHEDEN OKUNDU");
  //         currentChat.chattingUsername = userListesindekiKullanici.userName;
  //         currentChat.chattingProfilePicture =
  //             userListesindekiKullanici.profileURL;
  //       } else {
  //         print("Veriler VERİ TABANINDAN OKUNDU");
  //         print(
  //             "Aranılan user daha önceden veritabanından getirilmemiş, o yüzden veritabanından bu veriyi okumalıyız.");
  //         var _veritabanindenOkunanUser =
  //             await _fireStoreDbService.readUser(currentChat.talking_to);
  //         currentChat.chattingUsername = _veritabanindenOkunanUser.userName;
  //         currentChat.chattingProfilePicture =
  //             _veritabanindenOkunanUser.profileURL;
  //       }
  //       calculateTimeAgo(currentChat, _readTime);
  //     }
  //     return chatList;
  //   }
  // }

  MyUserClass findUserOnList(String userID) {
    for (int i = 0; i < tumKullaniciListesi.length; i++) {
      if (tumKullaniciListesi[i].userID == userID) {
        return tumKullaniciListesi[i];
      }
    }
    return null;
  }

  void calculateTimeAgo(Chat currentChat, DateTime _readTime) {
    timeago.setLocaleMessages("tr", timeago.TrMessages());
    var _duration = _readTime.difference(currentChat.created_at.toDate());
    currentChat.aradakiFark =
        timeago.format(_readTime.subtract(_duration), locale: "tr");
  }

  Future<List<Chat>> getAllChatsWithPagination(
      UserModel userID, Chat lastFetchedChat, int itemsPerFetch) async {
    if (appmode == AppMode.DEBUG) {
      return [];
    } else {
      DateTime _readTime =
          await _fireStoreDbService.showTime(userID.user.userID);

      var chatList = await _fireStoreDbService.getAllChatsWithPagination(
          userID, lastFetchedChat, itemsPerFetch);
      for (var currentChat in chatList) {
        var userListesindekiKullanici = findUserOnList(currentChat.talking_to);

        if (userListesindekiKullanici != null) {
          print("Veriler Local CACHEDEN OKUNDU");
          currentChat.chattingUsername = userListesindekiKullanici.userName;
          currentChat.chattingProfilePicture =
              userListesindekiKullanici.profileURL;
        } else {
          print("Veriler VERİ TABANINDAN OKUNDU");
          print(
              "Aranılan user daha önceden veritabanından getirilmemiş, o yüzden veritabanından bu veriyi okumalıyız.");
          var _veritabanindenOkunanUser =
              await _fireStoreDbService.readUser(currentChat.talking_to);
          currentChat.chattingUsername = _veritabanindenOkunanUser.userName;
          currentChat.chattingProfilePicture =
              _veritabanindenOkunanUser.profileURL;
        }
        calculateTimeAgo(currentChat, _readTime);
      }
      return chatList;
    }
  }

  Future<bool> removeMatch(String talkingTo, String chatOwner) async {
    var dbYazmaIslemi =
        await _fireStoreDbService.removeMatch(talkingTo, chatOwner);
    if (dbYazmaIslemi) {
      return true;
    } else {
      return false;
    }
  }
}
