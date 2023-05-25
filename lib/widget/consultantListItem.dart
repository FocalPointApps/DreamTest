

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:grocery_store/config/colorsFile.dart';
import 'package:grocery_store/localization/localization_methods.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grocery_store/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../screens/consultantDetailsScreen.dart';

class ConsultantListItem extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consult;
  final String consultType;

  ConsultantListItem({required this.consult, this.loggedUser, required this.consultType});

  @override
  _ConsultantListItemState createState() => _ConsultantListItemState();
}

class _ConsultantListItemState extends State<ConsultantListItem>
    with SingleTickerProviderStateMixin {
  bool sharing = false;
  String orderNum = "0";

  @override
  void initState() {
    if (widget.consult.ordersNumbers! < 100)
      orderNum = widget.consult.ordersNumbers.toString();
    else
      for (int x = 2; x < 1000000; x++) {
        if (widget.consult.ordersNumbers! < x * 100) {
          orderNum = ((x - 1) * 100).toString() + "+";
          break;
        }
      }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString(), languages = "";
    int timeNow = _now.hour;

    if (widget.consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(widget.consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(widget.consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultantDetailsScreen(
                consultant: widget.consult,
                loggedUser: widget.loggedUser,
                consultType: widget.consultType),
          ),
        );
      },
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightPink,
              blurRadius: 2.0,
              spreadRadius: 0.0,
              offset: Offset(0.0, 1.0), // shadow direction: bottom right
            )
          ],
        ),
        child: Stack(children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(left: 5, right: 5, bottom: 5, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: avaliable ? AppColors.green : Colors.red,
                          ),
                          width: 8.0,
                          height: 8.0,
                        ),
                        Text(
                          avaliable ? "Online" : "Offline",
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            fontWeight: FontWeight.normal,
                            color: AppColors.grey,
                            fontSize: 9.0,
                          ),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 61,
                          width: 61,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey, width: 1),
                            shape: BoxShape.circle,
                            color: AppColors.white,
                          ),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppColors.white, width: 5),
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: widget.consult.photoUrl!.isEmpty
                                ? Image.asset(
                                    'assets/applicationIcons/whiteLogo.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.fill,
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(100.0),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/images/load.gif',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder: (context, error,
                                              stackTrace) =>
                                          Image.asset(
                                              'assets/applicationIcons/whiteLogo.png',
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.fill),
                                      image: widget.consult.photoUrl!,
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
                        Image.asset(
                          'assets/applicationIcons/dashBorder.png',
                          width: 66,
                          height: 66,
                        )
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        sharing
                            ? Container(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator())
                            : InkWell(
                                onTap: () async {
                                  // Create DynamicLink
                                  share(context);
                                  //
                                },
                                child: Column(
                                  children: [
                                    Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: AppColors.lightPink,
                                          borderRadius:
                                              BorderRadius.circular(3.0),
                                        ),
                                        child: Center(
                                            child: Image.asset(
                                          'assets/applicationIcons/share.png',
                                          width: 12,
                                          height: 12,
                                        ))),
                                    Text(
                                      "Share",
                                      style: TextStyle(
                                       fontFamily: getTranslated(context, 'fontFamily'),
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.grey,
                                        fontSize: 9.0,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    )
                  ],
                ),
                SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: double.parse(widget.consult.rating.toString()),
                  size: 12.0,
                  onRatingChanged:  (v) {
                  },
                  color: AppColors.yellow,
                  borderColor: AppColors.yellow,
                  spacing: 1.0,
                ),
                Text(
                  getTranslated(context, "lang")=="ar"?widget.consult.consultName!.nameAr!:
                  getTranslated(context, "lang")=="en"?widget.consult.consultName!.nameEn!:
                  getTranslated(context, "lang")=="fr"?widget.consult.consultName!.nameFr!:
                  widget.consult.consultName!.nameIn!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                     fontFamily: getTranslated(context, 'fontFamily'),
                      color: AppColors.pink,
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
               /* Icon(
                  Icons.mic_none,
                  color: AppColors.pink,
                  size: 12.0,
                ),
                widget.consult.languages!.length > 1
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          langWidget(widget.consult.languages![0]),
                          SizedBox(
                            width: 5,
                          ),
                          langWidget(widget.consult.languages![1])
                        ],
                      )
                    : langWidget(widget.consult.languages![0]),*/
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child:  getTranslated(context, "lang")=="ar"?Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
               priceWidget(),
               callsWidget(),
              ],
            ):Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                callsWidget(),
                priceWidget(),
              ],
            ),
          ),
        ]),
      ),
    );
  }
  callsWidget(){return  Padding(
    padding: const EdgeInsets.only(left: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/applicationIcons/greenCall2.png',
          width: 12,
          height: 12,
        ),
        Text(
          //widget.consult.ordersNumbers==null?'0':widget.consult.ordersNumbers<100?widget.consult.ordersNumbers.toString():widget.consult.ordersNumbers<1000?"+100":"+1000",
          orderNum,
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 11.0,
          ),
        )
      ],
    ),
  );}
  priceWidget(){return  Container(
    width: 35,
    height: 20,
    decoration: BoxDecoration(
      color: AppColors.pink,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(8.0),
        topLeft: Radius.circular(20.0),
      ),
    ),
    child: Center(
      child: Text(
        widget.consultType == "voice"
            ? widget.consult.price! + "\$"
            : widget.consult.chatPrice! + "\$",
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontFamily: getTranslated(context, 'fontFamily'),
          color: Colors.white,
          fontSize: 11.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ));}
  share(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    print("share1");
    String uid=widget.consult.uid!;
    print("share2");
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse("https://dreamuser\.page\.link/consultant_id="+uid),
      uriPrefix:"https://dreamuser\.page\.link",
      androidParameters: const AndroidParameters(packageName: "com.app.dreamTest"),
      iosParameters: const IOSParameters(
          bundleId: "com.app.dreamTest",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    print("share3");
    ShortDynamicLink dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    print("share4");
    File file;
    if (widget.consult.photoUrl!.isEmpty) {
      print("share5");
      final bytes = await rootBundle.load('assets/applicationIcons/whiteLogo.png');
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
      print("share6");
    } else {
      print("share7");
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consult.photoUrl!));
      file = await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png')
              .writeAsBytes(response.bodyBytes);
      print("share8");
    }
    print("share9");
    Share.shareFiles(["${file.path}"],
        text: '(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consult.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    print("share10");
    setState(() {
      sharing = false;
    });
  }
  shareww(BuildContext context) async {
    setState(() {
      sharing = true;
    });
    // Create DynamicLink
    final dynamicLinkParams = DynamicLinkParameters(
      link: Uri.parse(
          "https://dreamuser.page.link?consultant_id=" + widget.consult.uid!),
      uriPrefix: "https://dreamuser.page.link",
      androidParameters:
      const AndroidParameters(packageName: "com.app.dreamTest"),
      iosParameters: const IOSParameters(
          bundleId: "com.app.dreamTest",
          appStoreId: "1515745954",
          minimumVersion: "2.2.17"),
    );
    ShortDynamicLink dynamicLink =
    await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
    File file;
    if (widget.consult.photoUrl!.isEmpty) {
      final bytes =
      await rootBundle.load('assets/applicationIcons/whiteLogo.png');
      final list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/image.jpg').create();
      file.writeAsBytesSync(list);
    } else {
      final directory = await getTemporaryDirectory();
      final path = directory.path;
      final response = await http.get(Uri.parse(widget.consult.photoUrl!));
      file =
      await File('$path/image_${DateTime.now().millisecondsSinceEpoch}.png')
          .writeAsBytes(response.bodyBytes);
    }

    Share.shareFiles(["${file.path}"],
        text: '(تطبيق رؤيا -Dream Application) '
            '\n ${getTranslated(context, "ilikead")} ${widget.consult.name} '
            ' ${getTranslated(context, "irecommendit")}.\n '
            '\n ${dynamicLink.shortUrl.toString()} ');
    setState(() {
      sharing = false;
    });
  }
  Widget langWidget(String langText) {
    return Container(
      height: 20,
      width: 40, //size.width * .30,
      decoration: BoxDecoration(
        color: AppColors.lightPink2,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Text(
          langText,
          textAlign: TextAlign.center,
          style: TextStyle(
           fontFamily: getTranslated(context, 'fontFamily'),
            color: AppColors.pink,
            fontSize: 9.0,
          ),
        ),
      ),
    );
  }
}
