

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/component/TextFormFieldWidget.dart';
import '../../widget/component/textWidget.dart';

class EditBioScreen extends StatefulWidget {
  final GroceryUser user;

  EditBioScreen({required this.user});

  @override
  State<EditBioScreen> createState() => _EditBioScreenState();
}

class _EditBioScreenState extends State<EditBioScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late Size size;



  bool isAdding = false;

  TextEditingController nameArController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();
  TextEditingController nameFrController = TextEditingController();
  TextEditingController nameInController = TextEditingController();

  TextEditingController bioArController = TextEditingController();
  TextEditingController bioEnController = TextEditingController();
  TextEditingController bioFrController = TextEditingController();
  TextEditingController bioInController = TextEditingController();


  @override
  void initState() {
    super.initState();

    nameArController.text=widget.user.consultName!.nameAr!;
    nameEnController.text=widget.user.consultName!.nameEn!;
    nameFrController.text=widget.user.consultName!.nameFr!;
    nameInController.text=widget.user.consultName!.nameIn!;

    bioArController.text=widget.user.consultBio!.bioAr!;
    bioEnController.text=widget.user.consultBio!.bioEn!;
    bioFrController.text=widget.user.consultBio!.bioFr!;
    bioInController.text=widget.user.consultBio!.bioIn!;
  }



  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          innerHeaderWidget(size),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20),
              children: [
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[


                        TextFormFieldWidget(name: getTranslated(context, "nameAr"),controller: nameArController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameEn"),controller: nameEnController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameFr"),controller: nameFrController,obscureText:false,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "nameIn"),controller: nameInController,obscureText:false,),
                        SizedBox(height: 40),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioAr"),controller: bioArController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioEn"),controller: bioEnController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioFr"),controller: bioFrController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),
                        TextFormFieldWidget(name: getTranslated(context, "bioIn"),controller: bioInController,obscureText:false,lines: 5,),
                        SizedBox(height: 40),

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          isAdding
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: InkWell(
                    onTap: () async {
                      await save();
                    },
                    child: Container(
                      width: size.width * .6,
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
                          )),
                      child: Center(
                        child: Text(
                          getTranslated(context, "save"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, 'fontFamily'),
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }
  Widget innerHeaderWidget(Size size){
    return   Container(
        width: size.width,
        child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      SizedBox(width: 5,),
                      TextWidget(text:getTranslated(context, "details"),color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w600,size: 17,
                        align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                    ],
                  ),



                ],
              ),
            )));
  }
  save() async {
    print("sssssss");
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      if (widget.user.uid != null) {
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
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          "consultName": {
            'nameAr': nameArController.text,
            'nameEn': nameEnController.text,
            'nameFr': nameFrController.text,
            'nameIn':nameInController.text,
            'searchIndexAr': indexListAr,
            'searchIndexEn':  indexListEn,
            'searchIndexFr': indexListFr,
            'searchIndexIn': indexListIn,
          },
          "consultBio":{
            'bioAr': bioArController.text,
            'bioEn': bioEnController.text,
            'bioFr': bioFrController.text,
            'bioIn':bioInController.text,
          }
        }, SetOptions(merge: true));

      }
      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Fluttertoast.showToast(
          msg: "Please fill all the details!",
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white);
    }
  }




}
