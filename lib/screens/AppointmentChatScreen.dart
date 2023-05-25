
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:intl/intl.dart' as intl;
import 'package:http/http.dart' as http;

import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/colorsFile.dart';
import '../providers/user_data_provider.dart';
import '../widget/rocordingWidget.dart';
import 'AgoraScreen.dart';

var image;
File? selectedProfileImage;

class AppointmentChatScreen extends StatefulWidget {
  final AppAppointments appointment;

  final GroceryUser user;

  const AppointmentChatScreen({required this.appointment, required this.user});

  @override
  _AppointmentChatScreenState createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false, checkAgora = false, uploadVideo = false;
  late bool isShowSticker,
      answered = false,
      done = true,
      endingCall = false,
      haveCall = false;
  late String imageUrl;
  var stCollection = 'messages', theme;
  ValueNotifier<String> text = ValueNotifier("");
  late AccountBloc accountBloc;
  final TextEditingController textEditingController = new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool checkCall = false;
  final FocusNode focusNode = new FocusNode();
  bool loadingCall = false;
  late DocumentReference reference;
  late Size size;
  @override
  void initState() {
    super.initState();
    loading = false;
    reference = FirebaseFirestore.instance
        .collection('AppAppointments')
        .doc(widget.appointment.appointmentId);
    checkStatus();
    focusNode.addListener(onFocusChange);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    userReadHisMessage(widget.user.userType!);
  }
  Future<void> checkStatus() async {
    reference.snapshots().listen((querySnapshot) {
      setState(() {
        checkCall = querySnapshot.get("allowCall");
      });
      print("fffffcheckCall");
      print(checkCall);
    });
  }
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "CONSULTANT")
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': 0,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': 0,
        }, SetOptions(merge: true));
    } catch (e) {
      print("cccccc" + e.toString());
    }
  }
  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    print("orderdata");
    print(widget.appointment.orderId);
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Image.asset(
                            getTranslated(context, "arrow"),
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.user.userType == "USER"
                            ? widget.appointment.consult.name
                            : widget.appointment.user.name,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                        style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 16.0,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    (widget.user.userType == "CONSULTANT" &&
                            widget.appointment.consultType == "voice" &&
                            widget.appointment.appointmentStatus == "open")
                        ? loadingCall
                            ? CircularProgressIndicator()
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.5),
                                    onTap: () {
                                      agoraCall();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      width: 60.0,
                                      height: 60.0,
                                      child: Icon(
                                        Icons.wifi_calling,
                                        color: AppColors.pink,
                                        size: 24.0,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                        : SizedBox(),
                    (widget.user.userType == "USER" &&
                            widget.appointment.consultType == "voice" &&
                            widget.appointment.appointmentStatus == "open")
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                splashColor: Colors.white.withOpacity(0.5),
                                onTap: () async {
                                  DocumentReference docRef2 = FirebaseFirestore
                                      .instance
                                      .collection(Paths.appAppointments)
                                      .doc(widget.appointment.appointmentId);
                                  final DocumentSnapshot documentSnapshot2 =
                                      await docRef2.get();
                                  if (AppAppointments.fromMap(documentSnapshot2.data() as Map).allowCall)
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AgoraScreen(
                                            appointment: widget.appointment,
                                            user: widget.user,
                                            appointmentId: widget
                                                .appointment.appointmentId,
                                            consultName: widget
                                                .appointment.consult.name,
                                        ),
                                      ),
                                    );
                                  else
                                    Fluttertoast.showToast(
                                      msg: getTranslated(
                                          context, "callNotStart"),
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 5,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: 50.0,
                                  height: 50.0,
                                  child: checkCall
                                      ? Image.asset(
                                          'assets/applicationIcons/call_1.gif',width: 50,height: 50,)
                                      : Icon(
                                          Icons.wifi_calling,
                                          color: Colors.grey,
                                          size: 24.0,
                                        ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: 2,
                  width: size.width * .9)),
          SizedBox(
            height: 10,
          ),
          widget.user.userType == "CONSULTANT"
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    endingCall
                        ? CircularProgressIndicator()
                        : Checkbox(
                            value: answered,
                            onChanged: (value) {
                              setState(() {
                                answered = !answered;
                                if (answered) {
                                  callDone();
                                  // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
                                }
                              });
                            },
                          ),
                    Text(
                      getTranslated(context, "closeAppointment"),
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                refreshChangeListener.refreshed = true;
              },
              child: StreamBuilder(
                stream:UserDataProvider.realtimeDbRef.child(
                    'appointmentsChatMessage/${widget.appointment.appointmentId}')
                    .orderByChild('messageTime')
                    .onValue,
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.data == null || !snapshot.hasData) {
                    return Center(
                      child: Text(getTranslated(context, "sendFirstMessage")),
                    );
                  } else if ((snapshot.data!).snapshot.value == null) {
                    return Center(
                      child: Text(getTranslated(context, "sendFirstMessage")),
                    );
                  } else {
                    List<dynamic> messages = Map<String, dynamic>.from(
                        (snapshot.data!).snapshot.value
                        as Map<dynamic, dynamic>)
                        .values
                        .toList()
                      ..sort((a, b) => a['messageTime'].compareTo(b['messageTime']));

                    messages=messages.reversed.toList();
                    return ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      padding: EdgeInsets.zero,
                      controller: listScrollController,
                      itemCount: messages.length,
                      itemBuilder: (ctx, index) => AppointChatMessageItem(
                          message: SupportMessage.fromDatabase(  Map<String, dynamic>.from(messages[index]),),
                          user: widget.user
                      ),
                    );
                  }
                },
              ),
            ),),
          widget.appointment.appointmentStatus != "closed"
              ? buildInput(size)
              : SizedBox(),
        ],
      ),
    );
  }

  agoraCall() async {
    setState(() {
      loadingCall = true;
    });
    if (widget.user.userType == "CONSULTANT")
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .set({
        'allowCall': true,
      }, SetOptions(merge: true));
    //sendCallNotification(widget.appointment.consult.name,widget.appointment.user.uid,widget.appointment.appointmentId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgoraScreen(
            appointment: widget.appointment,
            user: widget.user,
            appointmentId: widget.appointment.appointmentId,
            consultName: widget.appointment.consult.name),
      ),
    );
    setState(() {
      loadingCall = false;
    });
  }
  Widget buildInput(Size size) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image,color: AppColors.pink,),
                onPressed: () => cropImage(context),
                color: theme == "light"
                    ? Theme.of(context).primaryColor
                    : Colors.black,
              ),
            ),
            color: Colors.white,
          ),
          // Button send video
          uploadVideo
              ? Container(
            height: 25,
              width: 25,
              child: CircularProgressIndicator(),
          )
              : Material(
                  child: new Container(
                    margin: new EdgeInsets.symmetric(horizontal: 1.0),
                    child: new IconButton(
                      icon: new Icon(Icons.video_camera_front_outlined,color: AppColors.pink,),
                      onPressed: () => uploadToStorage(context),
                      color: theme == "light"
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                    ),
                  ),
                  color: Colors.white,
                ),
          //record button
          AudioRecorder(
            loggedId: widget.user.uid!,
            onSendMessage: onSendMessage,
            focusNode: focusNode,
          ),

          // Edit text
          Flexible(
            child: Container(
              child: ValueListenableBuilder<String>(
                valueListenable: text,
                builder: (context, value, child) => Directionality(
                  textDirection: intl.Bidi.detectRtlDirectionality(text.value)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: TextField(
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(
                        color: theme == "light"
                            ? Theme.of(context).primaryColor
                            : Colors.black,
                        fontSize: 15.0),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: getTranslated(context, "typeMessage"),
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    focusNode: focusNode,
                    onChanged: (str) {
                      text.value = str;
                    },
                  ),
                ),
              ),
            ),
          ),

          // Button send message
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 8.0),
              child: loading
                  ? Center(child: CircularProgressIndicator())
                  : Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor,
                      ),
                      child: Center(
                        child: new IconButton(
                          icon: new Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 15,
                          ),
                          onPressed: () =>
                              onSendMessage(
                              textEditingController.text,
                              "text",
                                size,
                          ),
                          color: theme == "light"
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                      ),
                    ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
    );
  }
  Future<void> onSendMessage(String content, String type, Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId = Uuid().v4();
    print("appointmentsChatMessage/${widget.appointment.appointmentId}/$messageId");
      await UserDataProvider.realtimeDbRef
          .child(
          "appointmentsChatMessage/${widget.appointment.appointmentId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'appointmentId': widget.appointment.appointmentId,
      });

      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      if (widget.user.userType == "CONSULTANT") {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.user.uid, data);
      } else {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.consult.uid, data);
      }

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }
  Future<void> callDone() async {
    try {
      setState(() {
        endingCall = true;
      });
      //closeAppointment
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .update({
        'appointmentStatus': "closed",
        'allowCall': false,
        'closedUtcTime': DateTime.now().toUtc().toString(),
        'closedDate': {
          'day': DateTime.now().toUtc().day,
          'month': DateTime.now().toUtc().month,
          'year': DateTime.now().toUtc().year,
        },
      });

      //closing
      setState(() {
        endingCall = false;
      });
      Navigator.pop(context);
    } catch (e) {
      print("eeeeee" + e.toString());
      errorLog("callDone", e.toString());
    }
  }
  errorLog(String function, String error) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': widget.user == null ? " " : widget.user.phoneNumber,
      'screen': "AppointmentChatScreen",
      'function': function,
    });
  }
  Future<void> sendNotification(String userId, String text) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => "Chat");
      notifMap.putIfAbsent('body', () => text);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      var refundRes = await http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
      /* var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
        print("sendnotification111  error");
      }
      else
      { print("sendnotification1111 success");}*/
    } catch (e) {
      print("sendnotification111  " + e.toString());
    }
  }
  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }
  Future cropImage(context) async {
    setState(() {
      loading = true;
    });
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      uploadImage(croppedFile);
      setState(() {
        selectedProfileImage = croppedFile;
      });
    } else {

    }
  }
  Future uploadImage(File image) async {
    size = MediaQuery.of(context).size;

    var uuid = Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(image);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "image", size);
  }
  Future<void> sendCallNotification( String consultName, String userId, String appointmentId) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('consultName', () => consultName);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent('appointmentId', () => appointmentId);
      var refundRes = await http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/sendCallingNotification'),
        body: notifMap,
      );
      var refund = jsonDecode(refundRes.body);
      if (refund['message'] != 'Success') {
        print("sendnotification111  error");
      } else {
        print("sendnotification1111 success");
      }
    } catch (e) {
      print("sendnotification111  " + e.toString());
    }
  }
  Future uploadToStorage(context) async {
    try {
      setState(() {
        uploadVideo = true;
      });
      final pickedFile = await ImagePicker.platform.pickVideo(source: ImageSource.gallery);
      final file = File(pickedFile!.path);
      var uuid = Uuid().v4();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('files/$uuid');
      await storageReference.putFile(file);
      var url = await storageReference.getDownloadURL();
      onSendMessage(url, "video", size);
    } catch (error) {
      print(error);
    }
  }
}
