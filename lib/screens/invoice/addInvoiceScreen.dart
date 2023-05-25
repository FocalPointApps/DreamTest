

import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/InvoiceModel.dart';
import 'package:grocery_store/screens/invoice/allInvoicesScreen.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../promoCodesScreens/allPromoCodesScreen.dart';
import '../../widget/invicelistitemWidget.dart';

class AddInvoiceScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  AddInvoiceScreen({
    required this.loggedUser,
  });
  @override

  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late String owner,
      code,
      discount,
      theme = "light";
  bool createInvoiceDone = false, showEmail = true;


  @override
  void initState() {
    super.initState();
    createInvoiceDone = false;
  }


  TextEditingController nameController = TextEditingController();
  TextEditingController consultantNameController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var due, expire;
  late GroceryUser user;
  List<GroceryUser> users = [];
  List<String> paymentGatewayList = <String>['Tap Company', 'Stripe'];
  String gateWayValue = "Tap Company";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Scaffold(backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: 60, left: 30, right: 30),
            child: Column(
              //  crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 80),
                    color: Colors.black45,
                    width: 60,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(left: 80),
                    color: Colors.black45,
                    width: 100,
                    height: 1,
                  ),
                ),
                Text(getTranslated(context, "createInvoice"),
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor,
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 80),
                    color: Colors.black45,
                    width: 100,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 80),
                    color: Colors.black45,
                    width: 60,
                    height: 1,
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientName");
                    }
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    labelText: getTranslated(context, "clientName"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                 TextFormField(
                  controller: emailController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientEmail");
                    }
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    labelText: getTranslated(context, "clientaccount"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: phoneController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientPhone");
                    }
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    labelText: getTranslated(context, "phoneNumber"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                /* SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: expireDateController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterExpireDate");
                    }
                  },
                  onSaved: (val) {},
                  onTap: () {
                    showDatePicker(context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 3)),
                    ).then((value) {
                      print('hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeee22');
                      print(value);
                      expireDateController.text = value.toString();
                      expire = value?.millisecondsSinceEpoch;
                    });
                  },
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.datetime,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    labelText: getTranslated(context, "expireDate"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),*/
                SizedBox(
                  height: 30,
                ),
                TextFormField(
                  controller: priceController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterPrice");
                    }
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 15.0),
                    helperStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    errorStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 13.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    hintStyle: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black54,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                    labelText: getTranslated(context, "invoiceprice"),
                    labelStyle: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslated(context, 'gateway'), style: TextStyle(
                        color: AppColors.pink,
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 15
                    ),),
                    Container(
                        height: 40.0, width: size.width * .5,
                        decoration: BoxDecoration(
                            color: theme == "light" ? Colors.white : Colors
                                .transparent,
                            border: Border.all(
                              color: Colors.grey,
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: DropdownButton<String>(
                            hint: Text(
                              getTranslated(context, "selectStatus"),
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                //color: Colors.black,
                                fontSize: 15.0,
                                letterSpacing: 0.5,
                              ),
                            ),
                            underline: Container(),
                            isExpanded: true,
                            value: gateWayValue,
                            icon: Icon(Icons.keyboard_arrow_down,
                                color: Colors.black),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Color(0xFF3b98e1),
                              fontSize: 13.0,
                              letterSpacing: 0.5,
                            ),
                            items: paymentGatewayList
                                .map((data) =>
                                DropdownMenuItem<String>(
                                    child: Text(
                                      data.toString(),
                                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                        color: Colors.black,
                                        fontSize: 15.0,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    value: data.toString() //data.key,
                                ))
                                .toList(),
                            onChanged: (String? value) {
                              print(value);
                              setState(() {
                                gateWayValue = value!;
                              });
                            },
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          setState(() {
                            createInvoiceDone = true;
                          });
                        }

                       if (gateWayValue == "Tap Company") {
                          postTapInvoice(
                              email: emailController.text,
                              // expiry: expireDateController.text,
                              phone: phoneController.text,
                              price: priceController.text,
                              userName: nameController.text
                          );
                       }

                       else
                         {
                            setState(() {
                              showEmail = false;
                            });
                        postStripeInvoice(
                          // email: emailController.text,
                          // expiry: expireDateController.text,
                            phone: phoneController.text,
                            userName: nameController.text,
                            price: priceController.text
                        );
                      }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            createInvoiceDone == true
                                ? CircularProgressIndicator()
                                : Container(
                              width: size.width * .3,
                              height: size.height * .06,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "createInvoice"),
                                  style: TextStyle(
                                   fontFamily: getTranslated(context, 'fontFamily'),
                                    color: Colors.white,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * .05,),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: size.width * .3,
                              height: size.height * .06,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Theme
                                    .of(context)
                                    .primaryColor),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "endInvoice"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }



  postStripeInvoice({
    required String userName,
    required var phone,
    required var price
  }) async {

    String phones = phone + "@gmail.com";

    var res;

    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath)
          .where( 'phoneNumber', isEqualTo: phoneController.text, ).get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if(users.length>0)
      {
        user=users[0];
        var dueDate=DateTime.now().add(Duration(minutes: 10));
        var expireDate=DateTime.now().add(Duration(days: 3));

        try {
          var response = await http.post( Uri.parse(
              'https://us-central1-dream-43bb8.cloudfunctions.net/postInvoice'),
            body: {
              'name' :userName,
              'email':phones,
              'price': (double.parse(priceController.text) * 100).round().toString()
              //(double.parse(price) * 100).toString()
            },
          );

          String responseBody = response.body;
          res = json.decode(responseBody);
          print(res['messageData']);

        } catch (e) {
          print("createInvoice111  " + e.toString());
        }

        String invoiceId = res['messageData']['id'];
        await FirebaseFirestore.instance.collection(Paths.invoicePath) .doc(invoiceId).set({
          'user': {
            'uid': user.uid,
            'name': userName,
            'image': user.photoUrl,
            'phone': phone,
            'countryCode': user.countryCode,
            'countryISOCode': user.countryISOCode,
          },
          'id':res['id'],
          'expiry':expireDate,
          'email':phone + "@gmail.com",
          'price':priceController.text,
          'invoice':res['messageData']['hosted_invoice_url'],
          'timestamp':DateTime.now(),
          'platform':'Stripe',
          'invoiceId':invoiceId,
        }).then((value){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceCreatedDone"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          print(expireDate.microsecondsSinceEpoch);
          print(dueDate.microsecondsSinceEpoch);
          Navigator.pop(context);
        }).catchError((error){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceDataError"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            createInvoiceDone=false;
          });
        });

      }
      else{
        //flutter toast
        Fluttertoast.showToast(
          msg: getTranslated(context, "invoiceDataError"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          createInvoiceDone=false;
        });
      }

    }catch(e){
      Fluttertoast.showToast(
        msg: getTranslated(context, "invoiceCreatedError"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }



  postTapInvoice({
    required String userName,
    required var phone,
    required var email,
    required var price,
  }) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(
          Paths.usersPath)
          .where('phoneNumber', isEqualTo: phoneController.text,).get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if (users.length > 0) {
        user = users[0];
        var dueDate = DateTime.now().add(Duration(minutes: 10));
        var expireDate = DateTime.now().add(Duration(days: 3));
        final uri = Uri.parse('https://api.tap.company/v2/invoices');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': "Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
          'Connection': 'keep-alive',
          'Accept-Encoding': 'gzip, deflate, br'
        };
        String description = "فاتورة حجز طلب";
       // if (user.countryCode != null && user.countryCode == "+966")
         // description = " السعر شامل ضريبة القيمة المضافة";
        Map<String, dynamic> body = {
          "draft": false,
          "due": dueDate.microsecondsSinceEpoch,
          "expiry": expireDate.microsecondsSinceEpoch,
          "description": "فاتورة حجز طلب",
          "mode": "INVOICE",
          "note": description,
          "notifications": {
            "channels": [
              "SMS",
              "EMAIL"
            ],
            "dispatch": true
          },
          "currencies": [
            "USD"
          ],
          "metadata": {
            "udf1": "1",
            "udf2": "2",
            "udf3": "3"
          },
          "charge": {
            "receipt": {
              "email": true,
              "sms": true
            },
            "statement_descriptor": description
          },
          "customer": {
            "email": "$email",
            "first_name": userName,
            "last_name": ".",
            "middle_name": ".",
            "phone": {
              "country_code": " ",
              "number": "$phone"
            }
          },
          "order": {
            "amount": price,
            "currency": "USD",
            "items": [
              {
                "amount": price,
                "currency": "USD",
                "description": "order ",
                "discount": {
                  "type": "P",
                  "value": 0
                },
                "image": "",
                "name": "order ",
                "quantity": 1
              }
            ],
            /*  "shipping": {
              "amount": 1,
              "currency": "USD",
              "description": "test",
              "provider": "ARAMEX",
              "service": "test"
            },
            "tax": [
              {
                "description": "test",
                "name": "VAT",
                "rate": {
                  "type": "F",
                  "value": 1
                }
              }
            ]*/
          },
          "payment_methods": [
            ""
          ],
          "post": {
            "url": "http://your_website.com/post_url"
          },
          "redirect": {
            "url": "http://your_website.com/redirect_url"
          },
          "reference": {
            "invoice": "INV_00001",
            "order": "ORD_00001"
          }
        };
        String jsonBody = json.encode(body);
        final encoding = Encoding.getByName('utf-8');
        var response = await http.post(
          uri,
          headers: headers,
          body: jsonBody,
          encoding: encoding,
        );
        print("ggggg2222");
        String responseBody = response.body;
        print(responseBody);
        var res = json.decode(responseBody);
        String url = res['url'];
        String invoiceId = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.invoicePath).doc(
            invoiceId).set({
          'user': {
            'uid': user.uid,
            'name': userName,
            'image': user.photoUrl,
            'phone': phone,
            'countryCode': user.countryCode,
            'countryISOCode': user.countryISOCode,
          },
          'id': res['id'],
          'expiry': expireDate,
          'email': email,
          'price': priceController.text,
          'invoice': url,
          'timestamp': DateTime.now(),
          'platform':'Tap',
          "invoiceId": invoiceId,
        }).then((value) {
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceCreatedDone"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          print(expireDate.microsecondsSinceEpoch);
          print(dueDate.microsecondsSinceEpoch);
          Navigator.pop(context);
        }).catchError((error) {
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceDataError"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
          setState(() {
            createInvoiceDone = false;
          });
        });
      }
      else {
        //flutter toast
        Fluttertoast.showToast(
          msg: getTranslated(context, "invoiceDataError"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        setState(() {
          createInvoiceDone = false;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: getTranslated(context, "invoiceCreatedError"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

}
