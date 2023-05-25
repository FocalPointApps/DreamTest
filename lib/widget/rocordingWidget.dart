
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

typedef _Fn = void Function();
Future<String> _getTempPath(String path) async {
  var tempDir = await getTemporaryDirectory();
  var tempPath = tempDir.path;
  return tempPath + '/' + path;
}

class AudioRecorder extends StatefulWidget {
  final onSendMessage;
  final focusNode;
  final String loggedId;
  const AudioRecorder(
      { this.onSendMessage,
        required this.loggedId,
         this.focusNode});
  @override
  _AudioRecorderState createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  String statusText="";
  bool isComplete = false;
  bool isShowSticker = false;
  bool uploadingRecord = false,recording=false;
  late String recordFilePath;int i=0;
  @override
  void initState() {
    widget.focusNode.addListener(onFocusChange);
    super.initState();
  }

  void onFocusChange() {
    if (widget.focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("uploadingRecord: $uploadingRecord");
    return Center(child:uploadingRecord?CircularProgressIndicator():Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: recording
                    ? Icon(Icons.pause_outlined, color: Colors.red)
                    : Icon(
                  Icons.mic,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () =>recording?stopRecord():startRecord(),//getRecorderFn(),
                color:Theme.of(context).primaryColor,
              ),
            ),
            color: Colors.white,
          ));

  }
  @override
  void dispose() {
    super.dispose();
  }
  _Fn getRecorderFn() {
    /* if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return () {};
    }*/
    return recording ? stopRecord : startRecord;
  }
  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }
  startRecord() async {
    print("startRecord11");
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      print("startRecord11qqq");
      recordFilePath = await getFilePath();
      //isComplete = false;
      setState(() {
        recording=true;
      });
      RecordMp3.instance.start(recordFilePath, (type) {
      });
    } else {
      print("startRecord11vvvvv");
    }

  }
  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test1111_${DateTime.now().millisecondsSinceEpoch.toString()+widget.loggedId}.mp3";
  }
  stopRecord() async {
    print("startRecord11");
    setState(() {
      recording=false;
      uploadingRecord=true;
    });
    bool s = RecordMp3.instance.stop();
    if (s) {
      //statusText = "Record complete";
      //isComplete = true;
      setState(() {});
      if (recordFilePath != null && File(recordFilePath).existsSync()) {
        print("stopRecord000");
        File recordFile = new File(recordFilePath);
        uploadRecord(recordFile);
      }
      else
      {
        print("stopRecord111");
      }
    }
  }
  Future uploadRecord(File voice) async {
    Size size = MediaQuery.of(context).size;
    print("permission uploadRecord1");
    var uuid = Uuid().v4();
    Reference storageReference =firebase_storage.FirebaseStorage.instance.ref().child('audio/$uuid');
    await storageReference.putFile(voice);
    var url = await storageReference.getDownloadURL();
    print("recording file222");
    print(url);
    widget.onSendMessage(url, "voice", size);
    setState(() {
      uploadingRecord = false;
    });

  }

}
