import 'dart:async';
import 'dart:convert';
import 'dart:math';
//import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/config.dart';
import '../config/paths.dart';

import '../localization/localization_methods.dart';
import '../main.dart';
import '../models/AppAppointments.dart';
import '../models/DefaultFirebaseConfig.dart';

import '../models/user.dart';
import '../repositories/authentication_repository.dart';
import '../repositories/user_data_repository.dart';
import '../repositories/web_Rtc_repository.dart';
import '../screens/AgoraScreen.dart';
import '../screens/AppointmentChatScreen.dart';
import '../screens/RtcScreens/call_sample.dart';

import '../screens/addReviewScreen.dart';
import '../screens/generalNotificationScreen.dart';
import '../screens/home_screen.dart';
import '../screens/payInfo1Screen.dart';
import '../screens/payInfoScreen.dart';
import 'callServiceKeep.dart';
import 'globalStuff.dart';

dynamic notificationData;
 FirebaseDatabase database =  FirebaseDatabase.instanceFor(app:Firebase.app(),databaseURL: 'https://dream-43bb8-f2c7f.europe-west1.firebasedatabase.app');
 final realtimeDbRef = database.ref();

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
RemoteNotification? value;
BuildContext? _context;
class FirebaseService {


  static init(context, uid, User currentUser) {
    _context=context;
    initDynamicLinks(context);
    updateFirebaseToken(currentUser);
    initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

initDynamicLinks(context) async {
  print("aaa initDynamicLinks");
  // PendingDynamicLinkData? data =
  // await FirebaseDynamicLinks.instance.getInitialLink();
  // Uri? deepLink = data?.link;
  // print("aaa deepLink");
  // print(data);
  // if (deepLink != null) {
  //   print('LAUNCH');
  //   print('DEEP LINK URL ::: $deepLink ');
  //   print(deepLink.toString());
  // print(deepLink.queryParameters['link']);

  // print(
  //     deepLink.queryParameters['link'].split('${Config().urlPrefix}/')[1]);

  // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
  // String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

  /*Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductScreen(
          productId: pid,
        ),
      ),
    );*/
  // }

  // FirebaseDynamicLinks.instance.onLink;
  /* FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData dynamicLink) async {
        Uri deepLink = dynamicLink?.link;

        if (deepLink != null) {
          print('ON_LINK');
          print('DEEP LINK URL ::: $deepLink ');
          // print(deepLink.queryParametersAll);
          // print(deepLink.queryParameters['link']);

          // print(deepLink.queryParameters['link']
          //     .split('${Config().urlPrefix}/')[1]);

          // var tempLink = deepLink.queryParameters['${Config().urlPrefix}/'];
          String pid = deepLink.toString().split('${Config().urlPrefix}/')[1];

          *//* Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                productId: pid,
              ),
            ),
          );*//*
        }
      }, onError: (OnLinkErrorException e) async {
    print('onLinkError');
    print(e.message);
  });*/
}

//FCM
updateFirebaseToken(User currentUser) {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  firebaseMessaging.getToken().then((token) {
    print(token);
    FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
      'tokenId': token,
    });
  });
}

