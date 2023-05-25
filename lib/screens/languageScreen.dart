

import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String lang="اللغة",langValue="",done="حفظ",title="من فضلك قم بتحديد لغة التطبيق",dropdownValue;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<KeyValueModel> _datas = [
    KeyValueModel(key: 0, value: "العربية"),
    KeyValueModel(key: 1, value: "English"),
    KeyValueModel(key: 2, value: "French"),
    KeyValueModel(key: 3, value: "Indonesian"),
  ];

  @override
  void initState() {
    super.initState();
    lang="العربية";
    dropdownValue = "0";
    title="من فضلك قم باختيار اللغة المفضلة";
    langValue="ar";
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
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body:  Column(
          children: <Widget>[
            Container(
              height: size.height*.5,
              width: size.width,
              color: Colors.white,
              child: Center(child: Image.asset('assets/applicationIcons/dreamLogo.png',width: 100,height: 100,))
            /*  Column(mainAxisAlignment: MainAxisAlignment.center,children: [
               // SizedBox(height: 70,),
                Padding(
                  padding:  EdgeInsets.only(top:size.height*.20,bottom: 30),
                  child: Center(
                      child:  Image.asset('assets/applicationIcons/dreamLogo.png',width: 100,height: 100,)
                  ),
                ),
                //SizedBox(height: 10,),

              ],)),*/
            ),
            Container(
              height: size.height*.5,
              width: size.width,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children:  [
                  Text(
                    title,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.grey,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(height: 20,),
                  Container(width:size.width*0.8,height: 45.0,decoration:
                    BoxDecoration(//color:Colors.grey[200] ,
                      border: Border.all(
                        color: Colors.grey,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5))
                     ),
                      child:Padding(
                        padding: const EdgeInsets.only(left: 10,right: 10),
                        child: DropdownButton<String>(
                          hint: Text(lang,textAlign:TextAlign.center,style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Colors.black,
                            fontSize: 15.0,
                            letterSpacing: 0.5,
                          ),),
                          underline:Container(),
                          isExpanded: true,
                          value: dropdownValue,
                          icon: Icon(Icons.keyboard_arrow_down,color: AppColors.pink),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Color(0xFF3b98e1),
                            fontSize: 13.0,
                            letterSpacing: 0.5,
                          ),
                          items: _datas
                              .map((data) => DropdownMenuItem<String>(alignment:AlignmentDirectional.center ,
                              child: Text(data.value!,textAlign:TextAlign.center,style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Colors.black,
                                fontSize: 15.0,
                                letterSpacing: 0.5,
                              ),),
                              value: data.key.toString()//data.key,
                          ))
                              .toList(),
                          onChanged: (String? value) {
                            if(value=="0")
                            {
                              setState(() {
                                lang="العربية";
                                dropdownValue = value!;
                                title="من فضلك قم باختيار اللغة المفضلة";
                                langValue="ar";
                                done="حفظ";
                              });
                            }
                            else if(value=="1") {
                              setState(() {
                                lang = "English";
                                dropdownValue = value!;
                                title="Please select language";
                                langValue="en";
                                done="Save";
                              });
                            }
                            else if(value=="2") {
                              setState(() {
                                lang = "French";
                                dropdownValue = value!;
                                title="Veuillez sélectionner la langue";
                                langValue="fr";
                                done="sauvegarder";
                              });
                            } else if(value=="3") {
                              setState(() {
                                lang = "Indonesia";
                                dropdownValue = value!;
                                title="Silakan pilih bahasa";
                                langValue="id";
                                done="menyimpan";
                              });
                            }

                          },

                        ),
                      )
                  ),

                  SizedBox(height: 40,),
                  Container(
                    width: size.width*.8,
                    height: 45.0,
                    child: MaterialButton(
                      onPressed: () async {
                        if(langValue=="")
                          {showFailedSnakbar(getTranslated(context, "chooseLang"));}
                        else{
                          _changeLanguage(langValue);
                          Navigator.pushNamed(context, '/OnBoardingScreen');
                        }

                      },
                      color: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Text(
                        done,
                        textAlign: TextAlign.center,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 20.0,
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
  void _changeLanguage(String lang) async {
    Locale _temp;
    switch (lang) {
      case 'en':
        _temp = Locale(lang, 'US');
        break;
      case 'ar':
        _temp = Locale(lang, 'AR');
        break;
      case 'fr':
        _temp = Locale(lang, 'FR');
        break;
      case 'id':
        _temp = Locale(lang, 'ARB');
        break;
      default:
        _temp = Locale('en', 'US');
        break;
    }
    Locale _locale = await setLocale(lang);
    MyApp.setLocale(context, _temp);
  }
}
