
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

import '../localization/localization_methods.dart';

class ConsultReviewWidget extends StatelessWidget {
  final ConsultReview review;
  ConsultReviewWidget({required this.review});

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
              child: review.image!.isEmpty
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
                  image: review.image!,
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
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          review.name,
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
                            Icon(
                              Icons.star,
                              size: 15,
                              color: AppColors.yellow,
                            ),
                            Text(
                              review.rating.toStringAsFixed(1),
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
                        review.review!,
                        trimLines: 1,
                        textAlign: TextAlign.start,
                        colorClickableText: AppColors.grey,
                        trimMode: TrimMode.Line,
                        trimCollapsedText: 'Show more',
                        trimExpandedText: 'Show less',
                        moreStyle:TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          color: AppColors.yellow,
                          fontSize: 10.0,
                          fontWeight: FontWeight.normal,
                          letterSpacing: 0.5,
                        ),
                        lessStyle:TextStyle(
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
}
