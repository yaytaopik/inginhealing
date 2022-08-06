import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/utils_color.dart';
import 'homescreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 5),
        () => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen())));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("6C3483"),
          hexStringToColor("E8DAEF"),
          hexStringToColor("FEF5E7")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Ingin Healing",
              style: GoogleFonts.pacifico(
                  fontStyle: FontStyle.normal, fontSize: 40),
            ),
            SizedBox(height: 30),
            Text(
              "by Yayang Taopik",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 15,
                  fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
