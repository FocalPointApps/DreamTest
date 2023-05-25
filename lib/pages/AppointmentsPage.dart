
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/userAppointmentWiget.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';

import '../config/colorsFile.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with AutomaticKeepAliveClientMixin<AppointmentsPage> {
  final TextEditingController searchController = new TextEditingController();

  late AccountBloc accountBloc;
  GroceryUser? user;
  bool fixed = true,closed=false;
  bool active = false;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body:BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          print("Account state");
          print(state);
          if (state is GetLoggedUserInProgressState) {
            return Center(child: CircularProgressIndicator());
          }
          else if (state is GetLoggedUserCompletedState) {
            user=state.user;
            return Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: user==null?SizedBox():Container(
                      height: 50,
                      width: size.width * .9,
                      padding: const EdgeInsets.all(5),

                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  fixed = true;
                                  closed=false;
                                });
                              },
                              child: Container(
                                height: 40,
                                width: size.width * .25,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: fixed
                                      ? Theme.of(context).primaryColor:AppColors.lightPink,
                                  borderRadius: BorderRadius.circular(10.0),

                                ),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, "fixed"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                      color: fixed
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            InkWell(
                              splashColor: Colors.green.withOpacity(0.6),
                              onTap: () {
                                setState(() {
                                  fixed = false;
                                  closed=true;
                                });
                              },
                              child: Container(
                                height: 40,
                                width: size.width * .25,
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: closed
                                      ? Theme.of(context).primaryColor
                                      : AppColors.lightPink,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, "closed"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                      color: closed
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ])),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                    child: Container(
                        color: AppColors.lightGrey, height: 1, width: size.width * .9)),
                SizedBox(
                  height: 30,
                ),
                fixed?Expanded(
                  child: PaginateFirestore(
                    itemBuilderType: PaginateBuilderType.listView,
                    separator:SizedBox(height: 30,),
                    padding:  EdgeInsets.only(
                        left: size.width*.10,right:size.width*.10, bottom: 16.0, top: 16.0),
                    itemBuilder: ( context, documentSnapshot,index) {
                      return UserAppointmentWiget(
                        appointment:
                        AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                        loggedUser: user!,
                      );
                    },
                    query: FirebaseFirestore.instance
                        .collection(Paths.appAppointments)
                        .where('user.uid', isEqualTo: user!.uid)
                        .where('appointmentStatus', isEqualTo: "open")
                        .orderBy('secondValue', descending: true),
                    isLive: true,
                  ),
                ):SizedBox(),
                closed?Expanded(
                  child: PaginateFirestore(

                    separator:SizedBox(height: 30,),
                    itemBuilderType: PaginateBuilderType.listView,
                    padding:  EdgeInsets.only(
                        left: size.width*.10,right:size.width*.10, bottom: 16.0, top: 16.0),
                    itemBuilder: ( context, documentSnapshot,index) {
                      return UserAppointmentWiget(
                        appointment:
                        AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                        loggedUser: user!,
                      );
                    },
                    query:  FirebaseFirestore.instance
                        .collection(Paths.appAppointments)
                        .where('user.uid', isEqualTo: user!.uid)
                        .where('appointmentStatus', isEqualTo: "closed")
                        .orderBy('secondValue', descending: true),
                    isLive: true,
                  ),
                ):SizedBox(),
              ],
            );
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  @override
  bool get wantKeepAlive => true;
}
