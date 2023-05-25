
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/invicelistitemWidget.dart';
import '../../FireStorePagnation/paginate_firestore.dart';
import '../../models/InvoiceModel.dart';
import 'addInvoiceScreen.dart';


class AllInvoicesScreen extends StatefulWidget {
   final GroceryUser loggedUser;
   const AllInvoicesScreen({required this.loggedUser});

   @override
  _AllInvoicesScreenState createState() => _AllInvoicesScreenState();
}
class _AllInvoicesScreenState extends State<AllInvoicesScreen>with SingleTickerProviderStateMixin {
  @override


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top:10),
          child: Column(
            children: <Widget>[
              Container(
                width: size.width,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                    child: Container(
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
                                    color: AppColors.pink,
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                         SizedBox()

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5,),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 80),
                  color: Colors.black45,
                  width: 60,
                  height: 1,
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 80),
                  color: Colors.black45,
                  width: 100,
                  height: 1,
                ),
              ),
              Text(getTranslated(context, "invoices"),
                style: TextStyle(
                  color: Theme
                      .of(context)
                      .primaryColor,
                 fontFamily: getTranslated(context, 'fontFamily'),
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(right: 80),
                  color: Colors.black45,
                  width: 100,
                  height: 1,
                ),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: EdgeInsets.only(right: 80),
                  color: Colors.black45,
                  width: 60,
                  height: 1,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: PaginateFirestore(separator: SizedBox(height: 10,),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding: const EdgeInsets.only(
                      left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
                  itemBuilder: ( context, documentSnapshot,index) {
                    return  InvoiceListItem(
                      invoice: Invoice.fromMap(documentSnapshot[index].data() as Map),

                    );
                  },
                  query: FirebaseFirestore.instance.collection(Paths.invoicePath)
                      .orderBy('timestamp', descending: true),
                  // to fetch real-time data
                  isLive: true,
                ),
              )
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>AddInvoiceScreen(loggedUser: widget.loggedUser,)));
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );

  }
}

