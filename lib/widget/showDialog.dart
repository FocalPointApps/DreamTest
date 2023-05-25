import 'package:flutter/material.dart';

import '../localization/localization_methods.dart';

class ShowDialog extends StatefulWidget {

  final String contentText;
  final VoidCallback noFunction;
  final VoidCallback yesFunction;

  const ShowDialog({Key? key, required this.contentText, required this.noFunction, required this.yesFunction}) : super(key: key);

  @override
  State<ShowDialog> createState() => _ShowDialogState();
}

class _ShowDialogState extends State<ShowDialog> {
  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: 16.0, right: 16.0, top: 20.0, bottom: 10.0),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: 15.0,
                ),
                Text(
                  getTranslated(context, widget.contentText),
                  style: TextStyle(
                   fontFamily: getTranslated(context, 'fontFamily'),
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: Colors.black87,
                  ),
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
                        onPressed: widget.noFunction,
                        child: Text(
                          getTranslated(context, 'no'),
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
                            color: Colors.black87,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                     Container(
                      width: 50.0,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(0.0),
                        onPressed: widget.yesFunction,
                        child: Text(
                          getTranslated(context, 'yes'),
                          style: TextStyle(
                           fontFamily: getTranslated(context, 'fontFamily'),
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
          },
        ),
      );
  }
}
