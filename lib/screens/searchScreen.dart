
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/colorsFile.dart';
import 'account_screen.dart';
import 'notification_screen.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({Key? key,}) : super(key: key);
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = new TextEditingController();
   GroceryUser? loggedUser;
  bool load=false;
  late String lang,userImage,theme="light";
  String name ="";
  late Query filterQuery;
  @override
  void initState() {
    super.initState();

    getCurrentUser();

  }
  getCurrentUser() async {
  if(FirebaseAuth.instance.currentUser!=null) {
    var __user = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid).get();
    loggedUser=GroceryUser.fromMap(__user.data() as Map);
  }
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


  @override
  Widget build(BuildContext context) {
    lang=getTranslated((context), "lang");
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      key:_scaffoldKey,
      body:Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
                width: size.width,
                // height: 80,
                // color: Colors.white,
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
                                  getTranslated(context,"arrow"),
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getTranslated(context, "search"),
                            textAlign:TextAlign.left,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                          ),



                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 2, width: size.width * .9)),

            SizedBox(height: 25,),
            Center(child: Container(height: 50,width: size.width*.9,child:
             Container(

              padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,//ِtheme=="light"?Colors.white:Color(0xff3f3f3f),
                borderRadius: BorderRadius.circular(10.0),

              ),
              child: TextField(
                onChanged: (val) => initiateSearch(val),
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly:false,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                  fontSize: 14.5,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 25.0,
                  ),
                  border: InputBorder.none,
                  hintText: getTranslated(context, "nameSearch"),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 14.5,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            ),),
            SizedBox(height: 15,),
            name==""?Expanded(
              child: Center(
                  child: SizedBox()
              ),
            ):Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.gridView,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 150,
                    childAspectRatio: 1.8),
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 16.0, top: 1.0),
                itemBuilder: (context, documentSnapshot, index) {
                  return  ConsultantListItem(
                      consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser: loggedUser,
                      consultType:documentSnapshot[index]['voice']?"voice":"chat"
                  );
                },

                query:filterQuery,
                isLive: true,
              ),
            )


          ],
        ),
        /* Positioned(
            right: 0.0,
            top: size.height*.24,
            left: 0,
            child:  Center(child: Container(height: 50,width: size.width*.9,child:
               Container(
                  //height: 35.0,
                  //width: size.width*.45,
                  padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
                  decoration: BoxDecoration(
                    color: theme=="light"?Colors.white:Color(0xff3f3f3f),
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.6),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (val) => initiateSearch(val),
                    keyboardType: TextInputType.text,
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    enableInteractiveSelection: true,
                    readOnly:false,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      fontSize: 14.5,
                      color: Colors.black87,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).primaryColor,
                        size: 25.0,
                      ),
                      border: InputBorder.none,
                      hintText: getTranslated(context, "nameSearch"),
                      hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        color: Theme.of(context).primaryColor,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ),)
        ),*/
      ]),
    );
  }
  void showNoNotifSnack(String text) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
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
      duration: Duration(milliseconds: 1500),
      icon: Icon(
        Icons.notification_important,
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
  Future<void> initiateSearch(String val) async {

    print("search event");
    String eventName = "af_search";
    Map eventValues = {
      "af_search_string": val,
      "af_content_list": [val],
    };
    addEvent(eventName, eventValues);
    await FirebaseAnalytics.instance.logSearch( searchTerm:val);
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=getTranslated(context, 'lang')=="ar"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('consultName.searchIndexAr', arrayContains: name)
          .orderBy('rating', descending: true):
      getTranslated(context, 'lang')=="en"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('consultName.searchIndexEn', arrayContains: name)
          .orderBy('rating', descending: true):
      getTranslated(context, 'lang')=="fr"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('consultName.searchIndexFr', arrayContains: name)
          .orderBy('rating', descending: true):FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('consultName.searchIndexIn', arrayContains: name)
          .orderBy('rating', descending: true);
    });
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
}
