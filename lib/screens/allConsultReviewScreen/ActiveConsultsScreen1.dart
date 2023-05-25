
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeReview.dart';
import 'package:grocery_store/widget/consultantListItem1.dart';
import '../../FireStorePagnation/paginate_firestore.dart';

class ActiveConsultsScreen1 extends StatefulWidget {
   final GroceryUser loggedUser;
   const ActiveConsultsScreen1({ required this.loggedUser, });
  @override
  _ActiveConsultsScreen1State createState() => _ActiveConsultsScreen1State();
}

class _ActiveConsultsScreen1State extends State<ActiveConsultsScreen1>with SingleTickerProviderStateMixin {
  late List<GroceryUser> activeList;
  late GroceryUser user;
  final TextEditingController searchController = new TextEditingController();
  bool load=false;
  late String lang,userImage,theme;
  String name ="";
  late Query filterQuery;
  @override
  void initState() {
    super.initState();

    activeList = [];

  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                  child: Container(height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: 38.0,
                                height: 35.0,
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "activeConsult"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddFakeReviewScreen(user: user),
                              ),
                            );
                          },
                          child: Icon(Icons.add_circle_outline,
                              size: 20, color: AppColors.white),
                        ),
                        SizedBox(width: 10)
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            name==""?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: (context, documentSnapshot,index) {
                  return  ConsultantListItem1(
                    consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map ),
                      loggedUser:widget.loggedUser
                  );

                },
                query: FirebaseFirestore.instance.collection('Users')
                    .where('userType', isEqualTo: 'CONSULTANT')
                    .where('accountStatus', isEqualTo: "Active")
                    .orderBy('createdDateValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            name!=""?Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: (context, documentSnapshot,index) {
                  return  ConsultantListItem1(
                    consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },

                query:filterQuery,
                isLive: true,
              ),
            ):SizedBox(),
          ],
        ),
        Positioned(
            right: 0.0,
            top: 100.0,
            left: 0,
            child:  Center(child: Container(height: 40,width: size.width*.8,child:
            Container(
              //height: 35.0,
              //width: size.width*.45,
              padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
              child: Center(
                child: TextField(
                  onChanged: (val) => initiateSearch(val),
                  keyboardType: TextInputType.text,
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  enableInteractiveSelection: true,
                  readOnly:false,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    color: Colors.black87,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                    prefixIcon: Image.asset(
                      'assets/applicationIcons/search.png',
                      width: 30,
                      height: 30,
                    ),
                    suffixIcon: InkWell(
                        child: Icon(Icons.send_rounded, size: 14), onTap: () {
                      initiateMobileSearch(searchController.text);
                    }),
                    border: InputBorder.none,
                    hintText: getTranslated(context, "search"),
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 14.5,
                      color: Theme.of(context).primaryColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            ),)
        ),
      ]),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
          .where('searchIndex', arrayContains: name)
          .orderBy('createdDateValue', descending: true);
    });
  }
  void initiateMobileSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
          .where('userType', isEqualTo: "CONSULTANT" )
          .where('accountStatus', isEqualTo: "Active" )
      // .where('searchIndex', arrayContains: name)
          .where('phoneNumber', isEqualTo: name)
          .orderBy('createdDateValue', descending: true);
    });
  }
}