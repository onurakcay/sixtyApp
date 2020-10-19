import 'package:sixtyseconds/Model/chat_model.dart';
import 'package:sixtyseconds/Model/message.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

abstract class DbBase {
  Future<bool> saveUser(MyUserClass user, String age, String gender,
      String interest, String username);
  Future<MyUserClass> readUser(String userID);
  Future<bool> updateUserName(String userID, String yeniUserName);
  Future<bool> updateProfilePhoto(String userID, String profilFotoURL);
  Future<List<MyUserClass>> getAllUsers(UserModel currentUser);

  // Future<List<Chat>> getAllChats(String userID);
  Future<List<Chat>> getAllChatsWithPagination(
      UserModel currentUser, Chat lastFetchedChat, int itemsPerFetch);
  Stream<List<Message>> getMessages(String curretUserID, String chattingUserID);
  Future<bool> saveMessage(Message saveMessage);
  Future<DateTime> showTime(String userID);
}
