

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/api/arabicPdf.dart';
import 'package:grocery_store/api/pdf_api.dart';
import 'package:grocery_store/api/pdf_paragraph_api.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/AppAppointments.dart';
import 'package:grocery_store/models/payHistory.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/screens/table.dart';
import 'package:grocery_store/widget/button_widget.dart';
import 'package:grocery_store/widget/techAppointmentWidget.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:intl/intl.dart';
import '../FireStorePagnation/paginate_firestore.dart';

import '../config/colorsFile.dart';
import 'invoice_service.dart';

class ConsultPaymentHistoryScreen extends StatefulWidget {
  final GroceryUser user;

  const ConsultPaymentHistoryScreen({Key? key, required this.user}) : super(key: key);
  @override
  _ConsultPaymentHistoryScreenState createState() => _ConsultPaymentHistoryScreenState();
}

class _ConsultPaymentHistoryScreenState extends State<ConsultPaymentHistoryScreen>with SingleTickerProviderStateMixin {
  List <PayHistory>PayHistoryList=[];
  bool load=false;
  final PdfInvoiceService service = PdfInvoiceService();

  @override
  void initState() {
    super.initState();
    getPaymentHistory();
  }
  
  getPaymentHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.payHistoryPath)
          .where('consultUid', isEqualTo:widget.user.uid )
          .orderBy("payDate", descending: true)
          .get();
      var payList = List<PayHistory>.from(
        querySnapshot.docs.map(
              (snapshot) => PayHistory.fromMap(snapshot.data() as Map),
        ),
      );
      print(payList.length);
      setState(() {
        PayHistoryList=payList;
        load=false;
      });
    } catch (e) {
      setState(() {
        load=false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    int numItems = 10;
    List<bool> selected = List<bool>.generate(numItems, (int index) => false);
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(backgroundColor: Colors.white,
      body:
        Column(
          children: <Widget>[
            Container(
                width: size.width,
                // height: 80,
                // color: Colors.white,
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
                                  'assets/applicationIcons/awesome-arrow-right.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getTranslated(context, "paymentHistory"),
                            textAlign:TextAlign.left,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                          ),



                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 2, width: size.width * .9)),
            SizedBox(height: 10,),
            Container(padding: EdgeInsets.only(top:40,bottom: 20),
                height: size.height * 0.2,
                child:Image.asset('assets/applicationIcons/walletImage.png',
                )
            ),
            SizedBox(height: 10,),
            load?CircularProgressIndicator():Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  for(int x=0;x<PayHistoryList.length;x++)
                    Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                        Text(
                          // '${new DateFormat('dd MMM yyyy, hh:mm a').format((PayHistoryList[x].payTime.toDate()))}',
                          '${new DateFormat('dd MMM yyyy').format((PayHistoryList[x].payTime.toDate()))}',
                          textAlign:TextAlign.start,
                          style: TextStyle(fontFamily: getTranslated(context,"fontFamily"),fontSize: 14.0,
                              color:AppColors.black,fontWeight: FontWeight.w400),
                        ),
                        Text(double.parse(PayHistoryList[x].balance.toString()).toStringAsFixed(1)+"\$",
                          textAlign:TextAlign.start,
                          style: TextStyle(fontFamily: getTranslated(context,"fontFamily"),fontSize: 14.0,
                              color:AppColors.black,fontWeight: FontWeight.w400),
                        ),
                        InkWell(onTap: () async {
                          final String date='${new DateFormat('dd MMM yyyy').format(PayHistoryList[x].payTime.toDate())}';
                          final pdfFile = await PdfParagraphApi.generate(widget.user,PayHistoryList[x],date,size);
                          PdfApi.openFile(pdfFile);
                        },
                          child: Icon(
                            Icons.arrow_circle_down,
                            color: Colors.black,
                            size: 25.0,
                          ),
                        ),
                      ],),
                    ),
                 
                ],),
            ),


          ],
        ),


    );
  }
}
