
import 'dart:convert';
import 'dart:io';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:sugar/sugar.dart' as sugar;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultPackage.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/promoCode.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/screens/reviews_screen.dart';
import 'package:grocery_store/screens/searchScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/addAppointmentDialog.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/setting.dart';
import '../models/user.dart';
import '../models/user_notification.dart';
import '../widget/showDialog.dart';
import 'package:http/http.dart' as http;
import 'account_screen.dart';
import 'bioDetailsScreen.dart';
import 'notification_screen.dart';
import 'package:share_plus/share_plus.dart';
class ConsultantDetailsScreen extends StatefulWidget {
  final GroceryUser consultant;
  final GroceryUser? loggedUser;
  final String consultType;
  const ConsultantDetailsScreen({Key? key, required this.consultant, this.loggedUser, required this.consultType}) : super(key: key);
  @override
  _ConsultantDetailsScreenState createState() => _ConsultantDetailsScreenState();
}
class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String languages="", workDays="",workDaysValue="",from="",to="",lang="";
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser? user;
  int currentNumber=0;
  late AccountBloc accountBloc;
  List <consultPackage>packages=[];
  List<ConsultReview>reviews=[];
  late int _selectedIndex=-1,reviewLength=0,localFrom,localTo;
  bool first=true,showPayView=false,load=false,valid=false,checkPromo=false,loadReviews=true,loadPackage=true,fromBalance=false;
  bool  showPromo=false,sharing=false;
  int _stackIndex = 1;
  String initialUrl = '',userImage="",orderId="",userName="dreamUser",orderNum="0";
  consultPackage? package;
  Orders? order;
  bool avaliable=false;
  dynamic destinationAmount=0.0;
  PromoCode? promo;
  String? promoCodeId;
  dynamic price,discount=0;
  late Size size;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;

  @override
  void initState() {
    super.initState();

    if(widget.loggedUser!=null)
      user=widget.loggedUser!;

    if(widget.consultant.ordersNumbers!<100)
      orderNum=widget.consultant.ordersNumbers.toString();
    else
      for(int x=2;x<1000000;x++)
      {
        if(widget.consultant.ordersNumbers!<x*100)
        {
          orderNum=((x-1)*100).toString()+"+";
          break;
        }
      }
    getConsultReviews();
    getConsultPackages();
    cleanConsultDays();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    if(user!=null)
    {
      getNumber();
      accountBloc.add(GetLoggedUserEvent());
    }
    localFrom= DateTime.parse(widget.consultant.fromUtc!).toLocal().hour;
    DateTime nowww = DateTime.parse(widget.consultant.fromUtc!).toLocal();
    print(nowww.toString());
    localTo=DateTime.parse(widget.consultant.toUtc!).toLocal().hour;
    DateTime noww = DateTime.parse(widget.consultant.toUtc!).toLocal();

    myFunction().then((value) {








      final pacificTimeZonee = tz.getLocation(value.toString());


      DateTime resultnoooo = tz.TZDateTime.from(noww, pacificTimeZonee);





      DateTime resultnooo = tz.TZDateTime.from(nowww, pacificTimeZonee);



      if(resultnooo.toLocal().hour==0)
        localTo=24;
      if(widget.consultant.languages!.length>0)
        widget.consultant.languages!.forEach((element) { languages=languages+" "+element;});
      if(widget.consultant.workTimes!.length>0)
      {
        if( resultnooo.hour==12)
          from="12 PM";
        else if( resultnooo.hour==0)
          from="12 AM";
        else if( resultnooo.hour>12){
          from=((resultnooo.hour)-12).toString()+" PM";

        }
        else{

          from=(((resultnooo.hour)-1)).toString()+" AM";


        }

      }
      if(widget.consultant.workTimes!.length>0)
      {
        if( resultnoooo.hour==12)
          to="12 PM";
        else if( resultnoooo.hour==0||resultnoooo.toLocal().hour==24)
          to="12 AM";
        else if( resultnoooo.hour>12)
          to=(((resultnoooo.hour)-12)-1).toString()+" PM";
        else
          to=(resultnoooo.hour).toString()+" AM";

      }
      accountBloc.stream.listen((state) {
        print(state);
        if (state is GetLoggedUserCompletedState) {
          user = state.user;
        }
      });
      //--------add details event
      print("content_view event");
      String eventName = "af_content_view";
      Map eventValues = {
        "af_price": widget.consultant.price,
        "af_content_id": widget.consultant.uid,
      };
      addEvent(eventName, eventValues);

    });

  }



  Future<void> getNumber() async {
    try{
      setState(() {
        load=true;
      });
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where( 'user.uid', isEqualTo: user!.uid,)
          .where( 'consult.uid', isEqualTo: widget.consultant.uid,)
          .where( 'consultType', isEqualTo: widget.consultType)
          .where( 'orderStatus', isEqualTo: 'open')
          .get().then((value) async {
        if(value!=null&&value.docs!=null&&value.docs.length>0) {
          var order2=Orders.fromMap(value.docs[0].data() as Map);
          setState(() {
            order=order2;
          });
          await FirebaseFirestore.instance
              .collection(Paths.appAppointments)
              .where( 'orderId', isEqualTo: order?.orderId,)
              .get().then((value) async {
            if(value.docs.length>0) {
              setState(() {
                currentNumber =(order!.packageCallNum - value.docs.length)>0?(order!.packageCallNum - value.docs.length):0;
              });
            }
            else {
              setState(() {
                currentNumber =order!.packageCallNum;
              });
            }
          }).catchError((err) {
            errorLog("getNumber1",err.toString());
            setState(() {
              load=false;
            });
          });

        }
        else {
          setState(() {
            currentNumber=0;
            order=null;
          });
        }
        setState(() {
          load=false;
        });
      }).catchError((err) {
        errorLog("getNumber",err.toString());
        setState(() {
          load=false;
        });
      });

    }catch(e) {
      errorLog("getNumber",e.toString());
      setState(() {
        load=false;
        currentNumber=0;
        order=null;
      });
    }

  }


  Future<String> myFunction() async {
    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();

    return currentTimeZone;
  }
  errorLog(String function,String error)async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': widget.loggedUser == null ? " " : widget.loggedUser!.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': function,
    });
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
  getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.packagesPath)
          .where('consultUid', isEqualTo:widget.consultant.uid )
          .where('active', isEqualTo: true )
          .where('type', isEqualTo: widget.consultType )
          .orderBy("callNum", descending: false)
          .get();
      var packageList = List<consultPackage>.from(
        querySnapshot.docs.map(
              (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        packages=packageList;
        loadPackage=false;
      });
    } catch (e) {
      setState(() {
        loadPackage=false;
      });
      errorLog("getConsultPackages",e.toString());
    }
  }
  getConsultReviews() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.consultReviewsPath)
          .where('consultUid', isEqualTo:widget.consultant.uid )
          .limit(3)
          .orderBy("reviewTime", descending: true)
          .get();
      var reviewsList = List<ConsultReview>.from(
        querySnapshot.docs.map((snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
        ),  );
      // print(reviewsList.where((o) => o.consultName== "").toList().length);

      setState(() {
        reviewLength=reviewsList.length;
        reviews=reviewsList;
        loadReviews=false;
      });

    } catch (e) {
      setState(() {
        loadReviews=false;
      });
      errorLog("getConsultReviews",e.toString());

    }
  }
  BoxShadow shadow(){return
    BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0, 1.0), // shadow direction: bottom right
    );}
  _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
      package=packages[index];
    });
    if(_selectedIndex==0)
    {
      setState(() {
        showPromo=true;
      });
      calculateDiscount();
    }
    else
      setState(() {
        showPromo=false;
        promo=null;
        controller.text="";
        promoCodeId="";
        checkPromo=false;
        valid=false;
        discount=0;
      });
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
    if(eventName=="af_content_view")
    {
      await FirebaseAnalytics.instance.logSelectItem(
        itemListId:widget.consultant.uid,
        itemListName:  getTranslated(context, "lang")=="ar"?widget.consultant.consultName!.nameAr!:
        getTranslated(context, "lang")=="en"?widget.consultant.consultName!.nameEn!:
        getTranslated(context, "lang")=="fr"?widget.consultant.consultName!.nameFr!:
        widget.consultant.consultName!.nameIn!,
      );
    }
    else if(eventName=="af_purchase")
      await FirebaseAnalytics.instance.logPurchase(
          currency: "USD",
          value: double.parse(price.toString()),
          affiliation: widget.consultant.uid,
          transactionId:orderId
      );

  }
  @override
  Widget build(BuildContext context) {
    String dayNow=DateTime.now().weekday.toString();
    int timeNow=DateTime.now().hour;
    if(widget.consultant.workDays!.contains(dayNow))
    {
      if (localFrom<=timeNow&&localTo>timeNow) {
        avaliable=true;
      }
    }
    lang=getTranslated(context, "lang");
    if(user!=null&&user!.photoUrl!=null&& user!.photoUrl!="")
      setState(() {
        userImage= user!.photoUrl!;
      });
    if(first&&widget.consultant.workDays!.length>0) {
      workDays="";
      if(widget.consultant.workDays!.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
      }
      if(widget.consultant.workDays!.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
      }
      if(widget.consultant.workDays!.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
      }
      if(widget.consultant.workDays!.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
      }
      if(widget.consultant.workDays!.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
      }
      if(widget.consultant.workDays!.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
      }
      if(widget.consultant.workDays!.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
      }
      setState(() {
        workDaysValue="";
        workDaysValue=workDays;
        first=false;
      });
    }
    size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      key:_scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            headerWidget(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
                child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [
                  Padding(
                    padding:  EdgeInsets.only(left: size.width*.20,right: size.width*.20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(children: [
                              Container(height: 30,
                                  width: 30,
                                  decoration:BoxDecoration(
                                    color: AppColors.green,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      shadow()
                                    ],
                                  ),child: Center(child: Image.asset( 'assets/applicationIcons/blackCall.png',width: 15,height: 15,))),
                              SizedBox(height: 1,),
                              Row(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.center,
                                children: [
                                  Image.asset('assets/applicationIcons/greenCall2.png',
                                    width: 12,
                                    height: 12,
                                  ),
                                  Text(//widget.consultant.ordersNumbers==null?'0':widget.consultant.ordersNumbers<100?widget.consultant.ordersNumbers.toString():widget.consultant.ordersNumbers<1000?"+100":"+1000",
                                    orderNum,
                                    style: GoogleFonts.poppins(
                                      color:Colors.black,
                                      fontSize: 11.0,
                                    ),),
                                ],
                              ),
                            ],),
                            Stack(alignment: Alignment.center,children: [
                              Container(
                                height: 71,
                                width: 71,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.grey,width: 1),
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.white,width: 5),
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                  child: widget.consultant.photoUrl!.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 70,height: 70,fit:BoxFit.fill,)
                                      :ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder:'assets/images/load.gif',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 70,height: 70,fit:BoxFit.fill),
                                      image: widget.consultant.photoUrl!,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                      Duration(milliseconds: 250),
                                      fadeInCurve: Curves.easeInOut,
                                      fadeOutDuration:
                                      Duration(milliseconds: 150),
                                      fadeOutCurve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),
                              Image.asset('assets/applicationIcons/dashBorder.png',width: 76,height: 76,),
                              Positioned(
                                bottom: 7,
                                left: 10.0,
                                child: Container(
                                  decoration:  BoxDecoration(
                                    // border: Border.all(color: Colors.white,width: 2),
                                    shape: BoxShape.circle,
                                    color: avaliable?AppColors.green:Colors.red,
                                  ),
                                  width: 8.0,
                                  height: 8.0,

                                ),
                              ),
                            ], ),
                            InkWell(onTap: (){
                              share(context);
                            },
                              child: Column(children: [
                                sharing?Center(child: CircularProgressIndicator()):Container(height: 30,
                                    width: 30,
                                    decoration:BoxDecoration(
                                      color: AppColors.lightPink,
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        shadow()
                                      ],
                                    ),child: Center(child: Image.asset( 'assets/applicationIcons/share.png',width: 15,height: 15,))),
                                SizedBox(height: 1,),
                                Text(widget.consultant.price.toString()+"\$",
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontWeight:FontWeight.bold,fontSize: 12.0,
                                    color: AppColors.black, ),
                                ),
                              ],),
                            )
                          ],
                        ),
                        Text(
                          getTranslated(context, "lang")=="ar"?widget.consultant.consultName!.nameAr!:
                          getTranslated(context, "lang")=="en"?widget.consultant.consultName!.nameEn!:
                          getTranslated(context, "lang")=="fr"?widget.consultant.consultName!.nameFr!:
                          widget.consultant.consultName!.nameIn!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontWeight:FontWeight.bold,fontSize: 14.0,
                            color: AppColors.grey, ),
                        ),
                        SmoothStarRating(
                          allowHalfRating: true,
                          starCount: 5,
                          onRatingChanged:  (v) {
                          },
                          rating: double.parse(widget.consultant.rating.toString()),
                          size: 12.0,
                          color: AppColors.yellow,
                          borderColor:AppColors.yellow,
                          spacing: 1.0,
                        ),
                        SizedBox(height: 20,),
                        /* Icon( Icons.mic_none_rounded,color:AppColors.pink,size: 15.0, ),
                        widget.consultant.languages!.length>1?Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                          langWidget(widget.consultant.languages![0]),
                          SizedBox(width: 5,),
                          langWidget(widget.consultant.languages![1])
                        ],):
                        langWidget(widget.consultant.languages![0]),*/
                      ],),
                  ),

                  SizedBox(height: 20,),
                  Center(
                    child: Container(width: size.width*.9,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: AppColors.lightGrey,width: 1),
                        boxShadow: [
                          shadow()
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 35,width: size.width*.30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                              boxShadow: [
                                shadow()
                              ],
                            ),
                            child:  Center(
                              child: Text(
                                getTranslated(context, "bio"),
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: AppColors.pink,
                                  fontSize: 15.0,),

                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text( getTranslated(context, "lang")=="ar"?widget.consultant.consultBio!.bioAr!:
                          getTranslated(context, "lang")=="en"?widget.consultant.consultBio!.bioEn!:
                          getTranslated(context, "lang")=="fr"?widget.consultant.consultBio!.bioFr!:
                          widget.consultant.consultBio!.bioIn!,maxLines: 3,
                            //widget.consultant.bio!.length>165?widget.consultant.bio!.substring(0,165):widget.consultant.bio!,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: Colors.black.withOpacity(0.5),
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,),
                          ),
                          SizedBox(height: 5,),
                          Row(mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>BioDetailsScreen(consult:widget.consultant),
                                  ),
                                );
                              },
                                child: Container(
                                  height: 20, //width: size.width*.40,
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.pink,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      shadow()
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, "readMore"),
                                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: AppColors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.normal,),

                                        ),
                                        Image.asset(
                                          'assets/applicationIcons/whiteMore.png',
                                          width: 10,
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),),
                  ),

                  SizedBox(height: 20,),
                  Center(
                    child: Container(width: size.width*.9,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5.0),
                        border: Border.all(color: AppColors.lightGrey,width: 1),
                        boxShadow: [
                          shadow()
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 35,width: size.width*.30,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                shadow()
                              ],
                            ),
                            child:  Center(
                              child: Text(
                                getTranslated(context, "Reviews"),
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: AppColors.pink,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,),
                              ),
                            ),
                          ),
                          SizedBox(height: 5,),
                          loadReviews?Center(
                              child: CircularProgressIndicator()):SizedBox(),
                          (loadReviews==false&&reviews.length==0)?Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                MainAxisAlignment.center,
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: <Widget>[

                                  SizedBox(
                                    height: 30.0,
                                  ),
                                  Text(
                                    getTranslated(context, "noReviews"),
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: Colors.black.withOpacity(0.5),
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,),
                                  ),
                                ],
                              ),
                            ),
                          ):SizedBox(),
                          (loadReviews==false&&reviews.length>0)?ListView.separated(
                            itemCount: reviews.length>2?2:reviews.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(0),
                            itemBuilder: (context, index) {
                              return  Container(height: 90,width: size.width,
                                  padding: const EdgeInsets.only(left: 10,right: 10,top:10),
                                  color: Colors.white,child: Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          border: Border.all(color:AppColors.pink,width: 1),
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                        child: reviews[index].image!.isEmpty ?
                                        Icon( Icons.person,color:AppColors.grey,size: 30.0, )
                                            :ClipRRect( borderRadius: BorderRadius.circular(100.0),
                                          child: FadeInImage.assetNetwork(
                                            placeholder:
                                            'assets/icons/icon_person.png',
                                            placeholderScale: 0.5,
                                            imageErrorBuilder:(context, error, stackTrace) => Icon(
                                              Icons.person,color:AppColors.pink,
                                              size: 30.0,
                                            ),
                                            image: reviews[index].image!,
                                            fit: BoxFit.cover,
                                            fadeInDuration:
                                            Duration(milliseconds: 250),
                                            fadeInCurve: Curves.easeInOut,
                                            fadeOutDuration:
                                            Duration(milliseconds: 150),
                                            fadeOutCurve: Curves.easeInOut,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 2,right: 2),
                                        child: Container(width: size.width*.5,
                                          child: Column(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                reviews[index].name,
                                                overflow:TextOverflow.ellipsis ,
                                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                                  color: Theme.of(context).primaryColor,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.bold,
                                                ),),
                                              Text(
                                                reviews[index].review!,
                                                maxLines: 2,
                                                overflow:TextOverflow.ellipsis ,
                                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                                  color:AppColors.grey,
                                                  fontSize: 13.0,
                                                  fontWeight: FontWeight.normal,
                                                ),),
                                            ],),
                                        ),
                                      ),
                                      Row(mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 13,
                                            color: Colors.orange,
                                          ),
                                          Text(
                                            reviews[index].rating.toStringAsFixed(1),
                                            textAlign: TextAlign.start,
                                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                              color: Theme.of(context).primaryColor,
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],)
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return Center(child: Container(color:AppColors.lightGrey,width: size.width*.8,height: 1,));
                            },
                          ):SizedBox(),
                          SizedBox(height: 5,),
                          Row(mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(onTap: (){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewScreens(consult:widget.consultant ,reviewLength:reviewLength,
                                      loggedUser: widget.loggedUser,), ),  );
                              },
                                child: Container(
                                  height: 20, //width: size.width*.40,
                                  padding: const EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.pink,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      shadow()
                                    ],
                                  ),
                                  child: Center(
                                    child: Row(
                                      children: [
                                        Text(
                                          getTranslated(context, "readMore"),
                                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: AppColors.white,
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.normal,),
                                        ),
                                        Image.asset(
                                          'assets/applicationIcons/whiteMore.png',
                                          width: 10,
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),),
                  ),
                  SizedBox(height: 20,),
                  Center(
                    child: Container(height: 38,width: size.width*.40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          shadow()
                        ],
                      ),
                      child:  Center(
                        child: Text(
                          getTranslated(context, "timeOfWork"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),  color: AppColors.pink,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,),

                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.center,children: [
                    //Icon( Icons.calendar_today_outlined,size:30,  color: Theme.of(context).primaryColor,),
                    Image.asset(  'assets/applicationIcons/Iconly-Two-tone-Calendar-1.png',
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: 5,),
                    Container(height: 70,width: size.width*.8,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey2,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child: Text(
                          workDaysValue,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: Theme.of(context).primaryColor,
                            fontSize: 13.0,
                            fontWeight: FontWeight.normal, ),
                        ),
                      ),
                    ),
                  ],),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.center,children: [
                    Image.asset(
                      'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png',
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: 5,),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey2,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:  Text(
                          from,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey2,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:Text(
                          to,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                    SizedBox(width: 5,),
                  ],),
                  SizedBox(height: 20,),
                  Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.center,children: [
                    Image.asset(
                      'assets/applicationIcons/Iconly-Two-tone-TimeCircle.png',
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: 5,),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey2,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:  Text(
                          from,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                    Container(height: 35,width: size.width*.3,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey2,
                        borderRadius: BorderRadius.circular(30.0),

                      ),child:  Center(
                        child:Text(
                          to,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                            letterSpacing: 0.5,
                          ),),
                      ),
                    ),
                    SizedBox(width: 5,),
                  ],),
                  SizedBox(height: 30,),
                  Center(
                    child: Container(height: 40,width: size.width*.40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          shadow()
                        ],
                      ),
                      child:  Center(
                        child: Text(
                          getTranslated(context, "Packages"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.pink,
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,),

                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20,),
                  loadPackage? Center(child: CircularProgressIndicator()):SizedBox(),
                  (loadPackage==false&&packages.length==0)?Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.asset(
                            'assets/images/credit_card.png',
                            width: size.width * 0.6,
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            getTranslated(context, "noPackages"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: AppColors.grey,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ):SizedBox(),
                  (loadPackage==false&&packages.length>0)?ListView.separated(
                    itemCount: packages.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(0),
                    itemBuilder: (context, index) {

                      return InkWell(
                        onTap: () {
                          _onSelected(index);
                        },
                        child: Container(height: 50,width: size.width*.8,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              // color: AppColors.white,
                              borderRadius: BorderRadius.circular(25.0),
                              border: Border.all(color: _selectedIndex != null && _selectedIndex == index
                                  ? AppColors.pink
                                  : AppColors.lightGrey,width: 1),

                            ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                              Container(width: size.width*.3,
                                child: Text(
                                  widget.consultType=="chat"?(packages[index].callNum.toString()+getTranslated(context, "chat"))
                                      :(packages[index].callNum.toString()+getTranslated(context, "call")),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: _selectedIndex != null && _selectedIndex == index
                                        ? AppColors.pink
                                        : AppColors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                  ),),
                              ),
                              index==0?SizedBox(): Container(height: 25,width: size.width*.25,
                                child:Center(
                                  child: Text(
                                    "-"+packages[index].discount.toString()+"%",
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                      color: _selectedIndex != null && _selectedIndex == index
                                          ? AppColors.pink
                                          : AppColors.grey,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),),
                                ),),
                              Container(height: 40,width: size.width*.3,
                                padding: const EdgeInsets.all(5),child:Center(
                                  child: Text(
                                    packages[index].price.toString()+"\$",
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                      color: _selectedIndex != null && _selectedIndex == index
                                          ? AppColors.pink
                                          : AppColors.grey,
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),),
                                ),)
                            ],)
                        ),
                      );
                    },
                    separatorBuilder:
                        (BuildContext context, int index) {
                      return SizedBox(
                        height: 8.0,
                      );
                    },
                  ):SizedBox(),
                  SizedBox(height: 20,),
                  Center(
                    child: Column(
                      children: [
                        showPromo?Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(height: 35,width: size.width*.7,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.lightGrey,
                                    blurRadius: 2.0,
                                    spreadRadius: 0.0,
                                    offset: Offset(
                                        0.0, 1.0), // shadow direction: bottom right
                                  )
                                ],
                              ),
                              child: TextFormField(
                                controller: controller,
                                keyboardType: TextInputType.text,
                                textAlign:TextAlign.center ,
                                textCapitalization: TextCapitalization.sentences,
                                textInputAction: TextInputAction.done,
                                enableInteractiveSelection: true,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  fontSize: 10.0,
                                  color:AppColors.pink,// Colors.black87,
                                  letterSpacing: 0.5,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  contentPadding:
                                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                                  border: InputBorder.none,
                                  hintText: getTranslated(context,"enterPromoCode"),
                                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    fontSize: 10.0,
                                    color:AppColors.pink,// Colors.black54,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  counterStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    fontSize: 12.5,
                                    color: Colors.black54,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                onChanged: (text) {
                                  if(text.length==5)
                                  {
                                    calculateDiscount();
                                  }
                                  if(text.length==0)
                                  {
                                    setState(() {
                                      promo = null;
                                      promoCodeId="";
                                      checkPromo=false;
                                      valid=false;
                                      discount=0;
                                    });
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 5,),
                            Icon(
                              Icons.check_circle,
                              color:valid?Colors.green:AppColors.lightGrey,
                              size: 30.0,
                            ),
                          ],
                        ):SizedBox(),
                        SizedBox(height: 10,),
                        showPromo?Text(
                          getTranslated(context, "proText")+ discount.toString()+"%",
                          maxLines: 3,
                          overflow:TextOverflow.ellipsis ,
                          softWrap: true,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.pink,//Colors.grey,
                          ),
                        ):SizedBox(),
                        showPromo?SizedBox(height: 20,):SizedBox(),
                        SizedBox(height: 20,),
                        (user!=null&&currentNumber!=0)?Container(
                          height: 35,
                          width: size.width*.5,
                          decoration: BoxDecoration(
                              color: Colors.yellow[200],
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(20.0),
                                topRight: const Radius.circular(20.0),
                              )
                          ),child :Center(
                          child: Text(
                            getTranslated(context, "remainingCalls")+": "+currentNumber.toString(),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.black,
                              fontSize: 13.0,
                            ),
                          ),
                        ),):SizedBox(),
                        load?Center(child: CircularProgressIndicator()):
                        SizedBox(
                          height:45,
                          width: size.width * 0.8,
                          child: MaterialButton(
                            onPressed: () async {
                              if(user==null)
                                Navigator.pushNamed(context, '/Register_Type');
                              else if(package==null&&currentNumber<=0)
                                showSnakbar(getTranslated(context,'selectPackage'),false);
                              else if(user!=null&&currentNumber<=0)
                              {
                                setState(() {
                                  load=true;
                                  price=package!.price.toString();
                                  double finalPrice=double.parse(price);
                                  if(valid&&promo!=null)
                                  {
                                    price = (finalPrice - ((finalPrice * double.parse(promo!.discount.toString() ) ) / 100)).toString();
                                  }
                                });
                                if(double.parse( user!.balance.toString())>=double.parse(price.toString()))
                                {
                                  var newBalance=double.parse( user!.balance.toString())-double.parse(price);
                                  await FirebaseFirestore.instance.collection(Paths.usersPath).doc( user!.uid).set({
                                    'balance': newBalance,
                                  }, SetOptions(merge: true));

                                  setState(() {
                                    fromBalance=true;
                                    user!.balance=newBalance;
                                  });
                                  updateDatabaseAfterAddingOrder(user!.customerId, "userBalance");
                                }
                                else
                                {
                                  setState(() {
                                    fromBalance=false;
                                  });
                                  pay();
                                }

                              }
                              else
                                showAddAppointmentDialog();


                            },
                            color: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            child: Text(
                              (user!=null&&currentNumber!=0)?
                              getTranslated(context,"confirm"):getTranslated(context,"participation"),
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                  SizedBox(height: 40,),

                ],),
              ),
            )


          ],
        ),

        showPayView ? Positioned(
          child: Scaffold(backgroundColor: Colors.white,
            body:IndexedStack(
              index: _stackIndex,
              children: <Widget>[
                WebView(
                  initialUrl:initialUrl,
                  navigationDelegate: (NavigationRequest request) {
                    print('request.url '+request.url);
                    if(request.url.startsWith("https://www.jeras.io/app/redirect_url")){
                      print('onPageSuccess');
                      setState(() {
                        _stackIndex = 1;
                        showPayView = false;
                        var str=request.url;
                        const start = "tap_id=";
                        final startIndex = str.indexOf(start);
                        print(str.substring(startIndex + start.length, str.length));
                        String charge=str.substring(startIndex + start.length, str.length);
                        print("chargeeee11111111  "+charge);
                        payStatus(charge);
                      });
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (url) => print("OnPagestarted " + url),
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (url) {
                    print("onPageFinished " + url);
                    //showSnakbar(url, true);
                    setState(() => _stackIndex = 0);} ,
                ),
                Center(child: Text('Loading  ...')),
                Center(child: Text('order ...'))
              ],
            ),
          ),
        ) : Container()
      ]),
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
                          Navigator.pop(context);
                        },
                        icon: Image.asset(  getTranslated(context,"arrow"),
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),
                  widget.loggedUser == null
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
                                            notificationBloc.add(
                                              NotificationMarkReadEvent(
                                                  widget.loggedUser!.uid.toString()),
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
                                          child: Image.asset( 'assets/applicationIcons/Iconly-Two-tone-Notification.png'
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
                                child: Image.asset('assets/applicationIcons/lightSearch.png',
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
                      if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountScreen(user:widget.loggedUser!,firstLogged:false), ),);
                      else if(widget.loggedUser!=null&&widget.loggedUser!.userType!="CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserAccountScreen(user:widget.loggedUser!,firstLogged:false), ),);
                      else{}
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
                        width: 50,
                        height: 50,
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
        SizedBox(
          height: 2,
        ),
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
                child: Image.asset('assets/applicationIcons/Iconly-Two-tone-Notification.png',
                ),
              ),
            ),
          ),
        ),
      ),
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

  calculateDiscount() async {
    print("ssssssss");
    print(_selectedIndex);
    setState(() {
      checkPromo=true;
    });
    if(controller.text!=null&&controller.text!="")
    {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: controller.text )
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
              (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
        ),
      );
      if(codes.length>0) {
        print("promo3");
        print(codes[0].type);
        bool isPrimary=(codes[0].type=="primary"&&codes[0].promoCodeStatus&&_selectedIndex != null &&_selectedIndex==0
            && user!.promoList!=null&& user!.promoList!.contains(codes[0].promoCodeId)==false);
        print(isPrimary);
        bool isDefault=(codes[0].type=="default"&&codes[0].promoCodeStatus&&_selectedIndex != null &&_selectedIndex==0);
        bool isPromition=(codes[0].type=="promotion"&&codes[0].promoCodeStatus&&codes[0].usedNumber==0&&_selectedIndex != null &&_selectedIndex==0);
        if(isDefault||isPrimary||isPromition)
          setState(() {
            promo = codes[0];
            promoCodeId=promo!.promoCodeId;
            checkPromo=false;
            valid=true;
            discount=promo!.discount;
          });
        else
          setState(() {
            print("promo4");
            promo = null;
            promoCodeId="";
            checkPromo=false;
            valid=false;
            discount=0;
          });
      }else{
        setState(() {
          print("promo4");
          promo = null;
          promoCodeId="";
          checkPromo=false;
          valid=false;
          discount=0;
        });
      }
    }

  }
  pay() async {
    try{
      if(user!=null&& user!.name!=null)
        userName= user!.name!;
      String description="السعر";
      /* if( user!.countryCode!=null&& user!.countryCode=="+966")
        description=" السعر شامل ضريبة القيمة المضافة";*/
      print("payStart111");
      final uri = Uri.parse('https://api.tap.company/v2/charges');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'

      };
      var destinationBody ={};
      /*  if(widget.consultant.allowEditPayinfo==false&&widget.consultant.marketplace!&&widget.consultant.destinationId!=null&&widget.consultant.destinationId!="")
      {  destinationBody={
        "destination": [
          {
            "id":widget.consultant.destinationId,// widget.consultant.destinationId!=null? widget.consultant.destinationId:setting.focalDestination,
            "amount": destinationAmount,
            "currency": "USD"
          },

        ]
      };
      }*/

      Map<String, dynamic> body ={
        "amount": price,
        "currency": "USD",
        "threeDSecure": true,
        "save_card": true,
        "description": description,
        "statement_descriptor": "مؤسسة  محور النقطة",
        "metadata": {
          "udf1": "مؤسسة  محور النقطة",
          "udf2": "مؤسسة  محور النقطة"
        },
        "reference": {
          "transaction": "txn_0001",
          "order": "ord_0001"
        },
        "receipt": {
          "email": false,
          "sms": true
        },
        "customer": {
          "id": user!.customerId!=null? user!.customerId:'',
          "first_name":userName,
          "middle_name": ".",
          "last_name": ".",
          "email": userName+"@dream.com",
          "phone": {"country_code": "",
            "number": user!.phoneNumber
          }
        },
        "destinations":destinationBody,
        "merchant": {
          "id": ""
        },
        "source": {
          "id": "src_all"
        },
        "post": {
          "url": "http://your_website.com/post_url"
        },
        "redirect": {
          "url": "https://www.jeras.io/app/redirect_url"
        }
      };

      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      String responseBody = response.body;
      print(responseBody);
      var res = json.decode(responseBody);
      String url = res['transaction']['url'];

      // Navigator.pop(context);
      setState(() {
        initialUrl=url;
        showPayView = true;
      });
    }catch(e){
      print("xxxxx"+e.toString());
      errorLog("pay",e.toString());
      await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
        "success": false,
        "reason": e.toString(),
        "userUid":widget.loggedUser!.uid
      } );
      setState(() {
        showPayView=false;
        //load=false;
      });
      showMessage(getTranslated(context, "failed"));
      showDialog(context: context, builder: (context)=> ShowDialog(
        contentText: 'otherPay',
        noFunction:()
        {
          setState(() {
            load=false;
          });
          Navigator.pop(context);
        },
        yesFunction: ()
        {
          Navigator.pop(context);
          setState(() {
            load=true;
          });
          stripePayment(email: widget.loggedUser!.phoneNumber.toString()+"Dream@gmail.com", amount: double.parse(price)*100,context: context);

        },
      ));
    }

  }
  showMessage(String message){
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }
  payStatus(String chargeId) async {
    try{
      print("payStatusqqqq");

      final uri = Uri.parse('https://api.tap.company/v2/charges/'+chargeId);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      var response = await get(
        uri,
        headers: headers,

      );
      print("aaaaalllll");
      print(response.body);
      String responseBody = response.body;
      var res = json.decode(responseBody);
      print(res);
      String? customerId=res['customer']['id'];
      customerId= customerId!=null?customerId:"";
      if(res['status']=="CAPTURED")
      {
        updateDatabaseAfterAddingOrder(customerId,"tapCompany");
      }
      else
      {
        setState(() {
          load=true;
          showPayView=false;
        });
        //--------add details event
        print("add_payment_info event");
        await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
          "success": false,
          "reason": res['status'],
          "userUid":widget.loggedUser!.uid
        } );
        String eventName = "af_add_payment_info";
        Map eventValues = {
          "af_success": false,
          "af_achievement_id": res['status'],
        };
        addEvent(eventName, eventValues);
        String id = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.errorLogPath) .doc(id).set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': res['status'],
          'phone': widget.loggedUser == null ? " " : widget.loggedUser!.phoneNumber,
          'screen': "ConsultantDetailsScreen",
          'function': "payStatus",
        });
        print("start payment with stripe");
        showMessage(getTranslated(context, "failed"));
        showDialog(context: context, builder: (context)=> ShowDialog(
          contentText: 'otherPay',
          noFunction:()
          {
            setState(() {
              load=false;
            });
            Navigator.pop(context);
          },
          yesFunction: ()
          {
            Navigator.pop(context);
            setState(() {
              load=true;
            });
            stripePayment(email: widget.loggedUser!.phoneNumber.toString()+"Dream@gmail.com", amount: double.parse(price)*100,context: context);

          },
        ));
      }
    }catch(e){
      errorLog("payStatus",e.toString());
      setState(() {
        showPayView=false;
        load=false;
      });
      await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
        "success": false,
        "reason": e.toString(),
        "userUid":widget.loggedUser!.uid
      } );
      String eventName = "af_add_payment_info";
      Map eventValues = {
        "af_success": false,
        "af_achievement_id": e.toString(),
      };
      addEvent(eventName, eventValues);
      showSnakbar(getTranslated(context, "failed"),true);
      showDialog(context: context, builder: (context)=> ShowDialog(
        contentText: 'otherPay',
        noFunction:()
        {
          setState(() {
            load=false;
          });
          Navigator.pop(context);
        },
        yesFunction: ()
        {
          Navigator.pop(context);
          setState(() {
            load=true;
          });
          stripePayment(email: widget.loggedUser!.phoneNumber.toString()+"Dream@gmail.com", amount: double.parse(price)*100,context: context);

        },
      ));
    }
  }
  updateDatabaseAfterAddingOrder(String? customerId,String payWith) async {
    try{
      String orderId=Uuid().v4();
      DateTime dateValue=DateTime.now();
      dynamic callPrice=double.parse(price.toString())/package!.callNum;
      await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
        'orderStatus':'open',
        'orderId': orderId,
        'date':{
          'day': dateValue.toUtc().day,
          'month': dateValue.toUtc().month,
          'year': dateValue.toUtc().year,
        },
        'utcTime':dateValue.toUtc().toString(),
        'orderTimestamp': Timestamp.now(),
        'orderTimeValue': DateTime(dateValue.year, dateValue.month, dateValue.day ).millisecondsSinceEpoch,
        "consultType":widget.consultType,
        'packageId': package!.Id,
        'promoCodeId':promoCodeId,
        'remainingCallNum':package!.callNum,
        'packageCallNum': package!.callNum,
        'answeredCallNum':0,
        'callPrice':callPrice,
        "payWith":payWith,
        "platform": Platform.isIOS ? "iOS" : "Android",
        'price':price.toString(),
        'consult': {
          'uid': widget.consultant.uid,
          'name': widget.consultant.name,
          'image': widget.consultant.photoUrl,
          'phone': widget.consultant.phoneNumber,
          'countryCode': widget.consultant.countryCode,
          'countryISOCode': widget.consultant.countryISOCode,

        },
        'user': {
          'uid': user!.uid,
          'name': user!.name,
          'image': user!.photoUrl,
          'phone': user!.phoneNumber,
          'countryCode': user!.countryCode,
          'countryISOCode': user!.countryISOCode,

        },
      });
      currentNumber=package!.callNum;
      getNumber();

      //update user order numbers
      int userOrdersNumbers=1;
      dynamic payedBalance=double.parse(price.toString());
      if( user!.ordersNumbers!=null)
        userOrdersNumbers= user!.ordersNumbers!+1;
      if( user!.payedBalance!=null)
        payedBalance= user!.payedBalance+payedBalance;

      if(promo!=null&&promo!.type!=null&&promo!.type=="primary")
        user!.promoList!.add(promo!.promoCodeId);

      await FirebaseFirestore.instance.collection(Paths.usersPath).doc( user!.uid).set({
        'ordersNumbers': userOrdersNumbers,
        'payedBalance':payedBalance,
        'customerId':customerId,
        'promoList': user!.promoList,
        'preferredPaymentMethod':"tapCompany"
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
//======update number of use of promocode
      if(promo!=null)
      {
        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.promoPath).doc(promo!.promoCodeId).get();
        Map data = documentSnapshot.data() as Map;
        int usedNumber = data['usedNumber'];
        await FirebaseFirestore.instance.collection(Paths.promoPath).doc(
            promo!.promoCodeId).set({
          'usedNumber': usedNumber + 1,
        }, SetOptions(merge: true));
      }
      //---------
      /*if(widget.consultant.allowEditPayinfo==false&&widget.consultant.marketplace!&&
          widget.consultant.destinationId!=null&&widget.consultant.destinationId!="") {
        await FirebaseFirestore.instance.collection(Paths.usersPath).doc(
            widget.consultant.uid!).set({
        'tapBalance': widget.consultant.tapBalance+destinationAmount,

        }, SetOptions(merge: true));
    }*/
      //--------add details event
      print("add_payment_info event");
      String eventName = "af_add_payment_info";
      Map eventValues = {
        "af_success": true,
        "af_achievement_id": "success",
      };
      addEvent(eventName, eventValues);
      await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
        "success": true,
        "reason": "success",
        "userUid":widget.loggedUser!.uid
      } );
      //-----------
      print("af_purchase event");
      eventName = "af_purchase";
      eventValues = {
        "af_revenue": price.toString(),
        "af_price": price.toString(),
        "af_content_id": widget.consultant.uid,
        "af_order_id": orderId,
        "af_currency": "USD",
      };
      addEvent(eventName, eventValues);

      //================
      showAddAppointmentDialog();

    }catch(e){
      errorLog("updateDatabaseAfterAddingOrder", e.toString());
    }
  }

  Future<void> stripePayment( { required String email, required double amount, required BuildContext context}) async {
    try {
      print("stripePayment1");
      print(amount.toString());
      final response = await http.post(
          Uri.parse(
              'https://us-central1-make-my-nikah-d49f5.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {
            'email': email,
            'amount': amount.toString(),
          });
      print("stripePayment2");
      final jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            // testEnv: false,
            applePay: PaymentSheetApplePay(merchantCountryCode: 'AE'),
            googlePay: PaymentSheetGooglePay(merchantCountryCode: 'AE'),
            merchantDisplayName: "Dream Application",
            style: ThemeMode.dark,
            appearance: PaymentSheetAppearance(
              /*   colors: PaymentSheetAppearanceColors(
                background: Colors.white,
                primary: Colors.white,
                componentBorder: Colors.black,
              ),
              shapes: PaymentSheetShape(
                borderWidth: 4,
                shadow: PaymentSheetShadowParams(color: Colors.white),
              ),*/
              primaryButton: PaymentSheetPrimaryButtonAppearance(
                shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
                colors: PaymentSheetPrimaryButtonTheme(
                  dark: PaymentSheetPrimaryButtonThemeColors(
                    background: AppColors.pink,
                    text: AppColors.white,
                    border: Colors.white,
                  ),
                  light: PaymentSheetPrimaryButtonThemeColors(
                    background: AppColors.pink,
                    text: AppColors.white,
                    border: Colors.white,
                  ),
                ),
              ),
            ),

          ));
      print("stripePayment3");
      await Stripe.instance.presentPaymentSheet();
      showMessage("Payment is successful");
      print("stripePayment4");
      updateDatabaseAfterAddingOrder( user!.customerId, "stripe ");
    } catch (errorr) {
      print("stripeerror");
      print("error in stripe is ${errorr.toString()}");
      if (errorr is StripeException) {
        showMessage('An error occured ${errorr.error.localizedMessage}');
      } else {
        showMessage('An error occured $errorr');
      }
      setState(() {
        load=false;
      });
    }
  }
  showAddAppointmentDialog() async {
    bool isProceeded = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AddAppointmentDialog(
            loggedUser: user!,
            consultant: widget.consultant,
            order:order!,
            localFrom: localFrom,
            localTo: localTo,
            currentNumber:currentNumber-1,
            consultType:widget.consultType

        );
      },
    );

    if (isProceeded != null) {
      if (isProceeded) {
        print("allah");
        setState(() {
          load=false;
        });
      }
    }
  }
  cleanConsultDays() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.consultDaysPath)
          .where('date', isLessThan:DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).millisecondsSinceEpoch)
          .where('consultUid', isEqualTo: widget.consultant.uid )
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance.collection(Paths.consultDaysPath).doc(doc.id).delete();
      }

    } catch (e) {
      print("hhhhhh"+e.toString());
    }
  }
  Widget langWidget(String langText){
    return Container(
      height: 20,
      width: 40,//size.width * .30,
      decoration: BoxDecoration(
        color: AppColors.lightPink2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          langText,
          textAlign: TextAlign.center,
          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),color: AppColors.pink,
            fontSize: 9.0, ),

        ),
      ),
    );
  }
  share(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    // Create DynamicLink
    String uid=widget.consultant.uid!;
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://dreamuser\.page\.link/consultant_id="+uid),
      uriPrefix:"https://dreamuser\.page\.link",
      androidParameters:
      const AndroidParameters(packageName: "com.app.dreamTest"),
      iosParameters: const IOSParameters(
          bundleId: "com.app.dreamTest",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    ShortDynamicLink dynamicLink =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    File file;
    if (widget.consultant.photoUrl!.isEmpty) {
      final bytes =
      await rootBundle.load('assets/applicationIcons/whiteLogo.png');
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
    } else {
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consultant.photoUrl!));
      file=await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png').writeAsBytes(response.bodyBytes);
    }

    Share.shareFiles(["${file.path}"],
        text:'(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consultant.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    setState(() {
      sharing = false;
    });
  }

}


