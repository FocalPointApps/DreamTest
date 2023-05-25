

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/colorsFile.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../screens/supervisor/supervisorConsultScreen.dart';
import '../component/textWidget.dart';

class consultItemWidget extends StatelessWidget {
  final GroceryUser consult;
  final GroceryUser loggedUser;
  consultItemWidget({required this.consult, required this.loggedUser});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString(), languages = "";
    int timeNow = _now.hour;

    if (consult.fromUtc!=null&&consult.toUtc!=null&&consult.workDays!=null&&consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    return    InkWell(
      onTap: () {
        print("llllllll");
        Clipboard.setData(
            ClipboardData(text: consult.phoneNumber!));
        Fluttertoast.showToast(
            msg: "phone number coped ",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.green,
            textColor: Colors.white);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color.fromRGBO(250, 250 ,250,1),
          borderRadius: BorderRadius.circular(31.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1,left: 2,right: 2),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: consult.photoUrl!.isEmpty
                        ? Icon(
                      Icons.person,
                      color: Colors.grey[400],
                      size: 25.0,
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/images/load.gif',
                        placeholderScale: 0.5,
                        imageErrorBuilder:
                            (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 25.0,
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
                    left: 1,
                    top: 5.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 1.0,
                        ),
                        color: avaliable ? AppColors.green : Colors.red,
                      ),
                      width: 10.0,
                      height: 10.0,
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
                  TextWidget(text: getTranslated(context, "lang")=="ar"?consult.consultName!.nameAr!:
                  getTranslated(context, "lang")=="en"?consult.consultName!.nameEn!:
                  getTranslated(context, "lang")=="fr"?consult.consultName!.nameFr!:
                  consult.consultName!.nameIn!,color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w600,size: 15,
                    align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextWidget(text:consult.phoneNumber!,color: Color.fromRGBO( 147, 147 ,147,1),weight: FontWeight.normal,size: 10,
                        align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                      SizedBox(width: 5,),
                      Image.asset(
                        'assets/applicationIcons/copy@3x.png',width: 10,height: 12,
                      ),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:  consult.ordersNumbers.toString(),color: Color.fromRGBO( 32, 32 ,32,1),
                            weight: FontWeight.w600,size: 10,
                            align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                          SizedBox(width: 3,),
                          Image.asset(
                            'assets/applicationIcons/greenCall2.png',
                            width: 8,
                            height: 8,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(text:consult.rating.toStringAsFixed(1),color: Color.fromRGBO( 32, 32 ,32,1),
                            weight: FontWeight.w600,size: 10,
                            align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                          SizedBox(width: 3,),
                          Image.asset(
                            'assets/applicationIcons/Polygon 24.png',width: 8,height: 8,
                          ),
                        ],
                      ),


                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                TextWidget(text:consult.userType=="CONSULTANT"? consult.price! + "\$":
                double.parse(consult.balance.toString()).toStringAsFixed(2) + "\$",
                  color: Color.fromRGBO( 123 ,108, 150,1),
                  weight: FontWeight.w600,size: 13,
                  align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                SizedBox(height: 20,),
                /* TextWidget(text:  consult.consultType == null ? "..." : consult.consultType,
                    color: Color.fromRGBO( 32 ,32, 32,1),
                    weight: FontWeight.normal,size: 11,
                    align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),*/

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConsultSupervisorScreen(
                          consultant: consult, key: null, loggedUser:loggedUser ,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(17.0),
                    ),child: Image.asset(
                         getTranslated(context, "arrow3"),width: 24,height: 24,
                        ),),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
