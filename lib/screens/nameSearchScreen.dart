
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/screens/supervisor/supervisorConsultScreen.dart';
import 'package:grocery_store/screens/techUserDetails/userDetailsScreen.dart';
import 'package:grocery_store/screens/userAccountScreen.dart';
import 'package:grocery_store/widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/colorsFile.dart';
import 'account_screen.dart';
import 'notification_screen.dart';

class NameSearchScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const NameSearchScreen({Key? key, this.loggedUser}) : super(key: key);
  @override
  _NameSearchScreenState createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
  String theme="light";
  String name ="";
  late Query filterQuery;late Size size;
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
     size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      key:_scaffoldKey,
      body: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding( padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                      child: Row(mainAxisAlignment: MainAxisAlignment.start,
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
                                  getTranslated(context,"arrow"),
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getTranslated(context, "nameSearch"),
                            textAlign:TextAlign.left,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 2, width: size.width * .9)),
            SizedBox(height: 25,),
            Center(child: Container(height: 50,width: size.width*.9,child:
              Container(

              padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(10.0),

              ),
              child: TextField(
                onChanged: (val) => initiateSearch(val),
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly:false,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                  fontSize: 14.5,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).primaryColor,
                    size: 25.0,
                  ),
                  border: InputBorder.none,
                  hintText: getTranslated(context, "nameSearch"),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 14.5,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            ),),
            SizedBox(height: 15,),
            name==""?Expanded(
              child: Center(
                  child: SizedBox()
              ),
            ):Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  NameWidget( GroceryUser.fromMap(documentSnapshot[index].data() as Map),size );
                },
                separator:Center(
                    child: Container(
                        color: AppColors.lightGrey, height: 1, width: size.width * .9)),

                query:filterQuery,
                isLive: true,
              ),
            )


          ],
        ),
    );
  }

  void initiateSearch(String val) {
    print("hhhhh");
    print(val);
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=getTranslated(context, 'lang')=="ar"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('consultName.searchIndexAr', arrayContains: name)
          .orderBy('name', descending: true):
          getTranslated(context, 'lang')=="en"?FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('consultName.searchIndexEn', arrayContains: name)
          .orderBy('name', descending: true):
          getTranslated(context, 'lang')=="fr"?FirebaseFirestore.instance.collection(Paths.usersPath)
              .where('consultName.searchIndexFr', arrayContains: name)
              .orderBy('name', descending: true):
          FirebaseFirestore.instance.collection(Paths.usersPath)
              .where('consultName.searchIndexIn', arrayContains: name)
              .orderBy('name', descending: true);
    });
  }
  Widget NameWidget(GroceryUser user,size){
    return InkWell(onTap: (){

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultSupervisorScreen(
            consultant: user, key: null, loggedUser:widget.loggedUser! ,
          ),
        ),
      );
    },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only( left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white,width: 0),
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: user.photoUrl!.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 50,height: 50,fit:BoxFit.fill,)
                  :ClipRRect(
                borderRadius: BorderRadius.circular(100.0),
                child: FadeInImage.assetNetwork(
                  placeholder:'assets/images/load.gif',
                  placeholderScale: 0.5,
                  imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 50,height: 50,fit:BoxFit.fill),
                  image: user.photoUrl!,
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
              padding: const EdgeInsets.only(left: 5, right: 5),
              child: Text(  getTranslated(context, "lang")=="ar"?user.consultName!.nameAr!:
              getTranslated(context, "lang")=="en"?user.consultName!.nameEn!:
              getTranslated(context, "lang")=="fr"?user.consultName!.nameFr!:
              user.consultName!.nameIn!,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontWeight: FontWeight.w100,
                  fontSize: 12,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
