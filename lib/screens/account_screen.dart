import 'dart:io';

import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_store/blocs/account_bloc/account_bloc.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:sugar/sugar.dart' as sugar;
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/user.dart';
import 'package:flutter/material.dart';
import 'package:grocery_store/widget/processing_dialog.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../config/colorsFile.dart';
import '../config/paths.dart';
import '../widget/component/TextFormFieldWidget.dart';
class AccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool? firstLogged;

  const AccountScreen({Key? key, required this.user, this.firstLogged}) : super(key: key);
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late AccountBloc accountBloc;
  bool profileCompleted=false,dataSave=false,showCheck=false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameArController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();
  TextEditingController nameFrController = TextEditingController();
  TextEditingController nameInController = TextEditingController();

  TextEditingController bioArController = TextEditingController();
  TextEditingController bioEnController = TextEditingController();
  TextEditingController bioFrController = TextEditingController();
  TextEditingController bioInController = TextEditingController();
  
  TextEditingController voicePriceController = TextEditingController();
  TextEditingController chatPriceController = TextEditingController();

  TimeOfDay selectedTime = TimeOfDay.now();
  late String userName,price,chatPrice,bio2,workDays="",lang="",type="",from,to,fromtime,totime,theme="light",location;
  late TextEditingController daysController ,langController,typeController,fromController,toController,fromtimeController,totimeController;
  bool monday=false,tuesday=false,wednesday=false,thursday=false,friday=false,saturday=false,sunday=false,first=true ;
  late ScrollController scrollController;
  late List<WorkTimes> workTimes;
  List<dynamic>daysValue=[];
  bool arabic=false,english=false,french=false,indonesian=false;
  bool allowVoice=false,allowChat=false,deleting=false,saving=false;
  WorkTimes _workTime=new WorkTimes();
  var image;
  File? selectedProfileImage;
  late Size size;
  @override
  void initState() {
    super.initState();
    userName=widget.user.name!;
    price=widget.user.price!;
    chatPrice=widget.user.chatPrice!;
    daysController= TextEditingController();
    typeController= TextEditingController();
    fromController= TextEditingController();
    toController= TextEditingController();
    fromtimeController= TextEditingController();
    totimeController= TextEditingController();
    nameArController.text=widget.user.consultName!.nameAr!;
    nameEnController.text=widget.user.consultName!.nameEn!;
    nameFrController.text=widget.user.consultName!.nameFr!;
    nameInController.text=widget.user.consultName!.nameIn!;

    bioArController.text=widget.user.consultBio!.bioAr!;
    bioEnController.text=widget.user.consultBio!.bioEn!;
    bioFrController.text=widget.user.consultBio!.bioFr!;
    bioInController.text=widget.user.consultBio!.bioIn!;
    
    chatPriceController.text=widget.user.chatPrice!;
    voicePriceController.text=widget.user.price!;

    if(widget.user.voice!){
      type=type+"Voice";
      allowVoice=true;
      typeController= TextEditingController(text:type);
    }
    if(widget.user.chat!) {
      type=type+"  Chat";
      allowChat=true;
      typeController= TextEditingController(text:type);
    }
    //update worktime
    if(widget.user.workTimes!.length>0) {

      _workTime = widget.user.workTimes![0];
      if(_workTime.from!=null){
        from=_workTime.from!;
        int fromvalue=int.parse(_workTime.from!);
        if(fromvalue==12)
          fromController.text="12 PM";
        else if(fromvalue==0)
          fromController.text="12 AM";
        else if(fromvalue>12)
          fromController.text=(fromvalue-12).toString()+" PM";
        else
          fromController.text=fromvalue.toString()+" AM";
      }
      if(_workTime.to!=null) {
        to=_workTime.to!;
        int toValue=int.parse(_workTime.to!);
        if(toValue==12)
          toController.text="12 PM";
        else if(toValue==0)
          toController.text="12 AM";
        else if(toValue>12)
          toController.text=(toValue-12).toString()+" PM";
        else
          toController.text=toValue.toString()+" AM";
      }
      if(_workTime.fromtime!=null) {
        fromtime=_workTime.fromtime!;
        int toValue=int.parse(_workTime.fromtime!);

        if(toValue==12)
          fromtimeController.text="12 PM";
        else if(toValue==0)
          fromtimeController.text="12 AM";
        else if(toValue>12)
          fromtimeController.text=(toValue-12).toString()+" PM";
        else
          fromtimeController.text=toValue.toString()+" AM";
      }
      if(_workTime.totime!=null) {
        totime=_workTime.totime!;
        int toValue=int.parse(_workTime.totime!);

        if(toValue==12)
          totimeController.text="12 PM";
        else if(toValue==0)
          totimeController.text="12 AM";
        else if(toValue>12)
          totimeController.text=(toValue-12).toString()+" PM";
        else
          totimeController.text=toValue.toString()+" AM";
      }
    }


    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.stream.listen((state) {
      print(state);
      if (state is GetLoggedUserCompletedState) {
        if(mounted&&dataSave)
        {
          dataSave=false;
         
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
                (route) => false,
          );
        }

      }
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if(mounted)
          showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        showSnack(getTranslated(context, "error"), context,false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if(mounted){
          accountBloc.add(GetLoggedUserEvent());
          selectedProfileImage=null;
          //Navigator.pop(context);
          // accountBloc.add(GetLoggedUserEvent(widget.user.uid));
        }

      }
    });
  }
  @override
  void didChangeDependencies() {

    //update lang
    if(widget.user.languages!.length>0){
      if(widget.user.languages!.contains("ar")) {arabic=true;
      lang=lang+"  "+getTranslated(context, 'ar');
      }
      if(widget.user.languages!.contains("en")) {english=true;
      lang=lang+" "+getTranslated(context, 'en');
      }
      if(widget.user.languages!.contains("fr")) {french=true;
      lang=lang+" "+getTranslated(context, 'fr');
      }
      if(widget.user.languages!.contains("id")) {indonesian=true;
      lang=lang+" "+getTranslated(context, 'id');
      }

    }
    langController= TextEditingController(text:lang);

    if(widget.user.workDays!.length>0) {
      if(widget.user.workDays!.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
        monday=true;
      }
      if(widget.user.workDays!.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
        tuesday=true;
      }
      if(widget.user.workDays!.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
        wednesday=true;
      }
      if(widget.user.workDays!.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
        thursday=true;
      }
      if(widget.user.workDays!.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
        friday=true;
      }
      if(widget.user.workDays!.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
        saturday=true;
      }
      if(widget.user.workDays!.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
        sunday=true;
      }
      setState(() {
        daysController.text=workDays;
      });
    }

    super.didChangeDependencies();
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
                          '/RegisterTypeScreen',
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
  void showSnack(String text, BuildContext context,bool status ) {
    Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(10),
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
    int compressQuality;
    /*if(File(image.path).readAsBytesSync().lengthInBytes <= 204800){
      compressQuality=100;
    }else{
      compressQuality=(20480000/File(image.path).readAsBytesSync().lengthInBytes).round();
    }*/
    File croppedFile = File(image.path);

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
  @override
  Widget build(BuildContext context) {

    size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      key: _scaffoldKey,
      body:Column(crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
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
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "account"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
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
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),
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
                        SizedBox(height: 10,),
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
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: AppColors.grey,
                              fontSize: 13.0,
                              fontWeight: FontWeight.normal,
                            ),),
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
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: Theme.of(context).primaryColor,
                                fontSize: 20.0,
                              ),),
                          ),
                        ),
                        SizedBox(height: 25,),

                        TextFormFieldWidget(name: getTranslated(context, "nameAr"),controller: nameArController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameEn"),controller: nameEnController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameFr"),controller: nameFrController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameIn"),controller: nameInController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "voicePrice"),controller: voicePriceController,obscureText:false,isNumber: true,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "chatPrice"),controller: chatPriceController,obscureText:false,isNumber: true,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioAr"),controller: bioArController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioEn"),controller: bioEnController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioFr"),controller: bioFrController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioIn"),controller: bioInController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        tabbedText("lang", getTranslated(context, "languages"), langController),
                        SizedBox(height: 40),
                        tabbedText("account", getTranslated(context, "accountType"), typeController),
                        SizedBox(height: 20,),

                        tabbedText("time", getTranslated(context, "timeOfWork"), daysController),
                        //////
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Text(
                              'الفترة الاولي',
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: AppColors.grey,
                                fontSize: 20.0,
                              ),),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                            Container(width:size.width*.3,
                              child: Column(children: [
                                Text(
                                  getTranslated(context, "from"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:AppColors.grey, ),
                                ),
                                Container(height: 45,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(35.0),
                                    border: Border.all(color: Colors.grey,width: 1),
                                  ),
                                  child: Center(
                                    child: Container(width: size.width*.2,
                                      child: TextFormField(
                                        onTap: () {
                                          _selectTimeFrom(context);
                                        },
                                        readOnly: true,
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 15,
                                        ),
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        /*onSaved: (val) {
                                             from=val!;
                                            },*/
                                        cursorColor: Colors.black,
                                        controller: fromController,
                                        keyboardType: TextInputType.name,
                                        decoration: new InputDecoration(
                                          hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          hintText: getTranslated(context,'from'),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],),
                            ),
                            Container(width:size.width*.3,
                              child: Column(children: [
                                Text(
                                  getTranslated(context, "to"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: AppColors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                                Container(height: 45,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(35.0),
                                    border: Border.all(color: Colors.grey,width: 1),
                                  ),
                                  child: Center(
                                    child:   Container(width: size.width*.2,
                                      child: TextFormField(
                                        onTap: () {
                                          _selectTimeTo(context);
                                        },
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        /* onSaved: (val) {
                                              to=val!;
                                            },*/
                                        readOnly: true,
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 15,
                                        ),

                                        cursorColor: Colors.black,
                                        controller: toController,
                                        keyboardType: TextInputType.name,
                                        decoration: new InputDecoration(
                                          hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          hintText: getTranslated(context,'to'),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],),
                            ),

                          ],),
                        ),
                        ////
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20,right: 20),
                            child: Text(
                              'الفترة الثانية',
                              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                color: AppColors.grey,
                                fontSize: 20.0,
                              ),),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                            Container(width:size.width*.3,
                              child: Column(children: [
                                Text(
                                  getTranslated(context, "from"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 15.0,color:AppColors.grey, ),
                                ),
                                Container(height: 45,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(35.0),
                                    border: Border.all(color: Colors.grey,width: 1),
                                  ),
                                  child: Center(
                                    child: Container(width: size.width*.2,
                                      child: TextFormField(
                                        onTap: () {
                                          _selectTimeFromtime(context);
                                        },
                                        readOnly: true,
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 15,
                                        ),
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        /*onSaved: (val) {
                                             from=val!;
                                            },*/
                                        cursorColor: Colors.black,
                                        controller: fromtimeController,
                                        keyboardType: TextInputType.name,
                                        decoration: new InputDecoration(
                                          hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          hintText: getTranslated(context,'from'),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],),
                            ),
                            Container(width:size.width*.3,
                              child: Column(children: [
                                Text(
                                  getTranslated(context, "to"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: AppColors.grey,
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),),
                                Container(height: 45,
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(35.0),
                                    border: Border.all(color: Colors.grey,width: 1),
                                  ),
                                  child: Center(
                                    child:   Container(width: size.width*.2,
                                      child: TextFormField(
                                        onTap: () {
                                          _selectTimeTotime(context);
                                        },
                                        validator: (String? val) {
                                          if (val!.trim().isEmpty) {
                                            return getTranslated(context, 'required');
                                          }
                                          return null;
                                        },
                                        /* onSaved: (val) {
                                              to=val!;
                                            },*/
                                        readOnly: true,
                                        style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                          color: Colors.black.withOpacity(0.6),
                                          fontSize: 15,
                                        ),

                                        cursorColor: Colors.black,
                                        controller: totimeController,
                                        keyboardType: TextInputType.name,
                                        decoration: new InputDecoration(
                                          hintStyle: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                            color: Colors.grey,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                          hintText: getTranslated(context,'to'),
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          errorBorder: InputBorder.none,
                                          disabledBorder: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],),
                            ),

                          ],),
                        ),

                        SizedBox(height: 40,),
                        Center(
                          child: saving?CircularProgressIndicator():InkWell(onTap: (){save();},
                            child: Container(
                              width: size.width*.6,
                              height: 45.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.linear1,
                                      AppColors.linear2,
                                      AppColors.linear2,
                                    ],
                                  )
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "saveAndContinue"),
                                  style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                                    color: Colors.white,
                                    fontSize: 18.0,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40,),
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
  tabbedText( String type,String name,TextEditingController controller){
    return TextFormField(
      controller: controller,
      onTap: (){
          if(type=="lang")
            _showLang(context,size);
          else if(type=="account")
            _showTypes(context,size);
          else
            _show(context,size);

      },
      textAlignVertical: TextAlignVertical.center,
      validator: (String? val) {
        if (val!.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      readOnly: true,
      enableInteractiveSelection: true,
      style: style(size),
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(10),
        errorStyle:style(size),
        hintStyle: style(size),

        labelText: name,
        labelStyle: style(size),
        enabledBorder: new OutlineInputBorder(
          borderSide: BorderSide(width:.5,color: Color.fromRGBO(158 ,158, 158,1)),
          borderRadius: BorderRadius.circular(7.0),

        ),
        focusedBorder: new OutlineInputBorder(
          borderSide: BorderSide(width:.5,color: Color.fromRGBO(123, 108, 150,1)),
          borderRadius: BorderRadius.circular(7.0),

        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(158 ,158, 158,1)),
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
    );
  }
  TextStyle style(Size size){
    return TextStyle(
        fontFamily:"Montserrat",// 'Montserrat',
        fontSize: 14,
        color: Color.fromRGBO(32,32,32,1),
        fontWeight: FontWeight.normal);
  }
  Widget getTitle (String title){
    return  Padding(
      padding: const EdgeInsets.only(top:5),
      child: Center(
        child: Container(height: 30,width: size.width*.30,
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
              style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 13.0,color:AppColors.pink, fontWeight:FontWeight.normal ),),
          ),
        ),
      ),
    );
  }
  BoxShadow shadow(){return
    BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0, 1.0), // shadow direction: bottom right
    );}
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
    setState(() {
      saving=true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      //names
      List<String>indexListAr=[],indexListEn=[],indexListFr=[],indexListIn=[];
      for(int y=1;y<=nameArController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
        indexListAr.add(nameArController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

      for(int y=1;y<=nameEnController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
        indexListEn.add(nameEnController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

      for(int y=1;y<=nameFrController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
        indexListFr.add(nameFrController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());

      for(int y=1;y<=nameInController.text.trimLeft().trimRight().replaceAll('.','').length;y++)
        indexListIn.add(nameInController.text.trimLeft().trimRight().replaceAll('.','').substring(0,y).toLowerCase());
      widget.user.consultName=ConsultName(
        nameAr: nameArController.text,
        nameEn: nameEnController.text,
        nameFr: nameFrController.text,
        nameIn:nameInController.text,
        searchIndexAr: indexListAr,
        searchIndexEn:  indexListEn,
        searchIndexFr: indexListFr,
        searchIndexIn: indexListIn,
      );
      widget.user.consultBio=ConsultBio(
        bioAr: bioArController.text,
        bioEn: bioEnController.text,
        bioFr: bioFrController.text,
        bioIn:bioInController.text,
      );
      //============voice packages
      if(voicePriceController.text!=price&&allowVoice){
        widget.user.price=voicePriceController.text;
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .where('type', isEqualTo: "voice")
            .get();

        if(querySnapshot.docs.length>0){
          for (var doc in querySnapshot.docs) {
            var discount = ((doc['callNum'] * int.parse(widget.user.price!)) * doc['discount']) / 100;
            double price= (doc['callNum'] * int.parse(widget.user.price!)) - discount;
            FirebaseFirestore.instance.collection(Paths.packagesPath).doc(doc.id).update({
              'price': price,
            });
          }
        }
        else
          {
            var discount=0.0;
            var packageId0 = Uuid().v4();
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId0)
                .set({
              'price': double.parse(widget.user.price.toString()),
              'discount': 0,
              'callNum': 1,
              'type':"voice",
              'consultUid': widget.user.uid,
              'Id': packageId0,
              'active': true,
            }, SetOptions(merge: true));

            var packageId1 = Uuid().v4();
             discount=(3*double.parse(widget.user.price!)*5)/100;
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId1)
                .set({
              'price': 3*double.parse(widget.user.price!)-discount,
              'discount': 5,
              'callNum': 3,
              "type":"voice",
              'consultUid': widget.user.uid,
              'Id': packageId1,
              'active': true,
            }, SetOptions(merge: true));



            var packageId2 = Uuid().v4();
            discount=(5*double.parse(widget.user.price!)*10)/100;
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId2)
                .set({
              'price': 5*double.parse(widget.user.price!)-discount,
              'discount': 10,
              'callNum': 5,
              'type':"voice",
              'consultUid': widget.user.uid,
              'Id': packageId2,
              'active': true,
            }, SetOptions(merge: true));

            var packageId3 = Uuid().v4();
            discount=(20*double.parse(widget.user.price!)*25)/100;
            await FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(packageId3)
                .set({
              'price': 20*double.parse(widget.user.price!)-discount,
              'discount': 25,
              'callNum': 20,
              "type":"voice",
              'consultUid': widget.user.uid,
              'Id': packageId3,
              'active': true,
            }, SetOptions(merge: true));
          }
      }
      //=============chat packages
      if(chatPriceController.text!=chatPrice&&allowChat){
        widget.user.chatPrice=chatPriceController.text;
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .where('type', isEqualTo: "chat")
            .get();

        if(querySnapshot.docs.length>0){
          for (var doc in querySnapshot.docs) {
            var discount = ((doc['callNum'] * int.parse(widget.user.chatPrice!)) * doc['discount']) / 100;
            double price= (doc['callNum'] * int.parse(widget.user.chatPrice!)) - discount;
            FirebaseFirestore.instance.collection(Paths.packagesPath).doc(doc.id).update({
              'price': price,
            });
          }
        }
        else
        {
          var discount=0.0;
          var packageId0 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId0)
              .set({
            'price': double.parse(widget.user.chatPrice.toString()),
            'discount': 0,
            'callNum': 1,
            'type':"chat",
            'consultUid': widget.user.uid,
            'Id': packageId0,
            'active': true,
          }, SetOptions(merge: true));

          var packageId1 = Uuid().v4();
          discount=(3*double.parse(widget.user.chatPrice!)*5)/100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId1)
              .set({
            'price': 3*double.parse(widget.user.chatPrice!)-discount,
            'discount': 5,
            'callNum': 3,
            "type":"chat",
            'consultUid': widget.user.uid,
            'Id': packageId1,
            'active': true,
          }, SetOptions(merge: true));



          var packageId2 = Uuid().v4();
          discount=(5*double.parse(widget.user.chatPrice!)*10)/100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId2)
              .set({
            'price': 5*double.parse(widget.user.chatPrice!)-discount,
            'discount': 10,
            'callNum': 5,
            'type':"chat",
            'consultUid': widget.user.uid,
            'Id': packageId2,
            'active': true,
          }, SetOptions(merge: true));

          var packageId3 = Uuid().v4();
          discount=(20*double.parse(widget.user.chatPrice!)*25)/100;
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId3)
              .set({
            'price': 20*double.parse(widget.user.chatPrice!)-discount,
            'discount': 25,
            'callNum': 20,
            "type":"chat",
            'consultUid': widget.user.uid,
            'Id': packageId3,
            'active': true,
          }, SetOptions(merge: true));
        }
      }
      var datenow=DateTime.now();
      var now = sugar.ZonedDateTime.now(sugar.Timezone('Asia/Riyadh'));

      print('hiiiiiiiiiii '+now.toString());


      _workTime.from=from;
      _workTime.to=to;
      _workTime.fromtime=fromtime;
      _workTime.totime=totime;
      widget.user.voice=allowVoice;
      widget.user.chat=allowChat;
      widget.user.workTimes!.clear();
      widget.user.workTimes!.add(_workTime);
      widget.user.name=nameArController.text;
      widget.user.bio=bioArController.text;
      widget.user.profileCompleted=true;
      widget.user.userLang=getTranslated(context, 'lang');
      if( widget.user.order==null)
        widget.user.order=0;
      //=============
      widget.user.fromUtc=DateTime(datenow.year, datenow.month, datenow.day,int.parse(from), 0, 0).toUtc().toString();
      widget.user.toUtc=DateTime(datenow.year, datenow.month, datenow.day,int.parse(to), 0, 0).toUtc().toString();
      setState(() {
        dataSave=true;
      });
      if (selectedProfileImage != null) {
        accountBloc.add(UpdateAccountDetailsEvent(
            user: widget.user, profileImage: selectedProfileImage));
      } else {
        accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
      }
    }
    setState(() {
      saving=false;
    });
  }
  _selectTimeFrom(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.from==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes![0].from! ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {

        //final now = DateTime.now();
        //final dt = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
        //print('object'+dt.toString());
        from=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          fromController.text="12 PM";
        else if(timeOfDay.hour==0)
          fromController.text="12 Am";
        else if(timeOfDay.hour>12)
          fromController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          fromController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
  _selectTimeFromtime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.fromtime==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes![0].fromtime! ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {
        fromtime=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          fromtimeController.text="12 PM";
        else if(timeOfDay.hour==0)
          fromtimeController.text="12 Am";
        else if(timeOfDay.hour>12)
          fromtimeController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          fromtimeController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
  _selectTimeTo(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.to==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes![0].to! ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {
        to=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          toController.text="12 PM";
        else if(timeOfDay.hour==0)
          toController.text="12 Am";
        else if(timeOfDay.hour>12)
          toController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          toController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
  _selectTimeTotime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.totime==null?selectedTime:TimeOfDay(hour:int.parse(widget.user.workTimes![0].totime! ), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if(timeOfDay != null )
    {
      setState(() {
        totime=timeOfDay.hour.toString();
        if(timeOfDay.hour==12)
          totimeController.text="12 PM";
        else if(timeOfDay.hour==0)
          totimeController.text="12 Am";
        else if(timeOfDay.hour>12)
          totimeController.text=(timeOfDay.hour-12).toString()+" PM";
        else
          totimeController.text=timeOfDay.hour.toString()+" AM";
      });
    }
  }
   _show(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.8,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "workDays"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: monday,
                          onChanged: (value) {
                            setState(() {
                              monday = value!;//!monday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "monday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: tuesday,
                          onChanged: (value) {
                            setState(() {
                              tuesday = !tuesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "tuesday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: wednesday,
                          onChanged: (value) {
                            setState(() {
                              wednesday = !wednesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "wednesday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: thursday,
                          onChanged: (value) {
                            setState(() {
                              thursday = !thursday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "thursday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: friday,
                          onChanged: (value) {
                            setState(() {
                              friday = !friday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "friday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: saturday,
                          onChanged: (value) {
                            setState(() {
                              saturday = !saturday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "saturday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: sunday,
                          onChanged: (value) {
                            setState(() {
                              sunday = !sunday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "sunday"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),

                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: MaterialButton(
                          onPressed: () {
                            workDays="";
                            daysValue.clear;
                            widget.user.workDays!.clear();
                            if(monday)
                            {
                              workDays=workDays+getTranslated(context,"monday")+",";
                              daysValue.add("1");
                            }
                            if(tuesday)
                            {
                              workDays=workDays+getTranslated(context,"tuesday")+",";
                              daysValue.add("2");
                            }
                            if(wednesday)
                            {
                              workDays=workDays+getTranslated(context,"wednesday")+",";
                              daysValue.add("3");
                            }
                            if(thursday)
                            {
                              workDays=workDays+getTranslated(context,"thursday")+",";
                              daysValue.add("4");
                            }
                            if(friday)
                            {
                              workDays=workDays+getTranslated(context,"friday")+",";
                              daysValue.add("5");
                            }
                            if(saturday)
                            {
                              workDays=workDays+getTranslated(context,"saturday")+",";
                              daysValue.add("6");
                            }
                            if(sunday)
                            {
                              workDays=workDays+getTranslated(context,"sunday")+",";
                              daysValue.add("7");
                            }
                            setState(() {
                              daysController.text=workDays;
                              print("days   "+ daysController.text);
                              widget.user.workDays=daysValue;
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
   _showTypes(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.4,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "accountType"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: allowChat,
                          onChanged: (value) {
                            setState(() {
                              allowChat =value!;// !allowChat;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "allowChat"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: allowVoice,
                          onChanged: (value) {
                            setState(() {
                              allowVoice = value!;//!allowVoice;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "allowVoice"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),


                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: MaterialButton(
                          onPressed: () {
                            type="";
                            if(allowVoice)
                            {
                              type=type+"Voice";
                              widget.user.voice=true;
                            }
                            if(allowChat)
                            {
                              type=type+"- Chat";
                              widget.user.chat=true;
                            }

                            setState(() {
                              typeController.text=type;
                              print("days   "+ typeController.text);
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
   _showLang(BuildContext ctx,size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) =>  Container(
        height: size.height*.4,
        width: size.width,
        padding:
        const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(40.0),
              topRight: const Radius.circular(40.0),
            )
        ),
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child:StatefulBuilder(builder: (context, setState) {
              return     SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children:  [

                    Text(
                      getTranslated(context, "languages"),
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: arabic,
                          onChanged: (value) {
                            setState(() {
                              arabic = !arabic;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "ar"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: english,
                          onChanged: (value) {
                            setState(() {
                              english = !english;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "en"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: french,
                          onChanged: (value) {
                            setState(() {
                              french = !french;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "fr"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.black,
                          activeColor: AppColors.lightGrey,
                          value: indonesian,
                          onChanged: (value) {
                            setState(() {
                              indonesian = !indonesian;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "id"),
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                          ),
                        ),
                      ],
                    ),

                    Center(
                      child: SizedBox(
                        height:35,
                        width: size.width * 0.5,
                        child: MaterialButton(
                          onPressed: () {
                            lang="";
                            widget.user.languages!.clear();
                            if(arabic)
                            {
                              lang=lang+" "+getTranslated(context, 'ar');
                              widget.user.languages!.add("ar");
                            }
                            if(english)
                            {
                              lang=lang+" "+getTranslated(context, 'en');
                              widget.user.languages!.add("en");
                            }
                            if(french)
                            {
                              lang=lang+" "+getTranslated(context, 'fr');
                              widget.user.languages!.add("fr");
                            }
                            if(indonesian)
                            {
                              lang=lang+" "+getTranslated(context, 'id');
                              widget.user.languages!.add("id");
                            }
                            setState(() {
                              langController.text=lang;
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: Text(
                            getTranslated(context,"done"),
                            style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],),
              );
            })


        ),
      ),);
  }
}
