import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/InvoiceModel.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../config/colorsFile.dart';

class UserInvoiceItem extends StatefulWidget {
Invoice invoice;
UserInvoiceItem({required this.invoice});

  @override
  State<UserInvoiceItem> createState() => _UserInvoiceItemState();
}

class _UserInvoiceItemState extends State<UserInvoiceItem> {
String status="..";
bool load=true;
  void initState() {
    if(widget.invoice.platform == 'Stripe')
      checksStripeStatus();
      else checkStatus();
    super.initState();

  }
  checkStatus() async {
    try{
      print("payStatusqqqq");

      final uri = Uri.parse('https://api.tap.company/v2/invoices/'+widget.invoice.id!);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      var response = await http.get(
        uri,
        headers: headers,

      );
      print(response.body);
      if(response.body.contains("errors"))
        { setState(() {
          status="...";
          load=false;
        });}
      else{
        String responseBody = response.body;
        var res = json.decode(responseBody);
        print(res);
        setState(() {
          status=res['status'];
          load=false;
        });
      }

    }catch(e){
      setState(() {
        status="...";
        load=false;
      });
    }
  }

  checksStripeStatus() async {
  try{
    print("start of stripe check");

    var response = await http.post( Uri.parse(
        'https://us-central1-dream-43bb8.cloudfunctions.net/getInvoice'),
      body: {
        'id' : widget.invoice.invoiceId,
      },
    );

    print("response of status = ${response.body}");
    String responseBody = response.body;
    var res = json.decode(responseBody);
    print(res);
    setState(() {
      status=res['status'];
      print("status of stripe = $status");
      load=false;
    });
  }catch(e){

  }
}


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;


    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return  Scaffold(backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top:50,left: 20,right:20),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: (){
                          Clipboard.setData(ClipboardData(text: widget.invoice.invoice.toString()));
                          Fluttertoast.showToast(
                            msg: getTranslated(context, "textCopy"),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 5,
                            backgroundColor: Colors.green,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );

                        },
                        icon:Icon(Icons.copy,color: Theme.of(context).primaryColor,)),
                    Spacer(),
                    Row(
                      children: [
                        Text(getTranslated(context, "invoices"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon:Icon(Icons.arrow_forward_outlined,color: Theme.of(context).primaryColor,)),
                      ],
                    )
                  ],
                ),
                SizedBox(height:40),
                Stack(alignment: Alignment.center,children: [
                  Container(
                    height: 81,
                    width: 81,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey,width: 1),
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white,width: 5),
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      child: widget.invoice.user!.image!.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 40,height: 40,fit:BoxFit.fill,)
                          :ClipRRect(
                        borderRadius: BorderRadius.circular(100.0),
                        child: FadeInImage.assetNetwork(
                          placeholder:'assets/images/load.gif',
                          placeholderScale: 0.5,
                          imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 80,height: 80,fit:BoxFit.fill),
                          image: widget.invoice.user!.image!,
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
                  ),
                  Image.asset('assets/applicationIcons/dashBorder.png',width: 86,height: 86,)
                ], ),
                SizedBox(height:15),
                Text(widget.invoice.user!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600
                    )),
                SizedBox(height:50),
                Card(
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),),
                  elevation:2,
                  shadowColor: Theme.of(context).primaryColor,
                  color: Colors.white,
                  child: Container(
                    width: size.width*8,
                    //height: size.height*.39,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(getTranslated(context, "clientName"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.user!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "clientaccount"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.email!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "phoneNumber"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.user!.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "due"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text('${dateFormat.format(widget.invoice.timestamp!.toDate())}',
                                  //'${dateFormat.format(widget.invoice.due.toDate())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "expireDate"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text('${dateFormat.format(widget.invoice.expire!.toDate())}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "price"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              Text(widget.invoice.price,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),
                          SizedBox(height:20),
                          Row(
                            children: [
                              Text(getTranslated(context, "status"),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                              Spacer(),
                              //Icon(Icons.check_circle_outline,color: Colors.green,)
                              load?CircularProgressIndicator(): Text(status,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600
                                  )),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}

