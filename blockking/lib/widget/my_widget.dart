import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

GestureDetector myButtonBox(String text, context) {
  return GestureDetector(
    onTap: () {},
    child: Container(
        height: 50.h,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  color: Color(0xffe2eef0),
                  offset: Offset(0, 3),
                  blurRadius: 6,
                  spreadRadius: 0)
            ],
            color: Color(0xffffffff)),
        child: Padding(
          padding: EdgeInsets.only(left: 16.w, right: 13.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: TextStyle(
                    color: const Color(0xff272727),
                    fontWeight: FontWeight.w400,
                    fontFamily: "NotoSansKR",
                    fontStyle: FontStyle.normal,
                    fontSize: 15.sp),
              ),
              RotatedBox(
                  quarterTurns: 3,
                  child: Image.asset(
                    'images/icon_arrow.png',
                    width: 13.h,
                    height: 7.2,
                    fit: BoxFit.contain,
                  )),
            ],
          ),
        )),
  );
}
