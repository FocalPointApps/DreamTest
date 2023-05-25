
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../config/colorsFile.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../widget/youtubePlayerWidget.dart';

class BioDetailsScreen extends StatefulWidget {
  final GroceryUser consult;
  const BioDetailsScreen({Key? key, required this.consult}) : super(key: key);

  @override
  _BioDetailsScreenState createState() => _BioDetailsScreenState();
}

class _BioDetailsScreenState extends State<BioDetailsScreen> {


  String theme="light";bool load=true;

  final List<String> _ids = [];


  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Scaffold(backgroundColor: Colors.white,
        body:  Column(children: [

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
                          getTranslated(context, "bio"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600, ),
                        ),



                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 1, width: size.width * .9)),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [

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
                          child: widget.consult.photoUrl!.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 80,height: 80,fit:BoxFit.fill,)
                              :ClipRRect(
                            borderRadius: BorderRadius.circular(100.0),
                            child: FadeInImage.assetNetwork(
                              placeholder:'assets/images/load.gif',
                              placeholderScale: 0.5,
                              imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/whiteLogo.png',width: 80,height: 80,fit:BoxFit.fill),
                              image: widget.consult.photoUrl!,
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

                    Center(
                      child: Text(
                        getTranslated(context, "lang")=="ar"?widget.consult.consultName!.nameAr!:
                        getTranslated(context, "lang")=="en"?widget.consult.consultName!.nameEn!:
                        getTranslated(context, "lang")=="fr"?widget.consult.consultName!.nameFr!:
                        widget.consult.consultName!.nameIn!,
                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'), color: AppColors.grey,
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600, ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Stack(children: [
                        Text(
                          getTranslated(context, "lang")=="ar"?widget.consult.consultBio!.bioAr!:
                          getTranslated(context, "lang")=="en"?widget.consult.consultBio!.bioEn!:
                          getTranslated(context, "lang")=="fr"?widget.consult.consultBio!.bioFr!:
                          widget.consult.consultBio!.bioIn!,
                          style: TextStyle(
                            fontSize: 13,
                           fontFamily: getTranslated(context, 'fontFamily'),
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth =0.4
                              ..color=AppColors.black.withOpacity(.8),
                          ),
                        ),
                        Text(
                          getTranslated(context, "lang")=="ar"?widget.consult.consultBio!.bioAr!:
                          getTranslated(context, "lang")=="en"?widget.consult.consultBio!.bioEn!:
                          getTranslated(context, "lang")=="fr"?widget.consult.consultBio!.bioFr!:
                          widget.consult.consultBio!.bioIn!,
                          textAlign:TextAlign.start ,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            color:AppColors.black.withOpacity(.8),
                            fontSize: 13.0,

                          ),),
                      ]),
                    ),
                    SizedBox(height: 10.0,),
                    (widget.consult.link!=null&&widget.consult.link!="")? ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),child: YouTubeVideoRow(link:widget.consult.link!)):SizedBox(),
                    (widget.consult.link!=null&&widget.consult.link!="") ?SizedBox(height: 30.0,):SizedBox(),]))),

        ],),
    );
  }
}