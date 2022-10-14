import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future showCustomDialog(BuildContext context, String text, {String buttonText = '확인'}) {  //TODO 확인 버튼 사이즈
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: 300.w,
            height: 160.h,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  width: 300.w,
                  height: 110.h,
                  decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.black12,
                            width: 0.5
                        ),
                      )
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(text,
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              letterSpacing: -0.48,
                              fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]
                  ),
                ),
                SizedBox(
                  width: 300.w,
                  height: 50.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(buttonText,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black, fontSize: 14, letterSpacing: -0.42,fontWeight: FontWeight.w400))
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
  );
}

Future showCustomDialog2(BuildContext context, String text, String text2, {String buttonText = '확인'}) {  //TODO 확인 버튼 사이즈
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: SizedBox(
            width: 300.w,
            height: 160.h,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  width: 300.w,
                  height: 110.h,
                  decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.black12,
                            width: 0.5
                        ),
                      )
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(text,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            letterSpacing: -0.48,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(
                          height: 14.h,
                        ),
                        Text(text2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color:  Color(0xff747474),
                            fontSize: 13,
                            letterSpacing: -0.48,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ]
                  ),
                ),
                SizedBox(
                  width: 300.w,
                  height: 50.h,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                            style: ButtonStyle(
                              overlayColor: MaterialStateProperty.all(Colors.transparent),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(buttonText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.black, fontSize: 14, letterSpacing: -0.42,fontWeight: FontWeight.w400))
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }
  );
}
