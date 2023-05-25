/*

import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/models/payInfo.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../widget/processing_dialog.dart';
import '../widget/product_added_dialog.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';
class PayInfo2Screen extends StatefulWidget {
  final String consultUid;


  const PayInfo2Screen({Key? key, required this.consultUid}) : super(key: key);
  @override
  _PayInfo2ScreenState createState() => _PayInfo2ScreenState();
}

class _PayInfo2ScreenState extends State<PayInfo2Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> adminMap = Map();
  var image;
  var selectedImage;
  bool isAdding=false,load=true;
  PayInfo consult=new PayInfo();
  late GroceryUser user;
  @override
  void initState() {
    super.initState();
    getConsultDetails();


  }
  Future<void> getConsultDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).get();
    PayInfo currentUser = PayInfo.fromMap(documentSnapshot.data() as Map);

    DocumentSnapshot documentSnapshotUser = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultUid).get();
    GroceryUser userData = GroceryUser.fromMap(documentSnapshotUser.data() as Map);
    setState(() {
      consult=currentUser;
      user=userData;
      load=false;
    });

  }




  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding=true;
      });
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'id':widget.consultUid,
        'businessNameAr': consult.businessNameAr,
        'businessNameEn': consult.businessNameEn,
        'entityNameAr': consult.entityNameAr,
        'entityNameEn': consult.entityNameEn,
        'email': consult.email,
        'iban': consult.iban,
        'brandNameAr': "رؤيا",
        'brandNameEn': "dream",
      }, SetOptions(merge: true));
     addBusiness();

    }

  }


  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.red.shade500,
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
        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
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
                                'assets/applicationIcons/awesome-arrow-right.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "paymentInfo"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                        ),



                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),

          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 5),
            child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
              decoration: BoxDecoration(
                border: Border.all( color: AppColors.pink, width: 1, ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                getTranslated(context, "step2"),
                textAlign:TextAlign.left,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 11.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          load?CircularProgressIndicator():Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10,),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: consult.businessNameAr,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.businessNameAr=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.perm_identity),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"businessNameAr"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.businessNameEn,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.businessNameEn=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.person),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"businessNameEn"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.entityNameAr,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.entityNameAr=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.home_repair_service_outlined),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"entityNameAr"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.entityNameEn,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.entityNameEn=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.home_repair_service),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"entityNameEn"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.email,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.email=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.alternate_email_outlined),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"email"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.iban,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.iban=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
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
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          prefixIcon: Icon(Icons.comment_bank_rounded),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: "IBAN",//getTranslated(context,"iban"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      isAdding?Center(child: CircularProgressIndicator()):Container(
                        height: 45.0,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: MaterialButton(
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

                              Text(
                                getTranslated(context, "save"),
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  addBusiness() async {
    String responseBody="";
    try{

      final uri = Uri.parse('https://api.tap.company/v2/business');
      final headers = {
        'Content-Type': 'application/json',
         'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_NmMSlUV8qnQtiTLW6yxYzeEw",
        'Authorization':"Bearer sk_live_evQF3d9g6BKbGR0LxEO1qcyV",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      Map<String, dynamic> body ={
        "name": {
            "en": consult.businessNameEn,
            "ar": consult.businessNameAr
            },
        "type": "ind",
        "entity": {
            "legal_name": {
            "en":consult.entityNameEn,
            "ar": consult.entityNameAr
            },
        "country": user.countryISOCode,
        "bank_account": {
        "iban": consult.iban
        }
        },
        "contact_person": {
        "name": {
            "title": "Mr",
            "first": consult.fullName!.split(" ")[0],
            "middle":consult.fullName!.split(" ")[1],
            "last": consult.fullName!.split(" ")[2],
          },
        "contact_info": {
        "primary": {
        "email": consult.email,
        "phone": {
        "country_code":user.countryCode!.replaceAll("+", "").trim(),
        "number": user.phoneNumber!.replaceAll(user.countryCode!, "").trim(),
        }
        }
        },
        },
        "brands": [
        {
        "name": {
        "en": "dream",
        "ar": "رؤيا"
        },
        "sector": [
        "Media",
        ],
        "website": "https://www.flexwares.company/",
        "social": [
        "https://twitter.com/flexwares",
        "https://www.linkedin.com/company/flexwares/"
        ],

        }
        ],
        "post": {
        "url": "http://flexwares.company/post_url"
        },
        "metadata": {
        "mtd": "metadata"
        }
        };
      print("bbbbbbbb0");
      print(body);
      String jsonBody = json.encode(body);
      print(jsonBody);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
       responseBody = response.body;
      print("bbbbbbbb01111");
      print(responseBody);
      var res = json.decode(responseBody);
      print("bbbbbbbb01111222222");
      print(res['id']);
      print(res['entity']['id']);
      consult.businessId=res['id'];
      consult.entityId=res['entity']['id'];
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'businessId':consult.businessId,
        'entityId': consult.entityId,
      }, SetOptions(merge: true));
      addDestination();
    }catch(e){
      print("xxxxx"+responseBody.toString());
      errorLog("addBusiness",responseBody);
      setState(() {
        isAdding=false;
      });
      //showSnack(getTranslated(context, "failed"),context);
      showSnack(responseBody.toString(),context);
    }

  }
  addDestination() async {
   String  responseBody="";
    try{

      final uri = Uri.parse('https://api.tap.company/v2/destination');
      final headers = {
        'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_NmMSlUV8qnQtiTLW6yxYzeEw",
        'Authorization':"Bearer sk_live_evQF3d9g6BKbGR0LxEO1qcyV",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      Map<String, dynamic> body ={
        "display_name": consult.businessNameEn,
        "business_id": consult.businessId,
        "business_entity_id": consult.entityId,
        "bank_account": {
          "iban": consult.iban
        }
      };
      print("bbbbbbbb0distnation");
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
       responseBody = response.body;
      print("bbbbbbbbdestinationId");
      print(responseBody);
      var res = json.decode(responseBody);
      print("bbbbbbbb01111222222");
      print(res['id']);
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'destinationId':res['id'],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultUid).set({
        'destinationId':res['id'],
      }, SetOptions(merge: true));
      setState(() {
        isAdding=false;
      });
      //Navigator.pop(context);
      //Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
    }catch(e){
      print("xxxxx"+responseBody.toString());
      errorLog("addDestination",responseBody.toString());
      setState(() {
        isAdding=false;
      });
      showSnack(e.toString(),context);
    }

  }
  errorLog(String function,String error)async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': user == null ? "phone" : user.phoneNumber,
      'screen': "payInfo2",
      'function': function,
    });
  }
}*/
