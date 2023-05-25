

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/orderListItem.dart';
import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colorsFile.dart';
import '../../widget/supervisorWidgets/consultItemWidget.dart';


class AllConsultantScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllConsultantScreen({Key? key, required this.loggedUser}) : super(key: key);
  @override
  _AllConsultantScreenState createState() => _AllConsultantScreenState();
}

class _AllConsultantScreenState extends State<AllConsultantScreen>with SingleTickerProviderStateMixin {
  final TextEditingController searchController = new TextEditingController();
  bool load=false,active=true,notActive=false;
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
  }
  @override
  void didChangeDependencies() {
     filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
        .where('userType', isEqualTo: 'CONSULTANT')
        .where('accountStatus', isEqualTo: "Active")
        .where('languages', arrayContains:getTranslated(context, "lang"))
        .orderBy('order', descending: true);
    super.didChangeDependencies();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container( width: size.width,
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
                                getTranslated(context, "arrow"),
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "consultNum"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:Colors.black.withOpacity(0.6),fontWeight: FontWeight.bold ),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),
          Padding(
            padding: const EdgeInsets.only(top: 20,right: 25,left: 25,bottom: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        active=true;
                        notActive=false;
                        filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
                            .where('userType', isEqualTo: 'CONSULTANT')
                            .where('accountStatus', isEqualTo: "Active")
                            .where('languages', arrayContains:getTranslated(context, "lang"))
                            .orderBy('order', descending: true);
                      });
                    },
                    child: Container(height: 40,width: size.width*.35,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: active?Theme.of(context).primaryColor:AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),child:Center(
                        child: Text(
                          getTranslated(context, "active"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: active?Colors.white:Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),),
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        active=false;
                        notActive=true;
                        filterQuery=FirebaseFirestore.instance.collection(Paths.usersPath)
                            .where('userType', isEqualTo: 'CONSULTANT')
                            .where('accountStatus', isEqualTo: "NotActive")
                            .where('userLang', isEqualTo:getTranslated(context, "lang"))
                            .orderBy('utcTime', descending: true);
                      });
                    },
                    child: Container(height: 40,width: size.width*.35,
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: notActive?AppColors.pink:AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(10.0),
                      ),child:Center(
                        child: Text(
                          getTranslated(context, "notActive"),
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color: notActive?Colors.white:Theme.of(context).primaryColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),),
                  ),
                ]),
          ),
          Expanded(
            child: PaginateFirestore(
              key: ValueKey(filterQuery),
              separator: SizedBox(height: 30,),
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  consultItemWidget(
                  consult: GroceryUser.fromMap(documentSnapshot[index].data() as Map), loggedUser: widget.loggedUser,
                );

              },
              query:filterQuery,
              isLive: true,
            ),
          )

        ],
      ),
    );
  }

}
