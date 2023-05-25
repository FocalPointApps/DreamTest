

import 'dart:io';

import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/colorsFile.dart';
import '../main.dart';
import 'appStoreScreen.dart';

class ForceUpdateScreen extends StatefulWidget {

  const ForceUpdateScreen({Key? key}) : super(key: key);
  @override
  _ForceUpdateScreenState createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  String lang="ar";
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang=getTranslated(context, "lang");
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body:  ListView(
        children: <Widget>[
          Container(
              height: size.height*.5,
              width: size.width,
              color: Colors.white,
              child: Center(child: Image.asset('assets/applicationIcons/dreamLogo.png',width: 100,height: 100,))
          ),
          Container(
            height: size.height*.5,
            width: size.width,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children:  [

                SizedBox(height: 20,),
                Padding(
                  padding: const EdgeInsets.only(left: 10,right: 10),
                  child: Center(
                    child: Text(
                      getTranslated(context, "lastVersion"),
                      maxLines: 3,
                      textAlign:TextAlign.center ,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.grey,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  width: size.width*.8,
                  height: 45.0,
                  child: MaterialButton(
                    onPressed: () async {

                      String url = Platform.isIOS ?"https://apps.apple.com/us/app/id1515745954": "https://play.google.com/store/apps/details?id=com.app.dreamTest";
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: Text(
                      getTranslated(context, "install"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],),
          ),
        ],
      ),
    );
  }
 
}
