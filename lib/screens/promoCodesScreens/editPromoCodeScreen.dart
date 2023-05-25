

import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/promoCode.dart';

import '../../main.dart';
import '../../models/user.dart';

class EditPromoCodeScreen extends StatefulWidget {
  final PromoCode promoCode;

  const EditPromoCodeScreen({Key? key, required this.promoCode}) : super(key: key);
  @override
  _EditPromoCodeScreenState createState() => _EditPromoCodeScreenState();
}

class _EditPromoCodeScreenState extends State<EditPromoCodeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String owner,code,discount,usedNumber,id,theme;
  bool isAdding=false,activeCode=false;
  late String dropdownLangValue;
  List<KeyValueModel> _langArray = [
    KeyValueModel(key: "primary", value: "primary"),
    KeyValueModel(key: "promotion", value: "promotion"),
    KeyValueModel(key: "default", value: "default"),
  ];
  @override
  void initState() {
    super.initState();
    isAdding = false;
    dropdownLangValue=widget.promoCode.type==null?"default":widget.promoCode.type!;
    id=widget.promoCode.promoCodeId;
    owner=widget.promoCode.ownerName;
    code=widget.promoCode.code;
    discount=widget.promoCode.discount.toString();
    usedNumber=widget.promoCode.usedNumber.toString();
    activeCode=widget.promoCode.promoCodeStatus;
  }
  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }
  addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding=true;
      });
      await FirebaseFirestore.instance.collection(
          Paths.promoPath).doc(id).set({
        'discount': int.parse(discount),
        'code': code,
        'ownerName': owner,
        'usedNumber': int.parse(usedNumber),
        'promoCodeId': id,
        'promoCodeStatus': activeCode,
        'promoCodeTimestamp':Timestamp.now(),
        'type':dropdownLangValue
      }, SetOptions(merge: true));
      if(activeCode!=widget.promoCode.promoCodeStatus)
      {
        if(activeCode==true)
          await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").set({
            'activePromoCodes': FieldValue.increment(1),
            'notActivePromoCodes': FieldValue.increment(-1),
          }, SetOptions(merge: true));
        else
          await FirebaseFirestore.instance.collection(Paths.appAnalysisPath).doc("TgWCp3B22sbkl0Nm3wLx").set({
            'activePromoCodes': FieldValue.increment(-1),
            'notActivePromoCodes': FieldValue.increment(1),
          }, SetOptions(merge: true));
      }

      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
    } else {
      showSnack('Please fill all the details!', context);
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
        style: GoogleFonts.poppins(
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
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
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
                          splashColor: Colors.white.withOpacity(0.6),
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
                      width: 8.0,
                    ),
                    Text(
                      getTranslated(context, "editPromo"),
                      style: GoogleFonts.poppins(
                        color: theme=="light"?Colors.white:Colors.black,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding:const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: <Widget>[
                SizedBox(height: 20,),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: code,
                        /* validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },*/
                        onSaved: (val) {
                          code=val!;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        readOnly: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"promoCodes"),
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
                        initialValue: owner,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          owner=val!;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"owner"),
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
                        initialValue: discount,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          discount=val!;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"discount"),
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
                                getTranslated(context, "type"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  //color: Colors.black,
                                  fontSize: 15.0,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              underline: Container(),
                              isExpanded: true,
                              value: dropdownLangValue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: Colors.black),
                              iconSize: 24,
                              elevation: 16,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Color(0xFF3b98e1),
                                fontSize: 13.0,
                                letterSpacing: 0.5,
                              ),
                              items: _langArray
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
                                  dropdownLangValue = value!;
                                });
                              },
                            ),
                          )),
                      SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "active"),
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context).primaryColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Switch(
                              value: activeCode,
                              onChanged: (value) {
                                setState(() {
                                  activeCode = value;
                                });
                              },
                              activeTrackColor: Colors.purple,
                              activeColor: Colors.orangeAccent,
                            ),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      isAdding?Center(child: CircularProgressIndicator()):Center(
                        child: Container(
                          height: 45.0,
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: () {

                              addCategory();
                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FaIcon(
                                  FontAwesomeIcons.atom,
                                  color: theme=="light"?Colors.white:Colors.black,
                                  size: 20.0,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  getTranslated(context,"save"),
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
                      ),
                      SizedBox(
                        height: 15.0,
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
}
