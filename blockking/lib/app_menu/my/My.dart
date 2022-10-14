import 'package:blockking/main.dart';
import 'package:blockking/util/reciept.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import '../../style/style.dart';
import '../../widget/app_bar.dart';
import '../../widget/my_widget.dart';
import 'package:http/http.dart' as http;

class My extends StatefulWidget {
  const My({Key? key}) : super(key: key);

  @override
  _MyState createState() => _MyState();
}

class _MyState extends State<My> {
  Future<String> _init(org,id) async {
    var token = '0';
    String blockUrl = '14.49.119.248:8080';
    final queryParameters = {
      'org': org,
      'id' : id
    };

    final blockResponse =
    await http.get(Uri.http(blockUrl, '/BalanceOf', queryParameters));
    if (blockResponse.statusCode == 200) {
      print(blockResponse.body.toString());
      token = blockResponse.body.toString();
    }
    return token;
  }

  // Future<String> getReciept(org,userId) async {
  //   String url = '14.49.119.248:8080';
  //   final queryParameters = {
  //     'org': org.toString(),
  //     'key': (org == "3")?'to':'from',
  //     'value': userId.toString(),
  //   };
  //   final response =
  //   await http.get(Uri.http(url, '/QueryReceipts', queryParameters));
  //
  //   if (response.statusCode == 200) {
  //     // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
  //     List<Reciept> reciepts = response.body
  //         .map((dynamic item) => Reciept.fromJson(item))
  //         .toList();
  //     return response.body;
  //   } else {
  //     // 만약 응답이 OK가 아니면, 에러를 던집니다.
  //     throw Exception('Failed to load post');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var org = Provider.of<UserProvider>(context, listen: false).user.role;
    var userId = Provider.of<UserProvider>(context, listen: false).user.id;

    return Scaffold(
        backgroundColor: const Color(0xfffafcfd),
        appBar: baseAppBar('MY'),
        body: FutureBuilder(
            future: _init(org,userId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData == false) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color(0xff54c9a8),
                ));
              } else {
                return SingleChildScrollView(
                  padding: EdgeInsets.all(15.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100.h,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xfff4f4f4),
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                spreadRadius: 0)
                          ],
                          color: Color(0xffffffff),
                        ),
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 5.w, top: 7.h, bottom: 5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Color(0xfffafcfd),
                                      backgroundImage: NetworkImage(
                                        'https://firebasestorage.googleapis.com/v0/b/supportus-a2878.appspot.com/o/user_image%2Ficon_my.png?alt=media&token=cd1ff5d6-cfee-4567-8f80-b2144019b7e5',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  Text(
                                    Provider.of<UserProvider>(context).user.name,
                                    style: const TextStyle(
                                        color: Color(0xff000000),
                                        fontWeight: FontWeight.w500,
                                        fontFamily: "NotoSansKR",
                                        fontStyle: FontStyle.normal,
                                        fontSize: 16.0),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Wallet'),
                                              content: SingleChildScrollView(
                                                child: ListBody(
                                                  children: <Widget>[
                                                    const Center(child: Text('잔액 [토큰]은')),
                                                    SizedBox(height: 10.h,),
                                                    Center(child: Text(snapshot.data,
                                                        style: const TextStyle(
                                                            color: Color(0xff000000),
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: "NotoSansKR",
                                                            fontStyle: FontStyle.normal,
                                                            fontSize: 24.0))),
                                                    SizedBox(height: 10.h,),
                                                    const Center(child: Text('입니다.')),
                                                  ],
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text('OK'),
                                                  onPressed: () {
                                                    // 다이얼로그 닫기
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          }
                                      );
                                    },
                                    icon: const Icon(Icons.wallet),
                                    iconSize: 15.w,
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(right: 10.w),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: const Color(0xff54c9a8),
                                    onPrimary: Colors.white,
                                  ),
                                  onPressed: () {
                                    Provider.of<UserProvider>(context, listen: false).removeUser();
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/LoginMain',
                                            (Route<dynamic> route) => false);
                                  },
                                  child: const Text('로그아웃'),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35.h,
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xfff4f4f4),
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                spreadRadius: 0)
                          ],
                          color: Color(0xffffffff),
                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(10.w, 20.h, 10.w, 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Center(
                                child: Text(
                                  "내 정보",
                                  style: TextStyle(
                                      color: Color(0xff000000),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "NotoSansKR",
                                      fontStyle: FontStyle.normal,
                                      fontSize: 22.0),
                                ),
                              ),
                              SizedBox(
                                height: 10.h,
                              ),
                              Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0xfff6f6f6),
                                        offset: Offset(0, 3),
                                        blurRadius: 6,
                                        spreadRadius: 0)
                                  ],
                                  // color: Color(0xfff6f6f6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Flexible(
                                          flex: 1,
                                          fit: FlexFit.tight,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text('이름',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('Email',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('Phone',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('주소',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('생년월일',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text('Role',
                                                  style: TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                height: 70,
                                                child: Text('ID',
                                                    style: TextStyle(
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: "NotoSansKR",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 18.0)),
                                              ),
                                            ],
                                          )),
                                      Flexible(
                                          flex: 2,
                                          fit: FlexFit.tight,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .name,
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .email,
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .phone,
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .address,
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .birth,
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text((Provider.of<UserProvider>(
                                                  context)
                                                  .user
                                                  .role == '3')?"산지유통인":"농부",
                                                  style: const TextStyle(
                                                      color: Color(0xff000000),
                                                      fontWeight: FontWeight.normal,
                                                      fontFamily: "NotoSansKR",
                                                      fontStyle: FontStyle.normal,
                                                      fontSize: 18.0)),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                height: 70,
                                                child: Text(Provider.of<UserProvider>(
                                                    context)
                                                    .user
                                                    .id,
                                                    style: const TextStyle(
                                                        color: Color(0xff000000),
                                                        fontWeight: FontWeight.normal,
                                                        fontFamily: "NotoSansKR",
                                                        fontStyle: FontStyle.normal,
                                                        fontSize: 18.0)),
                                              ),
                                            ],
                                          ))
                                    ],

                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20.h,
                              ),
                              // ElevatedButton(
                              //   style: ElevatedButton.styleFrom(
                              //     primary: Colors.grey,
                              //     onPrimary: Colors.white,
                              //   ),
                              //   onPressed: () async {
                              //     await getReciept(org,Provider.of<UserProvider>(
                              //         context, listen: false)
                              //         .user
                              //         .id).then((value) {
                              //           print(value);
                              //
                              //     });
                              //   },
                              //   child: const Text('거래 목록 확인'),
                              // ),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                );
              }
            }));
  }
}
