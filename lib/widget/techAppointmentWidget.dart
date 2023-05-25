
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:intl/intl.dart';

class TechAppointmentWiget extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser loggedUser;
  TechAppointmentWiget({required this.appointment, required this.loggedUser});

  @override
  _TechAppointmentWigetState createState() => _TechAppointmentWigetState();
}
class _TechAppointmentWigetState extends State<TechAppointmentWiget>with SingleTickerProviderStateMixin {
  bool userChating=false,consultChating=false;
  @override
  void initState() {
    super.initState();
    print("55554444455666");
    print(widget.appointment.appointmentId);

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

    return  Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xfff7f7f7),
          borderRadius: BorderRadius.circular(25.0),

        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "client") ,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color:Color(0xffb8b4b4),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text( widget.appointment.user.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color:Color(0xff202020),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                userChating
                    ? CircularProgressIndicator()
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.6),
                      onTap: () {
                        startUserChating();
                      },
                      child: Icon(
                        Icons.chat_outlined,
                        color:Color(0xff202020),
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "const") ,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color:Color(0xffb8b4b4),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text( widget.appointment.consult.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color:Color(0xff202020),
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.3,
                      ),
                    ),

                  ],
                ),
                consultChating
                    ? CircularProgressIndicator()
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.6),
                      onTap: () {
                        startConsultChating();
                      },
                      child: Icon(
                        Icons.chat_outlined,
                        color: Color(0xff202020),
                        size: 24.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 40,
                  width:size.width * .2,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(  double.parse(widget.appointment.callPrice.toString()).toStringAsFixed(1)+"\$",//getTranslated(context, "callStatus"),

                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 5,),
                Container(
                  height: 40,
                  width:size.width * .2,
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(
                      widget.appointment.appointmentStatus == "new"
                          ? getTranslated(context, "new")
                          : widget.appointment.appointmentStatus == "open"
                          ? getTranslated(context, "open")
                          : widget.appointment.appointmentStatus ==
                          "closed"
                          ? getTranslated(context, "closed")
                          : getTranslated(context, "canceled"),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:5,),

                widget.appointment.type == null
                    ? SizedBox()
                    : Container(
                  height: 40,
                  width: size.width * .2,
                  decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Center(
                    child: Text(
                      widget.appointment.type,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.black,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png',
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          '${dateFormat.format(localDate)}',
                          //'${dateFormat.format(widget.appointment.appointmentTimestamp.toDate())}',
                          // DateFormat.yMMMd().format(DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString())).toString(), // Apr
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                            color: Color(0xff202020),
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    )),
                SizedBox(
                  width: 30,
                ),
                Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png',
                          width: 25,
                          height: 25,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          time,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(fontFamily: getTranslated(context, 'fontFamily'),
                            color:Color(0xff202020),
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ))
              ],
            ),
            SizedBox(
              height: 6,
            ),
          ],
        ));
  }
  Widget build22(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('MM/dd/yy');
    DateTime localDate,closedDate=DateTime.now();
    if(widget.appointment.closedUtcTime!=null)
      closedDate=DateTime.parse(widget.appointment.closedUtcTime!).toLocal();
    if(widget.appointment.utcTime!=null)
      localDate=DateTime.parse(widget.appointment.utcTime).toLocal();
    else
      localDate=DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString()).toLocal();
    if(localDate.hour==12)
      time="12 Pm";
    else if(localDate.hour==0)
      time="12 Am";
    else if(localDate.hour>12)
      time=(localDate.hour-12).toString()+":"+localDate.minute.toString()+"Pm";
    else
      time=(localDate.hour).toString()+":"+localDate.minute.toString()+"Am";
    //String time=(widget.appointment.time.hour).toString()+":"+widget.appointment.time.minute.toString();

   /* if(widget.appointment.time.hour>12)
      time=(widget.appointment.time.hour-12).toString()+":"+widget.appointment.time.minute.toString()+"Pm";
    else
      time=(widget.appointment.time.hour).toString()+":"+widget.appointment.time.minute.toString()+"Am";*/
    return GestureDetector(
      onTap: () {

      },
      child:Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),child:Column(
            children: [
                Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "client")+widget.appointment.user.name,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    userChating?CircularProgressIndicator():ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            startUserChating();
                          },
                          child: Icon(
                            Icons.chat_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2,),
                Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "const")+widget.appointment.consult.name,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    consultChating?CircularProgressIndicator():ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            startConsultChating();
                          },
                          child: Icon(
                            Icons.chat_outlined,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_clock,
                      color: Colors.white,
                      size: 20.0,
                    ),
                    SizedBox(width: 3,),
                    Text(
                      widget.appointment.closedUtcTime==null?getTranslated(context, "callStatus"):
                      '${dateFormat.format(closedDate)}',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2,),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: 30,width: size.width*.25,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        widget.appointment.appointmentStatus,
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                  SizedBox(width: 5,),
                  Container(height: 30,width: size.width*.25,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        double.parse( widget.appointment.callPrice.toString()).toStringAsFixed(3)+"\$",
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                  SizedBox(width: 5,),
                  Container(height: 30,width: size.width*.25,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        widget.appointment.type,
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                ],
              ),
              SizedBox(height: 5,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.appointment.consultType==null?SizedBox():Container(height: 30,width: size.width*.25,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        widget.appointment.consultType,
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),
                  SizedBox(width: 5,),
                  widget.appointment.type==null?SizedBox():Container(height: 30,width: size.width*.25,
                    decoration: BoxDecoration(
                      color: AppColors.orange,
                      borderRadius: BorderRadius.circular(20.0),
                    ),child:Center(
                      child: Text(
                        double.parse( widget.appointment.callCost.toString()).toStringAsFixed(3)+"\$",
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),),

                ],
              ),
                SizedBox(height: 6,),
                Row(mainAxisAlignment:MainAxisAlignment.center,children: [
                  Container(child:
                  Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                    Image.asset('assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      '${dateFormat.format(localDate)}',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],)
                  ),
                  SizedBox(width: 30,),
                  Container(child: Row(mainAxisAlignment: MainAxisAlignment.start,children: [
                    Image.asset('assets/applicationIcons/whiteTime.png',
                      width: 15,
                      height: 15,
                    ),
                    SizedBox(width: 5,),
                    Text(
                      time,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],)

                  )
                ],),
                SizedBox(height: 6,),
            ],
          )),

          SizedBox(height: 20,)
        ],
      ),
    );
  }
  startUserChating() async{
    setState(() {
      userChating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.appointment.user.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      item.userName=widget.appointment.user.name;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
              item: item,
              user:widget.loggedUser), ),);
      setState(() {
        userChating=false;
      });

    }
    else
    {
      setState(() {
        userChating=false;
      });
    }
  }
  startConsultChating() async{
    setState(() {
      consultChating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.appointment.consult.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      item.userName=widget.appointment.consult.name;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
              item: item,
              user:widget.loggedUser), ),);
      setState(() {
        consultChating=false;
      });

    }
    else
    {
      setState(() {
        consultChating=false;
      });
    }
  }
}
