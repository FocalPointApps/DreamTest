
import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/blocs/sign_up_bloc/signup_bloc.dart';
import 'package:grocery_store/repositories/authentication_repository.dart';
import 'package:grocery_store/repositories/user_data_repository.dart';
import 'package:grocery_store/screens/forceUpdateScreen.dart';
import 'package:grocery_store/screens/languageScreen.dart';
import 'package:grocery_store/screens/onBoardingScreen.dart';
import 'package:grocery_store/screens/registerType.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import 'package:grocery_store/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/screens/welcomeScreen.dart';
import 'package:grocery_store/services/globalStuff.dart';
import 'localization/language_constants.dart';
import 'localization/set_localization.dart';
import 'models/CustomIntegrationListener.dart';
import 'models/DefaultFirebaseConfig.dart';
import 'screens/home_screen.dart';
import 'package:flutter_smartlook/flutter_smartlook.dart';

import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);


  if(kIsWeb){
    await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);

  }else{

    await Firebase.initializeApp();


  //  print("databaseurl${database.databaseURL  }");

    // await FlutterForegroundPlugin.setServiceMethodInterval(seconds: 5);
    // await FlutterForegroundPlugin.setServiceMethod(globalForegroundService);
  }




  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  final AuthenticationRepository authenticationRepository =  AuthenticationRepository();
  final UserDataRepository userDataRepository = UserDataRepository();

  //Stripe.publishableKey = "pk_test_51LGf3zIZ9vncbvUGFVRVNvyt75y86nq6llfnouDEjVpFhd4Cv6k5GWb0x5scZbwXKvquz5nrEDsP9ybBPh9Dobnx00V0eErOZu";
  Stripe.publishableKey = "pk_live_51LGf3zIZ9vncbvUGMeV92gCIdNJzyBX933ayRqrCTSy1DvUDIuYMGCCuBSl1p0qqfm6dUemwzWa8NXzPHft6kuHw00SYLyNXZ1";
  Stripe.merchantIdentifier = 'merchant.com.dreamApplication';
  // NavigationService().setupLocator();

  if(Platform.isIOS )
    await Stripe.instance.applySettings();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<SignupBloc>(
          create: (context) => SignupBloc(
            authenticationRepository: authenticationRepository,
            userDataRepository: userDataRepository,
          ),
        ),
        BlocProvider<SigninBloc>(
          create: (context) => SigninBloc(
            authenticationRepository: authenticationRepository,
          ),
        ),



        BlocProvider<AccountBloc>(
          create: (context) => AccountBloc(
            userDataRepository: userDataRepository,
          ),
        ),

        BlocProvider<NotificationBloc>(
          create: (context) => NotificationBloc(
            userDataRepository: userDataRepository,
          ),
        ),

      ],
      child: MyApp(initialLink),
    ),
  );
}


class MyApp extends StatefulWidget {
  final PendingDynamicLinkData? initialLink;
  const MyApp(this.initialLink,{Key? key, }) : super(key: key);
  static void setLocale(BuildContext context, Locale locale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(locale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final Smartlook smartlook = Smartlook.instance;
  bool isSet = false;
  String _timeString = "";
   Locale? _local;
  bool firstLansh=false;

  void setLocale(Locale locale) {
    setState(() {
      _local = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._local = locale;
      });
    });
    getFirstLanch().then((ss) {
      setState(() {
        this.firstLansh = ss;
      });
    });

    super.didChangeDependencies();
  }
  @override
  void initState() {
    super.initState();
    //initSmartlook();
    //===========appsFlyer
    initAppsFlyer();
    if(FirebaseAuth.instance.currentUser!=null){
      FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('callState').onDisconnect().set('closed');

    }
  }


  @override
  void dispose() {


    super.dispose();
  }

  Future<void> initAppsFlyer() async {
    if(Platform.isIOS) {
      Map<String, Object> appsFlyerOptions =  {
        "afDevKey": "mrP9nrMmbUYnkWEwtkrTmF",
        "afAppId": "id1515745954",
        "isDebug": true
      } ;
      AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
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
      AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
      appsflyerSdk.initSdk(
          registerConversionDataCallback: true,
          registerOnAppOpenAttributionCallback: true,
          registerOnDeepLinkingCallback: true
      );
    }
  }
  Future<void> initSmartlook() async {
    await smartlook.log.enableLogging();
    await smartlook.preferences.setProjectKey('54a00c69b25cef664f89519f3ad9b64944cb6a97');
    await smartlook.start();
    //smartlook.registerIntegrationListener(CustomIntegrationListener());
    //await smartlook.preferences.setWebViewEnabled(true);
    setState(() {
      isSet = true;
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    if (this._local == null) {
      return Container(
        child: Center(
          child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[800]!)),
        ),
      );
    } else {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DREAM',
        // navigatorKey: locator<NavigationService>().navigatorKey,
        locale: _local,
        supportedLocales: [
          Locale('en', 'US'),
          Locale('ar', 'AR'),
          Locale('fr', 'FR'),
          Locale('id', 'ARB')
        ],
        localizationsDelegates: [
          SetLocalization.localizationsDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: (deviceLocal, supportedLocales) {
          for(var local in supportedLocales) {
            if(local.languageCode == deviceLocal?.languageCode && local.countryCode == deviceLocal?.countryCode) {
              return deviceLocal;
            }
          }
          return supportedLocales.first;
        },
        theme: ThemeData(
        primaryColor: Color(0xFF9C3981),
        colorScheme:ColorScheme.light(primary: const Color(0xFF9C3981)),
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        ),
        //_theme,

        initialRoute: '/',
        routes: {
          '/': (context) => firstLansh?LanguageScreen():SplashScreen(widget.initialLink),
          '/welcome': (context) => WelcomeScreen(),
          '/RegisterTypeScreen': (context) =>RegisterTypeScreen(),
          '/home': (context) => HomeScreen(),
          '/sign_up': (context) => SignUpScreen(),
          '/Register_Type': (context) =>RegisterTypeScreen(),
          '/ForceUpdateScreen': (context) =>ForceUpdateScreen(),
          '/OnBoardingScreen': (context) =>OnBoardingScreen(),
        },
      );
    }
  }
}
