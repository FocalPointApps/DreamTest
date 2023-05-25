
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/reviews_screen.dart';

class ConsultantListItem1 extends StatelessWidget {
  final GroceryUser consult;
  final GroceryUser loggedUser;

  ConsultantListItem1({required this.consult, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    String lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    String languages = "";
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;
    if (consult.workDays!.contains(dayNow)) {
      if (int.parse(consult.workTimes![0].from!) <= timeNow &&
          int.parse(consult.workTimes![0].to!) >= timeNow) {
        avaliable = true;
      }
    }
    if (consult.languages!.length > 0)
      consult.languages!.forEach((element) {
        languages = languages + " " + element;
      });
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReviewScreens(
              consult: consult,
              loggedUser: loggedUser,
              reviewLength:1,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 3),
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: consult.photoUrl!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: Colors.black,
                                size: 50.0,
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder: 'assets/icons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    color: Colors.black,
                                    size: 50.0,
                                  ),
                                  image: consult.photoUrl!,
                                  fit: BoxFit.cover,
                                  fadeInDuration: Duration(milliseconds: 250),
                                  fadeInCurve: Curves.easeInOut,
                                  fadeOutDuration: Duration(milliseconds: 150),
                                  fadeOutCurve: Curves.easeInOut,
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: 5.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.0),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.5),
                              onTap: () {},
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                  shape: BoxShape.circle,
                                  color:
                                      avaliable ? AppColors.green : Colors.red,
                                ),
                                width: 10.0,
                                height: 10.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consult.name!,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.mobile_screen_share,
                            size: 15,
                            color: AppColors.white,
                          ),
                          Text(
                            consult.phoneNumber!,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.white,
                              fontSize: 15.0,
                              // fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.mic_none,
                            size: 18,
                            color: AppColors.white,
                          ),
                          Text(
                            languages,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.white,
                              fontSize: 15.0,
                              // fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
 SizedBox(height: 2,),
                            Row( mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.mic,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      getTranslated(context, "voice"),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                        color: Colors.white,
                                        fontSize: 11.0,
                                        //fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10,),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 15,
                                      color: Colors.white,
                                    ),

                                    Text(
                                      getTranslated(context, "chat"),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                        color: Colors.white,
                                        fontSize: 11.0,
                                        //fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),

                      //SizedBox(height: 2,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.star,
                                size: 13,
                                color: AppColors.yellow,
                              ),
                              Text(
                                consult.rating.toStringAsFixed(1),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: Colors.white,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/applicationIcons/greenCall.png',
                                width: 15,
                                height: 15,
                              ),
                              Text(
                                consult.ordersNumbers.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      consult.price! + "\$",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(
                            ClipboardData(text: consult.phoneNumber.toString()));
                        Fluttertoast.showToast(
                            msg: "phone is copped",
                            toastLength: Toast.LENGTH_SHORT,
                            backgroundColor: Colors.red,
                            textColor: Colors.white);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            // border: Border.all( color: Colors.red[500],),
                            color: avaliable ? AppColors.green : Colors.red,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Center(
                            child: Icon(
                          Icons.copy,
                          color: Colors.black,
                          size: 18.0,
                        )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