initFCM(String uid, context, User currentUser) async {
  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel', // id
      'call_channel', // title
      importance: Importance.max,
      vibrationPattern: Int64List.fromList([4]),


      playSound: true,
      sound:RawResourceAndroidNotificationSound('jeraston')
  );
  await flutterLocalNotificationsPlugin
      ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  var android = new AndroidInitializationSettings('grocery');
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String? langCode= await _prefs.getString('languageCode');//('grocery');
  var ios =  DarwinInitializationSettings(

      notificationCategories:[DarwinNotificationCategory("Call",
          actions:[
            DarwinNotificationAction.plain('Accept', langCode !=null&&langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",options:{
              DarwinNotificationActionOption.foreground,
            }),
            // DarwinNotificationAction.plain('Dicline',  langCode !=null&&langCode=='ar'?'رفض':"Dicline",options:{
            //   DarwinNotificationActionOption.destructive,
            // })

          ]

      )]
  ) ;
  var initSetting = new InitializationSettings(iOS: ios, android: android);
  flutterLocalNotificationsPlugin?.initialize(
      initSetting,
      onDidReceiveBackgroundNotificationResponse:onSelectNotification,
      onDidReceiveNotificationResponse:onSelectNotification

  );
}
@pragma('vm:entry-point')
Future<void> onSelectNotification(NotificationResponse? payload) async {

  if(payload!.actionId=='accept'){

    realtimeDbRef.child('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('acceptState').set('accepted');

  }

  if(value!=null){

    navigation(value!.title, value!.body, value!.titleLocKey, value!.bodyLocKey);

  }


}
configureFirebaseListeners(context, User currentUser) async {
  //app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if(message!=null&&message.notification!=null)
      navigation(message.notification!.title, message.notification!.body,message.notification!.titleLocKey, message.notification!.bodyLocKey);
  });

  //App is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    print('ON MESSAGE1122222 :: $message');

    if(message!.data['type']=='Call'){
      CallServiceKeep.displayIncomingCall(message!.data);
    }

    if (message != null&&message.notification!=null) {
      RemoteNotification notification = message.notification!;
      //AndroidNotification? android = message.notification?.android!;
      if (notification != null ) {
        print('ON MESSAGE111100 :: ');
        showNotification(
          notification,

        );
      } else
        print("aaa noshowNotification");
    }
  });
  // App is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      print('INITIAL MESSAGE :: $message');
      if (message != null) {
        navigation(message.notification!.title, message.notification!.body,
            message.notification!.titleLocKey, message.notification!.bodyLocKey);
      }
    });

  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);




}
//   @pragma("vm:entry-point")
//   Future<void>  onActionReceivedMethod(ReceivedAction receivedAction) async {
//   print("madmaxcx${receivedAction.actionType}");
//
// if(
// receivedAction.actionType == ActionType.Default){
//   print("madmaxcx$receivedAction");
//   //audioPlayer.dispose();
//
//   FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('acceptState').set('accepted');
//
//   staticAudio.newInstance()!.audioPlayerPublic.stop();
//
//
//
//
// //  print("dasdasdasdas");
//
// // await executeLongTaskInBackground();
// }
// else {
//   print( 'madmaxcxmadmaxcxmadmaxcxdismis');
//   staticAudio.newInstance()!.audioPlayerPublic.stop();
//  // audioPlayer.dispose();
//
// }
// }
//
//
//
//
//  Future<void> createNewNotification(data) async {
// bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
// // if (!isAllowed) isAllowed = await displayNotificationRationale();
// // if (!isAllowed) return;
// print("datattatt${data}");
//
//   // setupAudio();
//
// if(data['type']=="Call"){
//
//   await AwesomeNotifications().createNotification(
//
//       content: NotificationContent(
//           id:1, // -1 is replaced by a random number
//           channelKey: 'call_channel',
//           title: data['callerName'],
//           body:data['message'],
//           fullScreenIntent: true,
//           largeIcon:data['userimg'] ,
//           roundedLargeIcon: true,
//           showWhen: true,
//
//           icon: "resource://drawable/ic_stat_name",
//
//           // customSound: 'resource://raw/jeraston',
//           wakeUpScreen: true,
//           displayOnBackground: true,
//           displayOnForeground: true,
// //'asset://assets/images/balloons-in-sky.jpg',
//           notificationLayout: NotificationLayout.BigPicture,
//           payload: {"appointmentId":data['appointmentId']}),
//
//       actionButtons: [
//         NotificationActionButton(
//             key: 'Accept',
//             label: 'Accept',
//             requireInputText: false,
//             actionType: ActionType.Default
//         ),
//         NotificationActionButton(
//             key: 'DISMISS',
//             label: 'Dismiss',
//             actionType: ActionType.DismissAction,
//             isDangerousOption: true)
//       ]);
//
// }else if(data['type']=="missedCall"){
//   staticAudio.newInstance()!.audioPlayerPublic.stop();
//   await AwesomeNotifications().createNotification(
//
//       content: NotificationContent(
//           id: 1, // -1 is replaced by a random number
//           channelKey: 'call_channel',
//           title: data['callerName'],
//           body:data['message'],
//           fullScreenIntent: true,
//           icon: "resource://drawable/ic_stat_name",
//           largeIcon:data['userimg'] ,
//
//           // customSound: 'resource://raw/jeraston',
//           wakeUpScreen: true,
//           displayOnBackground: true,
//           displayOnForeground: true,
// //'asset://assets/images/balloons-in-sky.jpg',
//           notificationLayout: NotificationLayout.BigPicture,
//           payload: {"appointmentId":data['appointmentId']}),
//       actionButtons: [
//         // NotificationActionButton(
//         //     key: 'Accept',
//         //     label: 'Accept',
//         //     requireInputText: false,
//         //     actionType: ActionType.Default
//         // ),
//         // NotificationActionButton(
//         //     key: 'DISMISS',
//         //     label: 'Dismiss',
//         //     actionType: ActionType.DismissAction,
//         //     isDangerousOption: true)
//       ]);
//
// }
//
//
//
//
// }

