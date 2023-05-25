
import 'package:another_flushbar/flushbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/appointmentWidget.dart';
import 'package:grocery_store/widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';
import '../models/banner.dart';
import '../screens/consultantDetailsScreen.dart';
import '../screens/moreScreen.dart';

class HomePage extends StatefulWidget {
  final String? userType;

  const HomePage({Key? key, this.userType}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late AccountBloc accountBloc;
  GroceryUser? user;
  bool? first;
  bool voice = true;
  bool chat = false;
  bool load = true, loadPageWidget = true,loadBanner=true;
  bool active = false;
  bool loadData=false;
  List<banner> bannerList = [];
  late Query query, userQuery;
  late String lang;
  bool avaliable = false;
  DateTime _now = DateTime.now();

  late String userId;
  var registered = false;
  var hasPushedToCall = false;
  late AppLifecycleState state;

  @override
  void initState() {
    super.initState();
    first = true;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }
  @override
  void dispose() {
    first = true;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    userQuery = FirebaseFirestore.instance
        .collection('Users')
        .where('userType', isEqualTo: 'CONSULTANT')
        .where('accountStatus', isEqualTo: "Active")
        .where('voice', isEqualTo: true)
        .where('languages', arrayContains:getTranslated(context, "lang"))
        .orderBy('order', descending: true);
    getImageSlider();
    super.didChangeDependencies();
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
        style: TextStyle(
         fontFamily: getTranslated(context, 'fontFamily'),
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");
    print("ggggg444");
    print(lang);
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        key: _scaffoldKey,
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            print("Account state");
            print(state);
            if (state is GetLoggedUserInProgressState) {
              return loadingWidget();
            }
            else if (state is GetLoggedUserCompletedState) {
              user=state.user;
              if(user!.userType=="CONSULTANT") {
                 checkAvaliable();
                return consultHome(size);
              }
              else {
                return userHome(size);
              }
            }
            else {
              return userHome(size);
            }
          },
        ),
      ),
    );
  }
  Widget loadingWidget() {
    return Center(child: CircularProgressIndicator(color: AppColors.pink,),);
    Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.black.withOpacity(0.6),
        child: Container(
          height: 60,
          width: MediaQuery
              .of(context)
              .size
              .width * .9,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ));
  }
  Widget userHome(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding:  EdgeInsets.only(left: size.width*.05,right: size.width*.05,top: 10,bottom: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start,children: [
            Text.rich(
              TextSpan(
                text: getTranslated(context, "activeNow"),
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,
                  color:AppColors.black.withOpacity(.8), ),
                children: <TextSpan>[
                  TextSpan(
                    text: ' >',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.grey,
                    ),
                  ),

                ],
              ),
            ),
          ],),
        ),
        imageSlider(size),
        SizedBox(
          height: 20,
        ),
        Center(
          child: Container(
              width: size.width * .80,
              child: Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            voice = true;
                            chat = false;

                            userQuery = FirebaseFirestore.instance
                                .collection('Users')
                                .where('userType', isEqualTo: 'CONSULTANT')
                                .where('accountStatus', isEqualTo: "Active")
                                .where('languages', arrayContains:getTranslated(context, "lang"))
                                .where('voice', isEqualTo: true)
                                .orderBy('order', descending: true);
                          });
                        },
                        child: Container(
                          height: 27,
                          width: size.width * .30,
                          decoration: BoxDecoration(
                            color:
                                voice ? AppColors.pink : AppColors.lightPink2,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "voice"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: voice ? Colors.white : AppColors.pink,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            chat = true;
                            voice = false;
                            userQuery = FirebaseFirestore.instance
                                .collection('Users')
                                .where('userType', isEqualTo: 'CONSULTANT')
                                .where('accountStatus', isEqualTo: "Active")
                                .where('languages', arrayContains:getTranslated(context, "lang"))
                                .where('chat', isEqualTo: true)
                                .orderBy('order', descending: true);
                          });
                        },
                        child: Container(
                          height: 27,
                          width: size.width * .30,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: chat ? AppColors.pink : AppColors.lightPink2,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "chat"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: chat ? Colors.white : AppColors.pink,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              )),
        ),
        SizedBox(
          height: 10,
        ),
        Expanded(
          child: PaginateFirestore(
            key: ValueKey(userQuery),
            itemBuilderType: PaginateBuilderType.gridView,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 13,
                mainAxisSpacing: 13,
                mainAxisExtent: 150,
                childAspectRatio: 1.8),
            padding: const EdgeInsets.only(
                left: 20.0, right: 20.0, bottom: 16.0, top: 1.0),
            itemBuilder: (context, documentSnapshot, index) {
              final data = documentSnapshot[index].data() as Map;
              return ConsultantListItem(
                  consult: GroceryUser.fromMap(data),
                  loggedUser: user,
                  consultType: voice ? "voice" : "chat");
            },
            query: userQuery,
            isLive: true,
          ),
        )
      ],
    );
  }
  Widget consultHome(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 10),
          child: Center(
            child: Container(
              height: 30,
              width: size.width * .30,
              decoration: BoxDecoration(
                color: avaliable ? Colors.green : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Text(
                  avaliable
                      ? getTranslated(context, "available")
                      : getTranslated(context, "notAvailable"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    color: Colors.white,
                    fontSize: 12.0,
                  ),
                ),
              ),
            ),
          ),
        ),
         Expanded(
                child: PaginateFirestore(
                  separator:SizedBox(height: 30,),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding:  EdgeInsets.only(
                      left: size.width*.10,right:size.width*.10, bottom: 16.0, top: 16.0),
                  //Change types accordingly
                  itemBuilder: (context, documentSnapshot, index) {
                    return AppointmentWiget(
                        appointment: AppAppointments.fromMap(
                            documentSnapshot[index].data()  as Map),
                        loggedUser: user,);
                  },
                  query: FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .where('consult.uid', isEqualTo: user!.uid)
                      .where('appointmentStatus', isEqualTo: "open")
                      .orderBy('timestamp', descending: true),
                  // to fetch real-time data
                  isLive: true,
                ),
              )

      ],
    );
  }
  Widget imageSlider(Size size){

    return  Center(
        child: Stack(children: <Widget>[
          Column(
            children: [
              bannerList.length>0?Center(
                   child: ImageSlideshow(
                    width: size.width*.90,
                    height: size.height*0.15,
                    initialPage: 0,
                    indicatorColor: AppColors.white,
                    indicatorBackgroundColor: AppColors.linear1,

                    autoPlayInterval: 3000,
                    isLoop: true,
                    children: [
                      for ( var slideUser in bannerList )
                        InkWell(
                          onTap: () async {
                          setState(() {
                            loadData=true;
                          });
                          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath)
                              .doc(slideUser.uid).get();
                          GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);
                          setState(() {
                            loadData=false;
                          });
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsultantDetailsScreen(
                                consultant: currentUser,
                                consultType: currentUser.voice!?"voice":"chat",
                              ),
                            ),
                          );
                        },
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: slideUser.image!,
                                width: size.width*.90,
                                height: size.height*0.15,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.contain,
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.lightPink2,
                                        BlendMode.colorBurn,
                                      ),
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) =>Center(child:  CircularProgressIndicator(),),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/applicationIcons/GroupLogo.png',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Center(child: Visibility(visible:loadData,child: CircularProgressIndicator()))
                            ],
                          ),
                        ),

                    ],
                ),
              ):SizedBox(),
              SizedBox(
                height: 5,
              )
            ],
          ),
          Positioned(
            bottom:2,
            left: 25.0,
            child: InkWell(
              onTap: () {
              Navigator.push(
                  context,MaterialPageRoute(builder: (context) => MoreScreen()), );
               // logEvent();
              },
              child: Container(
                height: 20,
                padding: const EdgeInsets.only(left: 5, right: 5),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lightPink,
                      blurRadius: 4.0,
                      spreadRadius: 0.0,
                      offset:
                      Offset(0.0, 1.0), // shadow direction: bottom right
                    )
                  ],
                ),
                child: Center(
                  child: Row(
                    children: [
                      Text(
                        getTranslated(context, "visit"),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.pink,
                          fontSize: 10.0,
                        ),
                      ),
                      Image.asset(
                        'assets/applicationIcons/moreArrow.png',
                        width: 10,
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]));
}
  @override
  bool get wantKeepAlive => true;
  checkAvaliable() async {
    var dateUtc = DateTime.now().toUtc();
    var strToDateTime = DateTime.parse(dateUtc.toString());
    final convertLocal = strToDateTime.toLocal();
    print(convertLocal.hour);
    if (user != null &&
        user?.userType == "CONSULTANT" &&
        user!.profileCompleted!) {
      String dayNow = _now.weekday.toString();
      int timeNow = _now.hour;
      if (user!.workDays!.contains(dayNow)) {
        if (int.parse(user!.workTimes![0].from!) <= timeNow &&
            int.parse(user!.workTimes![0].to!) > timeNow) {
          //if(mounted)setState(() {
            avaliable = true;
         // });
        }
      }
    }
    if (user != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user!.uid!)
          .set({
        'userLang': getTranslated(context, "lang"),
      }, SetOptions(merge: true));
    }
  }
  getImageSlider() async {
    try {
      print("getImageSlider");
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.bannerPath)
        .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('status', isEqualTo:true)
          .get();
      var _bannerList = List<banner>.from(
        querySnapshot.docs.map(
              (snapshot) => banner.fromMap(snapshot.data() as Map),
        ),
      );
      print("bbbbbbbbbaner");
      print(_bannerList.length);
      setState(() {
        bannerList=_bannerList;
        loadBanner=false;
      });

    } catch (e) {
      print("bbbbbbbbbanererror");
      print(e.toString());
      setState(() {
        loadBanner=false;
      });

    }
  }

