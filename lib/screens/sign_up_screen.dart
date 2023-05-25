

import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/screens/privecy_screen.dart';
import 'package:grocery_store/screens/term_screen.dart';
import 'package:grocery_store/screens/verification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../config/colorsFile.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  final String? userType;

  const SignUpScreen({Key? key, this.userType}) : super(key: key);
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String   mobileNo="",countryCode="+966",countryISOCode="SA";
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late String phoneNumber, email="example@example.com", name="name";
  late bool inProgress, inProgressApple;
  final TextEditingController controller = TextEditingController();
  String initialCountry = 'SA';
  PhoneNumber number = PhoneNumber(isoCode: 'SA');

  @override
  void initState() {
    super.initState();
    inProgress = false;
    inProgressApple = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  signUpWithphoneNumber() async {

    if(mobileNo==null||mobileNo=="")
        {
      showFailedSnakbar(getTranslated(context, "enterAll"));
    }
    else
    {

      phoneNumber =  mobileNo;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: email,
            phoneNumber: phoneNumber,
            name: nameController.text,
            userType:widget.userType!,
            countryCode:countryCode,
            countryISOCode:countryISOCode,
            isSigningIn: false,
          ),
        ),
      );
    }
  }
  signUpWithphoneNumber2() async {
    if(mobileNo==null||mobileNo=="")//||nameController.text==null||nameController.text=="")
        {
      showFailedSnakbar(getTranslated(context, "enterAll"));
    }
    else
    {
      //mobileNo=replaceFarsiNumber(mobileNo);

      phoneNumber = countryCode + mobileNo;
      print("gggggg");
      print(phoneNumber);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerificationScreen(
            email: email,
            phoneNumber: phoneNumber,
            name: nameController.text,
            userType:widget.userType!,
            countryCode:countryCode,
            countryISOCode:countryISOCode,
            isSigningIn: false,
          ),
        ),
      );
    }
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
    String lang=getTranslated(context,"lang");

    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body:  ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
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
          ),
          Padding(
            padding:  EdgeInsets.only(top: size.height*0.08,bottom: 30),
            child: Center(
                child:  Image.asset('assets/applicationIcons/dreamLogo.png',width: 100,height: 100,)
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 30,left: 20,right: 20),
            child: Text(
              getTranslated(context, "loginText"),
              maxLines: 3,
              textAlign:TextAlign.center,
              overflow:TextOverflow.ellipsis,
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                  fontSize: 15.0,fontWeight: FontWeight.normal ),

            ),
          ),
          Padding(
            padding:const EdgeInsets.only(top: 30,bottom: 30,left: 30,right: 30),
            child: Container(height: 50,
              child: InternationalPhoneNumberInput(

                searchBoxDecoration:InputDecoration(
                  counterStyle: TextStyle(height: double.minPositive,),
                  counterText: "",
                  labelText: getTranslated(context, "countrySearch"),
                  labelStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                      fontSize: 11.0,fontWeight: FontWeight.normal ),
                 // fillColor: Colors.white,filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1,
                      color: AppColors.lightGrey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1,
                      color: AppColors.lightGrey,
                    ),
                  ),
                  contentPadding: EdgeInsets.only(left: 5,right: 5),
                  helperStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black.withOpacity(0.65),
                    letterSpacing: 0.5,
                  ),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.grey,//[400],
                    fontSize: 14.5,
                    letterSpacing: 0.5,
                  ),
                  hintText: getTranslated(context,'enterMobile'),

                ),
                inputDecoration: InputDecoration(
                  counterStyle: TextStyle(height: double.minPositive,),
                  counterText: "",
                  labelText: getTranslated(context, "phoneNumber"),
                  labelStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.lightGrey,
                      fontSize: 11.0,fontWeight: FontWeight.normal ),

                  //fillColor: Colors.white,filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1,
                      color: Colors.grey,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1,
                      color: Colors.grey,
                    ),
                  ),
                  contentPadding: EdgeInsets.only(left: 5,right: 5),
                  helperStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.black.withOpacity(0.65),
                    letterSpacing: 0.5,
                  ),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.grey,
                    fontSize: 14.5,
                    letterSpacing: 0.5,
                  ),
                  hintText: getTranslated(context,'enterMobile'),

                ),
                onInputChanged: (PhoneNumber number) {

                  setState(() {
                    mobileNo=number.phoneNumber!;
                    countryCode=number.dialCode!;
                    countryISOCode=number.isoCode!;
                  });
                },
                onInputValidated: (bool value) {
                  print(value);
                },
                locale:getTranslated(context,'lang') ,
                selectorConfig: SelectorConfig(
                  selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                ),
                ignoreBlank: false,
                autoValidateMode: AutovalidateMode.disabled,
                selectorTextStyle: TextStyle(color: Colors.black),
                initialValue: number,
                textFieldController: controller,
                formatInput: false,
                keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
                inputBorder: OutlineInputBorder(),
                onSaved: (PhoneNumber number) {
                  print('On Saved: $number');
                },
              ),
            ),
          ),
          Padding(
            padding:const EdgeInsets.only(top: 30,bottom: 30,left: 20,right: 20),
            child: Center(
              child: InkWell(onTap: (){
                signUpWithphoneNumber();},
                child: Container(
                  width: size.width*.6,
                  height: 45.0,
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
                  child: Center(
                    child: Text(
                      getTranslated(context, "sendCode"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.white,
                          fontSize: 14.0,fontWeight: FontWeight.normal ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Column(mainAxisAlignment:MainAxisAlignment.end,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 30,bottom: 20,left: 20,right: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:  [
                    Text(
                      getTranslated(context, "registerNote1"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                          fontSize: 12.0,fontWeight: FontWeight.normal ),
                    ),
                    SizedBox(height: 1,),
                    InkWell(splashColor: Colors.blue.withOpacity(0.6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivecyScreen(),//TermScreen(),
                          ),);
                      },
                      child: Text(
                        getTranslated(context, "registerNote2"),
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), decoration: TextDecoration.underline,
                          decorationColor:AppColors.pink,
                          decorationThickness: 1,
                          color:AppColors.pink,
                          fontSize: 10.0, ),
                      ),
                    ),
                    SizedBox(height: 1,),
                    InkWell(splashColor: Colors.blue.withOpacity(0.6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivecyScreen(),
                          ),);
                      },
                      child: Text(
                        getTranslated(context, "registerNote3"),
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), decoration: TextDecoration.underline,
                          decorationColor:AppColors.pink,
                          decorationThickness: 1,
                          color:AppColors.pink,
                          fontSize: 10.0, ),
                      ),
                    ),
                  ],),
              ),
            ],
          ),


        ],
      ),
    );
  }

}
