

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colorsFile.dart';

class UserAppointmentsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;
  const UserAppointmentsScreen({ Key? key, required this.user, required this.loggedUser}) : super(key: key);
  @override
  _UserAppointmentsScreenState createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen>with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(backgroundColor: Colors.white,
      body:  Column(
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
                            getTranslated(context, "appointments"),
                            textAlign:TextAlign.left,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:Colors.black.withOpacity(0.6),fontWeight: FontWeight.bold ),
                          ),



                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 2, width: size.width * .9)),

            SizedBox(height: 30,),
            Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                //Change types accordingly
                separator: SizedBox(height: 30,),
                itemBuilder: ( context, documentSnapshot,index) {

                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                  loggedUser: widget.loggedUser,
                  );
                },
                query: widget.user.userType=="USER"?FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .where('user.uid', isEqualTo: widget.user.uid)
                    .orderBy('secondValue', descending: true):
                FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .where('consult.uid', isEqualTo: widget.user.uid)
                    .orderBy('secondValue', descending: true),
                isLive: true,
              ),
            )

          ],
        ),

    );
  }
}
