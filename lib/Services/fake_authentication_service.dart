import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Services/auth_base.dart';

class FakeAuthenticationService implements AuthBase {
  String userID = "Onur";
  String userEmail = "a@b";

  @override
  Future<MyUserClass> currentUser() async {
    return await Future.value(MyUserClass(userID: userID, email: userEmail));
  }

  @override
  Future<MyUserClass> signInAnonymously() async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUserClass(userID: userID, email: userEmail));
  }

  @override
  Future<bool> signOut() {
    return Future.value(true);
  }

  @override
  Future<MyUserClass> signInWithGoogle() async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUserClass(userID: "google_user_id_423423", email: userEmail));
  }

  @override
  Future<MyUserClass> signInWithFaceBook() async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUserClass(userID: "facebook_user_id_423423", email: userEmail));
  }

  @override
  Future<MyUserClass> createUserWithEmailandPassword(String email, String sifre,
      String yas, String cinsiyet, String ilgi, String username) async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUserClass(userID: "created_user_id_423423", email: userEmail));
  }

  @override
  Future<MyUserClass> signInWithEmailandPassword(
      String email, String sifre) async {
    return await Future.delayed(Duration(seconds: 2),
        () => MyUserClass(userID: "signin_user_id_423423", email: userEmail));
  }
}
