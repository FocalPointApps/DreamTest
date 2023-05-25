
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/widget/consultReviewWidget1.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class ReviewScreens extends StatefulWidget {
  final GroceryUser consult;
  final GroceryUser? loggedUser;
  final int? reviewLength;
  const ReviewScreens({Key? key, required this.consult, this.reviewLength, this.loggedUser}) : super(key: key);
  @override
  _ReviewScreensState createState() => _ReviewScreensState();
}

class _ReviewScreensState extends State<ReviewScreens> {
  late List<ConsultReview>reviews;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    dynamic rating=0.0;
    String star=getTranslated(context, "stars");
    rating=(widget.consult.rating==null)?0.0:widget.consult.rating;
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(backgroundColor: Colors.white,
        body: Column(children: [
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
                          getTranslated(context, "Reviews"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:AppColors.pink, fontWeight: FontWeight.bold),
                        ),



                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),
          Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.0,
                ),
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
                          imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/GroupLogo.png',width: 80,height: 80,fit:BoxFit.fill),
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
                    widget.consult.name!,
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                widget.consult.userType=="CONSULTANT"?SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: double.parse(rating.toString()),
                  size: 20.0,
                  onRatingChanged:  (v) {
                  },
                  color: AppColors.yellow,
                  borderColor:AppColors.yellow,
                  spacing: 1.0,
                ):SizedBox(),
              ],
            ),
          ),
          widget.reviewLength!=0? Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0, top: 16.0),//Change types accordingly
              itemBuilder: ( context, documentSnapshot,index) {
                return  ConsultReviewWidget1(
                  id: documentSnapshot[index].id,
                  loggedUser: widget.loggedUser,
                  review: ConsultReview.fromMap(documentSnapshot[index].data() as Map),
                );
              },
              separator:Center(
                  child: Container(
                      color: AppColors.lightGrey, height: 1, width: size.width * .9)),
              query: widget.consult.userType=="CONSULTANT"? FirebaseFirestore.instance.collection('ConsultReview')
                  .where('consultUid', isEqualTo: widget.consult.uid)
                  .orderBy("reviewTime", descending: true):
              FirebaseFirestore.instance.collection('ConsultReview')
                  .where('uid', isEqualTo: widget.consult.uid)
                  .orderBy("reviewTime", descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ):
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 8.0),
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: <Widget>[

                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    getTranslated(context, "noReviews"),
                    style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.grey,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],),
      ),
    );
  }


}
