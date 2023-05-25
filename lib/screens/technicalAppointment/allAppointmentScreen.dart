

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/addFakeAppointment.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import '../../FireStorePagnation/paginate_firestore.dart';


class AllAppointmentsScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const AllAppointmentsScreen({Key? key, required this.loggedUser,}) : super(key: key);
  @override
  _AllAppointmentsScreenState createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen>with SingleTickerProviderStateMixin {
  bool load=false,today=true,all=false,filter=false;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool  showResult=false;
  late String from,to;
  late Query filterQuery;
  @override
  void initState() {
    super.initState();
   from="From";
   to="To";

  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
print("ggggghhhdfhfdhfh");
    return Scaffold(backgroundColor: Colors.white,
      body: Column(
          children: <Widget>[
            Container(
              width: size.width,
              decoration: BoxDecoration(
                color:Theme.of(context).primaryColor,
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
                          getTranslated(context, "appointments"),
                          style: GoogleFonts.poppins(
                            color:Colors.white,
                            fontSize: 19.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddAppointmentScreen(), ),);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: 38.0,
                                height: 35.0,
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color:Colors.white,
                                  size: 24.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 1,),
            Center(
              child:  Container(height: 60,width: size.width,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1.0),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 0.0),
                        blurRadius: 15.0,
                        spreadRadius: 2.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                  child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              today=true;
                              all=false;
                              filter=false;
                              showResult=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: today?Theme.of(context).primaryColor:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "today"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: today?Colors.white:Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              all=true;
                              today=false;
                              filter=false;
                              showResult=false;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: all?Theme.of(context).primaryColor:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "all"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: all?Colors.white:Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.5),
                          onTap: () {
                            setState(() {
                              today=false;
                              all=false;
                              filter=true;
                              //showResult=true;
                            });
                          },
                          child: Container(height: 40,width: size.width*.25,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: filter?Theme.of(context).primaryColor:Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "filter"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: filter?Colors.white:Theme.of(context).primaryColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),),
                        ),
                      ])
              ),
            ),
            SizedBox(height: 10,),
            today?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                    loggedUser:widget.loggedUser
                  );
                },
                query: FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .where('date.month', isEqualTo:DateTime.now().month)
                    .where('date.day', isEqualTo:DateTime.now().day)
                    .where('date.year', isEqualTo:DateTime.now().year)
                    .orderBy('secondValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            all?Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },
                query: FirebaseFirestore.instance.collection(Paths.appAppointments)
                    .orderBy('secondValue', descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            ):SizedBox(),
            filter?Column(children: [
              SizedBox(height: 5,),
              Center(
                child: Text(
                  getTranslated(context, "filter"),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.5),
                    onTap: () {
                      _selectFromDate(context);
                    },
                    child: Container(height: 40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple, //                   <--- border color
                          width: 1.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child:Center(
                        child: Text(
                          from,
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color:Colors.grey,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 5,),
                  InkWell(
                    splashColor:
                    Colors.white.withOpacity(0.5),
                    onTap: () {
                      _selectToDate(context);
                    },
                    child: Container(height: 40,width: size.width*.4,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.purple, //                   <--- border color
                          width: 1.0,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child:Center(
                        child: Text(
                          to,
                          textAlign: TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color:Colors.grey,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                height: 40.0,

                child:MaterialButton(
                  onPressed: () {
                    setState(() {
                      filterQuery=FirebaseFirestore.instance.collection(Paths.appAppointments)
                          .where('timeValue', isGreaterThanOrEqualTo:selectedFromDate.millisecondsSinceEpoch)
                          .where('timeValue', isLessThanOrEqualTo:selectedToDate.millisecondsSinceEpoch)
                          .orderBy('timeValue', descending: true);
                    });
                    showResult=true;
                  },
                  color:Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Text(
                    getTranslated(context, "results"),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 15.0,
              ),
            ],):SizedBox(),
            showResult?Expanded(
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(documentSnapshot[index].data() as Map),
                      loggedUser:widget.loggedUser
                  );
                },

                query:filterQuery,
                isLive: true,
              ),
            ):SizedBox(),
          ],
        ),

    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }
  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to=selectedToDate.toString().substring(0,10);
      });
  }
}
