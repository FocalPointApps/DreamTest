
import 'package:grocery_store/localization/language_constants.dart';
import 'package:grocery_store/localization/localization_methods.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:webview_flutter/webview_flutter.dart';

import '../config/colorsFile.dart';

class MoreScreen extends StatefulWidget {
  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  final _key = UniqueKey();

  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              // height: 80,
              // color: Colors.white,
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
                          icon: Image.asset(
                            getTranslated(context, "arrow"),
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      getTranslated(context, "dream"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                         fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: 16.0,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: 2,
                  width: size.width * .9)),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: getTranslated(context, 'lang') == "ar"
                      ? "https://dream-app.net/?lang=ar"
                      : "https://dream-app.net/search-page/",
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading == true
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
