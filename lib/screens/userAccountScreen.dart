
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../localization/language_constants.dart';
class UserAccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool? firstLogged;
  const UserAccountScreen({Key? key, required this.user, this.firstLogged}) : super(key: key);
  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  late AccountBloc accountBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  late String name,userName,bio,theme,age,education,lang="";
  late ScrollController scrollController;
  var image;
  File? selectedProfileImage;
  bool profileCompleted=false,dataSave=false,first=true,deleting=false;
  late Size size;
  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.stream.listen((state) {

      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if(mounted)
          showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        if(mounted)
          showSnack(getTranslated(context, "error"), context,false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if(mounted&&dataSave){
          dataSave=false;
          accountBloc.add(GetLoggedUserEvent());
          selectedProfileImage=null;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
          // Navigator.pop(context);
          // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
        }
      }
    });
  }
  @override
  void didChangeDependencies() {

    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
        lang=getTranslated(context, "lang");
        size = MediaQuery.of(context).size;
      });
    });
    super.didChangeDependencies();
  }
  void showSnack(String text, BuildContext context,bool status ) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: status?Theme.of(context).primaryColor:Colors.red.shade500,
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
        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: Colors.white,
        ),
      ),
    )..show(context);
  }
  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }
  Future cropImage(context) async {
    image = await ImagePicker().getImage(source: ImageSource.gallery);
    File croppedFile =File(image.path);

    if (croppedFile != null) {
      print('File size: ' + croppedFile.lengthSync().toString());
      setState(() {
        selectedProfileImage = croppedFile;
      });
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped

    }
  }
  showDeleteConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: Container(
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "deleteAccount"),
                style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 16.0,
                    color: AppColors.pink,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 15.0,
              ),
              Text(
                getTranslated(context, "deleteText"),
                style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 12.0,
                    color: Colors.black87,
                    fontWeight: FontWeight.w300),
              ),
              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: 50.0,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 13.0,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  deleting?CircularProgressIndicator():Container(
                    width: 50.0,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () async {
                        setState(() {
                          deleting=true;
                        });
                       await FirebaseFirestore.instance
                            .collection(Paths.supportListPath)
                            .doc(widget.user.supportListId)
                            .delete();
                           await FirebaseFirestore.instance
                            .collection(Paths.usersPath)
                            .doc(widget.user.uid)
                            .delete();
                        FirebaseAuth.instance.signOut();
                        setState(() {
                          deleting=false;
                        });
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                              (route) => false,
                        );
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
                        style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 15.0,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
  @override
  Widget build(BuildContext context) {
    if(first)
      setState(() {
        first=false;
        size= MediaQuery.of(context).size;
        lang=getTranslated(context, "lang");

      });
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body: Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 5.0, bottom: 6.0),
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
                                width: 25,
                                height: 25,
                              ),

                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "account"),
                          textAlign:TextAlign.center,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 14.0,color:Color.fromRGBO(63 ,63 ,63,1),fontWeight: FontWeight.w300 ),
                        ),
                        InkWell(onTap: (){
                          showDeleteConfimationDialog(size);
                        },
                          child: Column(
                            children: [
                              Icon( Icons.delete_outline,color:Colors.red, size: 20.0,),
                              Text(
                                getTranslated(context, "deleteAccount"),
                                textAlign:TextAlign.center,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 10.0,color:Colors.black.withOpacity(0.7), fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))),
           Container(
                  color: Color.fromRGBO(112 ,112, 112, 0.28), height: 1, width: size.width),
          Expanded(
            child: ListView(padding: EdgeInsets.all(20),
              children:  [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 20,),
                        Center(
                          child: InkWell(
                            onTap: () {
                              cropImage(context);
                            },
                            child: Container(height: 70,width: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0.0),
                                    blurRadius: 5.0,
                                    spreadRadius: 1.0,
                                    color: Colors.black.withOpacity(0.6),
                                  ),
                                ],
                              ),
                              child: widget.user.photoUrl==null &&selectedProfileImage == null
                                  ?  Image.asset('assets/applicationIcons/whiteLogo.png', fit:BoxFit.fill,height: 70,width: 70)
                                  : selectedProfileImage != null
                                  ? ClipRRect(borderRadius:BorderRadius.circular(35.0),child: Image.file(selectedProfileImage!,fit:BoxFit.fill,height: 70,width: 70))
                                  : ClipRRect(borderRadius:
                              BorderRadius.circular(35.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:'assets/icons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder: (context, error, stackTrace) =>
                                      Icon( Icons.person,color:Colors.black, size: 50.0,),
                                  image: widget.user.photoUrl!,
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
                        ),
                        SizedBox(height: 10,),
                        Center(
                          child: Text(
                            getTranslated(context, "welcomeBack"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:Color.fromRGBO(175, 175, 175,1),fontWeight: FontWeight.w300 ),
                          ),
                        ),
                       Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Text(
                              getTranslated(context, "lang")=="ar"?widget.user.consultName!.nameAr!:
                              getTranslated(context, "lang")=="en"?widget.user.consultName!.nameEn!:
                              getTranslated(context, "lang")=="fr"?widget.user.consultName!.nameFr!:
                              widget.user.consultName!.nameIn!,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              overflow:TextOverflow.clip ,
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:AppColors.pink, ),),
                          ),
                        ),
                        SizedBox(height: 25,),

                        getTitle(getTranslated(context, "name")),
                        Padding(
                          padding: const EdgeInsets.only(top: 10,bottom: 10),
                          child: SizedBox(height: 40,
                            child: Theme(
                              data: new ThemeData(
                                primaryColor: Colors.redAccent,
                                primaryColorDark: Colors.red,

                              ),
                              child: TextFormField(
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:Colors.black.withOpacity(0.6), ),
                                  cursorColor: AppColors.pink,
                                  initialValue: widget.user.name,
                                  keyboardType: TextInputType.name,
                                  validator: (String? val) {
                                    if (val!.trim().isEmpty) {
                                      return getTranslated(context, 'required');
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    widget.user.name=val;
                                  },
                                  enableInteractiveSelection: true,
                                  decoration: inputDecoration()
                              ),
                            ),
                          ),
                        ),

                      /*  getTitle(getTranslated(context, "bio")),
                        SizedBox(height: 10,),
                        Container(height: 150,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: theme=="light"?Colors.white:Colors.grey[300],
                            borderRadius: BorderRadius.circular(35.0),
                            border: Border.all(color: Colors.grey[300],width: 1),

                          ),
                          child: Center(
                            child:Container(width: size.width*.7,
                              child: TextFormField(
                                maxLines: 7,
                                maxLength: 300,
                                style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:Colors.black.withOpacity(0.6), ),

                                cursorColor: Colors.black,
                                initialValue: widget.user.bio,
                                keyboardType: TextInputType.multiline,

                                onSaved: (val) {
                                  widget.user.bio=val;
                                },
                                decoration: new InputDecoration(
                                  counterStyle: TextStyle( color: Colors.grey,
                                    fontSize: 13,),
                                  hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: Colors.grey,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  hintText: getTranslated(context,'bio'),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,

                                  //  hintText: sLabel
                                ),
                              ),
                            ),
                          ),
                        ),*/
                        SizedBox(height: 40,),
                        Center(
                          child: InkWell(onTap: (){save();},
                            child: Container(
                              width: size.width*.6,
                              height: 40.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color.fromRGBO(209, 105 ,180,1),
                                      Color.fromRGBO(134, 57, 114,1),
                                    ],
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "saveAndContinue"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:Colors.white, ),

                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],),
          ),
        ],
      ),
    );
  }
  Widget getTitle (String title){
    return  Padding(
      padding: const EdgeInsets.only(top:5),
      child: Center(
        child: Container(height: 30,width: size.width*.40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              shadow()
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:Color.fromRGBO(156, 57, 129,1), fontWeight:FontWeight.normal ),),
          ),
        ),
      ),
    );
  }
  InputDecoration inputDecoration(){
    return InputDecoration(
        fillColor: Colors.white,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        )

    );
  }
  save() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try{
        List<String>indexList=[];
        for(int y=1;y<=widget.user.name!.trimLeft().trimRight().length;y++)
        {
          indexList.add(widget.user.name!.trimLeft().trimRight().substring(0,y).toLowerCase());
        }
        widget.user.searchIndex=indexList;
        widget.user.consultName=ConsultName(
          nameAr: widget.user.name,
          nameEn: widget.user.name,
          nameFr: widget.user.name,
          nameIn:widget.user.name,
          searchIndexAr: indexList,
          searchIndexEn:  indexList,
          searchIndexFr: indexList,
          searchIndexIn: indexList,
        );
        widget.user.profileCompleted=true;
        widget.user.userLang=getTranslated(context, 'lang');

        setState(() {
          dataSave=true;
        });
        if (selectedProfileImage != null) {
          accountBloc.add(UpdateAccountDetailsEvent(
              user: widget.user, profileImage: selectedProfileImage));
        } else {
          accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
        }

      }catch(e)
      {print("rrrrrrrrrr"+e.toString());}
    }
    else
    {print("llllll");}
  }

  BoxShadow shadow(){return
    BoxShadow(
      color: Color.fromRGBO( 0, 0 ,0, 0.16),
      blurRadius: 1.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0, 1.0), // shadow direction: bottom right
    );}
}
