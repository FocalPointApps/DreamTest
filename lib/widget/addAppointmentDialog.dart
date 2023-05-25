
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/models/user.dart';
import 'package:hijri_picker/hijri_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:hijri_picker/hijri_picker.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/consultDays.dart';
import '../models/consultPackage.dart';
import '../models/order.dart';
class AddAppointmentDialog extends StatefulWidget {
  final GroceryUser loggedUser;
  final GroceryUser consultant;
  final Orders order;
  final int localFrom;
  final int localTo;
  final int currentNumber;
  final String consultType;
  AddAppointmentDialog({
     required this.loggedUser,
     required this.consultant,
    required this.order, required this.localFrom, required this.localTo, required this.currentNumber,required this.consultType
  });

  @override
  _AddAppointmentDialogState createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  int selectedCard = -1;
  bool hijri=false, gregorian=true,loadDates=true;
  String time=DateFormat('yyyy-MM-dd').format(DateTime.now()),dateText="", displayedTime=DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  late DateTime  selectedDate = DateTime.now(),date;
  List<dynamic> todayAppointmentList=[];
  @override
  void initState() {
    super.initState();
      getDate();

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.all(0),
      content: Container(
        height: size.height * 0.5,
        width: double.maxFinite,
        constraints: BoxConstraints.loose(size),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, "selectAppointment"),
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: AppColors.pink,
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.6),
                    onTap: () {
                      Navigator.pop(context);
                      //Navigator.pop(context);

                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                      ),
                      width: 38.0,
                      height: 35.0,
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24.0,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor: AppColors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        displayedTime=DateFormat('yyyy-MM-dd').format(DateTime.now());
                        selectedDate=DateTime.now();
                        time=DateFormat('yyyy-MM-dd').format(DateTime.now());
                        gregorian = true;
                        hijri = false;
                      });
                    },
                    child: Container(
                      height: 20,
                      width: size.width * .3,
                      decoration: BoxDecoration(
                        color: gregorian? Theme.of(context).primaryColor
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "gregorian"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: gregorian? Colors.white
                                :Theme.of(context).primaryColor,
                            fontSize: 9.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox( width: 5.0,),
                  InkWell(
                    splashColor: AppColors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        displayedTime=HijriCalendar.now().toString();
                        selectedDate=DateTime.now();
                        time=DateFormat('yyyy-MM-dd').format(DateTime.now());
                        gregorian = false;
                        hijri = true;
                      });
                    },
                    child: Container(
                      height: 20,
                      width: size.width * .3,
                      decoration: BoxDecoration(
                        color: hijri? Theme.of(context).primaryColor
                            : AppColors.grey,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "hijri"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: hijri? Colors.white
                                :Theme.of(context).primaryColor,
                            fontSize: 9.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Container(height: 25,//width: size.width*.60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 0.0),
                      blurRadius: 1.0,
                      spreadRadius: 1.0,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 5,right: 5),
                  child:   InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.6),
                    onTap: () async {
                      if(hijri)
                        _selectHijriDate(context);
                      else
                        _selectDate(context);
                    },
                    child: Row(
                      children: [
                        Expanded(flex:2,
                          child: Text(
                            displayedTime,
                            textAlign: TextAlign.center,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color:Theme.of(context).primaryColor,
                              fontSize: 11.0,
                            ),
                          ),
                        ),
                        Icon( Icons.date_range,size:20,
                          color: AppColors.pink,),
                      ],
                    ),
                  ),
                ),

              ),
              SizedBox( height: 10.0,),
              (loadDates==false&&todayAppointmentList.length>0)?
              GridView.count(
                shrinkWrap: true,
                physics: ScrollPhysics(),
                //physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                children: new List<Widget>.generate(todayAppointmentList.length, (index) {
                  String  minues="00", d="Am",finalTime="";
                  if(DateTime.parse(todayAppointmentList[index]).toLocal().minute!=0)
                    minues=DateTime.parse(todayAppointmentList[index]).toLocal().minute.toString();
                  if(DateTime.parse(todayAppointmentList[index]).toLocal().hour>12)
                    finalTime=((DateTime.parse(todayAppointmentList[index]).toLocal().hour)-12).toString()+":"+minues+"Pm";
                  else if(DateTime.parse(todayAppointmentList[index]).toLocal().hour==12)
                    finalTime=((DateTime.parse(todayAppointmentList[index]).toLocal().hour)).toString()+":"+minues+"Pm";
                  else
                    finalTime=DateTime.parse(todayAppointmentList[index]).toLocal().hour.toString()+":"+minues+"Am";
                  return
                   selectedCard == index?Center(child: CircularProgressIndicator()):InkWell( onTap: () async {
                     print("selectedindex"+index.toString());
                     setState(() {
                       selectedCard=index;
                     });
                     addAppointment(DateTime.parse(todayAppointmentList[index]).toLocal());
                   },
                     child: Card(
                          color: AppColors.pink,
                          child: new Center(
                            child: new Text('$finalTime', style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color:Colors.white,
                              fontSize: 11.0,
                            ),),
                          )
                      ),
                   );
                }),
              )
                  :Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),
                  loadDates?CircularProgressIndicator():SizedBox(),
                  Text(
                    dateText,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
  //-----------
  appointmentDialog(Size size,DateTime date) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "appointments"),
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text(
              getTranslated(context, "appointmentRegister"),
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            Text(
              // date.toString(),
              // DateTime.parse(date.toString()).toLocal().toString(),
              '${new DateFormat('dd MMM yyyy, hh:mm').format(DateTime.parse(date.toString()).toLocal())}',
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 15.0,
                fontWeight: FontWeight.normal,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context,true);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  Future<void>addAppointment(DateTime date)async {
    print("kkkkk15");
    try {

      date = date.toUtc();
      String appointmentId = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(
          appointmentId).set({
        'appointmentId': appointmentId,
        'appointmentStatus': 'open',
        'consultType':widget.consultType,
        'remainingCallNum':widget.currentNumber,
        'type':'valid',
        'lessonTime':10,
        'allowCall':false,
        'timestamp': DateTime.now().toUtc(),
        'timeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
        'secondValue': DateTime(
            date.year,
            date.month,
            date.day,
            date.hour,
            date.minute,
            date.second,
            date.millisecond).millisecondsSinceEpoch,
        'appointmentTimestamp': DateTime(
            date.year,
            date.month,
            date.day,
            date.hour,
            date.minute,
            date.second,
            date.millisecond),
        'utcTime': date.toString(),
        'consultChat': 0,
        'userChat': 0,
        'callCost':0.0,
        'isUtc': true,
        'orderId': widget.order.orderId,
        'callPrice': widget.order.callPrice,
        'consult': {
          'uid': widget.consultant.uid,
          'name': widget.consultant.name,
          'image': widget.consultant.photoUrl,
          'phone': widget.consultant.phoneNumber,
          'countryCode': widget.consultant.countryCode,
          'countryISOCode': widget.consultant.countryISOCode,
        },
        'user': {
          'uid': widget.loggedUser.uid,
          'name': widget.loggedUser.name,
          'image': widget.loggedUser.photoUrl,
          'phone': widget.loggedUser.phoneNumber,
          'countryCode': widget.loggedUser.countryCode,
          'countryISOCode': widget.loggedUser.countryISOCode,

        },
        'date': {
          'day': date.day,
          'month': date.month,
          'year': date.year,
        },
        'time': {
          'hour': date.hour,
          'minute': date.minute,
        },
      }).then((value) async {
        await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(
            widget.order.orderId).set({
          'orderStatus': widget.currentNumber>0?"open":"completed",
          'remainingCallNum': widget.currentNumber>0?widget.currentNumber:0,
        }, SetOptions(merge: true)).then((value) async {

        }).catchError((err) {
        });
      }).catchError((err) {
      });



//========================
      todayAppointmentList.removeAt(selectedCard);
      await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid!).set({
        'todayAppointmentList': todayAppointmentList,
      }, SetOptions(merge: true));
      setState(() {
        selectedCard=-1;
      });
      Navigator.pop(context);
      appointmentDialog(MediaQuery
          .of(context)
          .size, date);
    }catch(e)  {
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath).doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'payUrl':'',
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "addAppointment",
      });
    }
  }
  addEvent(String eventName,Map eventValues){
    AppsflyerSdk appsflyerSdk;
    if(Platform.isIOS) {
      Map<String, Object> appsFlyerOptions =  {
        "afDevKey": "mrP9nrMmbUYnkWEwtkrTmF",
        "afAppId": "id1515745954",
        "isDebug": true
      } ;
      appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true
      );
    }
    else {
      Map<String, Object> appsFlyerOptions =  {
        "afDevKey": "mrP9nrMmbUYnkWEwtkrTmF",
        "isDebug": true
      } ;
      appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true
      );
    }
    appsflyerSdk.logEvent(eventName, eventValues);

  }
  getDate() async {
    print("kkkkk");
    try{
      if(DateTime(selectedDate.year, selectedDate.month, selectedDate.day).isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
          ||(!widget.consultant.workDays!.contains(selectedDate.weekday.toString())))
       {
         print("kkkkk000");
         setState(() {
           loadDates=false;
           todayAppointmentList=[];
           dateText=getTranslated(context,"selectData");
         });
       }
      else
      {
        print("kkkkk11");
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid!).get();
        if(documentSnapshot!=null&&documentSnapshot.exists){
          ConsultDays consultDays = ConsultDays.fromMap(documentSnapshot.data() as Map);
          List<dynamic> appointmentList=[];

          for(int start=0;start<consultDays.todayAppointmentList!.length;start++)
          {
            print(DateTime.now());
            print("---------");
            print(DateTime.parse(consultDays.todayAppointmentList![start]).toLocal());
            if(DateTime.parse(consultDays.todayAppointmentList![start]).toLocal().isAfter(DateTime.now())) {
              appointmentList.add(consultDays.todayAppointmentList![start]);
            }
          }
          setState(() {
            loadDates=false;
            todayAppointmentList=appointmentList;
            if(todayAppointmentList.length==0)
              dateText=getTranslated(context,"noAppointment");
          });
        }
        else {
          print("kkkkk144444444444");
          var from = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,widget.localFrom);
          var to = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,widget.localTo);
          var ttt=(to.difference(from).inHours).round();
          if(ttt<=0) {
             to = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,24);
             ttt=(to.difference(from).inHours).round();
          }
          List<dynamic> appointmentList=[];
          //var lessonTime=10;
          var lessonMintes=10;
          print("11111---------");
          print(from);
          print(to);
          for(int start=0;start<ttt*6;start++)
          {

            print("---------");
            if(from.add(Duration( minutes: start*lessonMintes)).isAfter(DateTime.now())) {
              var value=from.add(Duration( minutes: start*lessonMintes)).toUtc().toString();
              appointmentList.add(value);
              print(value);
            }
          }
          print("kkkkk15");
          await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(time+"-"+widget.consultant.uid!).set({
            'id':time+"-"+widget.consultant.uid!,
            'day': time,
            'date': DateTime(selectedDate.year, selectedDate.month, selectedDate.day).millisecondsSinceEpoch,
            'consultUid':widget.consultant.uid,
            'todayAppointmentList': appointmentList,
          });
          setState(() {
            loadDates=false;
            todayAppointmentList=appointmentList;
          });
        }
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "getDate",
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try{
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          time = DateFormat('yyyy-MM-dd').format(picked);
          displayedTime=time;
          loadDates=true;
          todayAppointmentList=[];
          dateText=getTranslated(context,"load");
        });
        getDate();
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectDate",
      });
    }
  }
  Future<Null> _selectHijriDate(BuildContext context) async {
    try{
      final HijriCalendar? picked = await showHijriDatePicker(
        context: context,
        initialDate: new HijriCalendar.now(),
        lastDate: new HijriCalendar()
          ..hYear = 1445
          ..hMonth = 9
          ..hDay = 25,
        firstDate: new HijriCalendar()
          ..hYear = 1438
          ..hMonth = 12
          ..hDay = 25,
        initialDatePickerMode: DatePickerMode.day,
      );
      if (picked != null) {
        setState(() {
          selectedDate = HijriCalendar().hijriToGregorian( picked.hYear, picked.hMonth, picked.hDay);
          time = DateFormat('yyyy-MM-dd').format(selectedDate);
          displayedTime = picked.toString();
          loadDates = true;
          todayAppointmentList = [];
          dateText = getTranslated(context, "load");
        });
        getDate();
      }
    }catch(e){
      print("startnew12ddd"+e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectHijriDate",
      });
    }
  }
}
