import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../style/style.dart';
import '../../widget/dialog.dart';
import '../widget/app_bar.dart';
import 'package:http/http.dart' as http;

class SearchPassword extends StatefulWidget {
  const SearchPassword({Key? key}) : super(key: key);

  @override
  _SearchPasswordState createState() => _SearchPasswordState();
}

class _SearchPasswordState extends State<SearchPassword> {
  var idController = TextEditingController();
  var nameController = TextEditingController();
  var mobileController = TextEditingController();

  late FocusNode emailNode;
  late FocusNode nameNode;
  late FocusNode phoneNode;

  @override
  void initState(){
    emailNode = FocusNode();
    nameNode = FocusNode();
    phoneNode = FocusNode();
    super.initState();
  }

  @override
  void dispose(){
    emailNode.dispose();
    nameNode.dispose();
    phoneNode.dispose();
    super.dispose();
  }


  void judge() async{
    if(idController.text.isEmpty || nameController.text.isEmpty || mobileController.text.isEmpty){
      showCustomDialog(context, "빈 칸을 채워주세요.",buttonText: "확인");
    }
    else{
      fetchId().then((value) => showCustomDialog(
          context, value,
          buttonText: "확인"));
    }
  }

  Future<String> fetchId() async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'email': idController.text,
      'name': nameController.text,
      'phone': mobileController.text,
    };
    final response = await http.get(Uri.http(url, '/findpw', queryParameters));

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
      // resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: baseAppBar('비밀번호 찾기'),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: (){
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가입한 정보를 입력해주세요.',
                      style: getLoginTextStyle(),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 45.h,
                      child: TextFormField(
                        focusNode: emailNode,
                        cursorColor: const Color(0xffe2eef0),
                        style: getTextfieldFontSize(),
                        controller: idController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: (){
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: getInputDeco('이메일 입력'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 45.h,
                      child: TextFormField(
                        focusNode: nameNode,
                        cursorColor: const Color(0xffe2eef0),
                        style: getTextfieldFontSize(),
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        onEditingComplete: (){
                          FocusScope.of(context).nextFocus();
                        },
                        decoration: getInputDeco('이름 입력'),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 45.h,
                      child: TextFormField(
                        focusNode: phoneNode,
                        cursorColor: const Color(0xffe2eef0),
                        style: getTextfieldFontSize(),
                        controller: mobileController,
                        decoration: getInputDeco('핸드폰 번호(-제외)'),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (String value) async{
                          judge();
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
                              judge();
                            },
                            style: supprotusButtonStyle(const Color(0xff54c9a8)),
                            child: const Text('비밀번호 찾기',style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom:28.h),
                      child: TextButton(
                        style: TextButton.styleFrom(primary: const Color(0xffaeefdd)),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/searchId');
                        },
                        child: const Text(
                          '아이디 찾기',
                          style: TextStyle(
                            color:  Color(0xff484848),
                            fontWeight: FontWeight.w300,
                            fontFamily: "NotoSansKR",
                            fontStyle:  FontStyle.normal,
                            fontSize: 14.0,
                            decoration: TextDecoration.underline, //TODO 텍스트 밑줄 높이 조정
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
