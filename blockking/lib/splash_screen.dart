import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  //_fetchPosts
  void _fetchPosts() async {
    print('_fetchPosts');


    Timer(const Duration(seconds: 3), () {
      Navigator.pushNamedAndRemoveUntil(context, '/LoginMain', (Route<dynamic> route) => false);
      // Navigator.pushNamedAndRemoveUntil(context, '/Main', (Route<dynamic> route) => false);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment(0.02747553400695324, 0.061474572867155075),
                      end: Alignment(1.150573968887329, 1),
                      colors: [Color(0xff8ae5ab), Color(0xff16a8a3)])
              ),
              child: Center(
                child: Image.asset('images/splash.png',
                  width: 250.w),
              ),
            ),
          )
        ],
      ),
    );
  }
}
