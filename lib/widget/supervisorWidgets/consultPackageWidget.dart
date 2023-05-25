

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../config/colorsFile.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultPackage.dart';
import '../../models/user.dart';
import '../component/textWidget.dart';

class ConsultPackagesWidget extends StatefulWidget {
final String consultId;

  ConsultPackagesWidget({required this.consultId});

  @override
  _ConsultPackagesWidgetState createState() => _ConsultPackagesWidgetState();
}

class _ConsultPackagesWidgetState extends State<ConsultPackagesWidget>
    with SingleTickerProviderStateMixin {
  String selectedType="chat";
  List<consultPackage> packages = [];
  final TextEditingController callNumController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  bool activeValue=false,load=false,saving=false;
  late consultPackage package;
  @override
  void initState() {
    super.initState();
    getConsultPackages();
  }
  @override
  void dispose() {
    super.dispose();

    priceController.dispose();
    discountController.dispose();
    callNumController.dispose();
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
     return Container(
       padding: const EdgeInsets.all(30),
       decoration: decoration(),
       child:Column(
         mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           TextWidget(text:getTranslated(context, "allPackages"),color: Color.fromRGBO( 123, 108 ,150,1),weight: FontWeight.w600,size: 12,
             align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
           SizedBox(
             height: 20,
           ),
          packages.length == 0?
           Center(
             child: TextWidget(text:getTranslated(context, "noPackages"),color: Color.fromRGBO( 32, 32 ,32,1),weight: FontWeight.w600,size: 12,
               align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
           ):packageListWidget(size),

           SizedBox(height: 20,),
           Center(
             child: IconButton(
               onPressed: () {
                 package = new consultPackage(Id: Uuid().v4(), consultUid: widget.consultId, type: 'chat',
                   price:0,discount:0,active: true,callNum:0,);
                 packageDialog(size, package);
               },
               icon: Icon(
                 Icons.add_circle,
                 size: 40,
                 color:AppColors.pink
               ),
             ),
           ),
         ],
       ),
     );
  }
  packageListWidget(Size size){
    return ListView.separated(
    itemCount: packages.length,
    shrinkWrap: true,
    physics: NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.all(0),
    itemBuilder: (context, index) {
      print("kkkkkkkfhfhfhf");
      print( packages[index].type);
      return InkWell(
        onTap: () {
          packageDialog(size, packages[index]);
        },
        child: Container(
            height: 50,
            width: size.width,
            padding: const EdgeInsets.only( left: 10, right: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text:  packages[index].type=="voice"?
                  (packages[index].callNum .toString() + getTranslated( context, "call")):
                  (packages[index].callNum .toString() + getTranslated( context, "message")),
                  color: Color.fromRGBO( 32, 32 ,32,1),
                  weight: FontWeight.w500,size: 12,
                  align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),

                TextWidget(text: packages[index].discount .toString() +" %",color: Colors.red,
                  weight: FontWeight.w500,size: 12,
                  align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),

                TextWidget(text: packages[index].price.toString() +"\$",color: Color.fromRGBO( 123 ,108 ,150,1),
                  weight: FontWeight.w500,size: 15,
                  align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),

              ],
            )),
      );
    },
    separatorBuilder:
        (BuildContext context, int index) {
      return SizedBox(
        height: 20.0,
      );
    },
  );
  }
  packageDialog(Size size, consultPackage selectedPackage) {
    callNumController.text = selectedPackage.callNum.toString();
    priceController.text = selectedPackage.price.toString();
    discountController.text = selectedPackage.discount.toString();
    activeValue = selectedPackage.active;
    selectedType=selectedPackage.type;
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      splashColor: Colors.white.withOpacity(0.5),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection(Paths.packagesPath)
                            .doc(selectedPackage.Id)
                            .delete();
                        getConsultPackages();
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.delete,
                        color: Colors.red,
                        size: 24.0,
                      ),
                    ),
                    SizedBox(width: 10,),
                    InkWell(
                      splashColor: Colors.white.withOpacity(0.5),
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24.0,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                rowData(size,getTranslated(context, "call"),callNumController),
                SizedBox(
                  height: 20.0,
                ),
                rowData(size,getTranslated(context, "discount"),discountController),

                SizedBox(
                  height: 20.0,
                ),
                rowData(size,getTranslated(context, "price"),priceController),
                SizedBox(
                  height: 20.0,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(text:getTranslated(context, "type"),color: Color.fromRGBO( 32 ,32 ,32,1),
                      weight: FontWeight.w500,size: 15,
                      align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
                    Container(
                        width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedType,
                            items:
                            <String>['voice', 'chat'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: new Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                              print("sasasa" + value!);

                            },
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  height: 20.0,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: activeValue,
                      onChanged: (value) {
                        setState(() {
                          activeValue = !activeValue;
                        });
                      },
                    ),
                    TextWidget(text: getTranslated(context, "active"),color: Color.fromRGBO( 32 ,32 ,32,1),
                      weight: FontWeight.w500,size: 15,
                      align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),

                  ],
                ),
                SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: 50.0,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () {
                          setState(() {
                            load = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          getTranslated(context, 'cancel'),
                          style: GoogleFonts.cairo(
                            color: Colors.black87,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    saving
                        ? CircularProgressIndicator()
                        : Container(
                      width: 50.0,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: () async {
                          selectedPackage.type=selectedType;
                          savePackage(selectedPackage);},
                        child: Text(
                          getTranslated(context, 'save'),
                          style: GoogleFonts.cairo(
                            color: Colors.red.shade700,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }
  Widget rowData(Size size,String text,TextEditingController controller){
    return   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget(text:text,color: Color.fromRGBO( 32 ,32 ,32,1),
          weight: FontWeight.w500,size: 15,
          align: TextAlign.start,family: getTranslated(context, 'fontFamily'),),
        Container(
          width: size.width * .3,
          height: 40,
          padding: const EdgeInsets.symmetric(
              horizontal: 10.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly
            ],
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            enableInteractiveSelection: true,
            style: GoogleFonts.cairo(
              fontSize: 14.0,
              color: Colors.black87,
              letterSpacing: 0.5,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 5.0, vertical: 8.0),
              border: InputBorder.none,
              hintText: text,
              hintStyle: GoogleFonts.cairo(
                fontSize: 14.0,
                color: Colors.black54,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
              ),
              counterStyle: GoogleFonts.cairo(
                fontSize: 12.5,
                color: Colors.black54,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
    );
  }
  BoxDecoration decoration(){
    return BoxDecoration(
      color: Color.fromRGBO(250, 250 ,250,1),
      borderRadius: BorderRadius.circular(31.0),
    );
  }
  Future<void> getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where(
        'consultUid',
        isEqualTo: widget.consultId,
      )
          .orderBy("callNum", descending: false)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          packages = List<consultPackage>.from(
            querySnapshot.docs.map(
                  (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
            ),
          );
        });
      } else
        setState(() {
          packages = [];
        });
    } catch (e) {
      print("getnumbererror" + e.toString());
    }
  }
  savePackage(consultPackage selectedPackage) async {
    setState(() {
      saving = true;
    });
    await FirebaseFirestore.instance
        .collection(Paths.packagesPath)
        .doc(selectedPackage.Id)
        .set({
      'price': double.parse(  priceController.text.toString()),
      'discount': int.parse(discountController.text),
      'callNum': int.parse(callNumController.text),
      'consultUid': widget.consultId,
      'Id': selectedPackage.Id,
      'active': activeValue,
      'type':selectedPackage.type,
    }, SetOptions(merge: true));
    getConsultPackages();
    setState(() {
      saving = false;
    });
    Navigator.pop(context);
  }
}
