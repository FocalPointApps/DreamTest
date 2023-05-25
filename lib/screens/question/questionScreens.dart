
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/questions.dart';
import 'package:grocery_store/models/user.dart';
import 'package:grocery_store/screens/question/addQuestionScreen.dart';
import '../../FireStorePagnation/paginate_firestore.dart';
import '../../widget/questionListItem.dart';

class QuestionScreen extends StatefulWidget {
  final GroceryUser user;

  const QuestionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  late List<Questions> allQuestions;

  final TextEditingController searchController = new TextEditingController();
  bool load = false;
  String text = "";
  late Query filterQuery;
  late Size size;
  late String lang;
  @override
  void initState() {
    super.initState();
    initiateSearch(text);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
     lang = getTranslated(context, "lang");
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 35,
                      width: 35,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Theme.of(context).primaryColor,
                          size: 20,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                    (widget.user!=null&&widget.user.userType == "SUPPORT")?
                       IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddQuestionScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.post_add_outlined,
                              color: AppColors.pink,
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ))),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 21, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "hello"),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat",
                      fontStyle: FontStyle.normal,
                      fontSize: 30.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "howCanWeHelp"),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat",
                      fontStyle: FontStyle.normal,
                      fontSize: 30.0),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white4,
                  borderRadius: BorderRadius.circular(7.0),
                ),
                height: 40,
                width: size.width*.80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 28,
                      width: size.width * 0.5,
                      padding: EdgeInsets.only(left: 5, right: 5),
                      decoration: BoxDecoration(
                        color: AppColors.white4,
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child:  TextField(
                            onChanged: (val) => initiateSearch(val),
                            keyboardType: TextInputType.text,
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            enableInteractiveSelection: true,
                            readOnly: false,
                            style: TextStyle(
                             fontFamily: getTranslated(context, 'fontFamily'),
                              fontSize: 14.5,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(  horizontal: 5.0, vertical: 8.0),
                              prefixIcon: Container( width: 10,
                                height: 10,
                                child: Image.asset(
                                  'assets/applicationIcons/searchImage.png',
                                  color: AppColors.warmGrey,
                                ),
                              ),
                              border: InputBorder.none,
                              hintText: // "Ask a question",
                              getTranslated(context, "askQuestion"),
                              hintStyle: TextStyle(
                                  color: AppColors.warmGrey,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Montserrat",
                                  fontStyle: FontStyle.normal,
                                  fontSize: 15.0),
                            ),
                          ),
                      ),
                    ),
                    InkWell(onTap: (){
                      initiateSearch(searchController.text);
                    },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Container(
                          height: size.height * .04,
                          width: size.width * .14,
                          decoration: BoxDecoration(
                              color: AppColors.pink,
                              borderRadius: BorderRadius.circular(7)),
                          child: Center(
                            child: Text(
                              "Ask",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "fontFamily"),
                                color: AppColors.white,
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ),
          Expanded(
            child: PaginateFirestore(
              key: ValueKey(filterQuery),
              separator: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Container(
                      color: AppColors.lightGrey,
                      height: 1,
                      width: size.width * .9),
                ),
              ),
              itemBuilderType: PaginateBuilderType.listView,
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, bottom: 16.0, top: 16.0),
              //Change types accordingly
              itemBuilder: (context, documentSnapshot, index) {
                return QuestionListItem(
                    question: Questions.fromMap(documentSnapshot[index].data() as Map),
                    user: widget.user);
              },
              query: filterQuery,
              // to fetch real-time data
              isLive: true,
            ),
          )
        ],
      ),
    );
  }

  void initiateSearch(String text) {
    if (text == "")
      setState(() {
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.questionPath)
            .where('status',isEqualTo: true)
            .orderBy('order', descending: false);
      });
    else
     {
       if(lang=="ar")
       setState(() {
           filterQuery = FirebaseFirestore.instance
               .collection(Paths.questionPath)
               .where('searchIndexAr', arrayContains: text)
               .where('status',isEqualTo: true)
               .orderBy('order', descending: false);
       });
    else
      setState(() {
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.questionPath)
            .where('searchIndexEn', arrayContains: text)
            .where('status',isEqualTo: true)
            .orderBy('order', descending: false);
      });
     }
  }
}
