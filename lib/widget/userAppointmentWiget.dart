
import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/AppointmentChatScreen.dart';
import 'package:grocery_store/screens/consultantDetailsScreen.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:intl/intl.dart';
//import 'package:twilio_voice/twilio_voice.dart';

class UserAppointmentWiget extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  UserAppointmentWiget({required this.appointment, required this.loggedUser});
  @override
  Widget build(BuildContext context) {
    String lang = getTranslated(context, "lang");
    var size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    DateTime localDate;
    if (appointment.utcTime != null)
      localDate = DateTime.parse(appointment.utcTime).toLocal();
    else
      localDate =
          DateTime.parse(appointment.appointmentTimestamp.toDate().toString())
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
        return Column(
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
                  appointment.consult.name != null
                      ? appointment.consult.name
                      : appointment.consult.phone,
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
                      appointment.appointmentStatus == "new"
                          ? getTranslated(context, "new")
                          : appointment.appointmentStatus == "open"
                          ? getTranslated(context, "open")
                          : appointment.appointmentStatus ==
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
                  child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            InkWell(
            splashColor: Colors.green.withOpacity(0.6),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentChatScreen(
                      appointment: appointment,
                      user: loggedUser),
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
            appointment.userChat > 0
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
            ))

              ],
            );

  }

  void showNoNotifSnack(BuildContext context, String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade400,
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
      duration: Duration(milliseconds: 1400),
      icon: Icon(
        Icons.notification_important,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
}
