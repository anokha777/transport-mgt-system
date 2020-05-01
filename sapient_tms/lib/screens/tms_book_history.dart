import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/constants.dart' as Constants;
import 'home.dart';
import '../utils/voice.dart';

class BookHistory extends StatefulWidget {
  final String id;
  final String name;
  final String mobileNum;
  final String username;
  final String role;
  final String address;
  final String createdAt;
  Map<String, dynamic> bookingList;

  BookHistory(this.id, this.name, this.mobileNum, this.username, this.role,
      this.address, this.createdAt, this.bookingList);

  @override
  _BookHistoryState createState() => _BookHistoryState();
}

class _BookHistoryState extends State<BookHistory> {
  bool _isLoading = false;
  SharedPreferences sharedPreferences;
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  String resultText = "";
  int tempCount = 0;
  BuildContext currentContext;

  @override
  void initState() {
    super.initState();
    initSpeechRecognizer();
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() => resultText = speech),
    );

    _speechRecognition.setRecognitionCompleteHandler(() => {
          setState(() => _isListening = false),
          ententRecognisationMLServer(resultText),
        });

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  ententRecognisationMLServer(String resultText) async {
    setState(() {
      tempCount = tempCount + 1;
    });
    print('tempCount--------------$tempCount');
    if (tempCount == 3) {
      print('ka re-----------------------------$resultText');
      setState(() {
        tempCount = 0;
      });
      var jsonResponse = null;
      Map data = {'comment': resultText};
      print('data----------------------------------$data');
      var response = await http
          .post("${Constants.BACKEND_URL}/api/ml/${widget.id}", body: data);

      print(
          'response.statusCode--------------------------- ${response.statusCode}');
      if (response.statusCode == 201 || response.statusCode == 200) {
        jsonResponse = json.decode(response.body);
        print('Response status: ${response.statusCode}');
        print('Response body: $jsonResponse');

        if (jsonResponse != null) {
          setState(() {
            _isLoading = false;
          });
          print('jsonResponse.runtimeType ${jsonResponse.runtimeType}');
          print('entent----------------- ${jsonResponse['entent']}');

          if (jsonResponse['entent'] == 'create' ||
              jsonResponse['entent'] == 'show') {
            // speak text
            speak("Here you go.");

            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (BuildContext context) {
                return new BookHistory(
                    widget.id,
                    widget.name,
                    widget.mobileNum,
                    widget.username,
                    widget.role,
                    widget.address,
                    widget.createdAt,
                    jsonResponse);
              },
            ), (Route<dynamic> route) => false);
          } else if (jsonResponse['entent'] == 'home') {
            speak("Here is your home screen.");
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
              builder: (BuildContext context) {
                return new Home(
                    widget.id,
                    widget.name,
                    widget.mobileNum,
                    widget.username,
                    widget.role,
                    widget.address,
                    widget.createdAt);
              },
            ), (Route<dynamic> route) => false);
          } else if (jsonResponse['entent'] == 'undefined') {
            speak(
                "I did not understand, I can help you in booking and managing transport. Thankyou.");
          }
        }
      } else {
        // some error
        // implement text to speech
        speak(
            "I did not understand, I can help you in booking and managing transport. Thankyou.");
      }
      setState(() {
        currentContext = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('bookingList-------${widget.bookingList}');
    print(
        'transportBookingList-------${widget.bookingList['transportBookingList'][0]}');

    return Scaffold(
      appBar: AppBar(
        title:
            Text("Publicis Sapient TMS", style: TextStyle(color: Colors.white)),
      ),
      body: new ListView.builder(
        itemCount: widget.bookingList == null
            ? 0
            : widget.bookingList['transportBookingList'].length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              title: Text(
                'Travell Information: \nDate: ${widget.bookingList['transportBookingList'][index]["requestedDate"].replaceAll("00:00:00 GMT", '')}',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 20.0,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '\n Request Created: ${Jiffy(widget.bookingList['transportBookingList'][index]["createDatetime"]).format("MMMM do yyyy, h:mm:ss a")}',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 15.0,
                  color: Colors.cyan,
                  fontWeight: FontWeight.w100,
                ),
              ),
              trailing: Text(
                'Time: ${widget.bookingList['transportBookingList'][index]['requestedTime']}',
                style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontSize: 20.0,
                  color: Colors.teal,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn4',
        child: Icon(_isListening ? Icons.bubble_chart : Icons.mic),
        onPressed: () {
          setState(() {
            currentContext = context;
          });

//                          diagnoseMyCar(widget.user_id);

          if (_isAvailable & !_isListening)
            _speechRecognition.listen(locale: "en_US").then(
                  (result) => print('result---------------$result'),
//                                  ententRecognisationMLServer(
//                                  result, widget.id, context),
                );
        },
        backgroundColor: Colors.cyan,
      ),
    );
  }
}
