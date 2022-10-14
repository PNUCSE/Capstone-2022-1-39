import 'package:blockking/provider/navigator_provider.dart';
import 'package:blockking/provider/user_provider.dart';
import 'package:blockking/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'app_menu/contract/Contract.dart';
import 'app_menu/contract/Registration.dart';
import 'app_menu/home/Home.dart';
import 'app_menu/my/My.dart';
import 'app_menu/notice/Notice.dart';
import 'login/login_main.dart';
import 'login/search_id.dart';
import 'login/search_password.dart';
import 'login/signup_page.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp]); // 화면 세로로 고정
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (BuildContext context) => NavigatorProvider(),
        ),
        ChangeNotifierProvider(
          create: (BuildContext context) => UserProvider(),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Blockking',
            // You can use the library anywhere in the app even in theme
            // theme: ThemeData(
            //   primarySwatch: Colors.blue,
            //   textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            // ),
            routes: {
              //로그인 route
              '/LoginMain': (context) => LoginMain(),
              '/signUpPage': (context) => SignUpPage(),
              '/searchId': (context) => SearchId(),
              '/searchPassword': (context) => SearchPassword(),
              '/registration': (context) => Registration(),

              '/Main': (context) => Main(),
            },
            home: child,
          );
        },
        child: SplashScreen(),
      ),
    );
  }
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainStatefulWidget();
  }
}

/// This is the stateful widget that the main application instantiates.
class MainStatefulWidget extends StatefulWidget {
  const MainStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MainStatefulWidget> createState() => _MainStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MainStatefulWidgetState extends State<MainStatefulWidget> {
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    Contract(),
    Notice(),
    My(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      Provider.of<NavigatorProvider>(context, listen: false).changeIndex(index);
      if(index!=1){
        Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: _widgetOptions
            .elementAt(Provider.of<NavigatorProvider>(context).index),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco_outlined),
            label: '매매',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'MY',
          ),
        ],
        currentIndex: Provider.of<NavigatorProvider>(context).index,
        selectedItemColor: Color(0xff54c9a8),
        unselectedItemColor: Color(0xffeaeaea),
        onTap: _onItemTapped,
      ),
    );
  }
}
