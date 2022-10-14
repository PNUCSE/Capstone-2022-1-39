import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../provider/user_provider.dart';
import '../../style/style.dart';
import '../../widget/app_bar.dart';
import '../../widget/dialog.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:sn_progress_dialog/sn_progress_dialog.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  var titleController = TextEditingController();
  var kindController = TextEditingController();
  var typeController = TextEditingController();
  var areaController = TextEditingController();
  var locationController = TextEditingController();
  var methodController = TextEditingController();
  var departureDateController = TextEditingController();
  var priceController = TextEditingController();
  var gapController = TextEditingController();

  late ScrollController _scrollController;

  bool GAP = false;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  String getToday() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    var strToday = formatter.format(now);
    return strToday;
  }

  Future<String> fetchRegistration(assetID, userId) async {
    // var key = await genRandomPassword();

    String url = '52.8.145.104:3000';
    final queryParameters = {
      'id': assetID,
      'title': titleController.text,
      'kind': kindController.text,
      'type': typeController.text,
      'area': areaController.text,
      'location': locationController.text,
      'method': methodController.text,
      'departureDate': departureDateController.text,
      'price': priceController.text,
      'date': getToday().toString(),
      'userId': userId,
      'totalPrice': int.tryParse(areaController.text) == null ||
              int.tryParse(priceController.text) == null
          ? '0'
          : (int.parse(areaController.text) * int.parse(priceController.text))
              .toString(),
    };
    final response =
        await http.get(Uri.http(url, '/registration', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> fetchRegistrationBlock(userId, org) async {
    String url = '14.49.119.248:8080';
    final queryParameters = {
      'org': org,
      'owner': userId,
      'price': priceController.text,
      'totalprice': int.tryParse(areaController.text) == null ||
              int.tryParse(priceController.text) == null
          ? '0'
          : (int.parse(areaController.text) * int.parse(priceController.text))
              .toString(),
      'area': areaController.text,
      'location': locationController.text,
      'category': typeController.text,
      'kind': kindController.text,
    };
    final response =
        await http.get(Uri.http(url, '/CreateAsset', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> fetchGAPBlock(org,name) async {
    String url = '14.49.119.248:8080';
    final queryParameters = {
      'org': org.toString(),
      'gapnum': gapController.text,
      'name': name.toString(),
      'kind': kindController.text,
      'location': locationController.text,
      'area': areaController.text,
    };
    final response =
    await http.get(Uri.http(url, '/GapExists', queryParameters));

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
    var org = Provider.of<UserProvider>(context, listen: false).user.role;
    var name = Provider.of<UserProvider>(context, listen: false).user.name;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: baseAppBar('판매 등록'),
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
                          '제목',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: titleController,
                            decoration: getInputDeco('제목 입력'),
                            keyboardType: TextInputType.text,
                            onTap: () {
                              _scrollController.animateTo(1.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '품종명',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: kindController,
                            decoration: getInputDeco('품종명 입력'),
                            keyboardType: TextInputType.text,
                            onTap: () {
                              _scrollController.animateTo(10.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '종류',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: typeController,
                            decoration: getInputDeco(
                                '종류 입력(채소류, 양념채소류, 잡곡류, 기호과채류, 기타)'),
                            keyboardType: TextInputType.text,
                            onTap: () {
                              _scrollController.animateTo(80.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '면적',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: areaController,
                            decoration: getInputDeco('면적 입력(평수)'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onTap: () {
                              _scrollController.animateTo(150.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '소재지',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: locationController,
                            decoration: getInputDeco('소재지 입력(주소)'),
                            keyboardType: TextInputType.streetAddress,
                            onTap: () {
                              _scrollController.animateTo(220.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '재배방식',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: methodController,
                            decoration: getInputDeco('재배방식 입력(저농약, 관행...)'),
                            keyboardType: TextInputType.text,
                            onTap: () {
                              _scrollController.animateTo(280.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '최종출거일',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: departureDateController,
                            decoration: getInputDeco('최종출거일'),
                            keyboardType: TextInputType.datetime,
                            onTap: () {
                              _scrollController.animateTo(350.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '평당 가격',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: TextFormField(
                            autofocus: true,
                            cursorColor: const Color(0xffe2eef0),
                            style: getTextfieldFontSize(),
                            controller: priceController,
                            decoration: getInputDeco('평당 가격 입력'),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onTap: () {
                              _scrollController.animateTo(350.h,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.ease);
                            },
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          'Gap 인증',
                          style: getLoginTextStyle(),
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          height: 45.h,
                          child: Row(
                            children: [
                              Flexible(
                                child: TextFormField(
                                  autofocus: true,
                                  cursorColor: const Color(0xffe2eef0),
                                  style: getTextfieldFontSize(),
                                  controller: gapController,
                                  decoration: getInputDeco('Gap 인증 코드 입력'),
                                  keyboardType: TextInputType.text,
                                  onTap: () {
                                    _scrollController.animateTo(350.h,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.ease);
                                  },
                                ),
                              ),
                              SizedBox(width: 7.w,),
                              ElevatedButton(
                                style: supprotusButtonStyle(
                                    Colors.grey),
                                onPressed: () async {
                                  if (titleController.text.isEmpty ||
                                      kindController.text.isEmpty ||
                                      typeController.text.isEmpty ||
                                      areaController.text.isEmpty ||
                                      locationController.text.isEmpty ||
                                      methodController.text.isEmpty ||
                                      departureDateController.text.isEmpty ||
                                      priceController.text.isEmpty) {
                                    await showCustomDialog(
                                        context, "빈 칸을 모두 입력해주세요",
                                        buttonText: "확인");
                                    return;
                                  }
                                  if(GAP){
                                    await showCustomDialog(
                                        context, "인증된 매물입니다.",
                                        buttonText: "확인");
                                    return;
                                  }
                                  fetchGAPBlock(org,name).then((value) async {
                                    if(value.toString() == 'true'){
                                      GAP = true;
                                      await showCustomDialog(
                                          context, "인증에 성공하였습니다",
                                          buttonText: "확인");
                                    }else{
                                      await showCustomDialog(
                                          context, "인증에 실패하였습니다",
                                          buttonText: "확인");
                                    }
                                  });
                                },
                                child: const Text('인증',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 9.h),
                        Text(
                          '총 매매가 : ${int.tryParse(areaController.text) == null || int.tryParse(priceController.text) == null ? 0 : int.parse(areaController.text) * int.parse(priceController.text)} 원 ',
                          style: const TextStyle(
                              color: Color(0xff54c9a8),
                              fontWeight: FontWeight.bold,
                              fontFamily: "NotoSansKR",
                              fontStyle: FontStyle.normal,
                              fontSize: 20.0),
                        ),
                        SizedBox(height: 9.h),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if(!GAP){
                                    await showCustomDialog(
                                        context, "Gap 인증을 진행해주세요",
                                        buttonText: "확인");
                                    return ;
                                  }
                                  if (titleController.text.isEmpty ||
                                      kindController.text.isEmpty ||
                                      typeController.text.isEmpty ||
                                      areaController.text.isEmpty ||
                                      locationController.text.isEmpty ||
                                      methodController.text.isEmpty ||
                                      departureDateController.text.isEmpty ||
                                      priceController.text.isEmpty) {
                                    await showCustomDialog(
                                        context, "빈 칸을 모두 입력해주세요",
                                        buttonText: "확인");
                                    return;
                                  }
                                  print(titleController.text +
                                      kindController.text +
                                      typeController.text +
                                      areaController.text +
                                      locationController.text +
                                      methodController.text +
                                      departureDateController.text +
                                      priceController.text);
                                  var userId = Provider.of<UserProvider>(
                                          context,
                                          listen: false)
                                      .user
                                      .email;

                                  pd.show(
                                      max: 100,
                                      msg: "상품 등록중..");

                                  fetchRegistrationBlock(userId, org)
                                      .then((value) async {
                                    print(value);
                                    fetchRegistration(value, userId)
                                        .then((value1) async {
                                      pd.close();
                                      if (value1 == 'true') {
                                        await showCustomDialog(
                                                context, "상품 등록이 완료되었습니다.\n$value",
                                                buttonText: "확인")
                                            .then((value) =>
                                                Navigator.pop(context));
                                      } else {
                                        await showCustomDialog(
                                                context, "상품 등록에 실패하였습니다.",
                                                buttonText: "확인")
                                            .then((value) =>
                                                Navigator.pop(context));
                                      }
                                    });
                                  });
                                },
                                style: supprotusButtonStyle(
                                    const Color(0xff54c9a8)),
                                child: const Text('판매 등록',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ))
                  ]),
            )),
      ),
    );
  }
}
