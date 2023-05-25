/*

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/timeHelper.dart';
import 'package:grocery_store/models/user.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class AgoraAudioCall extends StatefulWidget {
  final AppAppointments appointment ;
  final GroceryUser user;
  const AgoraAudioCall({Key key, this.appointment, this.user}) : super(key: key);
  @override
  _AgoraAudioCallState createState() => _AgoraAudioCallState();
}

class _AgoraAudioCallState extends State<AgoraAudioCall>with SingleTickerProviderStateMixin {
  final Dependencies dependencies = new Dependencies();
  int _timer=0;  Timer timer; bool mic=true;
   AgoraClient client ;

  @override
  void initState() {
    super.initState();
    dependencies.stopwatch.start();
    startTimer();
    client= AgoraClient(
    agoraConnectionData: AgoraConnectionData(
      appId: "c43f829465b64368b158b8d82ffc3110",
      channelName:widget.appointment.appointmentId ,
    ),
    enabledPermission: [
      //Permission.camera,
      Permission.microphone,
    ],
);
    initAgora();
  }
  void startTimer() {
    _timer = 0;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(mounted){
        setState(() {
          _timer++;
        });
      if(_timer==600)
       {  print("ttttt");
         _endMeating(context);}
      }
    });
  }
  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }
  void initAgora() async {
    await client.initialize();
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.white,
        backgroundColor: Color(0xFF9D3A82),
        body: SafeArea(
          child:Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      widget.user.userType=="CONSULTANT"?widget.appointment.user.name:widget.appointment.consult.name,
                      style: Theme.of(context)
                          .textTheme
                          .headline4
                          .copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
                TimerText(dependencies: dependencies),
                AgoraVideoButtons(
                  client: client,
                  extraButtons: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(heroTag:"end",
                          backgroundColor: Colors.red,
                          child: Icon(Icons.call_end),
                          onPressed: () => _endMeating(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FloatingActionButton(heroTag:"mic",
                          backgroundColor: Colors.white,
                          child: Icon(mic?Icons.mic:Icons.mic_off,color: Colors.blue,),
                          onPressed: () => _toggleMic(context)),
                    )
                  ],
                  enabledButtons: [
                   // BuiltInButtons.toggleMic
                  ],
                ),

              ],
            ),
          ),

        ),
      ),
    );
  }
  _endMeating(BuildContext context) async {
    if(widget.user.userType=="CONSULTANT")
      {
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
          'allowCall': false,
        }, SetOptions(merge: true));
      }
    await client.sessionController.endCall();
    Navigator.pop(context);
  }
  _toggleMic(BuildContext context) async {
    setState(() {
      mic=!mic;
    });
    await client.sessionController.toggleMute();
    //Navigator.pop(context);

  }
}*/
