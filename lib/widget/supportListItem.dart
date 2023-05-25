
import 'package:another_flushbar/flushbar.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/SupportList.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/screens/supportMessagesScreen.dart';
import 'package:intl/intl.dart';

import '../config/colorsFile.dart';

class SupportListItem extends StatelessWidget {
  final Size size;
  final SupportList item;
  final GroceryUser user;
  const SupportListItem({
    required this.size,
    required this.item,
    required this.user,
    //@required this.index,
    //@required this.notificationList,
  });
  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 300),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: 2000),
      icon: Icon(
        Icons.error,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yy');

    return GestureDetector(
      onTap: () {
        (item.openingStatus! && user.userType == "SUPPORT")
            ? showSnack(getTranslated(context, "otherSupport"), context)
            : Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupportMessageScreen(
              item: item,
              user: user,
            ),
          ),
        );
      },
      child:  Container(
        width: size.width,
        padding: const EdgeInsets.only(
            left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.pink),
                  child: Center(
                    child: Image.asset(
                      'assets/applicationIcons/Group171.png',
                      width: 25,
                      height: 25,
                    ),
                  ),
                ),
                Container(width:size.width*.5,
                    padding: const EdgeInsets.only(left: 5, right: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(
                          user.userType! == "SUPPORT"
                              ? item.userName == null
                              ? item.owner=="USER"?"Client":"CONSULTANT"
                              : item.userName!
                              : '${getTranslated(context, "supportTeam")}',
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15,
                            color: AppColors.black,
                            //fontWeight: FontWeight.bold,
                            //letterSpacing: 0.3,
                          ),
                        ),
                       item.lastMessage == null
                          ? SizedBox()
                          : (item.lastMessage != "imageFile" &&
                          item.lastMessage != "voiceFile")
                          ? Text(
                        item.lastMessage!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 11.0,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      )
                          : Row(
                        children: [
                          Icon(
                            Icons.file_copy_outlined,
                            size: 15,
                            color: Colors.white.withOpacity(0.6),
                          ),
                          Text(
                            getTranslated(
                                context, "attatchment"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              fontSize: 13.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                  Container(
                    height: 23,
                    width: 23,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(255, 255, 255,1),
                          Color.fromRGBO(236, 236 ,236,1),
                        ], ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO( 0 ,0, 0, 0.12),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              0.0, 1.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Center(
                        child: Image.asset(
                          'assets/applicationIcons/Group 805.png',
                          width: 10,
                          height: 10,
                        ),
                    ),
                  ),
                  ((user.userType == "SUPPORT" && item.supportMessageNum > 0)||(user.userType != "SUPPORT" && item.userMessageNum > 0))
                      ? Positioned(
                    left: 0.0,
                    top: 0.0,
                    child: Container(
                      height: 5,
                      width: 5,
                      alignment:
                      Alignment.center,
                      decoration:
                      BoxDecoration(
                        shape:
                        BoxShape.circle,
                        color: Colors.amber,
                      ),
                    ),
                  )
                      : SizedBox()
                ],

                ),
                Text(
                  // date,
                  item.messageTime != null
                      ? '${dateFormat.format(item.messageTime!.toDate())}'
                      : '..',
                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 10.0,
                    color: Color.fromRGBO(199 ,198 ,198,1),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
