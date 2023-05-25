import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_foreground_plugin/flutter_foreground_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wakelock/wakelock.dart';
import 'dart:core';
import '../../Utils/screen_select_dialog.dart';
import '../../blocs/web_rtc_bloc/signaling.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../whiteBoaed/whiteboard.dart';
import '../../widget/endCallDialog.dart';

class CallSample extends StatefulWidget {
  static String tag = 'call_sample';

  final String host;
  bool  ?iscaller=false;
  bool ?acceptNotfi=false;
  AppAppointments ? appointment;
  GroceryUser  ? loggedUser ;

  String ? CallerId ="";
  String ? ReciverId="";

  bool ? isVideo=true;
  bool ? normalCall=true;



  CallSample({required this.host,this.iscaller,this
      .acceptNotfi,this.appointment,this.loggedUser,this.isVideo,this.normalCall,this.CallerId,this.ReciverId});

  @override
  _CallSampleState createState() => _CallSampleState();
}

class _CallSampleState extends State<CallSample> {
  Signaling? _signaling;
  List<dynamic> _peers = [];
  String? _selfId;
  bool ? isVideoRemoteSignaling=true;
  bool ? isVideolocalSignaling=true;
  bool  permissionGranted=false;
  bool anotherCall=false;
  bool refused=false;
  bool closed=false;
  bool Speaker=true;

  bool calling=true;
  bool oncall=false;


  bool startRecord=false;
  String micStateIcon='assets/icons/mute.png';
  String cameraStateIcon='assets/icons/videoon.png';
  RTCDataChannel? _dataChannel;
  bool showAcceptButtons=false;
  late Size size;
  bool mic=true,camera=true,share=true,toggle=true;
  int minutes = 0, seconds = 0;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _inCalling = true;
  Session? _session;
  DesktopCapturerSource? selected_source_;
  bool _waitAccept = true;
  AudioPlayer audioPlayer=  AudioPlayer()..setReleaseMode(ReleaseMode.loop);



  // ignore: unused_element
  _CallSampleState();



  @override
  initState()  {
    super.initState();
    Wakelock.enable();
    initRenderers();
    _connect(context);
    //  setupAudio();

    //  audioPlayerPublic.stop();
    if(!widget.normalCall!){
      this.isVideoRemoteSignaling=false;
      this.isVideolocalSignaling=false;
    }

    //setupAwosome();

    if(widget.iscaller!){
      _invitePeer(context, widget.ReciverId!, false, widget.isVideo!);

    }


    // if(!widget.iscaller!){
    // //  setupAudio();
    // }
    // else{
    //
    //   // if(widget.normalCall!) {
    //   //   FirebaseFirestore.instance.collection('AppAppointments').doc(
    //   //       widget.host).get().then((value) {
    //   //     String peerid = value.data()!['consult']['uid'] ==
    //   //         FirebaseAuth.instance.currentUser!.uid ? value
    //   //         .data()!['user']['uid'] : value.data()!['consult']['uid'];
    //   //
    //   //     print("peerIDss$peerid");
    //   //
    //   //   });
    //   // }
    //   // else{
    //   //   FirebaseFirestore.instance.collection('SupportList').doc(
    //   //       widget.host).get().then((value) {
    //   //     String peerid = value.data()!['userUid'] ;
    //   //
    //   //     print("peerIDss$peerid");
    //   //
    //   //     _invitePeer(context, peerid, false, widget.isVideo!);
    //   //   });
    //   //
    //   // }
    //   //
    //
    //
    //
    //
    //
    // }

    // if (Platform.isAndroid){
    //    startForegroundService();
    //
    // }


  }


  setupAudio() async {
    var audioByteData;
    // if(ifcaller){
    //    audioByteData = await rootBundle.load("assets/sound/jeraston.mp3");
    //
    // }
    // audioByteData = await rootBundle.load("sound/jeraston.mp3");

    //  Uint8List audioUint8List = audioByteData.buffer.asUint8List(audioByteData.offsetInBytes, audioByteData.lengthInBytes);
    //List<int> audioListInt = audioUint8List.map((eachUint8) => eachUint8.toInt()).toList();
    // audioPlayer.setSourceAsset('');
    audioPlayer.play(AssetSource('sound/jeraston.mp3'));

  }

  initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    // if(WebRTC.platformIsAndroid){
    //   await startForegroundService();
    //
    // }



  }


  @override
  void dispose() {
    if(FirebaseAuth.instance.currentUser!=null){
      FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('callState').onDisconnect().set('closed').then((value) =>CallKeep.instance.endAllCalls() );

    }
    super.dispose();
  }

  @override
  deactivate() {
    super.deactivate();
    _signaling?.close();

    _localRenderer.dispose();
    _remoteRenderer.dispose();

    FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('callState').set('closed').then((value) =>CallKeep.instance.endAllCalls() );


    // CallKeep.instance.endAllCalls();
    //  audioPlayer.release();




  }

