import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sixtyseconds/Model/user.dart';
import 'package:sixtyseconds/Services/auth_base.dart';

class FirebaseAuthService implements AuthBase {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  @override
  Future<MyUserClass> currentUser() async {
    try {
      User user = _firebaseAuth.currentUser;
      return _userFromFirebase(user);
    } catch (e) {
      print("Hata CURRENT USER:" + e.toString());
      return null;
    }
  }

  MyUserClass _userFromFirebase(User user) {
    if (user == null) {
      return null;
    } else {
      return MyUserClass(userID: user.uid, email: user.email);
    }
  }

  @override
  Future<MyUserClass> signInAnonymously() async {
    try {
      UserCredential sonuc = await _firebaseAuth.signInAnonymously();
      return _userFromFirebase(sonuc.user);
    } catch (e) {
      print("Hata ANONIM GIRIS:" + e.toString());
      return null;
    }
  }

  @override
  Future<bool> signOut() async {
    try {
      final _googleSignIn = GoogleSignIn();
      final _facebookLogIn = FacebookLogin();

      await _googleSignIn.signOut();
      await _facebookLogIn.logOut();
      await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print("Hata SIGN OUT:" + e.toString());
      return false;
    }
  }

  @override
  Future<MyUserClass> signInWithGoogle() async {
    GoogleSignIn _googleSignIn = GoogleSignIn();
    GoogleSignInAccount _googleUser = await _googleSignIn.signIn();

    if (_googleUser != null) {
      GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
      if (_googleAuth.idToken != null && _googleAuth.accessToken != null) {
        UserCredential sonuc = await _firebaseAuth.signInWithCredential(
            GoogleAuthProvider.credential(
                idToken: _googleAuth.idToken,
                accessToken: _googleAuth.accessToken));
        User _user = sonuc.user;
        return _userFromFirebase(_user);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  @override
  Future<MyUserClass> signInWithFaceBook() async {
    final _facebookLogin = FacebookLogin();
    FacebookLoginResult _faceResult = await _facebookLogin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    switch (_faceResult.status) {
      case FacebookLoginStatus.Success:
        if (_faceResult.accessToken != null) {
          UserCredential _firebaseResult =
              await _firebaseAuth.signInWithCredential(
            FacebookAuthProvider.credential(_faceResult.accessToken.token),
          );
          print("FACBOOK USER :" + _firebaseResult.toString());
          User _user = _firebaseResult.user;
          return _userFromFirebase(_user);
        }

        break;
      case FacebookLoginStatus.Cancel:
        print("Kullanıcı girişi iptal etti");
        break;
      case FacebookLoginStatus.Error:
        print("Hata çıktı: " + _faceResult.error.toString());
        break;
    }
    return null;
  }

  @override
  Future<MyUserClass> createUserWithEmailandPassword(String email, String sifre,
      String yas, String cinsiyet, String ilgi, String username) async {
    UserCredential sonuc = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
  }

  @override
  Future<MyUserClass> signInWithEmailandPassword(
      String email, String sifre) async {
    UserCredential sonuc = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: sifre);
    return _userFromFirebase(sonuc.user);
  }
}
