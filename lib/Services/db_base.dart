import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';

abstract class DbBase {
  Future<bool> saveUser(MyUserClass user, String age, String gender,
      String interest, String username);
  Future<MyUserClass> readUser(String userID);
  Future<bool> updateUserName(String userID, String yeniUserName);
  Future<bool> updateProfilePhoto(String userID, String profilFotoURL);
  Future<List<MyUserClass>> getAllUsers();
  Future<List<Chat>> getAllChats(String userID);
  Stream<List<Message>> getMessages(String curretUserID, String chattingUserID);
  Future<bool> saveMessage(Message saveMessage);
  Future<DateTime> showTime(String userID);
}
