
import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/timeHelper.dart';
import 'package:grocery_store/models/user.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../config/colorsFile.dart';

class AgoraScreen extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser user;
  final String appointmentId;

  final String consultName;

  const AgoraScreen(
      {Key? key,
      required this.appointment,
        required this.user,
        required this.appointmentId,
        required this.consultName})
      : super(key: key);

  @override
  _AgoraScreenState createState() => _AgoraScreenState();
}

class _AgoraScreenState extends State<AgoraScreen>
    with SingleTickerProviderStateMixin {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false, callStart = false;
  String name = " ", image = "  ";
  late RtcEngine engine;
  int minutes = 0, seconds = 0;
  bool mute = false, speaker = false, done = true, firstTime = false;

  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    initPlatformState();
    if (widget.user == null) {
    } else if (widget.user.uid == widget.appointment.consult.uid) {
      image = widget.appointment.user.image!;
      name = widget.appointment.user.name;
    } else {
      image = widget.appointment.consult.image!;
      name = widget.appointment.consult.name;

    }

  }

  @override
  Future<void> dispose() async {
    Wakelock.disable();
    if (widget.user != null && widget.user.userType == "CONSULTANT")
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .set({
        'allowCall': false,
      }, SetOptions(merge: true));
    engine.leaveChannel();
    engine.destroy();
    super.dispose();
  }

  // Init the app
  Future<void> initPlatformState() async {
    await [Permission.microphone].request();
    RtcEngineContext context = RtcEngineContext("a043844218f34404911b082cea15c57a");
    engine = await RtcEngine.createWithContext(context);
    engine.enableAudio();
    engine.disableVideo();
    engine.adjustPlaybackSignalVolume(400);
    engine.muteLocalAudioStream(mute);
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _joined = true;
        callStart = true;
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    }));
    await engine.joinChannel(null, widget.appointmentId, null, 0);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.lightGrey, //Color(0xffECECEC),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          padding: EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            // border: Border.all(color: AppColors.grey, width: 1),
                            shape: BoxShape.circle,
                            //color: AppColors.grey,
                          ),
                          child: image.isEmpty && image != null
                              ? Image.asset(
                                  'assets/applicationIcons/GroupLogo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.fill,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/load.gif',
                                    placeholderScale: 0.5,
                                    imageErrorBuilder: (context, error,
                                            stackTrace) =>
                                        Image.asset(
                                            'assets/applicationIcons/GroupLogo.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.fill),
                                    image: image,
                                    fit: BoxFit.cover,
                                    fadeInDuration: Duration(milliseconds: 250),
                                    fadeInCurve: Curves.easeInOut,
                                    fadeOutDuration:
                                        Duration(milliseconds: 150),
                                    fadeOutCurve: Curves.easeInOut,
                                  ),
                                ),
                        ),
                        Image.asset(
                          'assets/applicationIcons/dashBorder.png',
                          width: 82,
                          height: 82,
                        )
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      name == null ? " " : name,
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: AppColors.black,
                      ),
                    ),
                    SizedBox(height: 2),
                    (callStart == false)
                        ? Text(
                            getTranslated(context, "waitAgora") +
                                " " +
                                " " +
                                getTranslated(context, "join"),
                            style: TextStyle(
                             fontFamily: getTranslated(context, 'fontFamily'),
                              fontSize: 10.0,
                              fontWeight: FontWeight.normal,
                              color: AppColors.pink,
                            ),
                          )
                        : SizedBox(),
                    SizedBox(height: 8),
                    callStart
                        ? TweenAnimationBuilder<Duration>(
                            duration: Duration(minutes: 10),
                            tween: Tween(
                                begin: Duration(minutes: 10),
                                end: Duration.zero),
                            onEnd: () {
                              print('Timer ended');
                              _endMeating();
                            },
                            builder: (BuildContext context2, Duration value,
                                Widget? child) {
                              minutes = value.inMinutes;
                              seconds = value.inSeconds % 60;
                              if (minutes == 5 && seconds == 0) {
                                firstTime = true;
                              }
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5),
                                  child: Column(
                                    children: [
                                      Text('$minutes:$seconds',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: minutes < 5
                                                  ? Colors.red
                                                  : AppColors.white,
                                              fontSize: 15)),
                                      firstTime
                                          ? Text(
                                              getTranslated(
                                                      context, "fiveMinutes") +
                                                  minutes.toString() +
                                                  getTranslated(
                                                      context, "minutes"),
                                              maxLines: 2,
                                              textAlign: TextAlign.start,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: TextStyle(
                                               fontFamily: getTranslated(context, 'fontFamily'),
                                                fontSize: 11.0,
                                                color: AppColors.red,
                                              ),
                                            )
                                          : SizedBox(),
                                      /* Container(color: Colors.red.withOpacity(0.5),width: size.width*.8,child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                      Expanded(flex:2,
                                        child: Text( getTranslated(context, "fiveMinutes")+minutes.toString()+getTranslated(context, "minutes"),
                                          maxLines: 2,
                                          textAlign: TextAlign.start,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap:true,
                                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                            fontSize: 14.0,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: SizedBox(
                                          height: 25,
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                firstTime=false;
                                              });
                                            },
                                            color: Colors.black.withOpacity(0.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25.0),
                                            ),
                                            child: Text(
                                              getTranslated(context, "Ok"),
                                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                                color: AppColors.white,
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w500,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],),
                                  ),):SizedBox()*/
                                    ],
                                  ));
                            })
                        : SizedBox(),
                  ],
                ),
                SizedBox(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                            heroTag: "mic",
                            backgroundColor: Colors.black,
                            child: Icon(
                              mute ?Icons.mic_off: Icons.mic,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => _toggleMic()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            FloatingActionButton(
                                heroTag: "end",
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.call_end,
                                  size: 25,
                                ),
                                onPressed: () => _endMeating()),
                            SizedBox(
                              height: 30,
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FloatingActionButton(
                            heroTag: "speaker",
                            backgroundColor: Colors.black,
                            child: Icon(
                              speaker ? Icons.volume_up : Icons.volume_off,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => _toggleSpeaker()),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _toggleMic() {
    setState(() {
      mute = !mute;
    });
    engine.muteLocalAudioStream(mute);
  }

  _toggleSpeaker() {
    setState(() {
      speaker = !speaker;
    });

    if (speaker)
      engine.adjustPlaybackSignalVolume(400);
    else
      engine.adjustPlaybackSignalVolume(100);
  }

  _endMeating() async {
    if (widget.user != null && widget.user.userType == "CONSULTANT")
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .set({
        'allowCall': false,
      }, SetOptions(merge: true)).then((value) => Navigator.pop(context));
    else
      Navigator.pop(context);
  }
}
