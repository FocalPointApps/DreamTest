
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_store/blocs/notification_bloc/notification_bloc.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user_notification.dart';
import 'package:grocery_store/widget/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/colorsFile.dart';
import '../models/user_notification.dart' as prefix;

class NotificationScreen extends StatefulWidget {
  final UserNotification userNotification;

  const NotificationScreen({Key? key, required this.userNotification}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>with SingleTickerProviderStateMixin {
  late NotificationBloc notificationBloc;
  bool isLoading=true;
  String lang="ar";
  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    List<prefix.Notification> notificationList =
    widget.userNotification.notifications.reversed.toList();
    return Scaffold(backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          getTranslated(context, "notification"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                        ),
                        InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            deleteUser();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.delete,
                              color: Theme.of(context).primaryColor,
                              size: 24.0,
                            ),
                          ),
                        ),


                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 20.0,
              ),
              itemBuilder: (context, index) {
                return NotificationItem(
                  size: size,
                  userNotification: widget.userNotification,
                  notificationList: notificationList,
                  index: index,
                );
              },
              separatorBuilder: (context, index) {
                return
                  Center(
                      child: Container(
                          color: AppColors.lightGrey, height: 1, width: size.width * .9));
              },
              itemCount: notificationList.length,
            ),
          ),
        ],
      ),
    );
  }
  Future<void> deleteUser() async {
    String userUid=FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('UserNotifications').doc(userUid).delete();
    notificationBloc.add(GetAllNotificationsEvent(userUid));
    Navigator.pop(context);

  }
}
