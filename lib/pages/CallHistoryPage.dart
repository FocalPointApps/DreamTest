
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/historyAppointmentWidget.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import 'package:shimmer/shimmer.dart';

class CallHistoryPage extends StatefulWidget {
  @override
  _CallHistoryPageState createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage>
    with AutomaticKeepAliveClientMixin<CallHistoryPage> {

  late AccountBloc accountBloc;
  GroceryUser? user;

  DateTime selectedDate = DateTime.now();
  bool avaliable=false;
  DateTime _now = DateTime.now();
  bool filter=false;
  late String time;
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    filterQuery = FirebaseFirestore.instance.collection(Paths.appAppointments)
        .where('consult.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('appointmentStatus', isEqualTo: "closed")
        .orderBy('secondValue', descending: true);
    time="التصفية بحسب التاريخ";
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body:
      BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          print("Account state");
          print(state);
          if (state is GetLoggedUserInProgressState) {
            return Center(child: loadWidget());
          }
          else if (state is GetLoggedUserCompletedState) {
            user=state.user;
            checkAvaliable();
            return Column(
              children: <Widget>[
                SizedBox(height: size.height*.04,),
                Container(height: 35,width: size.width*.9,
                    padding: EdgeInsets.only(right: 10,left: 10),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 25,
                          width: size.width * .25,
                          decoration: BoxDecoration(
                            color: avaliable ? Colors.green : AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: Text(
                              avaliable?getTranslated(context, "available"):getTranslated(context, "notAvailable"),
                              textAlign: TextAlign.center,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Colors.white,
                                fontSize: 10.0,
                              ),
                            ),
                          ),
                        ),
                        Container(height: 30,width: size.width*.5,
                          padding: EdgeInsets.only(left: 5,right: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              shadow()
                            ],
                          ),
                          child:Center(
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  time,
                                  textAlign: TextAlign.center,
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color:Colors.grey,
                                    fontSize: 11.0,
                                  ),
                                ),
                                InkWell(
                                  splashColor:
                                  Colors.white.withOpacity(0.6),
                                  onTap: () {
                                    _selectDate(context);
                                  },
                                  child: Icon( Icons.date_range,size:20,
                                    color: AppColors.pink,),

                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),),
                SizedBox(height: size.height*.05,),
                InkWell(
                  splashColor:
                  Colors.white.withOpacity(0.6),
                  onTap: () {
                    setState(() {
                      filterQuery = FirebaseFirestore.instance.collection(Paths.appAppointments)
                          .where('consult.uid', isEqualTo: user!.uid)
                          .where('appointmentStatus', isEqualTo: "closed")
                          .orderBy('secondValue', descending: true);
                      time= getTranslated(context, "filter");
                    });
                  },
                  child: Center(
                    child: Text(
                      getTranslated(context, "allAppointment"),
                      textAlign: TextAlign.center,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color:Color.fromRGBO( 199, 198, 198,1),
                        fontSize: 15.0,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PaginateFirestore(
                    separator: SizedBox(height: 20,),
                    key: ValueKey(filterQuery),
                    itemBuilderType: PaginateBuilderType.listView,
                    padding:  EdgeInsets.only(
                        left: size.width*.1, right: size.width*.1, bottom: 16.0, top: 25.0),//Change types accordingly
                    itemBuilder: ( context, documentSnapshot,index) {
                      return  HistoryAppointmentWiget(
                        appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                        loggedUser: user!,
                      );
                    },
                    query:filterQuery,
                    isLive: true,
                  ),
                )

              ],
            );
          }
          else {
            return Center(child: loadWidget());
          }
        },
      ),


    );
  }
  BoxShadow shadow(){return
    BoxShadow(
      color: Color.fromRGBO(156 ,57 ,129, 0.18),
      blurRadius: 8.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0, 1.0), // shadow direction: bottom right
    );}
  Widget loadWidget()
  {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.black.withOpacity(0.6),
        child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width*.9,
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
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        print("_selectDate");
        print(selectedDate);
        int month=selectedDate.month;
        int day=selectedDate.day;
        print(month);
        print(day);
        filterQuery=FirebaseFirestore.instance.collection(Paths.appAppointments)
            .where('consult.uid', isEqualTo: user!.uid)
            .where('appointmentStatus', isEqualTo: "closed")
            .where('date.month', isEqualTo:month)
            .where('date.day', isEqualTo:day)
            .orderBy('secondValue', descending: true);
        time= selectedDate.toString().substring(0,10);
        filter=true;
      });
  }
  checkAvaliable() async {

    if(user!=null&&user!.userType=="CONSULTANT"&&user!.profileCompleted==true)
    {
      String dayNow=_now.weekday.toString();
      int timeNow=_now.hour;
      if(user!.workDays!.contains(dayNow))
      {
        if (int.parse(user!.workTimes![0].from! )<=timeNow&&int.parse(user!.workTimes![0].to! )>timeNow) {
          avaliable=true;

        }
      }
    }

  }
  @override
  bool get wantKeepAlive => true;
}
