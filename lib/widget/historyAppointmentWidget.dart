
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/twCallScreen.dart';
import 'package:intl/intl.dart';
//import 'package:twilio_voice/twilio_voice.dart';



class HistoryAppointmentWiget extends StatelessWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  HistoryAppointmentWiget({required this.appointment,required this.loggedUser});
  @override
  Widget build(BuildContext context) {
    String lang=getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    DateTime localDate=DateTime.parse(appointment.appointmentTimestamp.toDate().toString()).toLocal();
    if(localDate.hour==12)
      time="12 Pm";
    else if(localDate.hour==0)
      time="12 Am";
    else if(localDate.hour>12)
      time=(localDate.hour-12).toString()+":"+localDate.minute.toString()+"Pm";
    else
      time=(localDate.hour).toString()+":"+localDate.minute.toString()+"Am";

    return GestureDetector(
      onTap: () {},
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/applicationIcons/timeCircle.png',
                    width: 12,
                    height: 12,
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    time,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.grey,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              )),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(9.0),
              boxShadow: [
                shadow(),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only( left: 10, right: 10, top: 10, bottom: 2),
              child: Column(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        appointment.user.name != null
                            ? appointment.user.name
                            : appointment.user.phone,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.white,
                          fontSize: 15.0,
                        ),
                      ),

                      Container(height: 16,
                        //width: size.width * .17,
                        padding: EdgeInsets.only(left: 10,right: 10,),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(7.0),
                        ),
                        child: Center(
                          child: Text(
                            double.parse(appointment.callPrice.toString())
                                .toStringAsFixed(2) +
                                "\$",
                            textAlign: TextAlign.center,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Theme.of(context).primaryColor,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: size.width*.3,
                      padding: EdgeInsets.only(left: 10, right: 10, top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: InkWell(
                        splashColor: Colors.green.withOpacity(0.5),
                        onTap: () async {
                         /* if (!await (TwilioVoice.instance.hasMicAccess())) {
                            print("request mic access");
                            TwilioVoice.instance.requestMicAccess();
                            return;
                          }
                          TwilioVoice.instance.call.place(to:appointment.user.uid,from: loggedUser.uid!,extraOptions:{"user":"yasmeen","consult":"ahmed"});

                          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                              fullscreenDialog: true, builder: (context) => VoiceCallScreen(loggedUser:loggedUser,appointment:appointment,from:'history')));*/
                        },
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                          Image.asset('assets/applicationIcons/recall.png',
                            width: 9,
                            height: 9,
                          ),
                          SizedBox(width: 5,),
                          Text(
                            getTranslated(context, "recall"),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Theme.of(context).primaryColor,
                              fontSize: 10.0,

                            ),
                          ),
                        ],),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
  BoxShadow shadow() {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(0.0, 1.0), // shadow direction: bottom right
    );
  }
}
