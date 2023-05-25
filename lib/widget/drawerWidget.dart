
import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/sign_up_screen.dart';
import '../blocs/sign_in_bloc/signin_bloc.dart';
import '../localization/language_constants.dart';
import '../main.dart';
import '../screens/DevelopTechSupport/allDevelopSupport.dart';
import '../screens/aboutUsScreen.dart';
import '../screens/account_screen.dart';
import '../screens/addFakeReview.dart';
import '../screens/allConsultReviewScreen/ActiveConsultsScreen1.dart';
import '../screens/consultPaymentHistoryScreen.dart';
import '../screens/invoice/allInvoicesScreen.dart';
import '../screens/myOrderScreen.dart';
import '../screens/promoCodesScreens/allPromoCodesScreen.dart';
import '../screens/push_notifications_screens/AllSendedNotification.dart';
import '../screens/question/questionScreens.dart';
import '../screens/reviews_screen.dart';
import '../screens/suggestionScreen.dart';
import '../screens/supervisor/allConsultantsScreen.dart';
import '../screens/techUserDetails/userDetailsScreen.dart';
import '../screens/technicalAppointment/allAppointmentScreen.dart';
import '../screens/userAccountScreen.dart';
import '../screens/walletScreen.dart';
import 'default_text_widget.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget();

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late GroceryUser user;
  bool load = false, loadUser = true, wrongNumber = false,changeLang=false;
  late bool isSigningOut;
  TextEditingController searchController = new TextEditingController();
   String userImage="", userName="", lang="ar", theme = "light";
   String selectedLang=" ";
  late Size size;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());

  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang=getTranslated(context, "lang");
    return Drawer(backgroundColor: Colors.white,
        child: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            print("Account state");
            print(state);
            if (state is GetLoggedUserInProgressState) {
              return Center(child: CircularProgressIndicator());
            }
            else if (state is GetLoggedUserCompletedState) {
              user=state.user;
              return loggedUserDrawer(size);
            }
            else {
              return notLoggedUserDrawer(size);
            }
          },
        ));}
  Widget loggedUserDrawer(Size size) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
             /* IconButton(
                iconSize: 20,
                onPressed: () {
                  if (lang == "ar")
                    changelanguage("en", "US");
                  else
                    changelanguage("ar", "AR");
                },
                icon: Image.asset(
                  lang == "ar"
                      ? 'assets/applicationIcons/Group166.png'
                      : 'assets/applicationIcons/arabicPink.png',
                  width: 25,
                  height: 25,
                ),
              ),*/
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: InkWell(
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
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/applicationIcons/dreamLogo.png',
                )),
          ),
        ),

        Center(
          child: Text(
            getTranslated(context, "lang")=="ar"?user.consultName!.nameAr!:
            getTranslated(context, "lang")=="en"?user.consultName!.nameEn!:
            getTranslated(context, "lang")=="fr"?user.consultName!.nameFr!:
            user.consultName!.nameIn!,
            style: TextStyle(
              fontFamily: getTranslated(context, 'fontFamily'),
              fontSize: 12.0,
              color: Color.fromRGBO(156 ,57, 129,1),
            ),
          ),
        ),

        Center(
          child: Text(
            getTranslated(context, "welcomeBack"),
            style: TextStyle(
             fontFamily: getTranslated(context, 'fontFamily'),
              fontSize: 12.0,
              color: AppColors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding:
              const EdgeInsets.only(top: 20, right: 20, left: 20, bottom: 40),
          child: (user.userType != null && user.userType == "SUPPORT")
              ? Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      getTranslated(context, "searchByMobile"),
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 18.0,
                        color: AppColors.pink,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: searchController,
                      enableInteractiveSelection: true,
                      onChanged: (text) {
                        setState(() {
                          wrongNumber = false;
                        });
                      },
                      style: TextStyle(
                       fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.0,
                        color: AppColors.black,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor:
                            theme == "light" ? Colors.white : Color(0xff3f3f3f),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                        helperStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        errorStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 13.0,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        hintStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.black54,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        prefixIcon: Icon(Icons.search),
                        prefixStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        suffixIcon: InkWell(
                            child: Icon(Icons.send_rounded, size: 18),
                            onTap: () {
                              initiateSearch(searchController.text);
                            }),
                        // labelText: getTranslated(context, "phoneNumber"),
                        labelStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
/*
                                    border: InputBorder.none,
*/
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    load ? CircularProgressIndicator() : SizedBox(),
                    SizedBox(
                      height: 5,
                    ),
                    wrongNumber
                        ? Text(
                            getTranslated(context, "noUser"),
                            style: GoogleFonts.elMessiri(
                              color: Colors.red,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : SizedBox(),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          getTranslated(context, "balance"),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          double.parse(user.balance.toString())
                                  .toStringAsFixed(2) +
                              "\$",
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          getTranslated(context, "orderNum"),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            color: AppColors.grey,
                          ),
                        ),
                        Text(
                          user.ordersNumbers.toString(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
        InkWell(onTap: () {
          if (user != null && user.userType != "CONSULTANT")
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
        },child:
        DrawerItem(title: getTranslated(context, "account"),sz:17, image: 'assets/applicationIcons/Iconly-Two-tone-Profile.png',),),

        user.isSupervisor==true
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllConsultantScreen(
                loggedUser: user,
              ),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "consultNum"),sz:20, image: 'assets/applicationIcons/Group895.png',),): SizedBox(),

        user.userType == "USER"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletScreen(
                loggedUser: user,
              ),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "wallet"),sz:20, image: 'assets/applicationIcons/Group895.png',),): SizedBox(),

        user.userType == "CONSULTANT"
            ? InkWell(  onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConsultPaymentHistoryScreen(
                user: user,
              ),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "paymentHistory"),sz:20, image: 'assets/applicationIcons/Group895.png',),): SizedBox(),

        user.userType == "CONSULTANT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyOrdersScreen(
                user: user,
                loggedType: user.userType,
                fromSupport: false,
              ),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "orders"),sz:20, icon: Icons.list_alt_rounded,),): SizedBox(),

        user.userType == "CONSULTANT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewScreens(
                consult: user,
                reviewLength: 1,
              ),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "Reviews"),sz:20, icon: Icons.star_border,),): SizedBox(),

        user.userType == "SUPPORT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllInvoicesScreen(loggedUser: user,),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "invoices"), icon: Icons.wysiwyg_rounded,),): SizedBox(),

        user.userType == "SUPPORT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AllDevelopTechScreen(loggedUser: user),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "developNotes"),sz:20, icon: Icons.check,),): SizedBox(),

        user.userType == "SUPPORT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AllAppointmentsScreen(loggedUser: user,),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "appointments"),sz:20, icon: Icons.calendar_today_rounded,),): SizedBox(),


        user.userType == "SUPPORT"
            ? InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllPromoCodeScreen(),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "proCodes"),sz:20, icon: Icons.card_giftcard,),): SizedBox(),

        user.userType == "SUPPORT"
            ? InkWell(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AllSendedNotificationSreen(),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "notification"),sz:20, icon: Icons.notifications_none_sharp,),): SizedBox(),

        user.userType == "SUPPORT"
            ? InkWell(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveConsultsScreen1(loggedUser:user),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "Reviews"),sz:20, icon: Icons.note_add_outlined,),): SizedBox(),

        InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuggestionScreen(loggedUser: user),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "suggestions"),sz:22, image: 'assets/applicationIcons/Group894.png',),),

        InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionScreen(user: user),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "questions"),sz:20, image: 'assets/applicationIcons/question.png',),),

        InkWell(   onTap: () {
          showLangDialog(size);
        },child:
        DrawerItem(title: getTranslated(context, "languages"),sz:20, icon: Icons.language,),),


        InkWell(   onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutUsScreen(),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "aboutUs"),sz:23, icon: Icons.info_outline,),),

        InkWell( onTap: () {
          showSignoutConfimationDialog(size);
        },child:
        DrawerItem(title: getTranslated(context, "logout"),sz:20, image: 'assets/applicationIcons/system_update_alt-24px.png',),),


        SizedBox(
          height: 50,
        ),
        Center(
          child: Container(
            width: size.width * .8,
            height: 45.0,
            child: MaterialButton(
              onPressed: () async {
                inviteAFriend();
              },
              // color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/applicationIcons/Group896.png',
                    width: 25,
                    height: 25,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  text(getTranslated(context, "share"),)

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget text(String text,) {
    return  Stack(
      children: <Widget>[
        Text(
         text,
          style: TextStyle(
           fontFamily: getTranslated(context, 'fontFamily'),
            fontSize: 14,
            fontWeight: FontWeight.w300,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.5
              ..color = Color.fromRGBO(32, 32, 32, 1),
          ),
        ),
        // Solid text as fill.
        Text(
         text,
          style: TextStyle(
           fontFamily: getTranslated(context, 'fontFamily'),
            color:  Color.fromRGBO(32, 32, 32, 1),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
  Widget notLoggedUserDrawer(Size size) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
             /* IconButton(
                iconSize: 20,
                onPressed: () {
                  if (lang == "ar")
                    changelanguage("en", "US");
                  else
                    changelanguage("ar", "AR");
                },
                icon: Image.asset(
                  lang == "ar"
                      ? 'assets/applicationIcons/Group166.png'
                      : 'assets/applicationIcons/arabicPink.png',
                  width: 25,
                  height: 25,
                ),
              ),*/
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Center(
          child: InkWell(
            splashColor: Colors.white.withOpacity(0.6),
            onTap: () {
              Navigator.pushNamed(context, '/Register_Type');
            },
            child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/applicationIcons/dreamLogo.png',
                )),
          ),
        ),
        Center(
          child: Text(
            getTranslated(context, "welcomeBack"),
            style: TextStyle(
             fontFamily: getTranslated(context, 'fontFamily'),
              fontSize: 12.0,
              fontWeight: FontWeight.normal,
              color: AppColors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 70,
        ),
        InkWell(    onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SuggestionScreen(loggedUser: user),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "suggestions"),sz:20, image: 'assets/applicationIcons/Group894.png',),),

        InkWell(onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => QuestionScreen(user: user,),
          ),
          );
          },child:
        DrawerItem(title: getTranslated(context, "questions"),sz:20, image: 'assets/applicationIcons/question.png',),),

        InkWell(onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              //CONSULTANT
              builder: (context) => SignUpScreen(userType: "CONSULTANT"),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "BecomeConsultant"),sz:20, image: 'assets/applicationIcons/how to.png',),),

        InkWell(   onTap: () {
          showLangDialog(size);
        },child:
        DrawerItem(title: getTranslated(context, "languages"),sz:20, icon: Icons.language,),),

        InkWell( onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AboutUsScreen(),
            ),
          );
        },child:
        DrawerItem(title: getTranslated(context, "aboutUs"),sz:20, icon:Icons.info_outline,),),

        InkWell(onTap: () {
          Navigator.pushNamed(context, '/Register_Type');
        },child:
        DrawerItem(title: getTranslated(context, "login"),sz:20, image:'assets/applicationIcons/system_update_alt-24px.png'),),



        SizedBox(
          height: 90,
        ),
        Center(
          child: Container(
            width: size.width * .8,
            height: 45.0,
            child: MaterialButton(
              onPressed: () async {
                inviteAFriend();
              },
              //color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share,
                    color: AppColors.pink,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                 text(getTranslated(context, "share"),)

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  changelanguage(String lang, String code) async {
    setState(() {
      changeLang=true;
    });
    print("ggg4444");
    print(lang);
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    print(_temp);
    if (FirebaseAuth.instance != null&&FirebaseAuth.instance.currentUser!=null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user.uid)
          .set({
          'userLang': lang,
          'languages':user.userType=="CONSULTANT"?user.languages:[lang],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .doc(user.supportListId)
          .set({
        'userLang': lang,
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
    }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang=false;
    });
    Navigator.pop(context);
  }
  initiateSearch(String text) async {
    setState(() {
      load = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where(
          'phoneNumber',
          isEqualTo: text,
        )
        .limit(1)
        .get();
    if (querySnapshot != null && querySnapshot.docs.length != 0) {
      var userSearch = GroceryUser.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load = false;
      });
      print("llllllllluser");
      print(user.name);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsScreen(
            user: userSearch,
            loggedUser: user,
          ),
        ),
      );
    } else {
      setState(() {
        load = false;
        wrongNumber = true;
      });
    }
  }
  showSignoutConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "logout"),
                style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                getTranslated(context, "doYouNeedToLogout"),
                style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 13.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 50.0,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection(Paths.usersPath).doc(user.uid).set({
                          'tokenId': "",
                        }, SetOptions(merge: true));
                        FirebaseAuth.instance.signOut();
                        accountBloc.add(GetLoggedUserEvent());
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/Register_Type',
                              (route) => false,
                        );
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 15.0,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
  showLangDialog(Size size) {
    print("ffffffccc");
    print(getTranslated(context, "lang"));
    GroupController controller = GroupController(initSelectedItem: [getTranslated(context, "lang")]);

    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height*.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "chooseLang"),
                textAlign:TextAlign.center,
                style: TextStyle(
                    fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 16.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15.0,
              ),
              Container(
                height: MediaQuery.of(context).size.height*.3,
                width: 200,
                child: SimpleGroupedCheckbox<String>(
                  controller: controller,
                  onItemSelected: (data) {
                    print("gggggg000");
                    print(data);
                    setState(() {
                      selectedLang=data;
                    });

                  },
                  itemsTitle: [
                    getTranslated(context, 'ar'),
                    getTranslated(context, 'en'),
                    getTranslated(context, 'fr'),
                    getTranslated(context, 'id'),],
                  values: ["ar", "en", "fr", "id"],
                  groupStyle: GroupStyle(
                      activeColor: AppColors.pink,
                      itemTitleStyle: TextStyle(fontSize: 13)),
                  checkFirstElement: false,
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              Center(
                child: SizedBox(
                  height:35,
                  width: size.width * 0.5,
                  child: MaterialButton(
                    onPressed: () {

                      if (selectedLang=='ar')
                        changelanguage("ar", "AR");
                      else if (selectedLang=='en')
                        changelanguage("en", "US");
                      else if (selectedLang=='fr')
                        changelanguage("fr", "FR");
                      else if (selectedLang=="id")
                        changelanguage("id", "ARB");
                      else
                        changelanguage("en", "US");
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    child: Text(
                      getTranslated(context,"done"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
  Future inviteAFriend() async {
    await FlutterShare.share(
        title: 'رؤيا  - Dream',
        text:
            'رؤيا  - Dream \n يمكنك تحميل تطبيق رؤيا من خلال موقعنا الرسمي You can get Dream app from our website ',
        linkUrl: 'https://dream-app.net/',
        chooserTitle: 'رؤيا  - Dream');
  }
  Widget DrawerItem({String? image, IconData? icon ,required String title, isIcon,double? sz}){
    return

      ListTile(leading: icon!=null ? Icon(icon, color: AppColors.pink, size:sz,):
    Image.asset(image!, width: sz , height: sz, color: AppColors.pink,),
      title: Stack(
        children: <Widget>[
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
             fontFamily: getTranslated(context, 'fontFamily'),
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.5
                ..color = Color.fromRGBO(32, 32 ,32,1),
            ),
          ),
          // Solid text as fill.
          Text(
            title,
            textAlign: TextAlign.start,
            style: TextStyle(
             fontFamily: getTranslated(context, 'fontFamily'),
              color: Color.fromRGBO(32, 32 ,32,1),
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ), trailing: Icon(
      Icons.arrow_forward_ios, color: Color.fromRGBO(211, 211 ,211,1), size: 17,),);
  }
}
