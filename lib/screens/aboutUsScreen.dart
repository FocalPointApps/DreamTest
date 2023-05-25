
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../config/colorsFile.dart';

class AboutUsScreen extends StatefulWidget {

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;
  final _key = UniqueKey();
String url="https://dream-app.net/?lang=ar",lang="ar";
  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang=getTranslated(context,"lang");
    if(lang!="ar")url="https://dream-app.net/";
    return Scaffold(backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[

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
                          getTranslated(context, "aboutUs"),
                          textAlign:TextAlign.left,
                          style: TextStyle( fontFamily: getTranslated(context, 'fontFamily'),fontSize: 16.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                        ),



                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading ? Center( child: CircularProgressIndicator(),)
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
