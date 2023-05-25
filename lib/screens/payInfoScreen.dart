import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../widget/processing_dialog.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
class payInfoScreen extends StatefulWidget {
  final String consultUid;


  const payInfoScreen({Key? key, required this.consultUid}) : super(key: key);
  @override
  _payInfoScreenState createState() => _payInfoScreenState();
}

class _payInfoScreenState extends State<payInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> adminMap = Map();
  var image;
  var selectedImage;
  bool isAdding=false,load=true;
  late GroceryUser consult;
  @override
  void initState() {
    super.initState();
    getConsultDetails();


  }
  Future<void> getConsultDetails() async {
    print("ggggg");
    print(widget.consultUid);

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultUid).get();
    GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);
    print(currentUser);
    print(currentUser.name);
    print(currentUser.fullName);
    print("ggggg0000");
    setState(() {
      consult=currentUser;
      load=false;
    });

  }
  Future cropImage(context) async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        selectedImage = croppedFile;
        adminMap.update(
          'profileImage',
              (value) => selectedImage,
          ifAbsent: () => selectedImage,
        );
      });
    } else {
      //not croppped

    }
  }

  addNewAdmin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding=true;
      });
      String? url=consult.personalIdUrl;
      if(selectedImage!=null)
      {
        var uuid = Uuid().v4();
        Reference storageReference = FirebaseStorage.instance.ref().child('profileImages/$uuid');
        await storageReference.putFile(selectedImage);

        url = await storageReference.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consult.uid).set({
        'fullName': consult.fullName,
        'bankName': consult.bankName,
        'bankAccountNumber': consult.bankAccountNumber,
        'fullAddress': consult.fullName,
        'personalIdUrl': url,
      }, SetOptions(merge: true));

      setState(() {
        isAdding=false;
      });
      Navigator.pop(context);
      Navigator.pop(context);
    }

  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Adding new admin..\nPlease wait!',
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
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
                              color: Colors.white,
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
                      getTranslated(context, "paymentInfo"),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          load?CircularProgressIndicator():Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Text(
                            getTranslated(context, "personalPhotoId"),
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: size.width * 0.35,
                              width: size.width * 0.85,
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0.0),
                                    blurRadius: 15.0,
                                    spreadRadius: 2.0,
                                    color: Colors.black.withOpacity(0.05),
                                  ),
                                ],
                              ),
                              child: (consult.personalIdUrl==null||consult.personalIdUrl!.isEmpty )&&
                                  selectedImage == null
                                  ? Icon(
                                Icons.account_box_outlined,
                                size: 50.0,
                              )
                                  : selectedImage != null
                                  ? ClipRRect(
                                borderRadius:
                                BorderRadius.circular(0.0),
                                child: Image.file(selectedImage),
                              )
                                  : ClipRRect(
                                borderRadius:
                                BorderRadius.circular(0.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                  'assets/images/load.gif',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      Icon(
                                        Icons.person,
                                        size: 50.0,
                                      ),
                                  image: consult.personalIdUrl!,
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
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.6),
                                    onTap: () {
                                      //TODO: take user to edit
                                      cropImage(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      width: 30.0,
                                      height: 30.0,
                                      child: Icon(
                                        (consult.personalIdUrl==null||consult.personalIdUrl!.isEmpty )
                                            ? Icons.edit
                                            : Icons.add,
                                        color: Colors.white,
                                        size: 16.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: consult.fullName,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.fullName=val!;
                        },
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
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
                          prefixIcon: Icon(Icons.person),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"fullName"),
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
                        initialValue:  consult.bankName,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.bankName=val!;

                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
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
                          prefixIcon: Icon(Icons.account_balance),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          labelText: getTranslated(context,"bankName"),
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
                        initialValue: consult.bankAccountNumber,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"accountNumber");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.bankAccountNumber=val!;
                        },
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
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
                          prefixIcon: Icon(Icons.account_balance),
                          labelText:getTranslated(context,"accountNumber"),
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
                        initialValue: consult.fullAddress,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"address");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.fullAddress=val!;
                        },
                        enableInteractiveSelection: false,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.emailAddress,
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
                          prefixIcon: Icon(Icons.location_on_outlined),
                          labelText:getTranslated(context,"address"),
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
                        height: 25.0,
                      ),
                      isAdding?Center(child: CircularProgressIndicator()):Container(
                        height: 45.0,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: MaterialButton(
                          onPressed: () {
                            //add adminMap
                            addNewAdmin();
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.person_add,
                                color: Colors.white,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                getTranslated(context, "save"),
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
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
}