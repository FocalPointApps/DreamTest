

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/order.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/models/userPaymentHistory.dart';
import 'package:grocery_store/widget/orderListItem.dart';
import 'package:grocery_store/widget/userPaymentHistoryListItem.dart';
import 'package:http/http.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../config/colorsFile.dart';

class WalletScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const WalletScreen({Key? key, required this.loggedUser}) : super(key: key);
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late GroceryUser user;
  bool load=false,showBalance=true,showHistory=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false,showPayView=false;
  late GroceryUser searchUser;
  List<GroceryUser> users = [];
  late String to,amount,balance;
  int? _stackIndex = 1;
  String initialUrl = '';
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    accountBloc.stream.listen((state) {
      print(state);
      if (state is GetLoggedUserCompletedState) {
        user = state.user;
        if(mounted)
          setState(() {
            load=false;
          });
        if(user!=null&&user.photoUrl!=null&&user.photoUrl!="")
          if(mounted)
            setState(() {
              balance=user.balance.toString();
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(backgroundColor: Colors.white,
      body: Stack(children: <Widget>[
        Column(
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
                                  getTranslated(context, "arrow"),
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            getTranslated(context, "wallet"),
                            textAlign:TextAlign.left,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                          ),



                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 2, width: size.width * .9)),
            Container(padding: EdgeInsets.only(top:40,bottom: 20),
                height: size.height * 0.2,
                child:Image.asset('assets/applicationIcons/walletImage.png',
                )
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                getTranslated(context, "addBalanceText"),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 6,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:AppColors.grey),

              ),
            ),
            SizedBox(height: 20,),
            Center(
              child:  Container(height: 45,width: size.width*.9,
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 5,bottom: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGrey,
                        blurRadius: 2.0,
                        spreadRadius: 0.0,
                        offset: Offset(
                            0.0, 1.0), // shadow direction: bottom right
                      )
                    ],
                  ),
                  child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.6),
                          onTap: () {
                            setState(() {
                              showBalance=true;
                              showHistory=false;
                            });
                          },
                          child: Container(height: 30,width: size.width*.3,
                            decoration: BoxDecoration(
                              color: showBalance?Theme.of(context).primaryColor:Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "addBalance"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: showBalance?Colors.white:Theme.of(context).primaryColor,
                                  fontSize: 12.0,),

                              ),
                            ),),
                        ),
                        SizedBox(width: 5,),
                        InkWell(
                          splashColor: Colors.green.withOpacity(0.6),
                          onTap: () {
                            setState(() {
                              showHistory=true;
                              showBalance=false;
                            });
                          },
                          child: Container(height: 30,width: size.width*.3,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: showHistory?Theme.of(context).primaryColor:Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                            ),child:Center(
                              child: Text(
                                getTranslated(context, "paymentHistory"),
                                textAlign: TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: showHistory?Colors.white:Theme.of(context).primaryColor,
                                  fontSize: 12.0,),

                              ),
                            ),),
                        ),


                      ])
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            showBalance? Expanded(
              child: ListView(padding:const EdgeInsets.only(left: 10,right: 10),
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 25.0,
                            ),
                            SizedBox(height: 40,
                                child:  Center(
                                  child: TextFormField(
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 12.0,color:AppColors.grey, ),
                                        textAlign: TextAlign.center,
                                        cursorColor: AppColors.pink,
                                        keyboardType: TextInputType.phone,
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          to=val!;
                                        },
                                        enableInteractiveSelection: true,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.call,color: AppColors.pink,size: 17,),
                                            hintText: "+966XXXXXXXXX",
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppColors.grey,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppColors.lightGrey,
                                                width: 1.0,
                                              ),
                                            )

                                        )
                                    ),
                                ),
                              ),

                            SizedBox(
                              height: 15.0,
                            ),
                            SizedBox(height: 40,
                                child:  Center(
                                    child: TextFormField(
                                      textAlignVertical: TextAlignVertical.center,
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 12.0,color:AppColors.grey, ),
                                        textAlign: TextAlign.center,
                                        cursorColor: AppColors.pink,
                                        keyboardType: TextInputType.number,
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        onSaved: (val) {
                                          amount=val!;
                                        },
                                        enableInteractiveSelection: true,
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.attach_money,color: AppColors.pink,size: 20,),
                                            hintText: getTranslated(context, "amount"),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppColors.grey,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10.0),
                                              borderSide: BorderSide(
                                                color: AppColors.lightGrey,
                                                width: 1.0,
                                              ),
                                            )

                                        )
                                    ),
                                  ),
                              ),

                            SizedBox(
                              height: 40,
                            ),
                            saving?Center(child: CircularProgressIndicator()):Center(
                              child: InkWell(onTap: (){
                                save();},
                                child: Container(
                                  width: size.width*.6,
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.linear1,
                                          AppColors.linear2,
                                          AppColors.linear2,
                                        ],
                                      )
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.monetization_on_outlined,
                                          color:Colors.white,
                                          size: 20.0,
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text(
                                          getTranslated(context, "addBalance"),
                                          style: TextStyle(fontFamily: 'Ithra' ,color:Colors.white,
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w600, ),

                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ):SizedBox(),
            showHistory? Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),
                //Change types accordingly
                itemBuilder: ( context, documentSnapshot,index) {
                  return  UserPaymentHistoryListItem(
                      history: UserPaymentHistory.fromMap(documentSnapshot[index].data() as Map),
                     );
                },
                query: FirebaseFirestore.instance.collection(Paths.userPaymentHistory)
                    .where('userUid', isEqualTo: widget.loggedUser.uid)
                    .orderBy('payDateValue', descending: true),
                isLive: true,
              ),
            ):SizedBox(),

          ],
        ),

        showPayView ? Positioned(
          child: Scaffold(backgroundColor: Colors.white,
            body:IndexedStack(
              index: _stackIndex,
              children: <Widget>[
                WebView(
                  initialUrl:initialUrl,
                  navigationDelegate: (NavigationRequest request) {
                    if(request.url.startsWith("https://www.jeras.io/app/redirect_url")){
                      print('onPageSuccess');
                      setState(() {
                        _stackIndex = 1;
                        showPayView = false;
                        var str=request.url;
                        const start = "tap_id=";
                        final startIndex = str.indexOf(start);
                        print(str.substring(startIndex + start.length, str.length));
                        String charge=str.substring(startIndex + start.length, str.length);
                        print("chargeeee11111111  "+charge);
                        payStatus(charge);
                      });
                      return NavigationDecision.prevent;
                    }
                    return NavigationDecision.navigate;
                  },
                  onPageStarted: (url) => print("OnPagestarted " + url),
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (url) {
                    print("onPageFinished " + url);
                    setState(() => _stackIndex = 0);} ,
                ),
                Center(child: Text('Loading  ...')),
                Center(child: Text('order ...'))
              ],
            ),
          ),
        ) : Container()
      ]),
    );
  }

  save() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try{
        setState(() {
          saving=true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: to, )
            .where( 'userType', isEqualTo: "USER", ).get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if(users.length>0)
        {
          setState(() {
            searchUser=users[0];
          });
          pay();
        }
        else
        {
          addingDialog(MediaQuery.of(context).size,getTranslated(context, "noUser"),false);
          setState(() {
            saving=false;
          });
        }

      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }

  }
  addingDialog(Size size,String data,bool status) {

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(
              height: 5.0,
            ),
            Text(
              data,
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: Colors.black87,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }
  pay() async {
    final uri = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_Opnge3LNhdkXJaCbMwmoy9BS",
      'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'

    };
    Map<String, dynamic> body ={
      "amount": amount,
      "currency": "USD",
      "threeDSecure": true,
      "save_card": true,
      "description": "Test Description",
      "statement_descriptor": "Sample",
      "metadata": {
        "udf1": "test 1",
        "udf2": "test 2"
      },
      "reference": {
        "transaction": "txn_0001",
        "order": "ord_0001"
      },
      "receipt": {
        "email": false,
        "sms": true
      },
      "customer": {
        "id": widget.loggedUser.customerId!=null? widget.loggedUser.customerId:'',
        "first_name":  widget.loggedUser.name,
        "middle_name": ".",
        "last_name": ".",
        "email":  widget.loggedUser.name!+"@dream.com",
        "phone": {"country_code": "",
          "number":  widget.loggedUser.phoneNumber
        }
      },
      "merchant": {
        "id": ""
      },
      "source": {
        "id": "src_all"
      },
      "post": {
        "url": "http://your_website.com/post_url"
      },
      "redirect": {
        "url": "https://www.jeras.io/app/redirect_url"
      }
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    var response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    String responseBody = response.body;
    print("start5");
    print(responseBody);
    var res = json.decode(responseBody);
    print(res['transaction']);
    print("start6");
    String url = res['transaction']['url'];
    setState(() {
      initialUrl=url;
      print("yarab applepay");
      print(initialUrl);
      showPayView = true;
    });


  }
  payStatus(String chargeId) async {
    final uri = Uri.parse('https://api.tap.company/v2/charges/'+chargeId);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_Opnge3LNhdkXJaCbMwmoy9BS",
      'Authorization':"Bearer sk_live_UN9kc65zvtmrX1PjnagRYhLb",
      'Connection':'keep-alive',
      'Accept-Encoding':'gzip, deflate, br'
    };
    print("startchargeId1");
    var response = await get(
      uri,
      headers: headers,

    );
    print(response.body);
    String responseBody = response.body;
    var res = json.decode(responseBody);

    String customerId=res['customer']['id'];
    customerId= customerId!=null?customerId:"";
    if(res['status']=="CAPTURED")
    {
      //update userBalance
      dynamic balance=double.parse(amount.toString());
      if(searchUser.balance!=null)
      { balance=searchUser.balance+balance;
      searchUser.balance=balance;
      }
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser.uid).set({
        'customerId': customerId,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.userPaymentHistory).doc(Uuid().v4()).set({
        'userUid': widget.loggedUser.uid,
        'payType': "send",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue':DateTime.now().millisecondsSinceEpoch,
        'amount':amount,
        'otherData': {
          'uid': searchUser.uid,
          'name': searchUser.name,
          'image': searchUser.photoUrl,
          'phone': searchUser.phoneNumber,
        },
      });

      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(searchUser.uid).set({
        'balance': balance,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.userPaymentHistory).doc(Uuid().v4()).set({
        'userUid': searchUser.uid,
        'payType': "receive",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue':Timestamp.now().millisecondsSinceEpoch,
        'amount':amount,
        'otherData': {
          'uid': widget.loggedUser.uid,
          'name': widget.loggedUser.name,
          'image': widget.loggedUser.photoUrl,
          'phone': widget.loggedUser.phoneNumber,
        },
      });
      if(widget.loggedUser.phoneNumber==to)
        accountBloc.add(GetLoggedUserEvent());
      setState(() {
        showPayView=false;
        saving=false;
      });
      print("llllll");
      addingDialog(MediaQuery.of(context).size,getTranslated(context, "addBalanceDoneSuccessfully"),true);

    }
    else
    {
      setState(() {
        showPayView=false;
        saving=false;
      });
      showSnakbar(getTranslated(context, "failed"),true);

    }
  }
  InputDecoration inputDecoration(Icon icon){
    return InputDecoration(
        prefixIcon: Icon(Icons.call,color: AppColors.pink,size: 15,),
        hintText: getTranslated(context,'title'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: AppColors.lightGrey,
            width: 1.0,
          ),
        )

    );
  }
  void showSnakbar(String s,bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: status?Colors.lightGreen:Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);

  }
}
