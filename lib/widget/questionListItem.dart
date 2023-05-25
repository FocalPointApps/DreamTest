
import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/question/editQuestionScreen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/questions.dart';

class QuestionListItem extends StatefulWidget {
  final Questions question;
  final GroceryUser user;

  QuestionListItem({required this.question, required this.user});

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem>
    with SingleTickerProviderStateMixin {
  bool open = false;
  String lang="ar";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    height: 7,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: size.width * .75,
                    child: InkWell(
                      onTap: () {
                        (widget.user!=null&&widget.user.userType == "SUPPORT")?
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditQuestionScreen(
                                      questions: widget.question),
                                ),
                              )
                            : SizedBox();
                      },
                      child: Text(
                        lang == "ar"
                            ? widget.question.arQuestion
                            : widget.question.enQuestion,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            color: AppColors.black2,
                            fontWeight: FontWeight.w600,
                            //fontFamily: "Montserrat",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0),
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                splashColor: Colors.white.withOpacity(0.5),
                onTap: () {
                  setState(() {
                    open = !open;
                  });
                },
                child: Icon(
                  open ? Icons.remove : Icons.add,
                  color: Colors.black.withOpacity(0.5),
                  size: 20.0,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5,
          ),
          open
              ? Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: AppColors.pink,
                            width: 3,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Text(
                              lang == "ar"
                                  ? widget.question.arAnswer
                                  : widget.question.enAnswer,
                              textAlign: TextAlign.start,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: const TextStyle(
                                color: AppColors.grey5,
                                fontWeight: FontWeight.w300,
                                fontFamily: "Montserrat",
                                fontStyle: FontStyle.normal,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.question.link==null?SizedBox():Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.lightPink,
                                blurRadius: 4.0,
                                spreadRadius: 0.0,
                                offset: Offset(
                                    0.0, 1.0), // shadow direction: bottom right
                              )
                            ],
                          ),
                          child: Center(
                            child: InkWell(
                              onTap: () async {
                                var url = widget.question.link;
                                if (widget.question.link != null) {
                                  if (!url!.contains('http')) {
                                    url = 'https://$url';
                                  }
                                  await launch(url);
                                }
                              },
                              child: Icon(
                                Icons.play_circle_outline,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "watch"),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: AppColors.pink,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              getTranslated(context, "explain"),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: AppColors.pink,
                                fontSize: 10.0,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}
