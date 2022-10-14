import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widget/dialog.dart';
import '../../style/style.dart';
import '../widget/app_bar.dart';
import 'package:http/http.dart' as http;

class SearchId extends StatefulWidget {
  const SearchId({Key? key}) : super(key: key);

  @override
  _SearchIdState createState() => _SearchIdState();
}

class _SearchIdState extends State<SearchId> {
  var nameController = TextEditingController();
  var mobileController = TextEditingController();

  String userName = '';
  String userPhone = '';

  Future<String> fetchId() async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'name': userName,
      'phone': userPhone,
    };
    final response = await http.get(Uri.http(url, '/findid', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,//키보드올라올때 bottom overflow해결
      backgroundColor: Colors.white,
      appBar: baseAppBar('아이디 찾기'),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          child: Column(
            children: [
              const Flexible(
                fit: FlexFit.tight,
                child: Text(""),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 3,
                child: Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '가입한 이름과 전화번호를 입력해주세요.',
                        style: getLoginTextStyle(),
                      ),
                      SizedBox(height: 11.h),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //이름 입력 field
                          key: const ValueKey(1),
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          decoration: getInputDeco('이름 입력'),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            userName = value;
                          },
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: mobileController,
                          decoration: getInputDeco('핸드폰 번호(-제외)'),
                          textInputAction: TextInputAction.done,
                          onChanged: (value) {
                            userPhone = value;
                          },
                          onFieldSubmitted: (String value) async {
                            fetchId().then((value) => showCustomDialog(
                                context, value,
                                buttonText: "확인"));
                          },
                        ),
                      ),
                      SizedBox(
                        height: 9.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (nameController.text.isEmpty) {
                                  showCustomDialog(context, "이름을 입력해주세요.",
                                      buttonText: "확인");
                                } else {
                                  if (mobileController.text.isEmpty) {
                                    showCustomDialog(context, "핸드폰 번호를 입력해주세요.",
                                        buttonText: "확인");
                                  } else {
                                    fetchId().then((value) => showCustomDialog(
                                        context, value,
                                        buttonText: "확인"));
                                  }
                                }
                              },
                              style:
                                  supprotusButtonStyle(const Color(0xff54c9a8)),
                              child: const Text('아이디 찾기',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 28.h),
                      child: TextButton(
                        style: TextButton.styleFrom(
                            primary: const Color(0xffaeefdd)),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, '/searchPassword');
                        },
                        child: const Text(
                          '비밀번호 찾기',
                          style: TextStyle(
                            color: Color(0xff484848),
                            fontWeight: FontWeight.w300,
                            fontFamily: "NotoSansKR",
                            fontStyle: FontStyle.normal,
                            fontSize: 14.0,
                            decoration:
                                TextDecoration.underline, //TODO 텍스트 밑줄 높이 조정
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
