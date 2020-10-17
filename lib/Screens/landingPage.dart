import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:sixtyseconds/Screens/homePage.dart';
import 'package:sixtyseconds/Screens/SignIn/signIn.dart';

import 'package:sixtyseconds/viewModel/userModel.dart';

class LandingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _userModel = Provider.of<UserModel>(context);
    if (_userModel.state == ViewState.Idle) {
      if (_userModel.user == null) {
        return SignInPage();
      } else {
        return HomePage(
          user: _userModel.user,
        );
      }
    } else {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
