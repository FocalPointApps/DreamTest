import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../Utils/screen_select_dialog.dart';
import '../../Utils/random_string.dart';

import '../../Utils/device_info.dart'
if (dart.library.js) '../../Utils/device_info_web.dart';
import '../../config/paths.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
// import '../../Utils/turn.dart'
// if (dart.library.js) '../utils/turn_web.dart';

enum SignalingState {
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

enum permissionsState_enum {
  micdined,
  cameradined,
}
enum call_State{
  anotherCall,
  calling,
  refusd,
  closed,
  inCall

}


enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
  callStartCall,
}

enum VideoSource {
  Camera,
  Screen,
}

class Session {
  Session({required this.sid, required this.pid});
  String pid;
  String sid;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class Signaling {
  Signaling(this._host,this.isVideoCall, this._context,this.CallerId,this.ReciverId);


  JsonEncoder _encoder = JsonEncoder();
  JsonDecoder _decoder = JsonDecoder();
  // String _selfId = randomNumeric(6);
  bool isVideoCall=true;
  String _selfId = FirebaseAuth.instance.currentUser!.uid;
  BuildContext? _context;
  String CallerId='';
  String ReciverId="";

  RTCDataChannel? _dataChannel;
  Function (call_State)? checkCallState ;


  var _host;
  var _port = 8086;
  final StreamController<GroceryUser?> getclint =  StreamController<GroceryUser?>();
  final StreamController<GroceryUser?> getclint2 =  StreamController<GroceryUser?>();
  // final StreamController<GroceryUser?> getclint3 =  StreamController<GroceryUser?>.broadcast(sync: true);
  // final StreamController<GroceryUser?> getclint4 =  StreamController<GroceryUser?>.broadcast(sync: true);

  final StreamController<GroceryUser?> getmyData =  StreamController<GroceryUser?>();
  final StreamController<GroceryUser?> getmyData2 =  StreamController<GroceryUser?>();
  // final StreamController<GroceryUser?> getmyData3 =  StreamController<GroceryUser?>();
  // final StreamController<GroceryUser?> getmyData4 =  StreamController<GroceryUser?>();


  final StreamController<String?> getuserState =  StreamController<String?>();


  var _turnCredential;
  Map<String, Session> _sessions = {};
  MediaStream? _localStream;

  GroceryUser? myInfo;

  GroceryUser? peerInfo;

  List<MediaStream> _remoteStreams = <MediaStream>[];
  List<RTCRtpSender> _senders = <RTCRtpSender>[];
  VideoSource _videoSource = VideoSource.Camera;

  Function(SignalingState state)? onSignalingStateChange;

  Function(permissionsState_enum state)? permissionsState;

  Function(Session session, CallState state)? onCallStateChange;

  Function(MediaStream stream,bool isvideo)? onLocalStream;

  Function(bool isvideo)? onEnableLocalVideo;

  Function(Session session, MediaStream stream,bool isVideo)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;


  Function(dynamic event)? onPeersUpdate;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
  onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  String get sdpSemantics => 'unified-plan';

  Map<String, dynamic> _iceServers = {
    'iceServers': [
      // {'url': 'stun:stun.l.google.com:19302'},
      {
        'url': 'turn:relay1.expressturn.com:3478',
        'username': 'efUYLDP5TS63B4NXUI',
        'credential': 'DFTRoUiKJ3CoDbGt'
      },
      {'url': 'stun:stun.l.google.com:19302'},
      {'url': 'stun:stun1.l.google.com:19302'},
      {'url': 'stun:stun2.l.google.com:19302'},
      {'url': 'stun:stun3.l.google.com:19302'},
      {'url': 'stun:stun4.l.google.com:19302'},


      {
        'url': 'turn:34.122.107.197:19302',

      },

      // {
      //   'url': 'turn:34.122.107.197:3478',
      //   'username': 'hoksh',
      //   'credential': '0127287824'
      // },

    ]
  };

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  close() async {
    await _cleanSessions();
  }

  void switchCamera() {
    if (_localStream != null) {
      if (_videoSource != VideoSource.Camera) {
        _senders.forEach((sender) {
          if (sender.track!.kind == 'video') {
            sender.replaceTrack(_localStream!.getVideoTracks()[0]);
          }
        });
        _videoSource = VideoSource.Camera;
        onLocalStream?.call(_localStream!,true);
      } else {
        Helper.switchCamera(_localStream!.getVideoTracks()[0]);
      }
    }
  }


  Future<AppAppointments> getUsersInfo(String appontmentid ) async {

    DocumentSnapshot<Map<String, dynamic>> appontmentDoc =  await FirebaseFirestore.instance
        .collection(Paths.appAppointments).doc(appontmentid).get();


    AppAppointments Appointment=   AppAppointments.fromMap(
        appontmentDoc.data() as Map);








    return Appointment;
  }
  void switchToScreenSharing(MediaStream stream) {
    if (_localStream != null && _videoSource != VideoSource.Screen) {
      _senders.forEach((sender) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      });
      onLocalStream?.call(stream,true);
      _videoSource = VideoSource.Screen;
    }
  }
  void switchToAudioOnly(MediaStream stream) {
    if (_localStream != null && _videoSource != VideoSource.Camera) {
      _senders.forEach((sender) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getAudioTracks()[0]);
        }
      });
      onLocalStream?.call(stream,true);
      _videoSource = VideoSource.Screen;
    }
  }
  void muteMic() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
    }
  }

  void mutecamera() {
    if (_localStream != null) {
      bool enabled = _localStream!.getVideoTracks()[0].enabled;



      _localStream!.getVideoTracks()[0].enabled = !enabled;

      onEnableLocalVideo?.call(_localStream!.getVideoTracks()[0].enabled);

      //data?.send(RTCDataChannelMessage(text));

    }
  }

  void invite(String peerId, String media, bool useScreen, bool isVideo) async {



    print("selfffs$peerId");
    String sesssis = randomNumeric(20);

    //   var sessionId = _selfId + '-' + peerId;
    var sessionId =sesssis;

    // var sessionId =_host;

    try{
      Session session = await _createSession(null,
          peerId: peerId,
          sessionId: sessionId,
          media: media,
          screenSharing: useScreen,isVideo: isVideo);


      print( "sweretre${session.pid}" );

      _sessions[sessionId] = session;
      if (media == 'data') {
        _createDataChannel(session);

      }
      if(session!=null)
      {

        _createDataChannel(session);


        _createOffer(session, media,isVideo);


      }





      onCallStateChange?.call(session, CallState.CallStateNew);
      onCallStateChange?.call(session, CallState.CallStateInvite);

    }catch (e){

    }


  }

  void bye(String sessionId) {
    _send('bye', {
      'session_id': sessionId,
      'from': _selfId,
    });
    var sess = _sessions[sessionId];
    if (sess != null) {
      _closeSession(sess);
      FirebaseDatabase.instance.ref('userCallState').child(peerInfo!.uid!).child('callState').set('closed');
      FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid!).child('callState').set('closed');

    }
  }

  void accept(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    _createAnswer(session, 'video');
  }

  void reject(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  void onMessage(message) async {
    Map<String, dynamic> mapData = message;

    print("mapdata${mapData}");

    var data=mapData['data'];

    switch (mapData['type']) {
      case 'peers':
        {
          List peers =data ;
// data.forEach((key, value) =>  print("sasas$value"));



          if (onPeersUpdate != null) {
            Map<String, dynamic> event = Map<String, dynamic>();
            event['self'] = _selfId;
            event['peers'] = peers;
            onPeersUpdate?.call(event);
          }
        }
        break;
      case 'offer':
        {
          var peerId = data['from'];
          var description = data['description'];
          var media = data['media'];
          var isVideo=data['isVideo'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          var newSession = await _createSession(session,
              peerId: peerId,
              sessionId: sessionId,
              media: media,
              screenSharing: false,isVideo: isVideo);
          _sessions[sessionId] = newSession;
          await newSession.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          await _createAnswer(newSession, media);

          if (newSession.remoteCandidates.length > 0) {
            newSession.remoteCandidates.forEach((candidate) async {
              await newSession.pc?.addCandidate(candidate);
            });
            newSession.remoteCandidates.clear();
          }
          // AppAppointments appointments=await getUsersInfo(_host);
          // String reciverid;
          //
          // if(appointments.consult.uid==FirebaseAuth.instance.currentUser!.uid)
          // {
          //
          //   reciverid=appointments.user.uid!;
          //
          //
          // }
          // else{
          //   reciverid=appointments.consult.uid!;
          //
          // }
          // var ref = FirebaseFirestore.instance.collection(Paths.usersPath).doc(reciverid).withConverter(
          //   fromFirestore: GroceryUser.fromFirestore,
          //   toFirestore: (GroceryUser user, _) => user.toFirestore(), );
          // final docSnap = await ref.get();
          // Caller = docSnap.data();

          print("CallStateRingingsss");
          onCallStateChange?.call(newSession, CallState.CallStateNew);
          onCallStateChange?.call(newSession, CallState.CallStateRinging);
        }
        break;
      case 'answer':
        {
          var description = data['description'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          print("sasadasd${description['sdp']}");
          session?.pc?.setRemoteDescription(
              RTCSessionDescription(description['sdp'], description['type']));
          onCallStateChange?.call(session!, CallState.CallStateConnected);
        }
        break;
      case 'candidate':
        {
          var peerId = data['from'];
          var candidateMap = data['candidate'];
          var sessionId = data['session_id'];
          var session = _sessions[sessionId];
          RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[sessionId] = Session(pid: peerId, sid: sessionId)
              ..remoteCandidates.add(candidate);
          }
        }
        break;
      case 'leave':
        {
          var peerId = data as String;
          _closeSessionByPeerId(peerId);
        }
        break;
      case 'bye':
        {
          var sessionId = data['session_id'];
          print('bye: ' + sessionId);
          var session = _sessions.remove(sessionId);
          if (session != null) {
            onCallStateChange?.call(session, CallState.CallStateBye);
            _closeSession(session);
          }
        }
        break;
      case 'keepalive':
        {
          print('keepalive response!');
        }
        break;
      default:
        break;
    }
  }

  Future<void> connect(bool isnormalCall) async {
    var url = 'https://$_host:$_port/ws';
    //  _socket = SimpleWebSocket(url);

    print('connect to $url');

    // if (_turnCredential == null) {
    try {
      //  _turnCredential = await getTurnCredential(_host, _port);
      /*{
            "username": "1584195784:mbzrxpgjys",
            "password": "isyl6FF6nqMTB9/ig5MrMRUXqZg",
            "ttl": 86400,
            "uris": ["turn:127.0.0.1:19302?transport=udp"]
          }
        */
      _iceServers = {
        "iceServers": [

          // {"url": "stun:stun1.l.google.com:19302"},
          // {"url": "stun:stun2.l.google.com:19302"},
          // {"url": "stun:stun3.l.google.com:19302"},
          // {"url": "stun:stun4.l.google.com:19302"},
          // {"url": "stun:stun.voipbuster.com"},
          // {
          //   'url': 'turn:34.122.107.197:3478',
          //   'username': 'hoksh',
          //   'credential': '0127287824'
          // },

          {
            'url': 'turn:relay1.expressturn.com:3478',
            'username': 'efUYLDP5TS63B4NXUI',
            'credential': 'DFTRoUiKJ3CoDbGt'
          },
          {"url": "stun:stun1.l.google.com:19302"},
          {"url": "stun:stun2.l.google.com:19302"},
          {"url": "stun:stun3.l.google.com:19302"},
          {"url": "stun:stun4.l.google.com:19302"},
          {"url": "stun:stun.voipbuster.com"},
        ]
      };
    } catch (e) {}
    //  }



    onSignalingStateChange?.call(SignalingState.ConnectionOpen);


    // AppAppointments appointments=await getUsersInfo(_host);

    String _reciverId='';

    if(CallerId==FirebaseAuth.instance.currentUser!.uid){
      _reciverId=ReciverId;
    }else{
      _reciverId=CallerId;

    }

    var ref = FirebaseFirestore.instance.collection(Paths.usersPath).doc(_reciverId).withConverter(
      fromFirestore: GroceryUser.fromFirestore,
      toFirestore: (GroceryUser user, _) => user.toFirestore(), );
    final docSnap = await ref.get();
    peerInfo = docSnap.data();
    getclint.sink.add(peerInfo);
    getclint2.sink.add(peerInfo);
    // getclint3.add(peerInfo);
    // getclint3.sink.add(peerInfo);
    //
    //       getclint4.sink.add(peerInfo);


    var refMydata = FirebaseFirestore.instance.collection(Paths.usersPath).doc(_reciverId).withConverter(
      fromFirestore: GroceryUser.fromFirestore,
      toFirestore: (GroceryUser user, _) => user.toFirestore(), );
    final docSnaprefMydata = await refMydata.get();
    myInfo = docSnaprefMydata.data();
    getmyData.sink.add(myInfo);
    getmyData2.sink.add(myInfo);
    // getmyData3.sink.add(myInfo);
    // getmyData4.sink.add(myInfo);


    trigerCallState();


















    FirebaseDatabase.instance.ref('signaling').child(_host).child("message").child('peers').child(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'data': {
        'name': DeviceInfo.label,
        'id': _selfId,
        'user_agent': DeviceInfo.userAgent
      }});

    // _socket?.onOpen = () {
    //   print('onOpen');
    //   onSignalingStateChange?.call(SignalingState.ConnectionOpen);
    //   _send('new', {
    //     'name': DeviceInfo.label,
    //     'id': _selfId,
    //     'user_agent': DeviceInfo.userAgent
    //   });
    // };

    FirebaseDatabase.instance.ref('signaling').child(_host).child("message").child('candidate').onValue.listen((event) async {
      if(!event.snapshot.exists){
        return;
      }

      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);

      var data=value['data'];
      var peerId = data['from'];

      if(peerId!=_selfId){
        onMessage(value);

      }






    });

    FirebaseDatabase.instance.ref('signaling').child(_host).child("message").child('offer').onValue.listen((event) async {

      if(!event.snapshot.exists){
        return;
      }
      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);

      var data=value['data'];
      var peerId = data['from'];






      if(peerId!=_selfId){
        print("sadasdasdsadasd${peerId}");

        onMessage(value);



      }

    });

    FirebaseDatabase.instance.ref('signaling').child(_host).child("message").child('answer').onValue.listen((event) {
      if(!event.snapshot.exists){
        return;
      }
      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);

      print("valueanswer$value");

      var data=value['data'];
      var peerId = data['from'];


      if(peerId!=_selfId){
        onMessage(value);

      }

    });

