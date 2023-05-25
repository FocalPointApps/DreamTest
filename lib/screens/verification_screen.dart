
import 'dart:async';
import 'dart:io';

import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../config/colorsFile.dart';
import 'consultRules.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final bool isSigningIn;
  final String userType;
  final String countryCode;
  final String countryISOCode;
  const VerificationScreen({
    required this.phoneNumber,
    required this.email,
    required this.name,
    required this.isSigningIn,
    required this.userType,
    required  this.countryCode,
    required this.countryISOCode,
  });

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late int _timer;
  MaskedTextController otpController = MaskedTextController(mask: '000000');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Timer timer;
  String _code = "";
  bool inProgress=false;
  bool isResendOTP = false;
  late AccountBloc accountBloc;
  late String smsCode, theme = "light";
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _verificationCode = '';
  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
    inProgress = false;
    listOPT();
    signInWithphoneNumber(widget.phoneNumber);
    startTimer();
  }

  Future<void> checkUser(
      String phoneNumber, String userType, String uid) async {
    try {
      print("checkUser");
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get()
          .then((value) async {
        if (value != null && value.docs.length > 0 && phoneNumber != null) {

          print("login event00000");
          String eventName = "af_login";
          Map eventValues = {};
          addEvent(eventName, eventValues);
            Map<String, dynamic> data = value.docs[0].data();
         await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(data['uid'])
              .set({
            'userLang': getTranslated(context, 'lang'),
           'languages':data['userType']=="CONSULTANT"?data['languages']:[getTranslated(context, 'lang')],
          }, SetOptions(merge: true));
          await FirebaseFirestore.instance
              .collection(Paths.supportListPath)
              .doc(data['supportListId'])
              .set({
            'userLang': getTranslated(context, 'lang'),
          }, SetOptions(merge: true));
          print("login event000002222");
              if (data['isBlocked'] != null && data['isBlocked']){
              await FirebaseAuth.instance.signOut();
              Navigator.popAndPushNamed(
                context,
                '/home',
                arguments: {
                  'userType': userType,
                },
              );
            }
              else if (data['profileCompleted'] != null && data['profileCompleted']) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false,
              );
            }
              else {
              DocumentReference docRef = FirebaseFirestore.instance
                  .collection(Paths.usersPath)
                  .doc(uid);
              final DocumentSnapshot documentSnapshot = await docRef.get();
              var user = GroceryUser.fromMap(documentSnapshot.data() as Map);
              if (user.userType == "CONSULTANT") {
                print("CONSULTANTProfileNotCompleted");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => consultRuleScreen(user: user),
                  ),
                );
              } else {
                print("userProfileNotCompleted");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserAccountScreen(user: user, firstLogged: true),
                  ),
                );

              }
            }
        }
        else {
          //user nit found-create user and save it
          print("register event");
          String eventName = "af_complete_registration";
          Map eventValues = {
            "af_registration_method": "phone number",
          };
          addEvent(eventName, eventValues);
          DocumentReference ref = await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(uid);
          var data = {
            'accountStatus': 'NotActive',
            'userLang': getTranslated(context, 'lang'),
            'profileCompleted': false,
            'isBlocked': false,
            'uid': uid,
            'name': " ",
            'email': " ",
            'phoneNumber': phoneNumber,
            'photoUrl': '',
            'tokenId': "",
            'loggedInVia': "mobile",
            "userType": userType,
            "languages": [getTranslated(context, 'lang')],
            "countryCode": widget.countryCode,
            "countryISOCode": widget.countryISOCode,
            "createdDate": Timestamp.now(),
            'utcTime':DateTime.now().toUtc().toString(),
            'date': {
              'day': DateTime.now().toUtc().day,
              'month': DateTime.now().toUtc().month,
              'year': DateTime.now().toUtc().year,
            },
            "createdDateValue": DateTime(DateTime.now().year,
                DateTime.now().month, DateTime.now().day)
                .millisecondsSinceEpoch,
          };
          ref.set(data, SetOptions(merge: true));
          final DocumentSnapshot currentDoc = await ref.get();
          var user = GroceryUser.fromMap(currentDoc.data() as Map);
          if (user.userType == "CONSULTANT") {
            print("CONSULTANTProfileNotCompleted");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => consultRuleScreen(user: user),
              ),
            );
          } else {
            print("userProfileNotCompleted");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserAccountScreen(user: user),
              ),
            );
          }
        }
      }).catchError((err) {});
    } catch (e) {
      print("lllllerror");
      print(e);
      return null;
    }
  }
