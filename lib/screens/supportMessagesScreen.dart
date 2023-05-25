
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/SupportMessage.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/providers/user_data_provider.dart';
import 'package:grocery_store/widget/AppointChatMessageItem.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:intl/intl.dart' as intl;

import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/colorsFile.dart';
import '../widget/rocordingWidget.dart';

var image;
File? selectedProfileImage;

class SupportMessageScreen extends StatefulWidget {
  final SupportList item;
  final GroceryUser user;

  const SupportMessageScreen({required this.item, required this.user});

  @override
  _SupportMessageScreenState createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
  PaginateRefreshedChangeListener();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false, loadingCall = false, uploadVideo = false;
  String? imageUrl;
  var stCollection = 'messages', theme = "light";
  ValueNotifier<String> text = ValueNotifier("");
  final TextEditingController textEditingController =
  new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool answered = false, done = true, endingCall = false;
  bool checkAgora = false;
  final FocusNode focusNode = new FocusNode();
  String mobileNumber = '..';
  bool isRTL = false,first=true,pending=false;
  late Size size;

  @override
  void initState() {
    super.initState();
    loading = false;
    pending=widget.item.pending!;
    getUserMobileNumber();
    userReadHisMessage(widget.user.userType!);
  }
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }
  getUserMobileNumber() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.item.userUid);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var phone = GroceryUser.fromMap(userSnapshot.data() as Map).phoneNumber;
    setState(() {
      mobileNumber = phone!;
    });
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: endSupport,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: <Widget>[
            headerWidget(size),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: 1,
                    width: size.width * .9)),
            Visibility(visible: widget.user.userType == "SUPPORT",child: supportWidget()),
            Visibility(visible: widget.user.userType != "SUPPORT",child: helpWidget()),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshChangeListener.refreshed = true;
                },
                child: StreamBuilder(
                  stream:  UserDataProvider.realtimeDbRef
                      .child('/SupportMessage/${widget.item.supportListId}')
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
            buildInput(size),
          ],
        ),
      ),
    );
  }
  headerWidget(Size size){return  Container(
      width: size.width,
      child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 35,
                  width: 35,
                  child: Center(
                    child: IconButton(
                      onPressed: () {
                        endSupport();
                      },
                      icon: Image.asset(
                        getTranslated(context, "arrow"),
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ),
                ),
                widget.user.userType != "SUPPORT"
                    ? Text(
                  getTranslated(context, "tecSupport"),
                  style: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 16.0,
                      color: Colors.black.withOpacity(0.8),
                      fontWeight: FontWeight.bold),
                )
                    : Column(
                  children: [
                    Text(
                      widget.user.userType == "SUPPORT"
                          ? widget.item.userName == null
                          ? " "
                          : widget.item.userName
                          : getTranslated(context, "tecSupport"),
                      style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 16.0,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      mobileNumber,
                      style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 16.0,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                widget.user.userType == "SUPPORT"
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.6),
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: mobileNumber));
                        showSnack(
                            getTranslated(context, "copyDone"),
                            context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
                        width: 38.0,
                        height: 35.0,
                        child: Icon(
                          Icons.copy,
                          color: AppColors.pink,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ),
                )
                    : SizedBox(),
              ],
            ),
          )));}
  supportWidget(){return  Padding(
    padding: const EdgeInsets.only(
        right: 10, left: 10, top: 15, bottom: 15),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: answered,
              onChanged: (value) {
                setState(() {
                  answered = !answered;
                  callAnswered();
                });
              },
            ),
            Text(
              getTranslated(context, "answered"),
              style: TextStyle(
               fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 15.0,
                color: AppColors.grey,
              ),
            ),
            Spacer(),
            OutlinedButton(
              onPressed: () {
                rateSupport();
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    )
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20,
                    color: Colors.orange,
                  ),
                  SizedBox(width:10),
                  Text(
                    getTranslated(context, 'rateUs'),
                    style: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 15.0,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Checkbox(
              value: pending,
              onChanged: (value) {
                setState(() {
                  pending = !pending;
                  pendChat();
                });
              },
            ),
            Text(
              getTranslated(context, "pendChat"),
              style: TextStyle(
               fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 15.0,
                color: AppColors.grey,
              ),
            ),

          ],
        ),
      ],
    ),
  );}
  helpWidget(){return Padding(
    padding: const EdgeInsets.only(
        right: 10, left: 10, top: 15, bottom: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.pink, width: 1),
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Image.asset(
              'assets/applicationIcons/asset1.png',
              width: 25,
              height: 25,
            ),
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          getTranslated(context, "helpText"),
          style: TextStyle(
           fontFamily: getTranslated(context, 'fontFamily'),
            color: AppColors.grey,
            fontSize: 18.0,
          ),
        )
      ],
    ),
  );}
  Widget buildInput(Size size) {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(Icons.image),
                onPressed: () => cropImage(context), // getImage(0),
                color: Theme.of(context).primaryColor,
              ),
            ),
            color: Colors.white,
          ),
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
                icon: new Icon(Icons.video_camera_front_outlined),
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
            onSendMessage: onSendMessage,
            focusNode: focusNode,
            loggedId: widget.user.uid!,
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
                        color: Theme.of(context).primaryColor, fontSize: 15.0),
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
                  : IconButton(
                icon: new Icon(
                  Icons.send,
                  color: AppColors.pink,
                  size: 25,
                ),
                onPressed: () => onSendMessage(
                    textEditingController.text, "text", size),
                color: Theme.of(context).primaryColor,
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

  rateSupport() {
    onSendMessage(
        getTranslated(context, "closeSupportChatText"), "closing", size);
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    FocusScope.of(context).unfocus();
    if ((content.trim() != '' && type == "text") || type != "text") {
      textEditingController.clear();
      if (widget.user.userType == "SUPPORT") {
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
              ? "imageFile"
              : "voiceFile",
        }, SetOptions(merge: true));
      }
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'supportMessageNum': FieldValue.increment(1),
          'supportListStatus': false,
          'userName': widget.user.name,
          'userLang':getTranslated(context, 'lang'),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
              ? "imageFile"
              : "voiceFile",
        }, SetOptions(merge: true));
      String messageId = Uuid().v4();

      await UserDataProvider.realtimeDbRef
          .child("SupportMessage/${widget.item.supportListId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'supportId': widget.item.supportListId,
      });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });

    }
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
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped

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

  Future uploadToStorage(context) async {
    try {
      setState(() {
        uploadVideo = true;
      });
      final pickedFile =
      await ImagePicker.platform.pickVideo(source: ImageSource.gallery);
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

  Future uploadRecord(File voice) async {
    size = MediaQuery.of(context).size;

    var uuid = Uuid().v4();
    Reference storageReference =
    FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(voice);

    var url = await storageReference.getDownloadURL();
    print("recording file222");
    print(url);
    onSendMessage(url, "voice", size);
  }
  Future<void> pendChat() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'pending': pending,
    }, SetOptions(merge: true));
    Navigator.pop(context);
  }
  Future<void> callAnswered() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': true,
      'openingStatus': false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid)
        .set({
      'answeredSupportNum':
      int.parse(widget.user.answeredSupportNum.toString()) + 1,
    }, SetOptions(merge: true));
    var date = DateTime.now();
    await FirebaseFirestore.instance
        .collection(Paths.supportAnalysisPath)
        .doc(Uuid().v4())
        .set({
      'time': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
      'techSupportUser': widget.user.uid,
    }, SetOptions(merge: true));
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          //'supportMessageNum': 0,
          'openingStatus': true,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
    } catch (e) {
      print("cccccc" + e.toString());
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

  ////===============

  Future<bool>endSupport() async {
    try {
      if (widget.user.userType == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'openingStatus': false,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
      Navigator.of(context).pop(true);
      return Future.value(true);

    } catch (e) {
      print("cccccc" + e.toString());
      return Future.value(true);
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
}
