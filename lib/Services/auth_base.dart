import 'package:sixtyseconds/Model/user.dart';

abstract class AuthBase {
  Future<MyUserClass> currentUser();
  Future<MyUserClass> signInAnonymously();
  Future<bool> signOut();
  Future<MyUserClass> signInWithGoogle();
  Future<MyUserClass> signInWithFaceBook();
  Future<MyUserClass> signInWithEmailandPassword(String email, String sifre);
  Future<MyUserClass> createUserWithEmailandPassword(String email, String sifre,
      String yas, String cinsiyet, String ilgi, String username);
}
