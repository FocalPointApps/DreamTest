import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  const TextFormFieldWidget({
    required this.name, required this.controller, this.obscureText, this.icon, this.lines,this.isNumber, this.isReadOnly});
  final TextEditingController controller;
  final String name;
  final bool? obscureText;
  final bool? isNumber;
  final String? icon;
  final int? lines;
  final bool? isReadOnly;


  @override
  Widget build(BuildContext context) {
    Size size=MediaQuery.of(context).size;
    return  TextFormField(
      controller: controller,
      obscureText:obscureText==null?false:obscureText!,
      textAlignVertical: TextAlignVertical.center,
      validator: (String? val) {
        if (val!.trim().isEmpty) {
          return 'This field is required';
        }
        return null;
      },
      enableInteractiveSelection: true,
      style: style(size),
      maxLines: lines==null?1:lines,
      readOnly: isReadOnly==null?false:true,
      textInputAction: lines==null?TextInputAction.done:TextInputAction.newline,
      keyboardType: lines==null?isNumber!=null?TextInputType.number:TextInputType.text:TextInputType.multiline,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all((kIsWeb && size.width >400)?20:10),
        errorStyle:style(size),
        hintStyle: style(size),
        prefixIcon:icon==null?null:Image.asset(
          'assets/icons/'+icon!,
          width: 14,
          height: 12,
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: 50.0,
        ),
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
        fontSize: (kIsWeb && size.width >400)?17:14,
        color: Color.fromRGBO(32,32,32,1),
        fontWeight: FontWeight.normal);
  }

}