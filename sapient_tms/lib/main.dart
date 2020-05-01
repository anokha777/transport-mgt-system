import 'package:flutter/material.dart';
import 'screens/loginPage.dart';
import 'utils/voice.dart';

void main() => runApp(SapientTmsApp());

class SapientTmsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    speak(
        "Welcome to Sapient transport management system. I can help you in booking and managing your transport.");
    return MaterialApp(
      title: "Publicis Sapient TMS",
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      theme: ThemeData(accentColor: Colors.white70),
    );
  }
}