//////////test functions
  updateName() async {
    try{
      print("ggggg000");
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('userType',isEqualTo: "USER")
         // .where('accountStatus',isEqualTo: "Active")
          .get();
      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          print("hhhh");
          print(doc.id);
          print(doc['name']);

          List<String>indexListAr=[];
          for(int y=1;y<=doc['name'].trimLeft().trimRight().length;y++)
            indexListAr.add(doc['name'].trimLeft().trimRight().substring(0,y).toLowerCase());

          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
            'consultName': {
              'nameAr': doc['name'],
              'nameEn': doc['name'],
              'nameFr': doc['name'],
              'nameIn': doc['name'],
              'searchIndexAr': indexListAr,
              'searchIndexEn':indexListAr,
              'searchIndexFr': indexListAr,
              'searchIndexIn': indexListAr,
            },
            'userLang':'ar'

          }, SetOptions(merge: true));
        }
        print("ggggg00055555");
      }
      print("ggggg000end");
    }catch(e){
      print("ggggg000error");
      print(e.toString());
    }
  }
  updatelang() async {
    try{
      print("ggggg000");
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('userType',isEqualTo: "CONSULTANT")
          .where('languages',isEqualTo: ["العربية"])
          .get();
      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          print("hhhh");
          print(doc.id);
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(doc.id)
              .set({
             'languages':["ar"]
          }, SetOptions(merge: true));
        }
        print("ggggg00055555");
      }
      print("ggggg000end");
    }catch(e){
      print("ggggg000error");
      print(e.toString());
    }
  }
}
