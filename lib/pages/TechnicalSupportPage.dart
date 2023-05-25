
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/account_bloc/account_bloc.dart';
import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../screens/nameSearchScreen.dart';
import '../../widget/supportListItem.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../FireStorePagnation/paginate_firestore.dart';

class TechnicalSupportPage extends StatefulWidget {
  @override
  _TechnicalSupportPageState createState() => _TechnicalSupportPageState();
}

class _TechnicalSupportPageState extends State<TechnicalSupportPage> with AutomaticKeepAliveClientMixin<TechnicalSupportPage> {
  final TextEditingController searchController = new TextEditingController();
  PaginateRefreshedChangeListener refreshChangeListener = PaginateRefreshedChangeListener();

  late AccountBloc accountBloc;
  GroceryUser? user;
  bool _new=true,_pending=false,_all=false;
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
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          print("Account state");
          print(state);
          if (state is GetLoggedUserInProgressState) {
            return Center(child: CircularProgressIndicator());
          }
          else if (state is GetLoggedUserCompletedState) {
            user=state.user;
            return   Column(
              children: <Widget>[
                SizedBox(height: 5,),
                Visibility(visible: user!.userType=="SUPPORT",child:supportWidget(size)),
                SizedBox(height: 5,),
                Visibility(visible:_new&&user!.userType=="SUPPORT",child: list(size,initiateSearch("_new"))),
                Visibility(visible:_pending&&user!.userType=="SUPPORT",child: list(size,initiateSearch("_pending"))),
                Visibility(visible:_all&&user!.userType=="SUPPORT",child: list(size,initiateSearch("_all"))),
                Visibility(visible:user!.userType!="SUPPORT",child: list(size,initiateSearch(""))),
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
  Widget list(Size size,Query _query){
    return   Expanded(
      child:PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        padding: const EdgeInsets.only(
            left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
        itemBuilder: ( context, documentSnapshot,index) {
          return  SupportListItem(
            size:size,
            item: SupportList.fromMap(documentSnapshot[index].data() as Map),
            user:user!,
          );

        },
        query: _query,
        isLive: true,
      ),
    );
  }
  supportWidget(Size size){return Padding( padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
    child: Column(crossAxisAlignment:CrossAxisAlignment.center,children: [
      Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(height: 40,width: size.width*.7,
            padding: const EdgeInsets.symmetric( horizontal: 1.0, vertical: 0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey,
                  blurRadius: 2.0,
                  spreadRadius: 0.0,
                  offset: Offset(0.0, 1.0), // shadow direction: bottom right
                )
              ],
            ),
            child: Center(
              child: TextField(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NameSearchScreen(loggedUser: user!,),
                    ),
                  );
                },
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly:false,
                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                  fontSize: 14.5,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                  prefixIcon:Icon(Icons.search, size: 14,color:AppColors.pink),
                  suffixIcon: InkWell(
                      child: Icon(Icons.send_rounded, size: 14), onTap: () {
                  }),
                  border: InputBorder.none,
                  hintText: getTranslated(context, "name"),
                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 14.5,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
          Container(height: 40,width: size.width*.15,
            decoration: new BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,),
            child: InkWell(
                child: Icon(Icons.wifi_protected_setup, size: 18,color: AppColors.pink,), onTap: () {
              closeAll();
            }),
          ),
        ],
      ),
      SizedBox(height: 10,),
      Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _new = true;
                  _pending=false;
                  _all=false;
                  initiateSearch("_new");
                });
              },
              child: Container(
                height: 30,
                width: size.width * .25,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _new
                      ? Theme.of(context).primaryColor:AppColors.lightPink,
                  borderRadius: BorderRadius.circular(15.0),

                ),
                child: Center(
                  child: Text(
                    getTranslated(context, "_new"),
                    textAlign: TextAlign.center,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: _new
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 13.0,
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
                  _new = false;
                  _pending=true;
                  _all=false;
                  initiateSearch("_pending");
                });
              },
              child: Container(
                height: 30,
                width: size.width * .25,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _pending
                      ? Theme.of(context).primaryColor
                      : AppColors.lightPink,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Center(
                  child: Text(
                    getTranslated(context, "_pending"),
                    textAlign: TextAlign.center,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: _pending
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 13.0,
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
                  _new = false;
                  _pending=false;
                  _all=true;
                  initiateSearch("_all");
                });
              },
              child: Container(
                height: 30,
                width: size.width * .25,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _all
                      ? Theme.of(context).primaryColor
                      : AppColors.lightPink,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Center(
                  child: Text(
                    getTranslated(context, "_all"),
                    textAlign: TextAlign.center,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: _all
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                      fontSize: 13.0,
                    ),
                  ),
                ),
              ),
            ),
          ])
    ],),
  );}
  closeAll() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .where('openingStatus', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(doc.id)
            .update({
          'openingStatus': false,
        });
      }
    } catch (e) {
      print("jjjjjjjkkkk" + e.toString());
    }
  }
  Query initiateSearch(String val) {
    if( user!.userType=="SUPPORT"&&val=="_new")
      return FirebaseFirestore.instance.collection('SupportList')
          .where('supportMessageNum', isGreaterThan: 0)
          .where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('supportMessageNum', descending: true);

    else if( user!.userType=="SUPPORT"&&val=="_pending")
      return FirebaseFirestore.instance.collection('SupportList')
          .where('pending', isEqualTo: true)
          .where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('messageTime', descending: true);

    else if( user!.userType=="SUPPORT"&&val=="_all")
      return FirebaseFirestore.instance.collection('SupportList')
          //.where('userLang', isEqualTo: getTranslated(context, 'lang'))
          .orderBy('messageTime', descending: true);

    else
      return  FirebaseFirestore.instance.collection('SupportList')
          .where('userUid', isEqualTo: user!.uid)
          .orderBy('messageTime', descending: true);


  }

  @override
  bool get wantKeepAlive => true;
}
