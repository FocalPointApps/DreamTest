
import 'dart:convert';
import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

import '../localization/language_constants.dart';

class AddAppointmentScreen extends StatefulWidget {

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen>with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false;
   String? userPhone,consultPhone,theme="light";
   String? price,callNum,dropdownOrderTypeValue;
  List<KeyValueModel> _orderTypeArray = [
    KeyValueModel(key: "voice", value: "مكالمات"),
    KeyValueModel(key: "chat", value: "رسائل"),
  ];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            height:100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.5),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.arrow_back,
                              color: theme=="light"?Colors.white:Colors.black,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Text(
                        getTranslated(context, "addOrder"),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    SizedBox(
                      height: 25.0,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        userPhone=val!;
                      },
                     enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "userPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        consultPhone=val!;
                      },
                     enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "consultPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                            color: theme=="light"?Colors.white:Colors.transparent,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: DropdownButton<String>(
                            hint: Text(
                              getTranslated(context, "orderType"),
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                //color: Colors.black,
                                fontSize: 15.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            underline: Container(),
                            isExpanded: true,
                            value: dropdownOrderTypeValue,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.black),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Color(0xFF3b98e1),
                              fontSize: 13.0,
                              letterSpacing: 0.5,
                            ),
                            items: _orderTypeArray
                                .map((data) => DropdownMenuItem<String>(
                                child: Text(
                                  data.value!,
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: Colors.black,
                                    fontSize: 15.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                value: data.key.toString() //data.key,
                            ))
                                .toList(),
                            onChanged: (String? value) {
                              print("selectedValue");
                              print(value);
                              setState(() {
                                dropdownOrderTypeValue = value!;

                              });
                            },
                          ),
                        )),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        callNum=val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "packageCall"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        price=val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          // color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "price"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      height: 45.0,
                      width: double.infinity,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 0.0),
                      child: saving?Center(child: CircularProgressIndicator()):MaterialButton(
                        onPressed: () {
                          save();
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.send,
                              color: theme=="light"?Colors.white:Colors.black,
                              size: 20.0,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              getTranslated(context, "save"),
                              style: GoogleFonts.poppins(
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  save() async {
    GroceryUser user, consult;
    List<GroceryUser> users = [],consults=[];
    print("fake1111");
    if (_formKey.currentState!.validate()&&dropdownOrderTypeValue!=null) {
      print("fake111122");
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where('phoneNumber', isEqualTo: userPhone,).get();
        print("fake1111223");
        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (users.length > 0)
          user = users[0];
        else {
          print("usersnull");
          print(userPhone);
        }
        //get consultdata
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where('phoneNumber', isEqualTo: consultPhone).get();
        print("fake1111224");
        print(querySnapshot2.docs.length);
        print(consultPhone);
        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (consults.length > 0)
          consult = consults[0];
        else
          print("fake1111225");
          DateTime date = DateTime.now();
          if (users.length > 0 && consults.length > 0) {
            String orderId = Uuid().v4();
            dynamic callPrice = double.parse(price.toString()) /
                int.parse(callNum!);
            //add order
            print("fake1111226");
            await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(
                orderId).set({
              'orderStatus': 'open',
              'orderId': orderId,
              'consultType': dropdownOrderTypeValue,
              'utcTime': date.toUtc().toString(),
              'orderTimestamp': Timestamp.now(),
              'orderTimeValue': DateTime(date.year, date.month, date.day)
                  .millisecondsSinceEpoch,
              'packageId': "",
              'promoCodeId': "",
              'remainingCallNum': int.parse(callNum!),
              'packageCallNum': int.parse(callNum!),
              'answeredCallNum': 0,
              'callPrice': callPrice,
              "payWith": "support",
              "platform": Platform.isIOS ? "iOS" : "Android",
              'price': price.toString(),
              'consult': {
                'uid': consults[0].uid,
                'name': consults[0].name,
                'image': consults[0].photoUrl,
                'phone': consults[0].phoneNumber,
              },
              'user': {
                'uid': users[0].uid,
                'name': users[0].name,
                'image': users[0].photoUrl,
                'phone': users[0].phoneNumber,

              },
              'date': {
                'day': date
                    .toUtc()
                    .day,
                'month': date
                    .toUtc()
                    .month,
                'year': date
                    .toUtc()
                    .year,
              },
            });
            //add event
            print("fake1111227");
            print("af_purchase event");
            String eventName = "af_purchase";
            Map eventValues = {
              "af_revenue": price.toString(),
              "af_price": price.toString(),
              "af_content_id": consults[0].uid,
              "af_order_id": orderId,
              "af_currency": "USD",
            };
            print("fake1111228");
            addEvent(eventName, eventValues);
            await FirebaseAnalytics.instance.logPurchase(
                currency: "USD",
                value: double.parse(price.toString()),
                affiliation: consults[0].uid,
                transactionId: orderId
            );
            await FirebaseAnalytics.instance.logEvent(
                name: "payInfo", parameters: {
              "success": true,
              "reason": "success",
              "userUid": users[0].uid
            });
            // updateFocal(double.parse(price));
            //add appointment
            int currentNumber = int.parse(callNum!);
            String appointmentId = Uuid().v4();
            print("fake1111229");
            await FirebaseFirestore.instance.collection(Paths.appAppointments)
                .doc(
                appointmentId).set({
              'appointmentId': appointmentId,
              'appointmentStatus': 'open',
              'consultType': dropdownOrderTypeValue,
              'remainingCallNum': (currentNumber - 1) > 0
                  ? (currentNumber - 1)
                  : 0,
              'type': 'support',
              'lessonTime': 10,
              'allowCall': false,
              'callCost': 0.0,
              'timestamp': DateTime.now().toUtc(),
              'timeValue': DateTime(date.year, date.month, date.day)
                  .millisecondsSinceEpoch,
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
              'utcTime': date.toUtc().toString(),
              'consultChat': 0,
              'userChat': 0,
              'isUtc': true,
              'orderId': orderId,
              'callPrice': callPrice,
              'consult': {
                'uid': consults[0].uid,
                'name': consults[0].name,
                'image': consults[0].photoUrl,
                'phone': consults[0].phoneNumber,
              },
              'user': {
                'uid': users[0].uid,
                'name': users[0].name,
                'image': users[0].photoUrl,
                'phone': users[0].phoneNumber,

              },
              'date': {
                'day': date
                    .toUtc()
                    .day,
                'month': date
                    .toUtc()
                    .month,
                'year': date
                    .toUtc()
                    .year,
              },
              'time': {
                'hour': date.hour,
                'minute': date.minute,
              },
            })
                .then((value) async {
              print("kkkkk16");
              print("fake11112211");
              await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(
                  orderId).set({
                'orderStatus': (currentNumber - 1) > 0 ? "open" : "completed",
                'remainingCallNum': (currentNumber - 1) > 0 ? (currentNumber -
                    1) : 0,
              }, SetOptions(merge: true));
            });
            //update user order numbers
            int userOrdersNumbers = 1;
            dynamic payedBalance = double.parse(price.toString());
            if (users[0].ordersNumbers != null)
              userOrdersNumbers = users[0].ordersNumbers! + 1;
            if (users[0].payedBalance != null)
              payedBalance = users[0].payedBalance + payedBalance;
            print("fake111122555");
            await FirebaseFirestore.instance.collection(Paths.usersPath).doc(
                users[0].uid).set({
              'ordersNumbers': userOrdersNumbers,
              'payedBalance': payedBalance,
            }, SetOptions(merge: true));
            //-----------
            appointmentDialog(MediaQuery
                .of(context)
                .size, date.toString(), true);
          }
          else {
            appointmentDialog(MediaQuery
                .of(context)
                .size, getTranslated(context, 'invalidNumbers'), false);
          }
          setState(() {
            saving = false;
          });

      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }
    else
      print("fake11112");

  }
  addEvent(String eventName,Map eventValues) async {
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
  Future<void> updateFocal(double value) async {
    try {
      print("updateFocal start");
      await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").set({
        'orderNum': FieldValue.increment(1),
        'totalEarn':FieldValue.increment(value),
      }, SetOptions(merge: true));
      Map notifMap = Map();
      notifMap.putIfAbsent('price', () => value.toString());
      var response = await http.post(
        Uri.parse('https://us-central1-focalpoint-277d2.cloudfunctions.net/updateData'),
        body: notifMap,
      );
      print("updateFocal response");
      print(response.body);
      var res = jsonDecode(response.body);

    } catch (e) {
      print("updateFocal error  " + e.toString());
    }
  }
  appointmentDialog(Size size,String data,bool status) {

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
              getTranslated(context, "orders"),
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
              status?getTranslated(context, "orderAdded"):getTranslated(context, "error"),
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
                color: status?Colors.black87:Colors.red,
              ),
            ),
            Text(
              data,
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
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
}