showCallnotfication(notidata,bool iscall)
async {
  print("showCallnotfication");
  if(iscall){
    http.Response response = await http.get(Uri.parse(notidata['userimg']));

    var _base64 = base64Encode(response.bodyBytes);
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? langCode= await _prefs.getString('languageCode');
    flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
    var aNdroid = new AndroidNotificationDetails(
        'call_channel',
        'call_channel',
        //'desc',
        icon:'grocery',

        autoCancel: false,
        fullScreenIntent: true,
        vibrationPattern: vibrationPattern,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
        actions:iscall? <AndroidNotificationAction>[
          AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",showsUserInterface: true),
          // AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"قبول": "Accept",showsUserInterface: true),
          // AndroidNotificationAction('dissmis',    langCode!=null&&langCode=='ar'?"رفض":"Dicline",showsUserInterface: true),
        ]:[],
        importance: Importance.high,  priority: Priority.high,playSound: true,
        sound: iscall? RawResourceAndroidNotificationSound('jeraston'): RawResourceAndroidNotificationSound('soundandroid'),additionalFlags: Int32List.fromList(<int>[4])

    );
    var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
      presentAlert: true,
      categoryIdentifier: 'Call',
      presentBadge: true,
      presentSound: true,);
    var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
    print("aaa1111111 channelId data.title");
    // print( data.title);

    // value=data;
    await flutterLocalNotificationsPlugin!.show( 12,
      notidata['title'],
      notidata['body'],
      platform,

    );
    //staticAudio.newInstance().setupAudio();
  }else{
    http.Response response = await http.get(Uri.parse(notidata['userimg']));

    var _base64 = base64Encode(response.bodyBytes);
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    String? langCode= await _prefs.getString('languageCode');
    flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
    var aNdroid = new AndroidNotificationDetails(
        'call_channel',
        'call_channel',
        //'desc',
        icon:'grocery',

        autoCancel: false,
        fullScreenIntent: true,
        vibrationPattern: vibrationPattern,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
        actions:iscall? <AndroidNotificationAction>[
          //AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"قبول": "Accept",showsUserInterface: true),
        //  AndroidNotificationAction('dissmis',    langCode!=null&&langCode=='ar'?"رفض":"Dicline",showsUserInterface: true),
        ]:[],
        importance: Importance.high,  priority: Priority.high,playSound: true,
        sound: iscall? RawResourceAndroidNotificationSound('jeraston'): RawResourceAndroidNotificationSound('soundandroid'),additionalFlags: Int32List.fromList(<int>[4])

    );
    var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
      presentAlert: true,
      categoryIdentifier: 'Call',
      presentBadge: true,
      presentSound: true,);
    var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
    print("aaa1111111 channelId data.title");
    // print( data.title);

    // value=data;
    await flutterLocalNotificationsPlugin!.show(12,
      notidata['title'],
      notidata['body'],
      platform,

    );

  }

}

