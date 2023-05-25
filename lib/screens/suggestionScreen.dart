
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:webview_flutter/webview_flutter.dart';

class SuggestionScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const SuggestionScreen({Key? key, this.loggedUser}) : super(key: key);

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false;
   String? title,des;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
        body: Stack(children: <Widget>[
          Column(
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
                                    getTranslated(context, "arrow"),
                                    width: 30,
                                    height: 30,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              getTranslated(context, "suggestions"),
                              textAlign:TextAlign.left,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                            ),



                          ],
                        ),
                      ))),
              Center(
                  child: Container(
                      color: AppColors.lightGrey, height: 2, width: size.width * .9)),


              Expanded(
                child: ListView(padding:const EdgeInsets.only(left: 20,right: 20),
                    children: <Widget>[ Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(padding: EdgeInsets.only(top:20,bottom: 20),
                                height: size.height * 0.20,
                                child:Image.asset('assets/applicationIcons/suggetionImage.png',
                                )
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                            Text(
                              getTranslated(context, "suggestionText"),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 6,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:AppColors.grey ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 10,bottom: 10),
                              child: SizedBox(height: 35,
                                child: Theme(
                                  data: new ThemeData(
                                    primaryColor: Colors.redAccent,
                                    primaryColorDark: Colors.red,

                                  ),
                                  child: TextFormField(
                                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 10.0,color:AppColors.grey, ),
                                      textAlign: TextAlign.center,
                                      cursorColor: AppColors.pink,
                                      keyboardType: TextInputType.text,
                                      validator: (String? val) {
                                        if (val!.trim().isEmpty) {
                                          return getTranslated(context, 'required');
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {
                                        title=val!;
                                      },
                                      enableInteractiveSelection: true,
                                      decoration: inputDecoration()
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20,),
                            Container(height: 150,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                //color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: AppColors.lightGrey,width: 1),

                              ),
                              child: Center(
                                child:Container(width: size.width*.7,
                                  child: TextFormField(
                                    maxLines: 7,
                                    maxLength: 300,
                                    textAlign: TextAlign.center,
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 10.0,color:AppColors.grey, ),
                                    cursorColor: Colors.black,
                                    initialValue: des,
                                    keyboardType: TextInputType.multiline,

                                    onSaved: (val) {
                                      des=val!;
                                    },
                                    decoration: new InputDecoration(
                                      counterStyle: TextStyle( color: Colors.grey,
                                        fontSize: 10,),
                                      hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                      hintText: getTranslated(context,'description'),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,

                                      //  hintText: sLabel
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 40,
                            ),
                            InkWell(onTap: (){
                              save();
                            },
                              child: Container(
                                height: 45.0,
                                width: size.width*.6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.linear1,
                                        AppColors.linear2,
                                        AppColors.linear2,
                                      ],
                                    )
                                ),
                                child: saving?Center(child: CircularProgressIndicator()): Center(
                                  child: Text(
                                    getTranslated(context, "save"),
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                      color: Colors.white,
                                      fontSize: 18.0,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
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
                    ]),
              ),
            ],
          ),

        ]));
  }
  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        String suggestionId=Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.suggestionsPath)
            .doc(suggestionId)
            .set({
          "userUid":widget.loggedUser!.uid,
          'suggestionId': suggestionId,
          'status': false,
          'sendTime': Timestamp.now(),
          'title': title,
          'desc':des,
          'userData': {
            'uid': widget.loggedUser!.uid,
            'name': widget.loggedUser!.name,
            'image': widget.loggedUser!.photoUrl,
            'phone': widget.loggedUser!.phoneNumber,
          },

        });
        setState(() {
          saving = false;
        });
        addingDialog(MediaQuery.of(context).size,true);
      } catch (e) {
        print("rrrrrrrrrr" + e.toString());
      }
    }
  }
  addingDialog(Size size,bool status) {

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
              getTranslated(context, "suggestions"),
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
              getTranslated(context, "thanks"),
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
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                          (route) => false,
                    );
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

  void showSnakbar(String s,bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  InputDecoration inputDecoration(){
    return InputDecoration(
        //fillColor: Colors.white,
        hintText: getTranslated(context,'title'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1.0,
          ),
        )

    );
  }
}
