
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import '../main.dart';

class RegisterTypeScreen extends StatefulWidget {
  @override
  _RegisterTypeScreenState createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }



  void showFailedSnakbar(String s) {
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white2,
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  iconSize: 20,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Image.asset(
                    getTranslated(context, "arrow"),
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
            Image.asset(
              'assets/applicationIcons/dreamLogo.png',
              width: 100,
              height: 100,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //CONSULTANT
                    builder: (context) => SignUpScreen(userType: "USER"),
                  ),
                );
              },
              child: Container(
                width: size.width * .65,
                height: size.height * 0.065,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.linear1,
                        AppColors.linear2,
                        AppColors.linear2,
                      ],
                    )),
                child: Center(
                  child: Text(
                    getTranslated(context, "registerAsClient"),
                    style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14.0,
                        fontWeight: FontWeight.normal),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    //CONSULTANT
                    builder: (context) => SignUpScreen(userType: "CONSULTANT"),
                  ),
                );
              },
              child: Column(
                children: [
                  Image.asset(
                    'assets/applicationIcons/regConsult.jpeg',
                    width: 32,
                    height: 30,
                  ),
                  Text(
                    getTranslated(context, "registerAsConsultant"),
                    style: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.black2,
                      fontSize: 14.0,
                      fontStyle:  FontStyle.normal,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(left: size.width*.10,right: size.width*.10),
                    child: Center(
                      child: Text(
                        getTranslated(context, "noteDuringRegisterAsConsultant"),
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.grey,
                          fontWeight: FontWeight.w300,
                          fontSize: 13.0,
                          fontStyle:  FontStyle.normal,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              // Rectangle 355
            ),
            Center(
              child: Container(
                  width: size.width * 0.50,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                        Radius.circular(5)
                    ),
                    color:  AppColors.lightGrey,
                  )
              ),
            ),


          ],
        ),
      ),
    );
  }
}
