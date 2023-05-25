import 'package:flutter/material.dart';

import '../config/colorsFile.dart';

class TextDefaultWidget extends StatelessWidget {
  const TextDefaultWidget(
      {Key? key,
        required this.title,
        this.fontSize,
        this.fontWeight,
        this.color,
        this.gradientColors,
        this.maxLines,
        this.underlineText,this.textBaseline,this.textAlign, this.fontFamily,})
      : super(key: key);
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final Paint? gradientColors;
  final String title;
  final String? fontFamily;
  final int? maxLines;
  final bool? underlineText;
  final TextBaseline? textBaseline;
  final TextAlign? textAlign;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: color ?? AppColors.white,
          textBaseline: textBaseline,
          fontFamily: fontFamily ?? "Ithra",
          foreground: gradientColors,
          overflow: TextOverflow.ellipsis,
          decoration: underlineText == true
              ? TextDecoration.underline
              : TextDecoration.none),
      maxLines: maxLines??5,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

// class GradientTextWidget extends StatelessWidget {
//   const GradientTextWidget({
//     super.key,
//     required this.title,
//     this.fontSize,
//     this.fontWeight,
//     this.color,
//     this.maxlines,
//     this.gradientColors = const LinearGradient(
//       colors: <Color>[
//         Color(0xff42DEBF),
//         Color(0xff6CA5C2),
//         Color(0xff4876B2),
//         Color(0xff315FAA),
//       ],
//     ),
//   });
//
//   final String title;
//   final Gradient gradientColors;
//   final int? maxlines;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final Color? color;
//   @override
//   Widget build(BuildContext context) {
//     return ShaderMask(
//       blendMode: BlendMode.srcIn,
//       shaderCallback: (bounds) => gradientColors.createShader(
//         Rect.fromLTWH(0, 0, bounds.width, bounds.height),
//       ),
//       child: Text(
//         title,
//         style: TextStyle(
//           fontSize: fontSize ?? 16,
//           fontWeight: fontWeight ?? FontWeight.w500,
//           color: color ?? AppColors.white,
//         ),
//         maxLines: maxlines,
//       ),
//     );
//   }
// }