showNotification( RemoteNotification data )
async {
  flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',
    //'desc',
    icon:'grocery',
    autoCancel: true,
    fullScreenIntent: false,
    importance: Importance.high,  priority: Priority.high,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),

  );
  var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,);
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
  print("aaa1111111 channelId data.title");
  print( data.title);

  value=data;
  await flutterLocalNotificationsPlugin!.show( Random().nextInt(100),
    data.title,
    data.body,
    platform,

  );
  //staticAudio.newInstance().audioPlayerPublic.stop();

}
bool _callKeepInited = false;


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler( RemoteMessage message, ) async {
  print('ON MESSAGE :: ${message.data}');
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;
  Map<String,dynamic> data=message.data;



  if (notification != null)
  {
    print('ON MESSAGEmaxxx :: ${message.data}');

    showNotification(notification);


  }

  if(data!=null){
    switch(data['type']) {
      case "Call":
        CallServiceKeep.displayIncomingCall(message!.data);


        // showCallnotfication(
        //
        //     message.data,
        //     true
        //
        // );
        //  setupAwosome();
        //   main();
        //    ReceivedAction? initialAction = await AwesomeNotifications()
        //        .getInitialNotificationAction(removeFromActionEvents: false);
        //    createNewNotification(data);
        break;
      case "missedCall" :
        // showCallnotfication(
        //
        //     message.data,
        //     false
        //
        // );
        // ReceivedAction? initialAction = await AwesomeNotifications()
        //     .getInitialNotificationAction(removeFromActionEvents: false);
        // createNewNotification(data);
        break;

    // default:
    //   // showNotification(
    //   //     notification!,
    //   //     false,
    //   //     message.data
    //   //
    //   // );
    //   break;


    }


  }

//   if(data!=null &&data['type']=="Call"){
// print("calltype${data['type']}");
//
//
//     var payload = data;
//
//    String Appointmentid=payload['appointmentId'];
//    String userId=payload['userId'];
//
//
//    // print('backgroundMessage: displayIncomingCall ($callerId)');
//    //  _callKeep.displayIncomingCall(Appointmentid, userId,
//    //      localizedCallerName: "testname", hasVideo: true);
//    //  _callKeep.backToForeground();
//
//   }

}


// setupAwosome(){
//   AwesomeNotifications()
//       .setListeners(onActionReceivedMethod: onActionReceivedMethod,
//     onDismissActionReceivedMethod:       onActionReceivedMethod,
//     onNotificationCreatedMethod:onCreatedNotificationMethod ,
//     onNotificationDisplayedMethod: onDisplayedNotificationMethod,
//
//   );
// }
/// Use this method to detect when a new notification or a schedule is created\
// @pragma("vm:entry-point")
//  Future <void> onCreatedNotificationMethod(ReceivedNotification receivedNotification) async {
//   print("oncreated${receivedNotification.actionType}");
//
// // created code goes here
// }
// @pragma("vm:entry-point")
//  Future <void> onDisplayedNotificationMethod(ReceivedNotification receivedNotification) async {
//   print("ondisplay${receivedNotification.actionType}");
//
//   staticAudio.newInstance()!.setupAudio();
// // displayed code goes here
// }




navigation(String? title,String? body,String? titleKey,String? bodyKey) async {
  if((title=="المواعيد"||title=="Appointment")&&titleKey=="user"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 1,),
      ),
    );
  }
  else if((title=="المواعيد"||title=="Appointment")&&titleKey=="consult"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 0,),
      ),
    );
  }
  else if(title=="التقيم"||title=="Review"){
    List<String> dateParts = bodyKey!.split(",");
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            AddReviewScreen(consultId: dateParts[0],userId:titleKey!,appointmentId: dateParts[1],),
      ),
    );
  }
  else if(title=="الدعم الفني"||title=="Technical Support"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 2,),
      ),
    );
  }
  else if(title=="رسائل المحادثات"||title=="Chat messages"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => AppointmentChatScreen(
            appointment: appointment,
            user:user
        ),
      ),
    );

  }
  else if(title=="اتصال"||title=="Calling"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => AgoraScreen(
          appointment: appointment ,
          user:user,
          appointmentId:bodyKey! ,
          consultName: titleKey!,
        ),
      ),
    );

  }
  else if(title=="الحساب"||title=="Account"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => payInfo1Screen(
          consultId: titleKey!,
        ),
      ),
    );

  }
  else{
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            GeneralNotificationScreen(
                title:title!,
                body:body!,
                image:titleKey,
                link:bodyKey
            ),
      ),
    );
  }
}
