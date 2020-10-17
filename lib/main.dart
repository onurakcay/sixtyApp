import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sixtyseconds/Screens/landingPage.dart';
import 'package:sixtyseconds/locator.dart';
import 'package:sixtyseconds/viewModel/userModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setupLocator();
  runApp(MainWidget());
}

class MainWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      child: MaterialApp(
        title: "sixtysecondstolove",
        theme: ThemeData(
          primarySwatch: Colors.pink,
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: LandingWidget(),
      ),
      create: (_) => UserModel(),
    );
  }
}
