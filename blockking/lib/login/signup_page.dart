import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../style/style.dart';
import '../widget/app_bar.dart';
import '../widget/dialog.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';
import 'package:crypto/crypto.dart';

enum Role { manager, validation, buyer, seller }

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late FocusNode emailNode;
  late FocusNode nameNode;
  late FocusNode phoneNode;
  late FocusNode addressNode;
  late FocusNode birthNode;
  late FocusNode roleNode;
  late FocusNode passwordNode;
  late FocusNode passwordCheckNode;
  late FocusNode otpNode;

  var idController = TextEditingController();
  var nameController = TextEditingController();
  var mobileController = TextEditingController();
  var addressController = TextEditingController();
  var birthController = TextEditingController();
  var roleController = TextEditingController();
  var passwordController = TextEditingController();
  var passwordReController = TextEditingController();
  var otpController = TextEditingController();

  String userID = '';
  String userName = '';
  String userPhone = '';
  String userAddress = '';
  String userBirth = '';
  String userRole = '';
  String userPassword = '';
  String userPasswordCheck = '';

  bool checkid = false; //id 중복체크 여부
  bool idReadonly = false; // 아이디 텍스트폼필드 비활성화용
  bool privacyReadonly = false; // 개인정보 텍스트폼필드 비활성화용
  bool _visibility = false;
  bool _snsvisibility = false;

  bool authOk = false;
  bool requestedAuth = false;
  String verificationId = '';
  bool verifiedOK = true;

  late ScrollController _scrollController;

  Role _role = Role.seller;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    emailNode = FocusNode();
    nameNode = FocusNode();
    phoneNode = FocusNode();
    addressNode = FocusNode();
    birthNode = FocusNode();
    roleNode = FocusNode();
    passwordNode = FocusNode();
    passwordCheckNode = FocusNode();
    otpNode = FocusNode();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
    emailNode.dispose();
    nameNode.dispose();
    phoneNode.dispose();
    addressNode.dispose();
    birthNode.dispose();
    roleNode.dispose();
    passwordNode.dispose();
    passwordCheckNode.dispose();
    otpNode.dispose();
  }

  Future genRandomPassword() async {
    var random = Random();
    //무조건 들어갈 문자종류(문자,숫자,특수기호)의 위치를 기억할 리스트
    var leastCharacterIndex = [];
    var skipCharacter = [0x2B, 0x2D, 0x20]; // '+', '-', ' ' 사용하지 않을 아스키 문자
    var min = 0x21; //start ascii  사용할 아스키 문자의 시작
    var max = 0x7A; //end ascii    사용할 아스키 문자의 끝
    var dat = []; //비밀번호 저장용 리스트
    while (dat.length <= 32) {
      //무작위로 32개를 생성한다
      var tmp = min + random.nextInt(max - min); //랜덤으로 아스키값 받기
      if (skipCharacter.contains(tmp)) {
        //사용하지 않을 아스키 문자인지 확인
        //print('skip ascii code $tmp.');
        continue;
      }
      //dat 리스트에 추가
      dat.add(tmp);
    }

    //최소한 1개는 숫자, 문자, 특수 기호를 넣기 위해 랜덤하게 3개의 위치를 얻는다.
    while (leastCharacterIndex.length < 3) {
      //총 3개의 랜덤 위치
      var ran = random.nextInt(32); //위치로 사용하기 위해 0 - 31까지의 램덤 번호 얻기
      if (!leastCharacterIndex.contains(ran)) {
        //이미 등록된 위치 번호가 아닐때만 추가
        leastCharacterIndex.add(ran);
      }
    }
    //각 랜덤 위치에 포함되야할 문자 추가
    dat[leastCharacterIndex[0]] = 0x32; // '2'
    dat[leastCharacterIndex[1]] = 0x61; // 'a'
    dat[leastCharacterIndex[2]] = 0x40; // '@'
    return String.fromCharCodes(dat.cast<int>());
  }

  Future<String> fetchRegister(id) async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'name': userName,
      'email': userID,
      'password': userPassword,
      'phone': userPhone,
      'address': userAddress,
      'role': (_role.index + 1).toString(),
      'birth': userBirth,
      'id': id.toString()
    };
    final response =
        await http.get(Uri.http(url, '/register', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> fetchRegisterBlock() async {
    String url = '14.49.119.248:8080';
    final queryParameters = {
      'org': (_role.index + 1).toString(),
      'owner': userID,
      // 'walletid': id.toString()
    };
    final response =
        await http.get(Uri.http(url, '/CreateWallet', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> fetchCheckEmail() async {
    String url = '52.8.145.104:3000';
    final queryParameters = {'email': userID};
    final response =
        await http.get(Uri.http(url, '/existemail', queryParameters));

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
    ProgressDialog pd = ProgressDialog(context: context);

    AppBar appBar = baseAppBar('회원가입');

    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double appBarHeight = appBar.preferredSize.height;
    final logicalSize = MediaQuery.of(context).size;
    final double _height = logicalSize.height - statusBarHeight - appBarHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(20, 30.h, 20, 50.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Form(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '이메일 입력',
                        style: getLoginTextStyle(),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //아이디 입력 텍스트폼필드 key 1
                          readOnly: idReadonly,
                          focusNode: emailNode,
                          autofocus: true,
                          onChanged: (value) {
                            userID = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: idController,
                          decoration: getInputDeco('이메일 입력'),
                          keyboardType: TextInputType.emailAddress,
                          onTap: () {
                            _scrollController.animateTo(50.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              //중복체크버튼
                              onPressed: () async {
                                if (idController.value.text.isEmpty) {
                                  await showCustomDialog(context, "이메일을 입력해주세요",
                                      buttonText: "확인");
                                } else {
                                  fetchCheckEmail().then((value) async {
                                    if (value == 'true') {
                                      setState(() {
                                        checkid = true;
                                        idReadonly = true;
                                      });
                                      await showCustomDialog(
                                          context, "사용가능한 이메일입니다.",
                                          buttonText: "확인");
                                      FocusScope.of(context)
                                          .requestFocus(nameNode);
                                      _scrollController.animateTo(120.h,
                                          duration:
                                              const Duration(milliseconds: 500),
                                          curve: Curves.ease);
                                    } else {
                                      await showCustomDialog(
                                          context, "중복되는 이메일이 있습니다.",
                                          buttonText: "확인");
                                    }
                                  });
                                }
                              },
                              style:
                                  supprotusButtonStyle(const Color(0xff626262)),
                              child: const Text('중복체크',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Text(
                        '개인정보 입력',
                        style: getLoginTextStyle(),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //이름 입력 key 2
                          focusNode: nameNode,
                          readOnly: privacyReadonly,
                          onChanged: (value) {
                            userName = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(phoneNode);
                            _scrollController.animateTo(140.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          decoration: getInputDeco('이름 입력'),
                          onTap: () async {
                            if (!checkid) {
                              await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                                  buttonText: "확인");
                              FocusScope.of(context).requestFocus(emailNode);
                            }
                            _scrollController.animateTo(120.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                        child: Row(
                          children: [
                            Flexible(
                              flex: 21,
                              child: TextFormField(
                                //연락처 입력 key3
                                focusNode: phoneNode,
                                readOnly: privacyReadonly,
                                onChanged: (value) {
                                  //값이 바뀌면 변수에 저장
                                  userPhone = value;
                                },
                                cursorColor: const Color(0xffe2eef0),
                                style: getTextfieldFontSize(),
                                controller: mobileController,
                                decoration: getInputDeco('‘-’없이 연락처를 입력해주세요.'),
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.phone,
                                onTap: () async {
                                  if (!checkid) {
                                    await showCustomDialog(
                                        context, "이메일을 먼저 입력해주세요",
                                        buttonText: "확인");
                                    FocusScope.of(context)
                                        .requestFocus(emailNode);
                                  }
                                  _scrollController.animateTo(140.h,
                                      duration:
                                          const Duration(milliseconds: 500),
                                      curve: Curves.ease);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 9.h),
                      Visibility(
                        visible: _visibility,
                        child: SizedBox(
                          height: 46.h,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 21,
                                child: TextFormField(
                                  //otp 받는곳
                                  focusNode: otpNode,
                                  onChanged: (value) {
                                    //값이 바뀌면 변수에 저장
                                    userPhone = value;
                                  },
                                  cursorColor: const Color(0xffe2eef0),
                                  style: getTextfieldFontSize(),
                                  controller: otpController,
                                  decoration: getInputDeco('인증번호 6자리 입력해주세요'),
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.phone,
                                  onTap: () async {
                                    if (!checkid) {
                                      await showCustomDialog(
                                          context, "이메일을 먼저 입력해주세요",
                                          buttonText: "확인");
                                      FocusScope.of(context)
                                          .requestFocus(emailNode);
                                    }
                                    _scrollController.animateTo(140.h,
                                        duration:
                                            const Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                              Flexible(
                                flex: 6,
                                child: RawMaterialButton(
                                    fillColor: const Color(0xff626262),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    elevation: 2.0,
                                    child: const Center(
                                      child: Text('확인',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.white)),
                                    ),
                                    onPressed: () async {}),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //주소 입력 key
                          focusNode: addressNode,
                          onChanged: (value) {
                            userAddress = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: addressController,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(birthNode);
                            _scrollController.animateTo(250.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          decoration: getInputDeco('주소 입력'),
                          onTap: () async {
                            if (!checkid) {
                              await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                                  buttonText: "확인");
                              FocusScope.of(context).requestFocus(emailNode);
                            }
                            _scrollController.animateTo(200.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //생년월일 입력 key 2
                          focusNode: birthNode,
                          onChanged: (value) {
                            userBirth = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: birthController,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(roleNode);
                            _scrollController.animateTo(290.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          decoration: getInputDeco('생년월일 입력'),
                          onTap: () async {
                            if (!checkid) {
                              await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                                  buttonText: "확인");
                              FocusScope.of(context).requestFocus(emailNode);
                            }
                            _scrollController.animateTo(250.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 18.h,
                      ),
                      Text(
                        '역할 선택',
                        style: getLoginTextStyle(),
                      ),
                      SizedBox(
                        height: 45.h,
                        child: Row(
                          children: [
                            Expanded(
                              child: ListTile(
                                title: const Text('농부'),
                                leading: Radio<Role>(
                                  value: Role.seller,
                                  groupValue: _role,
                                  onChanged: (Role? value) {
                                    setState(() {
                                      _role = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListTile(
                                title: const Text('산지유통인'),
                                leading: Radio<Role>(
                                  value: Role.buyer,
                                  groupValue: _role,
                                  onChanged: (Role? value) {
                                    setState(() {
                                      _role = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        // child: TextFormField(
                        //   //역할 입력 key 2
                        //   focusNode: roleNode,
                        //   readOnly: privacyReadonly,
                        //   onChanged: (value) {
                        //     userRole = value;
                        //   },
                        //   cursorColor: const Color(0xffe2eef0),
                        //   style: getTextfieldFontSize(),
                        //   controller: roleController,
                        //   textInputAction: TextInputAction.next,
                        //   onFieldSubmitted: (_) {
                        //     FocusScope.of(context).requestFocus(passwordNode);
                        //     _scrollController.animateTo(290.h,
                        //         duration: const Duration(milliseconds: 500),
                        //         curve: Curves.ease);
                        //   },
                        //   decoration: getInputDeco('역할 입력'),
                        //   onTap: () async {
                        //     if (!checkid) {
                        //       await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                        //           buttonText: "확인");
                        //       FocusScope.of(context).requestFocus(passwordNode);
                        //     }
                        //     _scrollController.animateTo(290.h,
                        //         duration: const Duration(milliseconds: 500),
                        //         curve: Curves.ease);
                        //   },
                        // ),
                      ),
                      SizedBox(
                        height: 18.h,
                      ),
                      Text(
                        '비밀번호 입력',
                        style: getLoginTextStyle(),
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //비밀번호 입력 key 4
                          focusNode: passwordNode,
                          onChanged: (value) {
                            userPassword = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(passwordCheckNode);
                            _scrollController.animateTo(290.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                          decoration: getInputDeco('비밀번호 입력'),
                          onTap: () async {
                            if (!checkid) {
                              await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                                  buttonText: "확인");
                              FocusScope.of(context).requestFocus(emailNode);
                            }
                            _scrollController.animateTo(290.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(
                        height: 45.h,
                        child: TextFormField(
                          //비번 확인 key5
                          focusNode: passwordCheckNode,
                          onChanged: (value) {
                            userPasswordCheck = value;
                          },
                          cursorColor: const Color(0xffe2eef0),
                          style: getTextfieldFontSize(),
                          controller: passwordReController,
                          decoration: getInputDeco('비밀번호 확인'),
                          obscureText: true,
                          textInputAction: TextInputAction.done,

                          onTap: () async {
                            if (!checkid) {
                              await showCustomDialog(context, "이메일을 먼저 입력해주세요",
                                  buttonText: "확인");
                              FocusScope.of(context).requestFocus(emailNode);
                            }
                            _scrollController.animateTo(290.h,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease);
                          },
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (userID.isNotEmpty &&
                                    userName.isNotEmpty &&
                                    userPhone.isNotEmpty &&
                                    userAddress.isNotEmpty &&
                                    userBirth.isNotEmpty &&
                                    userPassword.isNotEmpty &&
                                    userPasswordCheck.isNotEmpty) {
                                  if (userPassword == userPasswordCheck) {
                                    // var id = await genRandomPassword();

                                    // var bytes = utf8.encode(userID);
                                    // var id = sha256.convert(bytes);

                                    pd.show(max: 100, msg: "회원가입..지갑생성중..");
                                    //하이퍼레저
                                    fetchRegisterBlock().then((value) async {
                                      print(value);
                                      if (value.length == 64) {
                                        fetchRegister(value).then((value1) async {
                                          pd.close();
                                          if (value1 == 'true') {
                                            await showCustomDialog(
                                                    context, "회원가입이 완료되었습니다.\n$value",
                                                    buttonText: "확인")
                                                .then((value) =>
                                                    Navigator.pop(context));
                                          }else {
                                            await showCustomDialog(context, value1,
                                                buttonText: "확인")
                                                .then((value) =>
                                                Navigator.pop(context));
                                          }
                                        });
                                      } else {
                                        pd.close();
                                        await showCustomDialog(context, value,
                                                buttonText: "확인")
                                            .then((value) =>
                                                Navigator.pop(context));
                                      }
                                    });
                                    // fetchRegister(id).then((value) async {
                                    //   if (value == 'true') {
                                    //     pd.close();
                                    //     await showCustomDialog(
                                    //             context, "회원가입이 완료되었습니다.",
                                    //             buttonText: "확인")
                                    //         .then((value) =>
                                    //             Navigator.pop(context));
                                    //
                                    //     //하이퍼레저
                                    //     // fetchRegisterBlock(id).then((value) async
                                    //     // {
                                    //     //   print(value);
                                    //     //   if(value == 'true'){
                                    //     //     await showCustomDialog(
                                    //     //         context, "회원가입이 완료되었습니다.",
                                    //     //         buttonText: "확인")
                                    //     //         .then((value) =>
                                    //     //         Navigator.pop(context));
                                    //     //   }else{
                                    //     //     await showCustomDialog(
                                    //     //         context, value,
                                    //     //         buttonText: "확인")
                                    //     //         .then((value) =>
                                    //     //         Navigator.pop(context));
                                    //     //   }
                                    //     // })
                                    //   }
                                    // });
                                  } else {
                                    await showCustomDialog(
                                        context, "비밀번호를 다시 확인해주세요",
                                        buttonText: "확인");
                                  }
                                } else {
                                  await showCustomDialog(
                                      context, "빈 칸을 모두 입력해주세요",
                                      buttonText: "확인");
                                }
                              },
                              style:
                                  supprotusButtonStyle(const Color(0xff54c9a8)),
                              child: const Text('회원가입 완료',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
