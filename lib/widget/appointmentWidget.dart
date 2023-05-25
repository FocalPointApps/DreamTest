
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:intl/intl.dart';

import '../config/paths.dart';
import '../screens/RtcScreens/call_sample.dart';
import '../screens/RtcScreens/riningScreen.dart';


class AppointmentWiget extends StatefulWidget {
  final GroceryUser? loggedUser;
  final AppAppointments appointment;

  AppointmentWiget({required this.appointment, this.loggedUser,});

  @override
  _AppointmentWigetState createState() => _AppointmentWigetState();
}

class _AppointmentWigetState extends State<AppointmentWiget>
    with SingleTickerProviderStateMixin {

  bool acceptLoad = false, loadingCall = false;
bool joinMeeting=false;
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    DateTime localDate;
    if (widget.appointment.utcTime != null)
      localDate = DateTime.parse(widget.appointment.utcTime).toLocal();
    else
      localDate = DateTime.parse(
              widget.appointment.appointmentTimestamp.toDate().toString())
          .toLocal();
    if (localDate.hour == 12)
      time = "12 Pm";
    else if (localDate.hour == 0)
      time = "12 Am";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":" +
          localDate.minute.toString() +
          "Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          "Am";

    return  Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/applicationIcons/timeCircle.png',
                      width: 12,
                      height: 12,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      time,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        color: Color.fromRGBO(184, 184, 184,1),
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/applicationIcons/outline-event_available-24px.png',
                      width: 12,
                      height: 12,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '${dateFormat.format(localDate)}',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        color: Color.fromRGBO(184, 184, 184,1),
                        fontSize: 10.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding:EdgeInsets.only(top: 10,right: 15,left: 15) ,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: new BorderRadius.only(
                    topRight: const Radius.circular(14.0),
                    topLeft: const Radius.circular(14.0),
                  )),
              child: Column(
                children: [
                  Text(
                    widget.appointment.user.name != null
                        ? widget.appointment.user.name
                        : widget.appointment.user.phone,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.white,
                      fontSize: 12.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        getTranslated(context, "callStatus"),
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      ),
                      Text(
                        widget.appointment.appointmentStatus == "new"
                            ? getTranslated(context, "new")
                            : widget.appointment.appointmentStatus == "open"
                            ? getTranslated(context, "open")
                            : widget.appointment.appointmentStatus ==
                            "closed"
                            ? getTranslated(context, "closed")
                            : getTranslated(context, "canceled"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.white,
                          fontSize: 10.0,
                        ),
                      )
                    ],
                  ),
                ],
              )),
          Container(
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    bottomRight: const Radius.circular(14.0),
                    bottomLeft: const Radius.circular(14.0),
                  ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0 ,0, 0, 0.1),
                    blurRadius: 5.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 2.0), // shadow direction: bottom right
                  )
                ],
              ),
              child: Column(
                children: [
                  (widget.appointment.appointmentStatus == "open")
                      ?  Row(
                children: [
                  widget.appointment.consultType=="voice"
                      ? Expanded(
                      flex: 1,
                      child: loadingCall
                          ? Center(
                          child:
                          CircularProgressIndicator())
                          : InkWell(
                        splashColor:
                        Colors.green.withOpacity(0.6),
                        onTap: () async {
                          webRtcCall();
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/applicationIcons/Iconly-Two-tone-Calling.png',
                              width: 12,
                              height: 12,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              getTranslated(
                                  context, "calling"),
                              textAlign: TextAlign.start,
                              overflow:
                              TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context)
                                    .primaryColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      ))
                      : SizedBox(),
                  widget.appointment.consultType=="voice"
                      ? Container(
                    height: 30,
                    width: 1,
                    color: Color.fromRGBO(184 ,184 ,184,1)
                  )
                      : SizedBox(),
                  Expanded(
                      flex: 1,
                      child: InkWell(
                        splashColor: Colors.green.withOpacity(0.6),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentChatScreen(
                                      appointment:
                                      widget.appointment,
                                      user: widget.loggedUser!),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Image.asset('assets/applicationIcons/Iconly-Two-tone-Chat.png',
                                    width: 12,
                                    height: 12,
                                  ),
                                  SizedBox(
                                    width: 3,
                                  ),
                                  widget.appointment.userChat > 0
                                      ? Positioned(
                                    left: 1.0,
                                    top: 1.0,
                                    child: Container(
                                      height: 5,
                                      width: 5,
                                      alignment:
                                      Alignment.center,
                                      decoration:
                                      BoxDecoration(
                                        shape:
                                        BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  )
                                      : SizedBox()
                                ]),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              getTranslated(context, "message"),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color:
                                Theme.of(context).primaryColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              )
                      : SizedBox(),
                  (widget.appointment.appointmentStatus == "closed")
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.6),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AppointmentChatScreen(
                                      appointment: widget.appointment,
                                      user: widget.loggedUser!),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Image.asset('assets/applicationIcons/Iconly-Two-tone-Chat.png',
                                    width: 12,
                                    height: 12,
                                  ),
                                  widget.appointment.userChat > 0
                                      ? Positioned(
                                    left: 1.0,
                                    top: 1.0,
                                    child: Container(
                                      height: 5,
                                      width: 5,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  )
                                      : SizedBox()
                                ]),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              getTranslated(context, "message"),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context).primaryColor,
                                fontSize: 11.0,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                      : SizedBox(),
                ],
              )),

        ],
      );
  }
  webRtcCall() async {
    print("startCall");
    try{
    setState(() {
      joinMeeting=true;
    });
    if(widget.loggedUser!.userType=="CONSULTANT")
    {

      Future(() =>
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (con) =>
              RiningScreen(host: widget.appointment.appointmentId, iscaller: true,
                loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: false,normalCall: false,CallerId: FirebaseAuth.instance.currentUser!.uid!
                ,ReciverId: widget.appointment.user.uid,)),(predict)=>predict.isCurrent?false:true));

//       await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
//         'allowCall':true,
//       }, SetOptions(merge: true));
//
//       try{
//         FirebaseFunctions functions = FirebaseFunctions.instance;
//         //  functions.useFunctionsEmulator('127.0.0.1', 5001);
//         //functions("10.0.2.2", 5001);
//
// //
//         HttpsCallable callable =   functions.httpsCallable("checkUserCallState");
//         print("callErrorffff");
//         print(widget.appointment.appointmentId);
//         print(widget.appointment.user.uid);
//         final res  = await callable.call({
//           'appointmentId':widget.appointment.appointmentId,
//           'reciverId':widget.appointment.user.uid,
//           'isNormal':false
//
//         });
//
//
//         print('rescall${res.data['code']}');
//
//
//         if(res.data['code']==101){
//
//
//           Fluttertoast.showToast(msg:  res.data['message']);
//
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.data['message']));
//
//
//         }else if(res.data['code']==200){
//
//           print("user id${widget.appointment.user.uid} appontmentid${widget.appointment.appointmentId}");
//
//               Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
//                   CallSample(host: widget.appointment.appointmentId, iscaller: true,
//                     loggedUser: widget
//                         .loggedUser, isVideo: false,normalCall: false,CallerId: FirebaseAuth.instance.currentUser!.uid!
//                     ,ReciverId: widget.appointment.user.uid,)));
//
//         }
//
//
//
//
//         print('rescall${res.data['code']}');
//
//
//
//
//       }catch(e){
//         print("callError000"+e.toString());
//         setState(() {
//           joinMeeting=false;
//         });
//       }





      // bool?   cheekconiction=  await  BlocProvider.of<WebRtcBloc>(context).webRtcRepository.initRenderers(true, true);

      // if(!cheekconiction!){
      //
      //   return;
      // }


      //  BlocProvider.of<WebRtcBloc>(context).webRtcRepository.webRtcProvider.localRender.initialize();
      // BlocProvider.of<WebRtcBloc>(context).webRtcRepository.webRtcProvider.remoteRenderer.initialize();
      //p//rint("hokshrender${checkrender}");

      //  BlocProvider.of<WebRtcBloc>(context).webRtcRepository.createOffer(true, true,widget.appointment.appointmentId,widget.appointment.user.uid,widget.appointment.consult.uid);
      //  Future(()=>   Navigator.of(context).push( MaterialPageRoute(builder: (con)=>CallScreen(widget.appointment.appointmentId))));

      //   print("triger111Call${trigerCall!.data()!['appointmentId']}");

      // await  FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).set({
      //     'callState':'calling',
      //     'timeStamp':ServerValue.timestamp,
      //     'roomId':widget.appointment.appointmentId,
      //     'callerID':FirebaseAuth.instance.currentUser!.uid,
      //     'reciverId':widget.appointment.consult.uid==FirebaseAuth.instance.currentUser!.uid?widget.appointment.user.uid:widget.appointment.consult.uid
      //
      //
      //   });
      //
      //   await  FirebaseDatabase.instance.ref('userCallState').child(widget.appointment.consult.uid==FirebaseAuth.instance.currentUser!.uid?widget.appointment.user.uid!:widget!.appointment!.consult!.uid!).set({
      //     'callState':'calling',
      //     'timeStamp':ServerValue.timestamp,
      //     'roomId':widget.appointment.appointmentId,
      //     'callerID':FirebaseAuth.instance.currentUser!.uid,
      //     'reciverId':widget.appointment.consult.uid==FirebaseAuth.instance.currentUser!.uid?widget.appointment.user.uid:widget.appointment.consult.uid
      //
      //
      //
      //   });
      //
      //
      //
      //   Future(()=>   Navigator.of(context).push( MaterialPageRoute(builder: (con)=>CallSample( host:widget.appointment.appointmentId ,iscaller:true))));

      //   startMeeting();
      setState(() {
        joinMeeting=false;
      });
    }
  /*  else
    {
      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId);
      var doc=await docRef2.get();
      if(AppAppointments.fromMap(doc.data() as Map).allowCall)
      {
        FirebaseFirestore.instance.collection("AppAppointmentsCall").doc(
            widget.appointment.appointmentId).set({      'callState':'pinding',
          'appointmentId': widget.appointment.appointmentId,
          'callerId': widget.appointment.consult.uid,
          'reciverId': widget.appointment.user.uid
        });
        //   BlocProvider.of<WebRtcBloc>(context).webRtcRepository.initRenderers(true, true);
        //  BlocProvider.of<WebRtcBloc>(context).webRtcRepository.createOffer(true, true,widget.appointment.appointmentId,widget.appointment.consult.uid,widget.appointment.user.uid);
        Future(()=>   Navigator.of(context).push( MaterialPageRoute(builder: (con)=>CallScreen(widget.appointment.appointmentId))));

        //   startMeeting();
      }
      else
      {
        Fluttertoast.showToast(
            msg: getTranslated(context, "notAllowed"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          joinMeeting=false;
        });
      }
    }*/
    }catch(e){
      print("callError"+e.toString());
    }
  }
/*  twilioCall() async {
    if (!await (TwilioVoice.instance.hasMicAccess())) {
      print("request mic access");
      TwilioVoice.instance.requestMicAccess();
      return;
    }
    TwilioVoice.instance.call.place(to: widget.appointment.user.uid, from: widget.loggedUser!.uid.toString());
    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => VoiceCallScreen(
            loggedUser: widget.loggedUser, appointment: widget.appointment)));
  }*/


}
