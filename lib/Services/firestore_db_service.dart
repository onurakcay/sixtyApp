import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Services/db_base.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

class FireStoreDbService implements DbBase {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(MyUserClass user, String age, String gender,
      String interest, String username) async {
    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc("users/${user.userID}").get();
    if (_okunanUser.data() == null) {
      await _fireStore
          .collection("users")
          .doc(user.userID)
          .set(user.toMap(gender, interest, age, username));
      return true;
    } else {
      return true;
    }
  }

  @override
  Future<MyUserClass> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _fireStore.collection("users").doc(userID).get();
    Map<String, dynamic> _okunanUserBilgilerMap = _okunanUser.data();
    MyUserClass _okunanUserNesnesi =
        MyUserClass.fromMap(_okunanUserBilgilerMap);
    // print("ReadUser Okunan user nesnesi: " + _okunanUserNesnesi.toString());
    // print("OkunanUSER: " + _okunanUserBilgilerMap.toString());
    return _okunanUserNesnesi;
  }

  @override
  Future<bool> updateUserName(String userID, String yeniUserName) async {
    var users = await _fireStore
        .collection("users")
        .where("userName", isEqualTo: yeniUserName)
        .get();
    if (users.docs.length != 0) {
      return false;
    } else {
      await _fireStore
          .collection("users")
          .doc(userID)
          .update({'userName': yeniUserName});
      return true;
    }
  }

  Future<bool> checkUserName(String yeniUserName) async {
    var users = await _fireStore
        .collection("users")
        .where("userName", isEqualTo: yeniUserName)
        .get();
    if (users.docs.length != 0) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Future<bool> updateProfilePhoto(String profilFotoURL, String userID) async {
    await _fireStore
        .collection("users")
        .doc(userID)
        .update({'profileURL': profilFotoURL});
    return true;
  }

  @override
  Future<List<MyUserClass>> getAllUsers(UserModel currentUser) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection("users")
        .where("gender", isEqualTo: currentUser.user.interest.toString())
        .get();

    List<MyUserClass> tumKullanicilar = [];
    for (DocumentSnapshot tekUser in querySnapshot.docs) {
      MyUserClass _tekUser = MyUserClass.fromMap(tekUser.data());
      tumKullanicilar.add(_tekUser);
    }

    var rnd = Random();

    var pickerUserIndex;

    MyUserClass _tekTek;
    bool _isChatBefore = false;
    QuerySnapshot randomlyPickedUser;
    int tumKullaniciSayisi = tumKullanicilar.length - 1;
    bool notFound = false;

    List randomlySelectedUserIndex = [];

    while (true) {
      pickerUserIndex = rnd.nextInt(tumKullanicilar.length);
      if (!randomlySelectedUserIndex.contains(pickerUserIndex)) {
        randomlySelectedUserIndex.add(pickerUserIndex);

        randomlyPickedUser = await _fireStore
            .collection("users")
            .where("userID", isEqualTo: tumKullanicilar[pickerUserIndex].userID)
            .where("gender", isEqualTo: currentUser.user.interest.toString())
            .get();
        for (DocumentSnapshot tekUser in randomlyPickedUser.docs) {
          _tekTek = MyUserClass.fromMap(tekUser.data());
        }

        if (_tekTek.userID != currentUser.user.userID) {
          QuerySnapshot checkForActiveChat = await _fireStore
              .collection("chats")
              .where("chat_owner", isEqualTo: currentUser.user.userID)
              .where("talking_to", isEqualTo: _tekTek.userID)
              .get();
          for (DocumentSnapshot isChatBefore in checkForActiveChat.docs) {
            print("is caht before :" + isChatBefore.toString());
            if (isChatBefore != null) {
              _isChatBefore = true;
            } else {
              _isChatBefore = false;
            }
          }
          if (_isChatBefore == false) {
            break;
          }
        }

        if (randomlySelectedUserIndex.length == tumKullaniciSayisi) {
          notFound = true;
          break;
        }
        print("Liste: " +
            randomlySelectedUserIndex.toString() +
            " Tum kullanici: " +
            tumKullaniciSayisi.toString());
      }
    }
    if (notFound != true) {
      List<MyUserClass> randomlySelectedUserList = [];
      for (DocumentSnapshot tekUser in randomlyPickedUser.docs) {
        MyUserClass _tekUser = MyUserClass.fromMap(tekUser.data());
        print("randomlyPickedUser == " + _tekUser.userName);
        randomlySelectedUserList.add(_tekUser);
      }
      return randomlySelectedUserList;
    } else {
      return [];
    }
  }

  // @override
  // Future<List<Chat>> getAllChats(String userID) async {
  //   QuerySnapshot querySnapshot = await _fireStore
  //       .collection("chats")
  //       .where("chat_owner", isEqualTo: userID)
  //       .orderBy("created_at", descending: true)
  //       .get();
  //   List<Chat> allChats = [];

  //   for (DocumentSnapshot singleChat in querySnapshot.docs) {
  //     Chat _singleChat = Chat.fromMap(singleChat.data());

  //     allChats.add(_singleChat);
  //   }

  //   return allChats;
  // }

  @override
  Stream<List<Message>> getMessages(
      String currentUserID, String chattingUserID) {
    var snapShot = _fireStore
        .collection('chats')
        .doc(currentUserID + "--" + chattingUserID)
        .collection("messages")
        .orderBy("date", descending: true)
        .snapshots();
    return snapShot.map((messageList) => messageList.docs
        .map((message) => Message.fromMap(message.data()))
        .toList());
  }

  Future<bool> matchWith(
      MyUserClass chattingUser, MyUserClass currentUser, bool isMatch) async {
    var _senderDocID = currentUser.userID + "--" + chattingUser.userID;
    var _receiverDocID = chattingUser.userID + "--" + currentUser.userID;
    await _fireStore
        .collection("chats")
        .doc(_senderDocID)
        .update({"isMatch": "true"});
    await _fireStore
        .collection("chats")
        .doc(_receiverDocID)
        .update({"isMatch": "true"});
    return true;
  }

  Future<bool> saveMessage(Message saveMessage, bool isMatch) async {
    var _messageID = _fireStore.collection("chats").doc().id;
    var _senderDocID = saveMessage.from + "--" + saveMessage.to;
    var _receiverDocID = saveMessage.to + "--" + saveMessage.from;
    var _savingMessageMapStructure = saveMessage.toMap();
    await _fireStore
        .collection("chats")
        .doc(_senderDocID)
        .collection("messages")
        .doc(_messageID)
        .set(_savingMessageMapStructure);
    print("MATCH OLMUŞ MU?: " + isMatch.toString());
    if (!isMatch) {
      await _fireStore.collection("chats").doc(_senderDocID).set({
        "chat_owner": saveMessage.from,
        "talking_to": saveMessage.to,
        "last_sent_message": saveMessage.message,
        "seen": false,
        "created_at": Timestamp.now(),
        "isMatch": false,
      });
    } else {
      await _fireStore.collection("chats").doc(_senderDocID).set({
        "chat_owner": saveMessage.from,
        "talking_to": saveMessage.to,
        "last_sent_message": saveMessage.message,
        "seen": false,
        "created_at": Timestamp.now(),
        "isMatch": true,
      });
    }

    _savingMessageMapStructure.update("fromMe", (value) => false);
    await _fireStore
        .collection("chats")
        .doc(_receiverDocID)
        .collection("messages")
        .doc(_messageID)
        .set(_savingMessageMapStructure);

    await _fireStore.collection("chats").doc(_receiverDocID).set({
      "chat_owner": saveMessage.to,
      "talking_to": saveMessage.from,
      "last_sent_message": saveMessage.message,
      "seen": false,
      "created_at": Timestamp.now()
    });

    return true;
  }

  @override
  Future<DateTime> showTime(String userID) async {
    await _fireStore.collection("server").doc(userID).set({
      "saat": Timestamp.now(),
    });

    var okunanMap = await _fireStore.collection("server").doc(userID).get();
    var okunanTarih = okunanMap.data()['saat'];
    return okunanTarih.toDate();
  }

  @override
  Future<List<Chat>> getAllChatsWithPagination(
      UserModel currentUser, Chat lastFetchedChat, int itemsPerFetch) async {
    QuerySnapshot _querySnapshot;
    List<Chat> _allChats = [];
    if (lastFetchedChat == null) {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("chats")
          .where("chat_owner", isEqualTo: currentUser.user.userID)
          .where("isMatch", isEqualTo: "true")
          .orderBy("created_at")
          .limit(itemsPerFetch)
          .get();
    } else {
      _querySnapshot = await FirebaseFirestore.instance
          .collection("chats")
          .where("chat_owner", isEqualTo: currentUser.user.userID)
          .where("isMatch", isEqualTo: "true")
          .orderBy("created_at")
          .startAfter([lastFetchedChat.created_at])
          .limit(itemsPerFetch)
          .get();
      await Future.delayed(Duration(milliseconds: 100));
    }
    print("QUERY SNAPHOT : " + _querySnapshot.toString());
    for (DocumentSnapshot snap in _querySnapshot.docs) {
      Chat _tekChat = Chat.fromMap(snap.data());
      print("QUERY SNAPHOT : " + _tekChat.toString());
      _allChats.add(_tekChat);
    }
    return _allChats;
  }

  Future<String> getToken(String to) async {
    DocumentSnapshot _token = await _fireStore.doc("tokens/" + to).get();
    if (_token != null) {
      return _token.data()["token"];
    } else {
      return null;
    }
  }

  removeMatch(String talkingTo, String chatOwner) async {
    var _senderDocID = talkingTo + "--" + chatOwner;
    var _receiverDocID = chatOwner + "--" + talkingTo;
    await _fireStore.collection("chats").doc(_senderDocID).delete();
    await _fireStore.collection("chats").doc(_receiverDocID).delete();
    await _fireStore.collection("server").doc(talkingTo).delete();
    await _fireStore.collection("server").doc(chatOwner).delete();
    return true;
  }
}
