import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';
import '../style/style.dart';
import '../util/user.dart';
import '../widget/dialog.dart';

class LoginMain extends StatefulWidget {
  @override
  State<LoginMain> createState() => _LoginMainState();
}

class _LoginMainState extends State<LoginMain> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  Future<String> fetchLogin() async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'email': emailController.text,
      'password': passwordController.text
    };
    final response = await http.get(Uri.http(url, '/login', queryParameters));

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
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                        child: Image.asset('images/blockking_logo.png')),
                    Form(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              cursorColor: const Color(0xffe2eef0),
                              style: getTextfieldFontSize(),
                              controller: emailController,
                              textInputAction: TextInputAction.next,
                              decoration: getInputDeco('이메일'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 45,
                            child: TextFormField(
                              cursorColor: const Color(0xffe2eef0),
                              style: getTextfieldFontSize(),
                              controller: passwordController,
                              decoration: getInputDeco('패스워드'),
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (String value) async {
                                // var result = await login(emailController: emailController, passwordController: passwordController);
                                // print('login result : $result');
                                // if(result['success']) {
                                //   showDialog_loginSuccess(context);
                                //   Navigator.pushNamedAndRemoveUntil(context, '/Main', (Route<dynamic> route) => false);
                                // } else {
                                //   showDialog_error_confirmBtn(context, result['message']);
                                // }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: 0,
                          child: Row(
                            children: const [
                              MyStatefulWidget(),
                              Text(
                                '로그인 정보 기억하기',
                                style: TextStyle(
                                  color: Color(0xff484848),
                                  fontSize: 12,
                                  fontFamily: 'NotoSansKR',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(children: [
                          GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.pushNamed(context, '/searchId');
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('아이디',
                                    style: TextStyle(
                                        color: Color.fromRGBO(72, 72, 72, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        letterSpacing: -0.6)),
                              )),
                          const Text(' | ',
                              style: TextStyle(
                                  color: Color.fromRGBO(72, 72, 72, 1),
                                  fontWeight: FontWeight.w300,
                                  fontSize: 12,
                                  letterSpacing: -0.6)),
                          GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.pushNamed(context, '/searchPassword');
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('비밀번호 찾기',
                                    style: TextStyle(
                                        color: Color.fromRGBO(72, 72, 72, 1),
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12,
                                        letterSpacing: -0.6)),
                              )),
                        ]),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pushNamed(context, '/signUpPage');
                            },
                            style:
                                supprotusButtonStyle(const Color(0xff54c9a8)),
                            child: const Text('회원가입',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (emailController.text.isNotEmpty &&
                                  passwordController.text.isNotEmpty) {
                                fetchLogin().then((value) async {

                                  if (value == "ID를 확인하세요.") {
                                    await showCustomDialog(
                                        context, "이메일을 확인하세요.",
                                        buttonText: "확인");
                                  } else if (value == "PW를 확인하세요.") {
                                    await showCustomDialog(
                                        context, "패스워드를 확인하세요.",
                                        buttonText: "확인");
                                  } else {
                                    final parsed = json.decode(value);
                                    Provider.of<UserProvider>(context, listen: false).changeUser(User.fromJson(parsed));
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/Main',
                                        (Route<dynamic> route) => false);
                                  }
                                });
                                // Navigator.pushNamedAndRemoveUntil(
                                //             context,
                                //             '/Main',
                                //             (Route<dynamic> route) => false);
                              } else {
                                await showCustomDialog(
                                    context, "이메일, 패스워드를 입력해주세요.",
                                    buttonText: "확인");
                              }
                            },
                            style:
                                supprotusButtonStyle(const Color(0xff3ca789)),
                            child: const Text('로그인',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.tight,
                flex: 1,
                child: Opacity(
                  opacity: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'SNS  간편 로그인',
                        style: TextStyle(
                          color: Color(0xff484848),
                          fontSize: 16,
                          fontFamily: 'NotoSansKR',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //       left: 50, top: 10, right: 50, bottom: 10),
                      //   child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //       children: [
                      //         Image.asset('images/102.png'),
                      //         Image.asset('images/103.png'),
                      //         Image.asset('images/104.png'),
                      //         Image.asset('images/105.png'),
                      //       ]),
                      // ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
} //로그인 화면(완료)

/// This is the stateful widget that the main application instantiates.
class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({Key? key}) : super(key: key);

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Checkbox(
      checkColor: Colors.white,
      fillColor: MaterialStateProperty.resolveWith(getColor),
      value: isChecked,
      onChanged: (bool? value) {
        setState(() {
          isChecked = value!;
        });
      },
    );
  }
}