//     FirebaseDatabase.instance.ref('signaling').child(_host).child("message").child('peers').onValue.listen((event) {
//       if(!event.snapshot.exists){
//         return;
//       }
//       Map<String ,dynamic> data= Map<String ,dynamic>();
//       List listpeer=[];
//       event.snapshot.children.forEach((e) {
//       var value = Map<String, dynamic>.from(
//       e.value! as Map<Object?, Object?>);
//   print('hokshvalue$value');
//   listpeer.add(Map<String, dynamic>.from(
//       value['data']! as Map<Object?, Object?>) );
// });
//
//       data.addAll({
//         "type":'peers',
//         'data':listpeer
//       });
//
//       onMessage(data);
//
//
//
//
//
//
//
//
//
//     });



    // _socket?.onMessage = (message) {
    //   print('Received data: ' + message);
    //   onMessage(_decoder.convert(message));
    // };

    FirebaseDatabase.instance.ref('signaling').child(_host).child("message").onDisconnect().remove().then((value) {
      onSignalingStateChange?.call(SignalingState.ConnectionClosed);

      // FirebaseFirestore.instance.collection("AppAppointmentsCall").doc(
      //     _host).set({      'callState':'closed',
      //
      // },SetOptions(merge: true));




    }
    );

    // onCallStateChange?.call(Session(sid: _selfId, pid:'' ),CallState.callStartCall);


    // _socket?.onClose = (int? code, String? reason) {
    //   print('Closed by server [$code => $reason]!');
    //   onSignalingStateChange?.call(SignalingState.ConnectionClosed);
    // };

    // await _socket?.connect();
  }

  Future<MediaStream> createStream(String media, bool userScreen,bool ? isVideo,
      {BuildContext? context}) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': userScreen ? false : true,
      'video': userScreen
          ? true
          : isVideoCall? {
        'mandatory': {
          'minWidth':
          '640', // Provide your own width, height and frame rate here
          'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }:false
    };
    late MediaStream stream;
    if (userScreen) {
      if (WebRTC.platformIsDesktop) {
        final source = await showDialog<DesktopCapturerSource>(
          context: context!,
          builder: (context) => ScreenSelectDialog(),
        );
        stream = await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
          'video': source == null
              ? true
              : {
            'deviceId': {'exact': source.id},
            'mandatory': {'frameRate': 30.0}
          }
        });
      } else {
        stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      }
    } else {
      try{

        print(mediaConstraints);



        stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);





      }



      catch( e){
        permissionsState?.call(permissionsState_enum.cameradined);
        permissionsState?.call(permissionsState_enum.micdined);


        print('sdasdsadsa${e.runtimeType}');
      }

      // var cameraStatus = await Permission.camera.status;
      // var MicStatus = await Permission.microphone.status;
      //
      //
      // if (cameraStatus.isDenied) {
      //   permissionsState?.call(permissionsState_enum.cameradined);
      //   print('isDeniedisDeniedcamera');
      //
      // }else if(MicStatus.isDenied){
      //
      //   permissionsState?.call(permissionsState_enum.micdined);
      //
      //   print('isDeniedisDeniedmic');
      //
      //
      // }


    }



    onLocalStream?.call(stream,isVideo!);
    return stream;
  }

  Future<Session> _createSession(
      Session? session, {
        required String peerId,
        required String sessionId,
        required String media,
        required bool screenSharing,
        required bool isVideo,
      }) async {
    var newSession = session ?? Session(sid: sessionId, pid: peerId);




    if (media != 'data')
    {

      _localStream =
      await createStream(media, screenSharing,isVideo, context: _context);

    }

    if(!isVideo){

      mutecamera();
    }



    print(_iceServers);
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    if (media != 'data') {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            onAddRemoteStream?.call(newSession, stream,isVideo);
            _remoteStreams.add(stream);
          };
          await pc.addStream(_localStream!);

          // _localStream!.getVideoTracks()[0].onMute=(){
          //
          //   print("xcxcxcxcxc");
          // };
          break;
        case 'unified-plan':
        // Unified-Plan
          pc.onTrack = (event) {

            if (event.track.kind == 'video') {
              onAddRemoteStream?.call(newSession, event.streams[0],isVideo);

            }
          };
          _localStream!.getTracks().forEach((track) async {

            _senders.add(await pc.addTrack(track, _localStream!));
          });


          break;
      }

      // Unified-Plan: Simuclast
      /*
      await pc.addTransceiver(
        track: _localStream.getAudioTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly, streams: [_localStream]),
      );

      await pc.addTransceiver(
        track: _localStream.getVideoTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            streams: [
              _localStream
            ],
            sendEncodings: [
              RTCRtpEncoding(rid: 'f', active: true),
              RTCRtpEncoding(
                rid: 'h',
                active: true,
                scaleResolutionDownBy: 2.0,
                maxBitrate: 150000,
              ),
              RTCRtpEncoding(
                rid: 'q',
                active: true,
                scaleResolutionDownBy: 4.0,
                maxBitrate: 100000,
              ),
            ]),
      );*/
      /*
        var sender = pc.getSenders().find(s => s.track.kind == "video");
        var parameters = sender.getParameters();
        if(!parameters)
          parameters = {};
        parameters.encodings = [
          { rid: "h", active: true, maxBitrate: 900000 },
          { rid: "m", active: true, maxBitrate: 300000, scaleResolutionDownBy: 2 },
          { rid: "l", active: true, maxBitrate: 100000, scaleResolutionDownBy: 4 }
        ];
        sender.setParameters(parameters);
      */
    }
    pc.onIceCandidate = (candidate) async {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      // This delay is needed to allow enough time to try an ICE candidate
      // before skipping to the next one. 1 second is just an heuristic value
      // and should be thoroughly tested in your own environment.
      await Future.delayed(
          const Duration(seconds: 1),
              () => _send('candidate', {
            'to': peerId,
            'from': _selfId,
            'candidate': {
              'sdpMLineIndex': candidate.sdpMLineIndex,
              'sdpMid': candidate.sdpMid,
              'candidate': candidate.candidate,
            },
            'session_id': sessionId,
          }));
    };

    pc.onIceConnectionState = (state) {};

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(newSession, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };

    pc.onDataChannel = (channel) {
      _addDataChannel(newSession, channel);
    };

    newSession.pc = pc;
    return newSession;
  }

  void _addDataChannel(Session session, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage?.call(session, channel, data);
    };
    session.dc = channel;
    onDataChannel?.call(session, channel);
  }

  Future<void> _createDataChannel(Session session,
      {label: 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 30;
    RTCDataChannel channel =
    await session.pc!.createDataChannel(label, dataChannelDict);
    _addDataChannel(session, channel);
  }

  Future<void> _createOffer(Session session, String media, bool isVideo) async {
    try {


      RTCSessionDescription s =
      await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(_fixSdp(s));
      print("sasasasasaxxx${s.type}");


      _send('offer', {
        'to': session.pid,
        'from': _selfId,
        'isVideo':isVideo,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
        'media': media,
      });
    } catch (e) {
      print("sweeetx${e.toString()}");
    }
  }

  RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  trigerCallState(){

    bool fristCalll=true;

    FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!= ReciverId?ReciverId:CallerId).child('callState').onValue.listen((event) {
      if(event.snapshot!=null){

        if(event.snapshot.value=='calling'){
          checkCallState!.call(call_State.calling);
        }
        else if(event.snapshot.value=='refused'){
          checkCallState!.call(call_State.refusd);

        }else if(event.snapshot.value=='closed'){
          checkCallState!.call(call_State.closed);

        }else if(event.snapshot.value=='oncall'){
          checkCallState!.call(call_State.inCall);

        }



      }



    });
  }


  Future<void> _createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s =
      await session.pc!.createAnswer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(_fixSdp(s));

      _send('answer', {
        'to': session.pid,
        'from': _selfId,
        'description': {'sdp': s.sdp, 'type': s.type},
        'session_id': session.sid,
      });
    } catch (e) {
      print(e.toString());
    }
  }

  _send(String event, data) async {
    var request = Map();
    request["type"] = event;
    request["data"] = data;


    switch(event)
    {
      case 'offer':{
        try {
          print("hoksgfgfgfgfgfg${event}");

          FirebaseDatabase.instance.ref('signaling').child(_host).child('message').child(event).set(request);


//           FirebaseFunctions functions = FirebaseFunctions.instance;
//
//           functions.useFunctionsEmulator('127.0.0.1', 5001);
//           //functions("10.0.2.2", 5001);
//
//
// //
//           HttpsCallable callable = functions.httpsCallable("createOffer");
//
//           final res = await callable.call({
//             'offerx': request,
//             'appointmentId': _host,
//             'reciverId': peerInfo!.uid
//           });
//
//           print('rescalloffer${res.data}');
        }
        on FirebaseFunctionsException catch(e){
          print("Sasasa${e.message}");

        }


        catch(e){
          //  print("Sasasa${e}");

        }
        break;
      }
      case 'answer':{

        FirebaseDatabase.instance.ref('signaling').child(_host).child('message').child(event).set(request);

        // FirebaseDatabase.instance.ref('userCallState').child(peerInfo!.uid!).child('callState').set('oncall');
        // FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid!).child('callState').set('oncall');

        break;

      }
      default :{
        FirebaseDatabase.instance.ref('signaling').child(_host).child('message').child(event).set(request);
        break;
      }

    };











    // _socket?.send(_encoder.convert(request));
  }

  void trunonOnSpeaker() {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enableSpeakerphone(true);
    }
  }
  void trunOnoFFSpeaker() {
    if (_localStream != null) {
      _localStream!.getAudioTracks()[0].enableSpeakerphone(false);
    }
  }

  Future<void> _cleanSessions() async {
    if (_localStream != null) {
      _localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localStream!.dispose();
      _localStream = null;
    }
    _sessions.forEach((key, sess) async {
      await sess.pc?.close();
      await sess.dc?.close();
    });
    _sessions.clear();
  }

  void _closeSessionByPeerId(String peerId) {
    var session;
    _sessions.removeWhere((String key, Session sess) {
      var ids = key.split('-');
      session = sess;
      return peerId == ids[0] || peerId == ids[1];
    });
    if (session != null) {
      _closeSession(session);
      onCallStateChange?.call(session, CallState.CallStateBye);
    }
  }

  Future<void> _closeSession(Session session) async {
    _localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    await session.pc?.close();
    await session.dc?.close();
    _senders.clear();
    _videoSource = VideoSource.Camera;
  }



}
