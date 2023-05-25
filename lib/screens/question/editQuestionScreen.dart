

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/questions.dart';


class EditQuestionScreen extends StatefulWidget {
  final Questions questions;

  const EditQuestionScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   String? arQuestion,  arAnswer, enQuestion, enAnswer, link, id,theme;
  late int order;
  late bool status;

  bool isAdding = false;

  @override
  void initState() {
    super.initState();
    isAdding = false;
    arQuestion = widget.questions.arQuestion;
    arAnswer = widget.questions.arAnswer;
    enQuestion = widget.questions.enQuestion;
    enAnswer = widget.questions.enAnswer;
    order = widget.questions.order;
    id = widget.questions.id;
    status = widget.questions.status;
    link = widget.questions.link;
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      List<String>indexListAr=[],indexListEn=[];
      for(int y=1;y<=arQuestion!.trimLeft().trimRight().length;y++)
      {
        indexListAr.add(arQuestion!.trimLeft().trimRight().substring(0,y).toLowerCase());
      }
      for(int y=1;y<=enQuestion!.trimLeft().trimRight().length;y++)
      {
        indexListEn.add(enQuestion!.trimLeft().trimRight().substring(0,y).toLowerCase());
      }
      await FirebaseFirestore.instance
          .collection(Paths.questionPath)
          .doc(id)
          .set({
        'arQuestion': arQuestion,
        'arAnswer': arAnswer,
        'enQuestion': enQuestion,
        'enAnswer': enAnswer,
        'id': id,
        'order': order,
        'status': status,
        'link': link,
        'searchIndexAr': indexListAr,
        'searchIndexEn': indexListEn,
      }, SetOptions(merge: true));

      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
    } else {
      showSnack('Please fill all the details!', context);
    }
  }

  void showSnack(String text, BuildContext context) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7.0),
      backgroundColor: Colors.red.shade500,
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
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, top: 0.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: 38.0,
                            height: 35.0,
                            child: Icon(
                              Icons.arrow_back,
                              color: theme == "light"
                                  ? Colors.white
                                  : Colors.black,
                              size: 24.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      getTranslated(context, "editQuestion"),
                      style: GoogleFonts.poppins(
                        color: theme == "light" ? Colors.white : Colors.black,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        // initialValue: getRandomString(5),
                        initialValue: arQuestion,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          arQuestion = val!;
                        },
                        maxLines: 2,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context, "arQuestion"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: arAnswer,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          arAnswer = val!;
                        },
                        maxLines: 6,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context, "arAnswer"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                         initialValue: enQuestion,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          enQuestion = val!;
                        },
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context, "enQuestion"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: enAnswer,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          enAnswer = val!;
                        },
                        maxLines:6,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context, "enAnswer"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: order.toString(),
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          order = int.parse(val!);
                        },
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 15.0),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context, "order"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: link,
                        /*validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },*/
                        onSaved: (val) {
                          link = val!;
                        },
                        maxLines: 3,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.words,
                        decoration: inputDecoration("link"),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "status"),
                              style: TextStyle(
                               fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context).primaryColor,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Switch(
                              value: status,
                              onChanged: (value) {
                                setState(() {
                                  status = value;
                                });
                              },
                              activeTrackColor: Colors.purple,
                              activeColor: Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Container(
                                height: 45.0,
                                width: double.infinity,
                                child: MaterialButton(
                                  onPressed: () {
                                    addCategory();
                                  },
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FaIcon(
                                        FontAwesomeIcons.atom,
                                        color: theme == "light"
                                            ? Colors.white
                                            : Colors.black,
                                        size: 20.0,
                                      ),
                                      SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        getTranslated(context, "save"),
                                        style: GoogleFonts.poppins(
                                          color: theme == "light"
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration inputDecoration(String value) {
    return InputDecoration(
      hintText: (value == "link"
          ? "https://www.youtuyoutubebe.com/watch?v=xxxxxxx"
          : ""),
      contentPadding: EdgeInsets.all( 15.0),
      helperStyle: GoogleFonts.poppins(
        color: Colors.black.withOpacity(0.65),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      errorStyle: GoogleFonts.poppins(
        fontSize: 13.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      hintStyle: GoogleFonts.poppins(
        color: Colors.black54,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      labelText: getTranslated(context, "bio"),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}
