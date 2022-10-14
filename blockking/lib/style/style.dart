import 'package:flutter/material.dart';

TextStyle getTextfieldFontSize() {
  return const TextStyle(
    fontSize: 13,
    letterSpacing: -0.26,
  );
}

TextStyle getMyTextStyle(){
  return const TextStyle(
      color:  Color(0xff222222),
      fontWeight: FontWeight.w600,
      fontFamily: "NotoSansKR",
      fontStyle:  FontStyle.normal,
      fontSize: 16.0
  );
}

TextStyle getLoginTextStyle(){
  return const TextStyle(
      color:  Color(0xff222222),
      fontWeight: FontWeight.w500,
      fontFamily: "NotoSansKR",
      fontStyle:  FontStyle.normal,
      fontSize: 16.0
  );
}

InputDecoration getInputDeco(String hintText) {
  return InputDecoration (
    filled: true,
    fillColor: const Color(0xfffcfdfd),
    contentPadding: const EdgeInsets.symmetric(horizontal: 23.0),
    hintText: hintText,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xffe2eef0), width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(5))
    ),
    focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xff54c9a8), width: 1.2),
        borderRadius: BorderRadius.all(Radius.circular(5))
    ),
  );
}

// 버튼 스타일
ButtonStyle supprotusButtonStyle(Color color){
  return  ElevatedButton.styleFrom(
      primary: color,
      shadowColor: const Color(0xffe2eef0),
      padding: const EdgeInsets.all(14.0)
  );
}