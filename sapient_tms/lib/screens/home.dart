import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../utils/constants.dart' as Constants;
import 'tms_book_history.dart';
import '../utils/voice.dart';

class Home extends StatefulWidget {
  final String id;
  final String name;
  final String mobileNum;
  final String username;
  final String role;
  final String address;
  final String createdAt;

  Home(this.id, this.name, this.mobileNum, this.username, this.role,
      this.address, this.createdAt);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
    return Scaffold(
      appBar: AppBar(
        title:
            Text("Publicis Sapient TMS", style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.blue, Colors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircleAvatar(
                    radius: 50.0,
                    backgroundImage: AssetImage('images/avatar.png'),
                  ),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontSize: 40.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.role,
                    style: TextStyle(
                      fontFamily: 'Source Sans Pro',
                      color: Colors.teal.shade100,
                      fontSize: 20.0,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                    width: 150.0,
                    child: Divider(
                      color: Colors.teal.shade100,
                    ),
                  ),
                  Card(
//                padding: EdgeInsets.all(10.0),
                    color: Colors.white,
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.phone,
                            color: Colors.teal,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            widget.mobileNum,
                            style: TextStyle(
                              color: Colors.teal.shade900,
                              fontFamily: 'Source Sans Pro',
                              fontSize: 20.0,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Colors.white,
//                padding: EdgeInsets.all(10.0),
                    margin:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.home,
                            color: Colors.teal,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Flexible(
                            child: new Text(
                              widget.address,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: Colors.teal.shade900,
                                fontFamily: 'Source Sans Pro',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FloatingActionButton(
                    heroTag: 'btn2',
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
                ],
              ),
      ),
    );
  }
}
