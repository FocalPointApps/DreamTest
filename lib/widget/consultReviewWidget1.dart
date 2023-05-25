
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:readmore/readmore.dart';

class ConsultReviewWidget1 extends StatefulWidget {
  final ConsultReview review;
  final GroceryUser? loggedUser;
  final String id ;
  ConsultReviewWidget1({required this.review, required this.id, this.loggedUser,});

  @override
  State<ConsultReviewWidget1> createState() => _ConsultReviewWidget1State();
}

class _ConsultReviewWidget1State extends State<ConsultReviewWidget1> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        color: Colors.transparent,
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                //border: Border.all(color: AppColors.pink, width: 1),
                shape: BoxShape.circle,
              ),
              child: widget.review.image!.isEmpty
                  ? Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: 30.0,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/icons/icon_person.png',
                        placeholderScale: 0.5,
                        imageErrorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person,
                          color: AppColors.grey,
                          size: 30.0,
                        ),
                        image: widget.review.image!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: 250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(milliseconds: 150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.review.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            color: AppColors.grey,
                            fontSize: 11.0,
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            (widget.loggedUser!=null&&widget.loggedUser!.userType=="SUPPORT")?InkWell(
                                    onTap: () {
                                      deleteDialog(size);
                                    },
                                    child: Icon(
                                      Icons.delete_forever_outlined,
                                      size: 18,
                                      color: AppColors.red,
                                    ),
                                  ):SizedBox(),
                            SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 15,
                              color: AppColors.yellow,
                            ),
                            Text(
                              widget.review.rating.toStringAsFixed(1),
                              textAlign: TextAlign.start,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context).primaryColor,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                      child: ReadMoreText(
                        widget.review.review!,
                        trimLines: 1,
                        textAlign: TextAlign.start,
                        colorClickableText: AppColors.grey,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        moreStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.yellow,
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.5,
                        ),
                        lessStyle: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.yellow,
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.5,
                        ),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: Theme.of(context).primaryColor,
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  deleteDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20.0),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "deleteReview"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 10, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          delete = true;
                            await FirebaseFirestore.instance
                                .collection(Paths.consultReviewsPath)
                                .doc(widget.id)
                                .delete();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "yes"),
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 100),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "no"),
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 5, right: 5, top: 5, bottom: 10),
                  child: Container(
                    width: size.width,
                    height: 0.5,
                    color: AppColors.lightGrey1,
                  ),
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }
}