addEvent(String eventName,Map eventValues) async {
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
  if(eventName=="af_login")
    await FirebaseAnalytics.instance.logLogin(
        loginMethod: "phone",);
  else
    await FirebaseAnalytics.instance.logSignUp(
      signUpMethod: "phone",);

}
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  listOPT() async {
    try {
      await SmsAutoFill().listenForCode;
    } catch (e) {
      print("ffffffss" + e.toString());
    }
  }

  void startTimer() {
    _timer = 60;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _timer--;
      });
      if (_timer == 0) {
        timer.cancel();
      }
    });
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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
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
                ],
              ),
            ),
            Container(
                height: size.height * 0.30,
                child: Image.asset(
                  'assets/applicationIcons/otplight.png',
                  /* width: 50,
                          height: 50,*/
                )),



            Padding(
              padding: EdgeInsets.only(
                  top: size.height * .09, bottom: 30, left: 20, right: 20),
              child: Text(
                _timer > 50
                    ? getTranslated(context, "otpSending")
                    : getTranslated(context, "otpSend"),
                  textAlign:TextAlign.center,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                  fontSize: 15.0,
                  fontWeight: FontWeight.w400, ),

              ),
            ),

            _timer > 50
                ? loadVerificationCode()
                : Container(
              height: 52.0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 25.0, vertical: 0.0),
              child: TextFormField(
                controller: otpController,
                textAlignVertical: TextAlignVertical.center,
                validator: (String? val) {
                  if (val!.isEmpty) {
                    return getTranslated(context, "optRequired");
                  } else if (val!.length < 6) {
                    return getTranslated(context, "invalidOtp");
                  }
                  return null;
                },
                onChanged: (val) {
                  print(val);
                  smsCode = val;
                  print(val.trim().length);
                  if (val.trim().length == 6) {
                    signInWithSmsCode(val);
                    setState(() {
                      inProgress = true;
                    });
                  }
                },
                enableInteractiveSelection: true,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400, ),

                textAlign: TextAlign.center,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  helperStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  errorStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    // color: Colors.black54,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                  hintText: 'OTP',
                  // labelText: 'OTP',
                  labelStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400, ),
                  contentPadding: const EdgeInsets.all(0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Container(
              height: 40.0,
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      '$_timer sec',
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.grey,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  _timer == 0
                      ? MaterialButton(
                    onPressed: () {
                      print('Resend OTP');

                      print(widget.phoneNumber);
                      //signInWithphoneNumber(widget.phoneNumber);
                      resendOTP(widget.phoneNumber);

                      startTimer();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      getTranslated(context, "resendOtp"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                        fontSize: 13.0,
                        fontWeight: FontWeight.w400, ),
                    ),
                  )
                      : SizedBox(),
                ],
              ),
            ),
            //===========
            PinFieldAutoFill(
              decoration: UnderlineDecoration(
                textStyle: TextStyle(fontSize: 20, color: Colors.transparent),
                colorBuilder: FixedColorBuilder(Colors.transparent),
              ),
              codeLength: 6,
              onCodeSubmitted: (code) {},
              onCodeChanged: (code) {
                if (code!.length == 6) {
                  FocusScope.of(context).requestFocus(FocusNode());
                  otpController.text = code;
                  print(code);
                  signInWithSmsCode(code);
                  //signupBloc.add(VerifyphoneNumber(code));
                  setState(() {
                    inProgress = true;
                    smsCode = code;
                  });
                }
              },
            ),
            //===============

            SizedBox(
              height: 15.0,
            ),
            _timer > 50
                ? Center(child: CircularProgressIndicator())
                : buildVerificationBtn(context, inProgress, size),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVerificationBtn(
      BuildContext context, bool inProgress, Size size) {
    return inProgress
        ? Center(child: CircularProgressIndicator())
        : Padding(
      padding:
      const EdgeInsets.only(top: 30, bottom: 30, left: 20, right: 20),
      child: Center(
        child: InkWell(
          onTap: () {
            VerifyphoneNumber(smsCode);
            //signupBloc.add(VerifyphoneNumber(smsCode));
            setState(() {
              inProgress = true;
            });
          },
          child: Container(
            width: size.width * .6,
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
                )),
            child: Center(
              child: Text(
                getTranslated(context, "Verify"),
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
    );
  }

  Widget loadVerificationCode() {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.black.withOpacity(0.6),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width * .8,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
            horizontal: 20.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15.0),
          ),
        ));
  }

  //================
  //send code
  Future<bool> signInWithphoneNumber(String phoneNumber) async {
    try {
      print("signInWithphoneNumber222");
      isResendOTP = false;

      int? forceResendToken;
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (authCredential) =>
            phoneVerificationCompleted(authCredential),
        verificationFailed: (authException) =>
            phoneVerificationFailed(authException, phoneNumber),
        codeSent: (String verificationId, int? resendToken) async {
          print("otp sent000");
          print(verificationId);
          this._verificationCode = verificationId;
        },
            //(verificationId, [code]) => phoneCodeSent(verificationId, [code!]),
        codeAutoRetrievalTimeout: phoneCodeAutoRetrievalTimeout,
        forceResendingToken: forceResendToken,
      );
      print("dreamphonesendotpSuccess");
      return true;
    } catch (e) {
      print("dreamphonesendotpfailed");
      print(e);
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithphoneNumber",
      });

      setState(() {
        inProgress = false;
      });
      showFailedSnakbar(e.toString());
      return false;
    }
  }

  //resend OTP
  Future<bool> resendOTP(String phoneNumber) async {
    try {
      isResendOTP = true;

      http.post(
        Uri.parse(
            'https://us-central1-dream-43bb8.cloudfunctions.net/twilioSendVerificationCode'),
        body: {'phoneNumber': widget.phoneNumber},
      );

      return true;
    } catch (e) {
      print(e);
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithphoneNumber",
      });

      setState(() {
        inProgress = false;
      });
      showFailedSnakbar(e.toString());
      return false;
    }
  }

  phoneVerificationCompleted(PhoneAuthCredential authCredential) {
    print("verification completed ${authCredential.smsCode}");
    // otpController.text=authCredential.smsCode;
    showFailedSnakbar("verification completed ${authCredential.smsCode}");
    signInWithSmsCodeStep2(authCredential: authCredential);
    print('verified');
  }

  phoneVerificationCompleted2(AuthCredential authCredential) {
    print('verified');
  }

  phoneVerificationFailed(FirebaseException authException, String phone) async {
    print('failedssssssss111');
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': authException.message.toString(),
      'phone': phone,
      'screen': "otp",
      'function': authException.code.toString(),
    });
    print('Message: ${authException.message}');
    print('Code: ${authException.code}');
    setState(() {
      inProgress = false;
    });
    showFailedSnakbar(authException.message.toString());
  }

  phoneCodeAutoRetrievalTimeout(String verificationCode) {
    print("verificationCode");
    print(verificationCode);
    this._verificationCode = verificationCode;
  }

  phoneCodeSent(String verificationCode, List<int> code) {
    print("otp sent");
    print(verificationCode);
    print(code.toString());
    this._verificationCode = verificationCode;
  }

  Future<void> signInWithSmsCode(String smsCode) async {
    try {
      setState(() {
        inProgress = true;
      });
      if (isResendOTP) {
        signInWithSmsCodeStep2();
      } else {
        AuthCredential authCredential = PhoneAuthProvider.credential(
            verificationId: _verificationCode, smsCode: smsCode);
        signInWithSmsCodeStep2(authCredential: authCredential);
      }
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithSmsCode",
      });

      print('Code: ${e.toString()}');
      setState(() {
        inProgress = false;
      });
      showFailedSnakbar(e.toString());
      print("phonenumber11error " + e.toString());
      return null;
    }
  }

  Future<void> signInWithSmsCodeStep2({AuthCredential? authCredential}) async {
    try {
      setState(() {
        inProgress = true;
      });

      UserCredential authResult;

      if (isResendOTP) {
        var authUserRes = await http.post(
          Uri.parse(
              'https://us-central1-dream-43bb8.cloudfunctions.net/twilioVerifyPhoneNum'),
          body: {'userCode': smsCode, 'phoneNumber': widget.phoneNumber},
        );

        print('TOKENNN :: ');

        final token = authUserRes.body;

        print(token);

        authResult = await firebaseAuth.signInWithCustomToken(token);
      } else {
        authResult = await firebaseAuth.signInWithCredential(authCredential!);
      }

      if (authResult != null &&
          authResult.user != null &&
          authResult.user!.uid != null) {
        checkUser(widget.phoneNumber, widget.userType, authResult.user!.uid);
      } else {
        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.errorLogPath)
            .doc(id)
            .set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': "invalid sms code",
          'phone': widget.phoneNumber,
          'screen': "otp",
          'function': "signInWithSmsCodeStep2",
        });

        showFailedSnakbar("invalid sms code");
        setState(() {
          inProgress = false;
        });
      }
    } catch (e) {
      print("phonenumber11error " + e.toString());
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': widget.phoneNumber,
        'screen': "otp",
        'function': "signInWithSmsCodeStep2",
      });

      showFailedSnakbar(e.toString());
      setState(() {
        inProgress = false;
      });
      return null;
    }
  }
}