//   @pragma("vm:entry-point")
//   Future<void>  onActionReceivedMethod(ReceivedAction receivedAction) async {
//     print("madmaxcx${receivedAction.actionType}");
//
//     if(
//     receivedAction.actionType == ActionType.Default){
//
//
//
//
//   print("saranewmax");
//
// // await executeLongTaskInBackground();
//     }
//
//   }


  // setupAwosome(){
  //   AwesomeNotifications()
  //       .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  //
  // }


  void _connect(BuildContext context) async {
    _signaling ??= Signaling(widget.host,false, context,widget.CallerId!,widget.ReciverId!)..connect(widget.normalCall!);

    _signaling?.onDataChannelMessage = (_, dc, RTCDataChannelMessage data) {
      print('Got text ${data.text} ');

      final datac=jsonDecode(data.text!);
      if(datac['strok']!=null){

        return;
      }
      if(datac['strokStart']!=null){

        return;
      }
      print('isVideoRemoteSignaling ${datac['video']} ');

      isVideoRemoteSignaling=datac['video'];

      setState(() {
        if (data.isBinary) {
          print('Got binary [' + data.binary.toString() + ']');
        } else {

        }
      });
    };

    _signaling?.checkCallState=(callStat){
      switch (callStat){

        case call_State.anotherCall:

          break;
        case call_State.calling:
          calling =true;
          refused=false;
          oncall=false;
          closed=false;
          break;
        case call_State.refusd:
          refused=true;
          oncall=false;
          closed=false;
          calling=false;
          break;
        case call_State.closed:
          closed=true;
          oncall=false;
          calling=false;
          refused=false;

          break;
        case call_State.inCall:
          oncall=true;
          calling=false;
          closed=false;
          refused=false;


          break;
      }

      setState(() {


      });


    };

    _signaling?.onDataChannel = (_, channel) {

      print("sdasdasdas");
      _dataChannel = channel;
    };

    _signaling?.onSignalingStateChange = (SignalingState state) {
      switch (state) {
        case SignalingState.ConnectionClosed:
        case SignalingState.ConnectionError:
        case SignalingState.ConnectionOpen:
          break;
      }
    };

    _signaling!.permissionsState=(state)async
    {
      switch(state){

        case permissionsState_enum.micdined:

          permissionGranted=false;


          break;
        case permissionsState_enum.cameradined:
          permissionGranted=false;

          break;

        default:
          permissionGranted=true;


      }
      setState(() {

      });

    };

    _signaling?.onCallStateChange = (Session session, CallState state) async {
      switch (state) {
        case CallState.CallStateNew:
          setState(() {
            _session = session;
          });
          break;

        case CallState.callStartCall:
        // setState(() {
        //   ifcaller = true;
        // });
          break;
        case CallState.CallStateRinging:


          FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('acceptState').onValue.listen((event) {
            if(event.snapshot!=null){
              print("usercallState${event.snapshot.value.toString()}");


              if(event.snapshot.value.toString()=='accepted'){

                // Future.delayed(Duration(seconds: 10),(){
                //   _accept();
                //   setState(() {
                //     _inCalling = true;
                //   });
                // });



              }

            }



          });

          setState(() {
            showAcceptButtons=true;

          });













          break;
        case CallState.CallStateBye:
          if (_waitAccept) {
            print('peer reject');
            _waitAccept = false;
            Navigator.of(context).pop(false);
            //   audioPlayer.release();
          }
          setState(() {
            _localRenderer.srcObject = null;
            _remoteRenderer.srcObject = null;
            _dataChannel = null;

            _inCalling = false;
            _session = null;
          });
          break;
        case CallState.CallStateInvite:
          _waitAccept = true;
          //  _showInvateDialog();
          break;
        case CallState.CallStateConnected:
          if (_waitAccept) {
            _waitAccept = false;
            //   Navigator.of(context).pop(false);
          }
          setState(() {
            _inCalling = true;
          });

          break;
        case CallState.CallStateRinging:
      }
    };

    _signaling?.onPeersUpdate = ((event) {
      setState(() {
        _selfId = event['self'];



        _peers = event['peers'];

        // if(_peers.length>1){
        //   var peer=_peers.firstWhere((element) => element['id']!=_selfId&&widget.iscaller!);
        //
        //   _invitePeer(context, peer['id'], false);
        // }



      });
    });

    _signaling?.onLocalStream = ((stream,isVideolocalSignaling) {
      if(stream!=null){
        _localRenderer.srcObject = stream;
        this.isVideolocalSignaling=isVideolocalSignaling;
        print('dsdsdasda');
        setState(() {});

      }

      _signaling?.onEnableLocalVideo=(isVideolocalSignaling){
        this.isVideolocalSignaling=isVideolocalSignaling;
        //   print('dsdsdasda');
        setState(() {});
      };



    });

    _signaling?.onAddRemoteStream = ((_, stream,isVideoRemoteSignaling) {
      _remoteRenderer.srcObject = stream;
      this.isVideoRemoteSignaling=isVideoRemoteSignaling;

      setState(() {});
    });
//     _remoteRenderer!.srcObject!.getVideoTracks()[0].onMute=(){
//       this.isVideoRemoteSignaling=false;
//       print("madmaxxxcxcx");
// setState(() {
//
// });
//     };
    _signaling?.onRemoveRemoteStream = ((_, stream) {
      _remoteRenderer.srcObject = null;
    });


    // _localRenderer.srcObject!.getVideoTracks()[0].onMute=(){
    //   print("sweethsweethearear");
    //
    // };

  }

  Future<bool?> _showAcceptDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("title"),
          content: Text("accept?"),
          actions: <Widget>[
            MaterialButton(
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            MaterialButton(
              child: Text(
                'Accept',
                style: TextStyle(color: Colors.green),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showInvateDialog() {
    return showDialog<bool?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("title"),
          content: Text("waiting"),
          actions: <Widget>[
            TextButton(
              child: Text("cancel"),
              onPressed: () {
                // audioPlayerPublic.stop();
                _hangUp();

                Navigator.of(context).pop(false);

              },
            ),
          ],
        );
      },
    );
  }
  _invitePeer(BuildContext context, String peerId, bool useScreen,bool isVideo) async {
    if (_signaling != null && peerId != _selfId) {
      _signaling?.invite(peerId, 'video', useScreen,isVideo);
    }
  }
  _accept() {
    if (_session != null) {
      _signaling?.accept(_session!.sid);
      //  audioPlayer.release();

    }
  }
  _reject() {
    print("kkkk00000");
    if (_session != null) {
      _signaling?.reject(_session!.sid);
      FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('callState').set('refused');
    }
  }
  _hangUp() {
    print("_hangUp");
    Wakelock.disable();
    if(widget.loggedUser==null||widget.loggedUser!.userType!="CONSULTANT")
    {
      if (_session != null) {

        _signaling?.bye(_session!.sid);
        if(Platform.isAndroid){
          stopForegroundService();

        }
        CallKeep.instance.endAllCalls();

        Navigator.pop(context);

      }
    }
    else{
      if (_session != null) {
        _signaling?.bye(_session!.sid);
        if(Platform.isAndroid){
          stopForegroundService();

        }
      }
      if(widget.appointment!=null)
        confirmEndCallDialog(MediaQuery.of(context).size);
      else
        Navigator.pop(context);

    }
  }
  confirmEndCallDialog(Size size) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EndCallDialog(
          user: widget.loggedUser!,
          appointment: widget.appointment!,);
      },
    );
  }
  _switchCamera() async {

    /*if(startRecord){
      if(Platform.isAndroid){
        stopForegroundService();

      }
      startRecord =false;
    }*/

    _signaling?.switchCamera();
  }
  Future<void> selectScreenSourceDialog(BuildContext context) async {
    MediaStream? screenStream;
    if (WebRTC.platformIsDesktop) {
      final source = await showDialog<DesktopCapturerSource>(
        context: context,
        builder: (context) => ScreenSelectDialog(),
      );
      if (source != null) {
        try {
          var stream =
          await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
            'video': {
              'deviceId': {'exact': source.id},
              'mandatory': {'frameRate': 30.0}
            }
          });
          stream.getVideoTracks()[0].onEnded = () {
            print(
                'By adding a listener on onEnded you can: 1) catch stop video sharing on Web');
          };
          screenStream = stream;
        } catch (e) {
          print(e);
        }
      }
    }
    else if (WebRTC.platformIsWeb) {
      screenStream =
      await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'audio': false,
        'video': true,
      });
    }
    else if (WebRTC.platformIsAndroid) {

      if(startRecord){
        stopForegroundService();
        startRecord =false;
        _signaling?.switchCamera();
        return;
      }
      await startForegroundService();
      startRecord=true;
      screenStream = await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'audio': false,
        'video': true,
      });
    }
    else if (WebRTC.platformIsIOS) {
      print("startshare1");
      print(startRecord);
      if(startRecord){
        startRecord =false;
        _signaling?.switchCamera();
        return;
      }
      startRecord=true;
      screenStream =
      await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
        'audio': false,
        'video': true,
      });
      print("startshare2");
      print(screenStream);
    }
    if (screenStream != null) _signaling?.switchToScreenSharing(screenStream);
    else{
      print("startshare0000000");
      Fluttertoast.showToast(msg:  "can't start share");
    }
  }
  _muteMic() {
    _signaling?.muteMic();

    bool enable = _localRenderer.srcObject!.getAudioTracks()[0].enabled;
    if (enable) {
      setState(() {
        mic=enable;
        micStateIcon = 'assets/icons/unmute.png';
      });
    } else {
      setState(() {
        mic=enable;
        micStateIcon = 'assets/icons/mute.png';
      });
    }
  }
  _muteCamera() {

    _signaling?.mutecamera();

    bool enable=   _localRenderer.srcObject!.getVideoTracks()[0].enabled;
    if(enable){
      setState(() {
        camera=enable;
        cameraStateIcon='assets/icons/videoon.png';

      });

    }
    else{
      setState(() {
        cameraStateIcon='assets/icons/novideo.png';

      });
    }

    _handleDataChannelTest(
        {
          'video':enable
        });

  }
  _closeCamera() async {
    // await stopForegroundService();

    startRecord=false;
    MediaStream?  screenStream =
    await navigator.mediaDevices.getUserMedia(<String, dynamic>{
      'audio': true,
      'video': false,
    });
    if (screenStream != null)  _signaling?.switchToAudioOnly(screenStream);
  }
  static void globalForegroundService() {
    debugPrint("current datetime is ${DateTime.now()}");
  }
  Future<bool> startForegroundService() async {
    await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
    await FlutterForegroundPlugin.setServiceMethod(globalForegroundService);
    await FlutterForegroundPlugin.startForegroundService(
      holdWakeLock: false,
      onStarted: () {
        print('Foreground on Started');
      },
      onStopped: () {
        print('Foreground on Stopped');
      },
      title: 'Tcamera',
      content: 'Tcamera sharing your screen.',
      iconName: 'ic_stat_mobile_screen_share',);



    return true;
  }
  _handleDataChannelTest(Map<String ,dynamic> data) async {
    // String text =
    //     'Say hello ' + timer.tick.toString() + ' times, from [$_selfId]';
    // _dataChannel
    //     ?.send(RTCDataChannelMessage.fromBinary(Uint8List(timer.tick + 1)));


    _dataChannel?.send(RTCDataChannelMessage(json.encode(data)));
  }
  Future<bool> stopForegroundService() async {

    await FlutterBackground.initialize();
    await FlutterBackground.disableBackgroundExecution();
    await FlutterForegroundPlugin.stopForegroundService();


    return true;
  }
  _buildRow(context, peer) {
    var self = (peer['id'] == _selfId);
    return ListBody(children: <Widget>[
      ListTile(
        title: Text(self
            ? peer['name'] + ', ID: ${peer['id']} ' + ' [Your self]'
            : peer['name'] + ', ID: ${peer['id']} '),
        onTap: null,
        trailing: SizedBox(
            width: 100.0,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.videocam,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], false,true),
                    tooltip: 'Video calling',
                  ),
                  IconButton(
                    icon: Icon(self ? Icons.close : Icons.screen_share,
                        color: self ? Colors.grey : Colors.black),
                    onPressed: () => _invitePeer(context, peer['id'], true,true),
                    tooltip: 'Screen sharing',
                  )
                ])),
        subtitle: Text('[' + peer['user_agent'] + ']'),
      ),
      Divider()
    ]);
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(child:
    Scaffold(
        backgroundColor: Color.fromRGBO(247, 247, 247,1),
        extendBodyBehindAppBar: true,


        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        body: calling?ShimmerLoad():

        oncall?OrientationBuilder(builder: (context, orientation) {
          return Container(
            color: Colors.white,
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(

                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: this.isVideoRemoteSignaling!? RTCVideoView(_remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,):
                    Container(
                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(children: [
                            Align(
                              alignment : Alignment.bottomCenter,
                              child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0x33ae9cce),
                                          offset: Offset(0, 6),
                                          blurRadius: 12,
                                          spreadRadius: 0)
                                    ],
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 6,
                                      color: Colors.white,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/applicationIcons/whiteLogo.png',
                                    width: 65,
                                    height: 65,
                                  )
                              ),
                              /*ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child:FadeInImage.assetNetwork(
                                  width: 100,
                                  height: 100,
                                  placeholder:
                                  'assets/icons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child:  Icon(
                                          Icons.person,
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                  ,
                                  image:_signaling!.peerInfo!.photoUrl!
                                  ,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                  Duration(milliseconds: 250),
                                  fadeInCurve: Curves.easeInOut,
                                  fadeOutDuration:
                                  Duration(milliseconds: 150),
                                  fadeOutCurve: Curves.easeInOut,
                                ),
                              ),*/

                            )
                          ],),
                          SizedBox(height: 10,),
                          Text(
                            _signaling!.peerInfo!.name!,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 10,),
                          TweenAnimationBuilder<Duration>(
                              duration: Duration(minutes: 10),
                              tween: Tween(
                                  begin: Duration(minutes: 10),
                                  end: Duration.zero),
                              onEnd: () {
                                print('Timer ended');
                                _hangUp();
                              },
                              builder: (BuildContext context, Duration value,
                                  Widget? child) {
                                minutes = value.inMinutes;
                                seconds = value.inSeconds % 60;
                                return   text('$minutes:$seconds',16,minutes <= 5
                                    ? Colors.red
                                    : Color.fromRGBO(156, 57, 129, 1),FontWeight.w300);
                              }),
                        ],) ,)
                    ,
                    decoration: BoxDecoration(color: Colors.white),
                  )),
              Positioned(
                left: 20.0,
                top: 30.0,
                child:  Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

               widget.normalCall!?     FutureBuilder(

                      future: FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!= widget.ReciverId?widget.ReciverId:widget.CallerId).withConverter(
                        fromFirestore: GroceryUser.fromFirestore,
                        toFirestore: (GroceryUser user, _) => user.toFirestore(), ).get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<GroceryUser>?> snapshot) {
                        // print("dsadsa${snapshot.data!.name!}");
                        if(snapshot.connectionState==ConnectionState.waiting)
                        {
                          return Center(child: LinearProgressIndicator(),);
                        }
                        //  print("dsadsa${snapshot.data!.name!}");
                        else
                        {
                          return  headerWidget(snapshot!.data!.data()!.name!);
                        }





                      },):Container()
                    ,
                    SizedBox(height: 15,),
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.normalCall!?
                        Container(
                          decoration: BoxDecoration(
                            color:Colors.black54,
                            //borderRadius: BorderRadius.circular(30.0),

                          ),
                          width: orientation == Orientation.portrait ? 90.0 : 120.0,
                          height: orientation == Orientation.portrait ? 120.0 : 90.0,
                          child: isVideolocalSignaling!?  RTCVideoView(_localRenderer, mirror: true,
                            placeholderBuilder: (context){
                              return  Container(width: 100,height: 100, decoration: BoxDecoration(
                                color:Colors.black54,
                                //borderRadius: BorderRadius.circular(30.0),

                              ),);
                            },): Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x33ae9cce),
                                      offset: Offset(0, 6),
                                      blurRadius: 12,
                                      spreadRadius: 0)
                                ],
                                color: Colors.white,
                                border: Border.all(
                                  width: 6,
                                  color: Colors.white,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/applicationIcons/whiteLogo.png',
                                width: 65,
                                height: 65,
                              )
                          ),
                          /*Container(child:
                                ClipRRect( borderRadius: BorderRadius.circular(10.0),
                                  child: FadeInImage.assetNetwork(
                                    width: 100,
                                    height: 100,


                                    placeholder: 'assets/call/bxs-user-circle@3x.png',
                                    // placeholderScale: 0.5,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                        Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey,
                                          child:  Image.asset(
                                            'assets/call/bxs-user-circle@3x.png',
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                    image:_signaling!.myInfo!=null?_signaling!.myInfo!.photoUrl!:"",
                                    fit: BoxFit.scaleDown,
                                    fadeInDuration:
                                    Duration(milliseconds: 250),
                                    fadeInCurve: Curves.easeInOut,
                                    fadeOutDuration:
                                    Duration(milliseconds: 150),
                                    fadeOutCurve: Curves.easeInOut,
                                  ),
                                ),
                                ),*/
                        ):Container(),
                        SizedBox(width: 20,)

                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.0,
                right: 20,
                bottom: 20,
                child: Column(
                  children: [
                    endCallWidget(),
                    SizedBox(height: 10,),

                    Row(
                        mainAxisAlignment: widget.normalCall!?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                        children: <Widget>[
                          widget.normalCall!?   switchCameraWidget():Container(),
                          widget.normalCall!?   toggleCameraWidget():Container(),
                          (WebRTC.platformIsAndroid&&widget.normalCall!)?  shareScreenWidget(context):Container(),
                        //  widget.normalCall!?  whiteboardWidget():Container(),

                          micWidget(),
                          SizedBox(width: 50,),
                          toggleSpeakerWidget(),


                        ]),
                  ],
                ),
              )
            ]),
          );
        }):
        refused? endWidget("userRefuse"):
        closed? endWidget("userClose"):OrientationBuilder(builder: (context, orientation) {
          return Container(
            color: Colors.white,
            child: Stack(children: <Widget>[
              Positioned(
                  left: 0.0,
                  right: 0.0,
                  top: 0.0,
                  bottom: 0.0,
                  child: Container(

                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: this.isVideoRemoteSignaling!? RTCVideoView(_remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,):
                    Container(

                      child:   Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(children: [


                            Align(
                              alignment : Alignment.bottomCenter,
                              child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0x33ae9cce),
                                          offset: Offset(0, 6),
                                          blurRadius: 12,
                                          spreadRadius: 0)
                                    ],
                                    color: Colors.white,
                                    border: Border.all(
                                      width: 6,
                                      color: Colors.white,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Image.asset(
                                    'assets/applicationIcons/whiteLogo.png',
                                    width: 65,
                                    height: 65,
                                  )
                              ), /*ClipRRect(

                                borderRadius: BorderRadius.circular(50.0),
                                child: FadeInImage.assetNetwork(
                                  width: 100,
                                  height: 100,
                                  placeholder:
                                  'assets/icons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey,
                                        child:  Icon(
                                          Icons.person,
                                          color: Colors.black,
                                          size: 50.0,
                                        ),
                                      )
                                  ,
                                  image:_signaling!.peerInfo!.photoUrl!
                                  ,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                  Duration(milliseconds: 250),
                                  fadeInCurve: Curves.easeInOut,
                                  fadeOutDuration:
                                  Duration(milliseconds: 150),
                                  fadeOutCurve: Curves.easeInOut,
                                ),
                              ),*/

                            )

                          ],),

                          SizedBox(height: 10,),
                          Text(
                            _signaling!.peerInfo!.name!,
                            style: TextStyle(
                              color: AppColors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(height: 10,),


                          TweenAnimationBuilder<Duration>(
                              duration: Duration(minutes: 10),
                              tween: Tween(
                                  begin: Duration(minutes: 10),
                                  end: Duration.zero),
                              onEnd: () {
                                print('Timer ended');
                                _hangUp();
                              },
                              builder: (BuildContext context, Duration value,
                                  Widget? child) {
                                minutes = value.inMinutes;
                                seconds = value.inSeconds % 60;
                                return   text('$minutes:$seconds',16,minutes <= 5
                                    ? Colors.red
                                    : Color.fromRGBO(156, 57, 129, 1),FontWeight.w300);
                              }),





                        ],) ,)
                    ,
                    decoration: BoxDecoration(color: Colors.white),
                  )),
              Positioned(
                left: 20.0,
                top: 30.0,
                child:  Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    widget.normalCall!?     FutureBuilder(

                      future: FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!= widget.ReciverId?widget.ReciverId:widget.CallerId).withConverter(
                        fromFirestore: GroceryUser.fromFirestore,
                        toFirestore: (GroceryUser user, _) => user.toFirestore(), ).get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<GroceryUser>?> snapshot) {
                        // print("dsadsa${snapshot.data!.name!}");
                        if(snapshot.connectionState==ConnectionState.waiting)
                        {
                          return Center(child: LinearProgressIndicator(),);
                        }
                        //  print("dsadsa${snapshot.data!.name!}");
                        else
                        {
                          return  headerWidget(snapshot!.data!.data()!.name!);
                        }





                      },):Container()
                    ,
                    SizedBox(height: 15,),
                    Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        widget.normalCall!?
                        Container(
                          decoration: BoxDecoration(
                            color:Colors.black54,
                            //borderRadius: BorderRadius.circular(30.0),

                          ),
                          width: orientation == Orientation.portrait ? 90.0 : 120.0,
                          height: orientation == Orientation.portrait ? 120.0 : 90.0,
                          child: isVideolocalSignaling!?  RTCVideoView(_localRenderer, mirror: true,
                            placeholderBuilder: (context){
                              return  Container(width: 100,height: 100, decoration: BoxDecoration(
                                color:Colors.black54,
                                //borderRadius: BorderRadius.circular(30.0),

                              ),);
                            },): Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x33ae9cce),
                                      offset: Offset(0, 6),
                                      blurRadius: 12,
                                      spreadRadius: 0)
                                ],
                                color: Colors.white,
                                border: Border.all(
                                  width: 6,
                                  color: Colors.white,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/applicationIcons/whiteLogo.png',
                                width: 65,
                                height: 65,
                              )
                          ),
                          /*Container(child:

                          ClipRRect( borderRadius: BorderRadius.circular(10.0),
                            child: FadeInImage.assetNetwork(
                              width: 100,
                              height: 100,


                              placeholder: 'assets/call/bxs-user-circle@3x.png',
                              // placeholderScale: 0.5,
                              imageErrorBuilder:
                                  (context, error, stackTrace) =>
                                  Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey,
                                    child:  Image.asset(
                                      'assets/call/bxs-user-circle@3x.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  ),
                              image:_signaling!.myInfo!=null?_signaling!.myInfo!.photoUrl!:"",
                              fit: BoxFit.scaleDown,
                              fadeInDuration:
                              Duration(milliseconds: 250),
                              fadeInCurve: Curves.easeInOut,
                              fadeOutDuration:
                              Duration(milliseconds: 150),
                              fadeOutCurve: Curves.easeInOut,
                            ),
                          ),

                          ),*/
                        ):Container(),
                        SizedBox(width: 20,)

                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20.0,
                right: 20,
                bottom: 20,
                child: Column(
                  children: [
                    endCallWidget(),
                    SizedBox(height: 10,),

                    Row(
                        mainAxisAlignment: widget.normalCall!?MainAxisAlignment.spaceBetween:MainAxisAlignment.center,
                        children: <Widget>[
                          widget.normalCall!?   switchCameraWidget():Container(),
                          widget.normalCall!?   toggleCameraWidget():Container(),
                          (WebRTC.platformIsAndroid&&widget.normalCall!)?  shareScreenWidget(context):Container(),
                          //  widget.normalCall!?  whiteboardWidget():Container(),

                          micWidget(),
                          SizedBox(width: 50,),
                          toggleSpeakerWidget(),


                        ]),
                  ],
                ),
              )
            ]),
          );
        })


    ),
      onWillPop: ()async => true,
      // {
      //     if(widget.normalCall!&& widget.iscaller!){
      //       //confirmEndCallDialog();
      //     }
      //     _hangUp();
      //     return Future(() => true);
      //   }
    ) ;
  }

  Widget ShimmerLoad(){
    return  Stack(
      children: [
        // Positioned(
        //     left: 10,
        //     top: 10,
        //     child:
        //     Container(
        //       width: 150,
        //       height: 150,
        //       child: RTCVideoView( _localRenderer!),
        //     )
        // ),
        Align(child:
        Container(padding: EdgeInsets.symmetric(vertical: 50),
          child:Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  Stack(children: [
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 100,
                          width: 100,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ))


                  ],),
                  SizedBox(width:size.width*.20 ,height: 10,),

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child: Container(
                        height: 50,
                        width: kIsWeb && MediaQuery.of(context).size.width > 400
                            ? MediaQuery.of(context).size.width * .3
                            : MediaQuery.of(context).size.width * .8,
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      )),
                  SizedBox(width:size.width*.20 ,height: 10,),

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child: Container(
                        height: 50,
                        width: kIsWeb && MediaQuery.of(context).size.width > 400
                            ? MediaQuery.of(context).size.width * .3
                            : MediaQuery.of(context).size.width * .8,
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ))                ],
              ),
              SizedBox(),
              !widget.iscaller!? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child:  Container(
                        height: 60,width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.0),

                        ),
                      ))

                  ,

                  SizedBox(width:size.width*.20 ,height: 10,),
                  Shimmer.fromColors(
                      period: Duration(milliseconds: 800),
                      baseColor: Colors.grey.withOpacity(0.6),
                      highlightColor: Colors.black.withOpacity(0.6),
                      child:  Container(
                        height: 60,width: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(30.0),

                        ),
                      )),
                  SizedBox(width:size.width*.20 ,height: 10,),

                ],
              ):widget.iscaller!?                   Shimmer.fromColors(
                  period: Duration(milliseconds: 800),
                  baseColor: Colors.grey.withOpacity(0.6),
                  highlightColor: Colors.black.withOpacity(0.6),
                  child:  Container(
                    height: 60,width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30.0),

                    ),
                  )) :Container(),

            ],) ,)






          ,)

      ],

    ) ;
  }

  Widget toggleSpeakerWidget(){
    return  InkWell(onTap: (){
      if(Speaker){
        _signaling!.trunOnoFFSpeaker();
        Speaker=false;
      }else{
        _signaling!.trunonOnSpeaker();
        Speaker=true;
      }

      setState(() {

      });
    },
      child:  Container(
        width: 50,height: 50,
        decoration: decoration(),
        child: Center(
          child: Image.asset(
            Speaker?'assets/call/speaker_open.png':'assets/call/mute.png',
            width: 30,
            height: 30,
          ),
        ),
      ),
      /*Container(
        decoration:decoration(),
        child: Center(
          child: Image.asset(
            'assets/call/videocam@3x.png',
            width: 40,
            height: 40,
          ),
        ),
      ),*/
    );
  }

  Widget text(String text,double size,Color color,FontWeight weight){
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily:"Ithra",// 'Montserrat',
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }
  Widget refuseWidget(){
    return  InkWell(onTap: (){
      print("kkkkkkkkkkkkkk");
      //  audioPlayer.stop();
      _reject();
      stopForegroundService();
      Navigator.pop(context);

    }, child:
    Container(
      height: 60,width: 100,
      decoration: BoxDecoration(
        color: Color.fromRGBO(234, 33, 33,1),
        borderRadius: BorderRadius.circular(30.0),

      ),
      child: Center(
        child: Image.asset(
          'assets/call/md-call@3x.png',
          width: 40,
          height: 40,
        ),
      ),
    ),
    );
  }
  Widget acceptWidget(){
    return  InkWell(onTap: (){
      _accept();
      setState(() {
        _inCalling = true;
      });
    },
      child: Container(
        height: 60,width: 100,
        decoration: BoxDecoration(
          color: Color.fromRGBO( 1 ,199 ,21,1),
          borderRadius: BorderRadius.circular(30.0),

        ),
        child: Center(
          child: Image.asset(
            'assets/call/md-call1@3x.png',
            width: 25,
            height: 25,
          ),
        ),
      ),
    );
  }
  Widget closeWidget(){
    return  InkWell(onTap: (){
      print("kkkkkkkkkkkkkk");
      //  audioPlayer.stop();
      _reject();
      if(WebRTC.platformIsAndroid)
        stopForegroundService();
      Wakelock.disable();
      Navigator.pop(context);

    }, child:
    Container(
      height: 40,width: 200,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20.0),

      ),
      child: Center(
        child: text(getTranslated(context, "Ok"),15,Colors.white,FontWeight.w300),
      ),
    ),
    );
  }
  Widget endCallWidget(){
    return  InkWell(onTap: (){

      _hangUp();

    },
      child:  Container(
        height: 60,width: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromRGBO(234, 33, 33,1),
          // borderRadius: BorderRadius.circular(30.0),

        ),
        child: Center(
          child: Image.asset(
            'assets/call/md-call@3x.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }
  Widget switchCameraWidget(){
    return  InkWell(onTap: (){
      _switchCamera();
    },
      child:  Container(
        width: 50,height: 50,
        decoration:decoration(),
        child: Center(
          child: Image.asset(
            'assets/call/flip_camera_android-24px@3x.png',
            width: 25,
            height: 25,
          ),
        ),
      ),
    );
  }
  Widget micWidget(){
    return  InkWell(onTap: (){
      _muteMic();
    },
      child:  Container(
        width: 50,height: 50,
        decoration:decoration(),
        child: Center(
          child: Image.asset(
            mic?'assets/call/mic-fill@3x.png': 'assets/call/mic-mute-fill@3x.png',
            width: 15,
            height: 25,
          ),
        ),
      ),
    );
  }
  // Widget whiteboardWidget(){
  //   return  InkWell(onTap: (){
  //     Future(() =>
  //         Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
  //             WhiteBoard(signaling: _signaling,dataChannel: _dataChannel,))));
  //   },
  //     child:  Container(
  //       width: 50,height: 50,
  //       decoration: decoration(),
  //       child: Center(
  //         child: Image.asset('assets/call/note-edit-line@3x.png',
  //           width: 24,
  //           height: 14,
  //         ),
  //       ),
  //     ),
  //     /*Container(
  //       decoration:decoration(),
  //       child: Center(
  //         child: Image.asset(
  //           'assets/call/videocam@3x.png',
  //           width: 40,
  //           height: 40,
  //         ),
  //       ),
  //     ),*/
  //   );
  // }
  shareScreenWidget(BuildContext context){
    return  InkWell(onTap: (){
      selectScreenSourceDialog(context);
    },
      child:  Container(
        width: 50,height: 50,
        decoration:decoration(),
        child: Center(
          child: Image.asset(
            startRecord?'assets/call/record-circle@3x.png':'assets/call/Icon feather-share@3x.png',
            width: 16,
            height: 20,
          ),
        ),
      ),
    );
  }
  Widget toggleCameraWidget(){
    return  InkWell(onTap: (){
      _muteCamera();
    },
      child:  Container(
        width: 50,height: 50,
        decoration: decoration(),
        child: Center(
          child: Image.asset(
            camera?'assets/call/videocam@3x.png':'assets/call/videocam-off@3x.png',
            width: 24,
            height: 14,
          ),
        ),
      ),
      /*Container(
        decoration:decoration(),
        child: Center(
          child: Image.asset(
            'assets/call/videocam@3x.png',
            width: 40,
            height: 40,
          ),
        ),
      ),*/
    );
  }
  Widget headerWidget(param0){
    return   Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            text("$param0",17,Colors.white,FontWeight.w600),
            TweenAnimationBuilder<Duration>(
                duration: Duration(minutes: 60),
                tween: Tween(
                    begin: Duration(minutes: 60),
                    end: Duration.zero),
                onEnd: () {
                  print('Timer ended');
                  _hangUp();
                },
                builder: (BuildContext context, Duration value,
                    Widget? child) {
                  minutes = value.inMinutes;
                  seconds = value.inSeconds % 60;
                  return   text('$minutes:$seconds',16,minutes <= 5
                      ? Colors.red
                      : Colors.white,FontWeight.w300);
                }),
          ],
        ),
        SizedBox(width: 5,),
        /* Container(
          width: 50,height: 50,
          decoration:BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: Border.all(color: Color.fromRGBO(211, 211 ,211,1), width: .5),
          *//*gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromRGBO(255, 255, 255, 0),
                    Color.fromRGBO(0, 0, 0, 1),
                  ],
                )*//*
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset(
              'assets/call/Icon feather-arrow-left@3x.png',
              width: 18,
              height: 18,
            ),
          ),
        ),*/
      ],
    );
  }
  BoxDecoration decoration(){
    return  BoxDecoration(
        shape: BoxShape.circle,
        //color: Color.fromRGBO(255, 255, 255,.42),
        border: Border.all(color: Color.fromRGBO(211, 211 ,211,1), width: .5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, .5),
            Color.fromRGBO(0, 0, 0, 1),
          ],
        )
    );
  }
  endWidget(String _text){return
    Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: const Color(0x33ae9cce),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                      spreadRadius: 0)
                ],
                color: Colors.white,
                border: Border.all(
                  width: 6,
                  color: Colors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/applicationIcons/whiteLogo.png',
                width: 65,
                height: 65,
              )
          ),
          SizedBox(height: size.height*.15,),
          Center(child: text(getTranslated(context, _text),13,Color.fromRGBO(32, 32 ,32,1),FontWeight.w500)),
          SizedBox(height: size.height*.15,),
          Center(child: closeWidget())
        ],
      ),
    );}
}
