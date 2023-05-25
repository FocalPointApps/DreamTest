

import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body:  Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: size.height*.20,),
          Image.asset('assets/applicationIcons/welcome.png',width: 200,height: 200,),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              getTranslated(context, "firstApp"),
              textAlign: TextAlign.center,
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                color: AppColors.pink,
                fontSize: 15.0,
              ),
            ),
          ),
          SizedBox(height: size.height*.10,),
          Center(
            child: InkWell(onTap: (){
              Navigator.popAndPushNamed(context, '/home');
            },
              child: Container(
                width: size.width*.8,
                height: 45.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.linear1,
                        AppColors.linear2,
                        AppColors.linear2,
                      ],
                    )
                ),
                child: Center(
                  child: Text(
                    getTranslated(context, "yourDream"),
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.white,
                      fontSize: 18.0,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }

}
