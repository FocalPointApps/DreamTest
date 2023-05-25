
import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/blocs/sign_in_bloc/signin_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/pages/AppointmentsPage.dart';
import 'package:grocery_store/pages/home_page.dart';
import 'package:grocery_store/pages/TechnicalSupportPage.dart';
import 'package:grocery_store/pages/CallHistoryPage.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';

import '../blocs/account_bloc/account_bloc.dart';
import '../config/colorsFile.dart';
import '../models/user_notification.dart';
import '../services/firebase_service.dart';
import '../widget/drawerWidget.dart';
import 'DevelopTechSupport/allDevelopSupport.dart';
import 'RtcScreens/call_sample.dart';
import 'account_screen.dart';
import 'consultantDetailsScreen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? notificationPage;

  const HomeScreen({Key? key, this.notificationPage}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  static FirebaseDatabase database =  FirebaseDatabase.instanceFor(app:Firebase.app(),databaseURL: 'https://dream-43bb8-f2c7f.europe-west1.firebasedatabase.app');
  static final realtimeDbRef = database.ref();

  late int _selectedPage;
  late PageController _pageController;
  late int cartCount;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;
  late AccountBloc accountBloc;
  late GroceryUser user;
   String userType="",theme="light",userImage="",lang="",userName="";
  late Size size;
  User? currentUser=FirebaseAuth.instance.currentUser;
  bool load=true,first=true;

  CallkeeponEvent(){

    CallKeep.instance.onEvent.listen((event) async {
      // TODO: Implement other events
      if (event == null) return;
      switch (event.type) {
        case CallKeepEventType.callAccept:
          final data = event.data as CallKeepCallData;
          print('call answered: ${data.toMap()}');

          CallKeep.instance.endAllCalls();

          FirebaseDatabase.instance.ref('userCallState').child( FirebaseAuth.instance.currentUser!.uid).child('callState').set('oncall').then((value) =>  Future(() =>
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (con) =>
                  CallSample(host: data.extra!['appointmentId'], iscaller: false,
                    isVideo: true,normalCall: false,CallerId: data.extra!['callerId']
                    ,ReciverId: FirebaseAuth.instance.currentUser!.uid!,)),(predict)=>predict.isCurrent?false:true))
          );








          // NavigationService.instance
          //     .pushNamedIfNotCurrent(AppRoute.callingPage, args: data.toMap());
          // if (callback != null) callback.call(event);
          break;
        case CallKeepEventType.callDecline:
          final data = event.data as CallKeepCallData;
          print('call declined: ${data.toMap()}');


          // await requestHttp("ACTION_CALL_DECLINE_FROM_DART");
          //   if (callback != null) callback.call(data);
          break;
        default:
          break;
      }
    });


  //  Fluttertoast.showToast(msg: "dfdfdfdfdf");

    // startCall(currentCall?.toMap());
    // NavigationService.instance
    //     .pushNamedIfNotCurrent(AppRoute.callingPage, args: currentCall.toMap());

  }

  Future<CallKeepCallData?> getCurrentCall() async {
    //check current call from pushkit if possible
    var calls = await CallKeep.instance.activeCalls();
    if (calls.isNotEmpty) {
      print('DATA: $calls');

      //   _currentUuid = calls[0].uuid;
      return calls[0];
    } else {
      //   _currentUuid = "";
      return null;
    }
  }


  checkAndNavigationCallingPage() async {
    var currentCall = await getCurrentCall();
    print('not answered call ${currentCall?.toMap()}');
    // Fluttertoast.showToast("sasaaa${currentCall!.duration}");
    if (currentCall != null) {
      CallKeep.instance.endAllCalls();

      FirebaseDatabase.instance.ref('userCallState').child( FirebaseAuth.instance.currentUser!.uid).child('callState').set('oncall').then((value) =>  Future(() =>
          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (con) =>
              CallSample(host: currentCall.extra!['appointmentId'], iscaller: false,
                isVideo: true,normalCall: false,CallerId: currentCall.extra!['callerId']
                ,ReciverId: FirebaseAuth.instance.currentUser!.uid!,)),(predict)=>predict.isCurrent?false:true))
      );


    }
  }


  @override
  void initState() {
    super.initState();
    if(widget.notificationPage!=null)
      _selectedPage=widget.notificationPage!;
    else
      _selectedPage = 0;
    _pageController = PageController(initialPage: _selectedPage);
    //----------
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    notificationBloc = BlocProvider.of<NotificationBloc>(context);

    notificationBloc.stream.listen((state) {
      print('NOTIFICATION STATE :::: $state');
    });

    print("dataurl${  FirebaseDatabase.instance.databaseURL}");


    if(FirebaseAuth.instance.currentUser!=null){
      // trigerCallMethod();
      checkAndNavigationCallingPage();
      CallkeeponEvent();

    }
    if(FirebaseAuth.instance.currentUser!=null){
      FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('callState').onDisconnect().set('closed');

    }


  }

  void trigerCallMethod(){


    realtimeDbRef.child('userCallState').child(FirebaseAuth.instance.currentUser!.uid).onValue.listen((event) async {
      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);
      if(value['callState']=='calling'){

        if(value!['roomId']!=null){

          if(value!['callerID']!=null&&value!['callerID']!=FirebaseAuth.instance.currentUser!.uid)
          {
            bool acceptcall=false;


            //    AwesomeNotifications().setListeners(onActionReceivedMethod:(ReceivedAction receivedAction){
            //
            //      if(receivedAction!=null&&receivedAction!.actionType==ActionType.Default){
            //        acceptcall=true;
            //      }
            //
            //   //   print("madmaxcx$receivedAction");
            //
            //      return Future(() => print(''));
            // });





            Future(()=>   Navigator.of(context).push( MaterialPageRoute(builder: (con)=>CallSample( host:value!['roomId'] ,iscaller:false,acceptNotfi: acceptcall,normalCall: value!['isNormal']??true,CallerId: value!['callerID'],ReciverId:value!['reciverId']))));


          }


        }



      }

      realtimeDbRef.child('userCallState').child(FirebaseAuth.instance.currentUser!.uid).onDisconnect().set({
        'callState':'closed',
        'timeStamp':db.ServerValue.timestamp,
        'roomId':value!['roomId'],
        'callerID':value!['callerID'],
        'reciverId':value!['reciverId']


      });

    });


    //
    // webRtcBloc=   BlocProvider.of<WebRtcBloc>(context)..add(parantEvent());
    //
    //
    // webRtcBloc!.stream.listen((event) async {
    //   if(event is getWebRtcCallCompletedState){
    //
    //     trigerCall=event.trigerCall;
    //
    //     //print("hokshrender${checkrender}");
    //    // db.FirebaseDatabase.instance.ref('signaling').child(trigerCall?.data()!['appointmentId']).child("message").child('peers').child(FirebaseAuth.instance.currentUser!.uid)
    //       //   .set({
    //       // 'data': {
    //       //   'name': DeviceInfo.label,
    //       //   'id': randomNumeric(6),
    //       //   'user_agent': DeviceInfo.userAgent
    //       // }});
    //
    //
    //     print("triger111Call${trigerCall!.data()!['appointmentId']}");
    //     Future(()=>   Navigator.of(context).push( MaterialPageRoute(builder: (con)=>CallSample( host:trigerCall?.data()!['appointmentId'] ,))));
    //
    //
    //
    //
    //   }
    //
    //
    // });
  }

  @override
  void didChangeDependencies() {
    GroceryUser? loggedUser;
    super.didChangeDependencies();
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      if (dynamicLinkData != null) {
        if(FirebaseAuth.instance.currentUser!=null) {
          var __user = await FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid).get();
           loggedUser=GroceryUser.fromMap(__user.data() as Map);
        }
        final Uri link = dynamicLinkData.link;
        print(dynamicLinkData.link.toString());
        String result = dynamicLinkData.link.toString().replaceAll('https://dreamuser.page.link/consultant_id=', ' ');
        String consultantId = result.trim();
        print("hhhhh = $link");
        print(consultantId);
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(consultantId)
            .get()
            .then((value) async {
          GroceryUser currentUser = GroceryUser.fromMap(value.data() as Map);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultantDetailsScreen(
                consultant: currentUser,
                loggedUser:loggedUser,
                consultType: currentUser.voice!?"voice":"chat",
              ),
            ),
          );
        });
        return;
      }
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
    }).
    onError((error) {
      print("ffffffzfdsffdsf");
      print(error.toString());
    });
  }
  @override
  Widget build(BuildContext context) {
     size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(backgroundColor: Colors.white,
        drawer: DrawerWidget(),
        key: _scaffoldKey,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white54,
          ),
          height:Platform.isAndroid ? 50.0 : 75.0,
          width: size.width,
          child:  BlocBuilder(
            bloc: accountBloc,
            builder: (context, state) {
              print("Account state");
              print(state);
              if (state is GetLoggedUserInProgressState) {
                return Center(child: userBottomNavigation());
              }
              else if (state is GetLoggedUserCompletedState) {
                user=state.user;
                if (mounted&first) {
                  FirebaseService.init(context, currentUser!.uid, currentUser!);
                  notificationBloc.add(GetAllNotificationsEvent(currentUser!.uid));
                  first = false;
                }
                return  BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  notchMargin: 6.0,
                  child: (user.userType!="CONSULTANT")?
                  userBottomNavigation()
                      :consultBottomNavigation(),
                );
              }
              else {
                return Center(child: userBottomNavigation());
              }
            },
          ),


        ),
        body: Column(
          children: <Widget>[
            headerWidget(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: <Widget>[
                  HomePage(userType: userType,),//0
                  AppointmentsPage(),//1
                  TechnicalSupportPage(),//2
                  CallHistoryPage(),//3
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget userBottomNavigation(){
    return Container(//width: size.width,height: Platform.isAndroid ? 100:85,
      decoration: BoxDecoration(
        //color:Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              color: AppColors.lightGrey, height: 1, width: size.width),
          //SizedBox(height: 1,),
          Padding(
            padding: const EdgeInsets.only(top: 1,bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _pageController.jumpToPage(
                        0,);
                      setState(() {
                        _selectedPage = 0;
                      });
                    },
                    child: Container(width: size.width*.33,color: Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 0?'assets/applicationIcons/Group.png':'assets/applicationIcons/Group1.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"schedule"),
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 0?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600, ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('appointments');
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, '/Register_Type');
                      } else {
                        _pageController.jumpToPage(1, );
                      }

                      setState(() {
                        _selectedPage = 1;
                      });
                    },
                    child: Container(width: size.width*.33,color: Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 1?'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"appointments") ,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 1 ?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600, ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('support');
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, '/Register_Type');
                      } else {
                        _pageController.jumpToPage( 2,);
                      }
                      setState(() {
                        _selectedPage = 2;
                      });
                    },
                    child: Container(width: size.width*.33,
                      color: Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 2?'assets/applicationIcons/Path.png':'assets/applicationIcons/Group1711.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"support") ,overflow: TextOverflow.ellipsis,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 2?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600, ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget consultBottomNavigation(){
    return Container(//width: size.width, height: Platform.isAndroid ? 100:85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              color: AppColors.lightGrey, height: 1, width: size.width),
          Padding(
            padding: const EdgeInsets.only(top: 1,bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('appointments');
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, '/Register_Type');
                      } else {
                        _pageController.jumpToPage(0, );
                      }

                      setState(() {
                        _selectedPage = 0;
                      });
                    },
                    child: Container(width: size.width*.33,color: Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 0?'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationIcons/Iconly-Two-tone-Calendar.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"appointments") ,softWrap:true,overflow:TextOverflow.ellipsis,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 0?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      _pageController.jumpToPage(
                        3,);
                      setState(() {
                        _selectedPage = 3;
                      });
                    },
                    child: Container(width: size.width*.33,color:Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 3?'assets/applicationIcons/callbackPurple.png':'assets/applicationIcons/callbackGray.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"callHistory"),softWrap:true,overflow:TextOverflow.ellipsis,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 3?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      print('support');
                      if (FirebaseAuth.instance.currentUser == null) {
                        Navigator.pushNamed(context, '/Register_Type');
                      } else {
                        _pageController.jumpToPage( 2,);
                      }
                      setState(() {
                        _selectedPage = 2;
                      });
                    },
                    child: Container(width: size.width*.33,
                      color: Colors.white,
                      child: Center(
                        child: Column(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _selectedPage == 2?'assets/applicationIcons/Path.png':'assets/applicationIcons/Group1711.png',
                              width: 20,
                              height: 20,
                            ),
                            Text(getTranslated(context,"support") ,overflow: TextOverflow.ellipsis,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: _selectedPage == 2?Theme.of(context).primaryColor:AppColors.grey,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w600, ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget headerWidget() {
    return Column(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Padding(
            padding:
            const EdgeInsets.only(left: 16, right: 16, top: 35, bottom: 25),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    height: 35,
                    width: 35,
                    decoration: decoration(),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          if(_scaffoldKey.currentState!.isDrawerOpen){
                            _scaffoldKey.currentState!.openEndDrawer();
                          }else{
                            _scaffoldKey.currentState!.openDrawer();
                          }

                        },
                        icon: Image.asset(
                          theme == "light"
                              ? 'assets/applicationIcons/Iconly-Two-tone-Category.png'
                              : 'assets/applicationIcons/dashbord.png',
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  currentUser == null
                      ? noNotificationWidget()
                      : BlocBuilder(
                    bloc: notificationBloc,
                    buildWhen: (previous, current) {
                      if (current is GetAllNotificationsInProgressState ||
                          current is GetAllNotificationsFailedState ||
                          current is GetAllNotificationsCompletedState ||
                          current is GetNotificationsUpdateState) {
                        return true;
                      }
                      return false;
                    },
                    builder: (context, state) {
                      if (state is GetAllNotificationsInProgressState) {
                        return noNotificationWidget();
                      }
                      if (state is GetNotificationsUpdateState) {
                        if (state.userNotification != null) {
                          if (state.userNotification.notifications.length ==
                              0) {
                            return noNotificationWidget();
                          }
                          userNotification = state.userNotification;
                          if(userNotification.notifications.length>=200)
                            Fluttertoast.showToast(
                                msg: getTranslated(context, "removeNotification"),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);

                          return Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                height: 35,
                                width: 35,
                                decoration: decoration(),
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: Material(
                                      color: AppColors.white,
                                      child: InkWell(
                                        splashColor: Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          if (userNotification.unread) {
                                            notificationBloc.add( NotificationMarkReadEvent(
                                                  currentUser!.uid),
                                            );
                                          }
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  NotificationScreen(
                                                    userNotification:
                                                    userNotification,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                          ),
                                          width: 25.0,
                                          height: 25.0,
                                          child: Image.asset(
                                            theme == "light"
                                                ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                                                : 'assets/applicationIcons/darkNotification.png',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              userNotification.unread
                                  ? Positioned(
                                right: 4.0,
                                top: 4.0,
                                child: Container(
                                  height: 7.5,
                                  width: 7.5,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.amber,
                                  ),
                                ),
                              )
                                  : SizedBox(),
                            ],
                          );
                        }
                        return noNotificationWidget();
                      }
                      return noNotificationWidget();
                    },
                  ),
                  InkWell(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SearchScreen(),
                      ),
                    );
                  },
                    child: Center(
                      child: Container(
                          height: 35.0,
                          width: size.width * .45,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 0.0),
                          decoration: decoration(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10,right: 10),
                                child: Image.asset(
                                  theme == "light"
                                      ? 'assets/applicationIcons/lightSearch.png'
                                      : 'assets/applicationIcons/darkSearch.png',
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                              Text(
                                getTranslated(context, 'search'),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: AppColors.grey,
                                  fontSize: 11.0,
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              )
                            ],
                          )),
                    ),
                  ),
                  SizedBox(width: 5),
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.6),
                    onTap: () {
                      if (user != null && user.isDeveloper!)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllDevelopTechScreen(loggedUser: user),
                          ),
                        );
                      else if (user != null && user.userType != "CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserAccountScreen(user: user, firstLogged: false),
                          ),
                        );

                      else if (user != null && user.userType == "CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AccountScreen(user: user, firstLogged: false),
                          ),
                        );
                      else {
                        Navigator.pushNamed(context, '/Register_Type');
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: userImage == null
                          ? Image.asset(
                        'assets/applicationIcons/whiteLogo.png',
                        width: 40,
                        height: 40,
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                          placeholder:
                          'assets/applicationIcons/whiteLogo.png',
                          //placeholderScale: 0.5,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                                'assets/applicationIcons/whiteLogo.png',
                                width: 50,
                                height: 50,
                              ),
                          image: userImage,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration(milliseconds: 250),
                          fadeInCurve: Curves.easeInOut,
                          fadeOutDuration: Duration(milliseconds: 150),
                          fadeOutCurve: Curves.easeInOut,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Center(
            child: Container(
                color: AppColors.lightGrey, height: 1, width: size.width * .9)),

      ],
    );
  }
  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8.0),
      boxShadow: [
        BoxShadow(
          color: AppColors.lightPink,
          blurRadius: 4.0,
          spreadRadius: 0.0,
          offset: Offset(
              0.0, 1.0), // shadow direction: bottom right
        )
      ],

    );
  }
  Widget noNotificationWidget() {
    return Container(
      height: 35,
      width: 35,
      decoration: decoration(),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50.0),
          child: Material(
            color: AppColors.white,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.6),
              onTap: () {
                Fluttertoast.showToast(
                    msg: getTranslated(context, "noNotification"),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                ),
                width: 25.0,
                height: 25.0,
                child: Image.asset(
                  theme == "light"
                      ? 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
                      : 'assets/applicationIcons/Iconly-Two-tone-Notification2.png',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
