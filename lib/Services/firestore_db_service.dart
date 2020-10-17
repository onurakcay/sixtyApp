import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Services/db_base.dart';

class FireStoreDbService implements DbBase {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  @override
  Future<bool> saveUser(MyUserClass user, String age, String gender,
      String interest, String username) async {
    await _fireStore
        .collection("users")
        .doc(user.userID)
        .set(user.toMap(gender, interest, age, username));

    DocumentSnapshot _okunanUser =
        await FirebaseFirestore.instance.doc("users/${user.userID}").get();

    Map _okunanUserBilgileriMap = _okunanUser.data();

    MyUserClass _okunanUserBilgilerNesne =
        MyUserClass.fromMap(_okunanUserBilgileriMap);

    print("okunan user nesnesi :" + _okunanUserBilgilerNesne.toString());

    return true;
  }

  @override
  Future<MyUserClass> readUser(String userID) async {
    DocumentSnapshot _okunanUser =
        await _fireStore.collection("users").doc(userID).get();
    Map<String, dynamic> _okunanUserBilgilerMap = _okunanUser.data();
    MyUserClass _okunanUserNesnesi =
        MyUserClass.fromMap(_okunanUserBilgilerMap);
    print("ReadUser Okunan user nesnesi: " + _okunanUserNesnesi.toString());
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
  Future<List<MyUserClass>> getAllUsers() async {
    QuerySnapshot querySnapshot = await _fireStore.collection("users").get();
    List<MyUserClass> tumKullanicilar = [];
    for (DocumentSnapshot tekUser in querySnapshot.docs) {
      MyUserClass _tekUser = MyUserClass.fromMap(tekUser.data());
      tumKullanicilar.add(_tekUser);
    }
    // map ile
    // tumKullanicilar = querySnapshot.docs
    //     .map((tekSatir) => MyUserClass.fromMap(tekSatir.data()))
    //     .toList();
    return tumKullanicilar;
  }

  @override
  Future<List<Chat>> getAllChats(String userID) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection("chats")
        .where("chat_owner", isEqualTo: userID)
        .orderBy("created_at", descending: true)
        .get();
    List<Chat> allChats = [];

    for (DocumentSnapshot singleChat in querySnapshot.docs) {
      Chat _singleChat = Chat.fromMap(singleChat.data());

      allChats.add(_singleChat);
    }

    return allChats;
  }

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

  Future<bool> saveMessage(Message saveMessage) async {
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

    await _fireStore.collection("chats").doc(_senderDocID).set({
      "chat_owner": saveMessage.from,
      "talking_to": saveMessage.to,
      "last_sent_message": saveMessage.message,
      "seen": false,
      "created_at": Timestamp.now()
    });

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
}
