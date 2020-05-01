import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void speak(String textVoice) async {
  FlutterTts flutterTts = FlutterTts();

  print('textVoice-------------$textVoice');
  await flutterTts.setLanguage("en-US");
  await flutterTts.setPitch(1);
  await flutterTts.speak(textVoice);
}
