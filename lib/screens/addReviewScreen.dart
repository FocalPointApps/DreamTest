
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/config/paths.dart';
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:grocery_store/models/consultReview.dart';
import 'package:grocery_store/models/user.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';

class AddReviewScreen extends StatefulWidget {
  final String consultId;
  final String userId;
  final String appointmentId;
  const AddReviewScreen({Key? key, required this.consultId, required this.userId, required this.appointmentId}) : super(key: key);
  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController controller = TextEditingController();
  bool load=true, adding=false;
  late GroceryUser consult,user;
  dynamic rating=0.0,consultRating=0.0;
  String name="....",image="";
  late RatingDialog _dialog ;
  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    getConsultDetails();

  }
  
Future<void> getConsultDetails() async {
  DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultId);
  final DocumentSnapshot documentSnapshot = await docRef.get();

  DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.userId);
  final DocumentSnapshot documentSnapshot2 = await docRef2.get();
  setState(() {
    consult= GroceryUser.fromMap(documentSnapshot.data() as Map);
    name=consult.name!;
    image=consult.photoUrl!;
    consultRating=(consult.rating==null)?0.0:consult.rating;
    user=GroceryUser.fromMap(documentSnapshot2.data() as Map);
    load=false;
  });

}
  @override
  Widget build(BuildContext context) {
    String star=getTranslated(context, "stars");
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(backgroundColor: Colors.white,
        resizeToAvoidBottomInset:false,
        body: Column(children: [
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
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
                          getTranslated(context, "Reviews"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:AppColors.pink, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: load?CircularProgressIndicator():Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10.0,
                  ),
                  (consult.photoUrl==""||consult.photoUrl==null)?
                  Image.asset('assets/applicationIcons/GroupLogo.png',width: 80,height: 80,fit:BoxFit.fill):Stack(alignment: Alignment.center,children: [
                    Container(
                      height: 81,
                      width: 81,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey,width: 1),
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.white,width: 5),
                          shape: BoxShape.circle,
                          color: AppColors.white,
                        ),
                        child: consult.photoUrl!.isEmpty ?Image.asset('assets/applicationIcons/whiteLogo.png',width: 80,height: 80,fit:BoxFit.fill,)
                            :ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: FadeInImage.assetNetwork(
                            placeholder:'assets/images/load.gif',
                            placeholderScale: 0.5,
                            imageErrorBuilder:(context, error, stackTrace) => Image.asset('assets/applicationIcons/GroupLogo.png',width: 80,height: 80,fit:BoxFit.fill),
                            image: consult.photoUrl!,
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
                    Image.asset('assets/applicationIcons/dashBorder.png',width: 86,height: 86,)
                  ], ),
                  Center(
                    child: Text(
                      consult.name!,
                      style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.grey,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  SmoothStarRating(
                    allowHalfRating: true,
                    starCount: 5,
                    onRatingChanged:  (v) {
                    },
                    rating: double.parse(consult.rating.toString()),
                    size: 20.0,
                    color: AppColors.yellow,
                    borderColor:AppColors.yellow,
                    spacing: 1.0,
                  ),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Text(
                        getTranslated(context, "rateConsult")+":-",
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Center(
                    child: SmoothStarRating(
                      allowHalfRating: true,
                      onRatingChanged:  (v) {
                        setState(() {
                          rating = v;
                        });
                      },
                      starCount: 5,
                      rating: rating,
                      size: 20.0,
                      color: Colors.orange.shade500,
                      borderColor: Colors.orange.shade500,
                      spacing: 1.0,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      maxLines: 10,
                      controller: controller,

                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 11.0,
                        letterSpacing: 0.5,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[100],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                            color:  Colors.grey.shade100,
                            width: 0.0,
                          ),
                        ),
                        /* border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10.0),
                                        borderSide:  BorderSide(color: Colors.white ),
                                    ),*/
                        contentPadding: EdgeInsets.all(10),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          letterSpacing: 0.5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: 11.0,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        hintText: getTranslated(context,'rateConsult'),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 15.0,
                  ),
                  Center(
                    child: adding?CircularProgressIndicator():SizedBox(
                      height:50,
                      width: size.width * 0.7,
                      child: MaterialButton(
                        onPressed: () {
                          //rate event
                          if (rating > 0.0) {
                            //proceed
                            addReview();
                          }
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          getTranslated(context,"rate"),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
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
    );
  }
  Future<bool?> addReview()async {
    setState(() {
      adding=true;
    });
    /*showDialog(
      context: context,
      builder: (context) => _dialog,
    );*/
    String reviewId=Uuid().v4();
    try {
      await FirebaseFirestore.instance.collection(Paths.consultReviewsPath).doc(reviewId).set({
        'rating': double.parse((rating.toString())),
        'review': controller.text,
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'consultUid': consult.uid,
        'appointmentId':widget.appointmentId,
        'reviewTime':Timestamp.now(),
        'consultName': consult.name,
        'consultImage': consult.photoUrl,
      }
      );
      //update user review
      List<ConsultReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.consultReviewsPath)
            .where('consultUid', isEqualTo: consult.uid)
            .get();

        reviews = List<ConsultReview>.from(
          (snap.docs).map(
                (e) => ConsultReview.fromMap(e.data() as Map),
          ),
        );
        double _rating=0;
        if (reviews.length > 0) {
          for (var review in reviews) {
            _rating = _rating + double.parse(review.rating.toString());
          }
          _rating = _rating / reviews.length;
          _rating=double.parse((_rating.toStringAsFixed(1)));
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consult.uid).set({
            'rating': _rating,
            'reviewsCount':reviews.length,

          }, SetOptions(merge: true));
        }
          setState(() {
            adding=false;
          });
        Navigator.pop(context);
      } catch (e) {
        print("reviewwwwww"+e.toString());
        return null;
      }
      return true;
    } catch (e) {
      print("reviewwwwww222"+e.toString());
    }
  }

}
