import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../provider/navigator_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0x99f7fbfc),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            margin: EdgeInsets.only(left: 15.w, right: 15.w, top: 80.h),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/blockking_logo.png',
                    width: 282.w,
                  ),
                  SizedBox(height: 21.h),
                  SizedBox(
                    height: 40.h,
                    child: Container(
                        decoration: const BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                            boxShadow: [
                              BoxShadow(
                                  color: Color(0xffe2eef0),
                                  offset: Offset(0, 3),
                                  blurRadius: 6,
                                  spreadRadius: 0)
                            ],
                            color: Color(0xffffffff)),
                        child: Row(
                          children: <Widget>[
                            const Flexible(
                              child: TextField(
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: 16, bottom: 4, top: 4),
                                    hintText: '품목 검색'),
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                width: 67.w,
                                height: 40.h,
                                decoration: const BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color(0xffe2eef0),
                                          offset: Offset(0, 3),
                                          blurRadius: 6,
                                          spreadRadius: 0)
                                    ],
                                    color: Color(0xff54c9a8)),
                                child: const Center(
                                  child: Text("검색",
                                      style: TextStyle(
                                          color: Color(0xffffffff),
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "NotoSansKR",
                                          fontStyle: FontStyle.normal,
                                          fontSize: 18.0),
                                      textAlign: TextAlign.left),
                                ),
                              ),
                              onTap: () {
                                Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(0);
                              },
                            )
                          ],
                        )),
                  ),
                  SizedBox(
                    height: 32.h,
                  ),
                  SizedBox(
                    height: 100.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 25.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              RawMaterialButton(
                                  onPressed: () {
                                    Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                    Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(1);
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Image.asset(
                                    'images/main_img_1.png',
                                    width: 40.h,
                                    height: 40.h,
                                    fit: BoxFit.fill,
                                  )),
                              SizedBox(height: 7.h),
                              const Text(
                                "채소류",
                                style: TextStyle(
                                    color: Color(0xff313131),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "NotoSansKR",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.0),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RawMaterialButton(
                                  onPressed: () {
                                    Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                    Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(2);
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Image.asset(
                                    'images/main_img_2.png',
                                    width: 40.h,
                                    height: 40.h,
                                    fit: BoxFit.fill,
                                  )),
                              SizedBox(height: 7.h),
                              const Text(
                                "양념채소류",
                                style: TextStyle(
                                    color: Color(0xff313131),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "NotoSansKR",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.0),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RawMaterialButton(
                                  onPressed: () {
                                    Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                    Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(3);
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Image.asset(
                                    'images/main_img_3.png',
                                    width: 40.h,
                                    height: 40.h,
                                    fit: BoxFit.fill,
                                  )),
                              SizedBox(height: 7.h),
                              const Text(
                                "잡곡류",
                                style: TextStyle(
                                    color: Color(0xff313131),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "NotoSansKR",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.0),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  SizedBox(
                    height: 100.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 0, 25.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              RawMaterialButton(
                                  onPressed: () {
                                    Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                    Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(4);
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Image.asset(
                                    'images/main_img_4.png',
                                    width: 40.h,
                                    height: 40.h,
                                    fit: BoxFit.fill,
                                  )),
                              SizedBox(height: 7.h),
                              const Text(
                                "기호과채류",
                                style: TextStyle(
                                    color: Color(0xff313131),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "NotoSansKR",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.0),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              RawMaterialButton(
                                  onPressed: () {
                                    Provider.of<NavigatorProvider>(context, listen: false).changeIndex(1);
                                    Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(5);
                                  },
                                  elevation: 2.0,
                                  fillColor: Colors.white,
                                  padding: const EdgeInsets.all(15.0),
                                  shape: const CircleBorder(),
                                  child: Icon(Icons.eco_outlined,size: 40.h,)),
                              SizedBox(height: 7.h),
                              const Text(
                                "기타",
                                style: TextStyle(
                                    color: Color(0xff313131),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "NotoSansKR",
                                    fontStyle: FontStyle.normal,
                                    fontSize: 11.0),
                              ),
                            ],
                          ),
                          Opacity(
                            opacity: 0,
                            child: Column(
                              children: [
                                RawMaterialButton(
                                    onPressed: () {},
                                    elevation: 2.0,
                                    fillColor: Colors.white,
                                    padding: const EdgeInsets.all(15.0),
                                    shape: const CircleBorder(),
                                    child: Icon(Icons.eco_outlined,size: 40.h,)),
                                SizedBox(height: 7.h),
                                const Text(
                                  ".",
                                  style: TextStyle(
                                      color: Color(0xff313131),
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "NotoSansKR",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 11.0),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
