import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../provider/navigator_provider.dart';
import '../../provider/user_provider.dart';
import '../../util/agriculturalProduct.dart';
import '../../util/user.dart';
import '../../widget/app_bar.dart';
import '../../widget/dialog.dart';

class Contract extends StatefulWidget {
  const Contract({Key? key}) : super(key: key);

  @override
  State<Contract> createState() => _ContractState();
}

class _ContractState extends State<Contract> with TickerProviderStateMixin{
  final choices = ['전체', '채소류', '양념채소류', '잡곡류', '기호과채류', '기타'];
  var index = 0; //test
  late TabController _tabController;

  late Future<List<AgriculturalProducts>> agriculturalProducts;

  Future<List<AgriculturalProducts>> _init(org, tabIndex) async {
    _tabController.animateTo(tabIndex);
    // Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(0);

    String url = '52.8.145.104:3000';
    String blockUrl = '14.49.119.248:8080';

    final queryParameters = {
      'org': org,
    };

    final response = await http.get(Uri.http(url, '/getAllProducts'));
    final blockResponse =
        await http.get(Uri.http(blockUrl, '/GetAllAssets', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      List<dynamic> body = json.decode(response.body);
      List<AgriculturalProducts> agriculturalProducts = body
          .map((dynamic item) => AgriculturalProducts.fromJson(item))
          .toList();

      //check !!
      if (blockResponse.statusCode == 200) {
        print(blockResponse.body.toString());
        if (blockResponse.body.toString() !=
            "SyntaxError: Unexpected end of JSON input") {
          List<dynamic> blockBody = json.decode(blockResponse.body);

          blockBody.forEach((element) {
            if (!element["description"]) {
              agriculturalProducts.forEach((product) {
                if (product.id == element["id"]) {
                  product.onSale = false;
                  print('팔림');
                }
              });
            }
          });
        }
      }
      return agriculturalProducts;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> IsTransactionRequest(assetId) async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'id': assetId.toString()
    };
    final response = await http.get(Uri.http(url, '/isTransactionRequest', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> transactionRequest(assetId,fromId,toId) async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'assetId': assetId.toString(),
      'fromId': fromId.toString(),
      'toId': toId.toString(),
      'agree': 'false',
      'balance': 'false',
    };
    final response = await http.get(Uri.http(url, '/transactionRequest', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<String> transferTokenBlock(org, fromID, toID, value) async {
    String blockUrl = '14.49.119.248:8080';
    final queryParameters = {
      'org': org.toString(),
      'client': fromID.toString(),
      'recipient': toID.toString(),
      'value': value.toString(),
    };
    final response = await http.get(Uri.http(blockUrl, '/TransferToken', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      print(response.body);
      return response.body;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  Future<User> getUserInfo(id) async {
    String url = '52.8.145.104:3000';
    final queryParameters = {
      'id': id.toString(),
    };
    final response = await http.get(Uri.http(url, '/getUserInfo', queryParameters));

    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      final parsed = json.decode(response.body);
      var user = User.fromJson(parsed);


      return user;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }

  @override
  void initState() {
    _tabController = TabController(
      initialIndex: 0,
      length: 6,
      vsync: this,  //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );
    super.initState();

    // agriculturalProducts = _init(org);
  }

  @override
  Widget build(BuildContext context) {
    var org = Provider.of<UserProvider>(context, listen: false).user.role;
    var userId = Provider.of<UserProvider>(context, listen: false).user.id;
    var userName = Provider.of<UserProvider>(context, listen: false).user.name;
    var userBirth = Provider.of<UserProvider>(context, listen: false).user.birth;
    var userAddress = Provider.of<UserProvider>(context, listen: false).user.address;
    var userPhone = Provider.of<UserProvider>(context, listen: false).user.phone;

    var tabIndex = Provider.of<NavigatorProvider>(context, listen: false).tabIndex;
    ProgressDialog pd = ProgressDialog(context: context);

    return DefaultTabController(
        length: choices.length,
        child: Scaffold(
          backgroundColor: const Color(0x99f7fbfc),
          appBar: baseAppBar('매매'),
          floatingActionButton: (org == '4')
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                  backgroundColor: const Color(0xff54c9a8),
                  child: const Icon(Icons.add),
                )
              : null,
          body: FutureBuilder(
              future: _init(org,tabIndex),
              //_init
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: Color(0xff54c9a8),
                  ));
                } else {
                  return Center(
                    child: Column(
                      children: [
                        Container(
                          decoration: const BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color(0xffe2eef0),
                                offset: Offset(0, 3),
                                blurRadius: 6,
                                spreadRadius: 0)
                          ], color: Color(0xffffffff)),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 40.h,
                                child: TabBar(
                                  controller: _tabController,
                                  onTap: (idx) {
                                    setState(() {
                                      Provider.of<NavigatorProvider>(context, listen: false).changeTabIndex(idx);

                                      index = idx;
                                    });
                                  },
                                  tabs: choices.map((String choice) {
                                    return Tab(text: choice);
                                  }).toList(),
                                  isScrollable: true,
                                  unselectedLabelColor: const Color(0xff313131),
                                  indicatorColor: const Color(0xff54c9a8),
                                  labelColor:
                                      const Color(0xff54c9a8), // 많으면 자동 스크롤
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                              left: 15.w,
                                              top: 11.h,
                                              right: 15.w,
                                              bottom: 2.h),
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              primary: const Color(0x99f7fbfc),
                                              elevation: 0.0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(19.0),
                                              ),
                                            ),
                                            child: Container(
                                              height: 133.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(19.0),
                                                color: Colors.white,
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Color(0xffe2eef0),
                                                      offset: Offset(0, 3),
                                                      blurRadius: 6,
                                                      spreadRadius: 0)
                                                ],
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 12.w,
                                                    top: 7.h,
                                                    right: 12.w,
                                                    bottom: 13.h),
                                                child: Column(
                                                  children: [
                                                    Flexible(
                                                        flex: 64,
                                                        fit: FlexFit.tight,
                                                        child: Row(
                                                          children: [
                                                            Image.asset(
                                                              'images/main_img_3.png',
                                                              width: 40.h,
                                                              height: 40.h,
                                                              fit: BoxFit.fill,
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        left: 15
                                                                            .w),
                                                                    child:
                                                                        Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          snapshot
                                                                              .data[index]
                                                                              .title,
                                                                          style: TextStyle(
                                                                              color: const Color(0xff313131),
                                                                              fontWeight: FontWeight.w400,
                                                                              fontFamily: "NotoSansKR",
                                                                              fontStyle: FontStyle.normal,
                                                                              fontSize: 16.sp),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5.h,
                                                                        ),
                                                                        Text(
                                                                          '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                          style: TextStyle(
                                                                              color: const Color(0xff797979),
                                                                              fontWeight: FontWeight.w400,
                                                                              fontFamily: "NotoSansKR",
                                                                              fontStyle: FontStyle.normal,
                                                                              fontSize: 13.sp),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  (org == '3')?
                                                                  ElevatedButton(
                                                                    style: ElevatedButton.styleFrom(
                                                                      primary:
                                                                          const Color(
                                                                              0xff54c9a8),
                                                                      onPrimary: Colors.white,
                                                                    ),
                                                                    onPressed: () async {
                                                                      // /////////////////구매요청//////////////////////
                                                                      var bytes = utf8.encode(snapshot.data[index].userId);
                                                                      var fromId = sha256.convert(bytes);

                                                                      // print(fromId);
                                                                      // print(snapshot.data[index].id);
                                                                      // print(userId);
                                                                      // print(snapshot.data[index].totalPrice);
                                                                      // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                      await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                        print(value);
                                                                        if(value == 'true'){
                                                                          await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                                      buttonText: "확인");
                                                                        }else{
                                                                          getUserInfo(fromId).then((value) {
                                                                            showDialog(
                                                                                context: context,
                                                                                barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                                builder: (BuildContext context) {
                                                                                  return AlertDialog(
                                                                                    title: const Text('구매 요청'),
                                                                                    content: SingleChildScrollView(
                                                                                      child: ListBody(
                                                                                        children: <Widget>[
                                                                                          const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                              color:  Color(0xff222222),
                                                                                              fontWeight: FontWeight.w500,
                                                                                              fontFamily: "NotoSansKR",
                                                                                              fontStyle:  FontStyle.normal,
                                                                                              fontSize: 16.0
                                                                                          ),)),
                                                                                          SizedBox(height: 20.h,),
                                                                                          const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                              style: TextStyle(
                                                                                                  fontSize: 18.0,
                                                                                                  fontWeight: FontWeight.w300),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 20.h,),
                                                                                          Row(
                                                                                            children: [
                                                                                              const Text('매도인(갑)'),
                                                                                              SizedBox(width: 20.w,),
                                                                                              Expanded(
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text("성명 : ${value.name}"),
                                                                                                    Text("생년월일 : ${value.birth}"),
                                                                                                    Text("구매자 주소 : ${value.address}"),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(height: 10.h,),
                                                                                          Row(
                                                                                            children: [
                                                                                              const Text('매수인(을)'),
                                                                                              SizedBox(width: 20.w,),
                                                                                              Expanded(
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text("성명 : $userName"),
                                                                                                    Text("생년월일 : $userBirth"),
                                                                                                    Text("구매자 주소 : $userAddress"),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(height: 20.h,),
                                                                                          Text("소재지 : ${snapshot.data[index].location}"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Row(
                                                                                            children: [
                                                                                              Text("품목 : ${snapshot.data[index].kind}"),
                                                                                              SizedBox(width: 40.w,),
                                                                                              Text("품종 : ${snapshot.data[index].type}"),
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          const Text("계약일 : --"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                          SizedBox(height: 20.h,),
                                                                                          Text("갑의 연락처 : ${value.phone}"),
                                                                                          SizedBox(height: 5.h,),
                                                                                          Text("을의 연락처 : $userPhone"),
                                                                                          SizedBox(height: 20.h,),
                                                                                          const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.w300),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 20.h,),
                                                                                          const Divider(),
                                                                                          const Text('제1조(매매대금)'),
                                                                                          const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제2조 (계약금)'),
                                                                                          const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제3조 (목적물의 확인)'),
                                                                                          const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                          const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제5조 (목적물의 관리)'),
                                                                                          const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제6조 (목적물의 반출)'),
                                                                                          const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제7조 (위험부담)'),
                                                                                          const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제8조 (담보책임)'),
                                                                                          const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제9조 (계약해제)'),
                                                                                          const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                          const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제11조 (통지방법)'),
                                                                                          const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제12조 (위약금)'),
                                                                                          const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),
                                                                                          SizedBox(height: 10.h,),
                                                                                          const Text('제13조 (관할법원)'),
                                                                                          const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                              style: TextStyle(
                                                                                                  fontSize: 11.0,
                                                                                                  fontWeight: FontWeight.bold),
                                                                                              textAlign: TextAlign.justify),


                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    actions: <Widget>[FlatButton(
                                                                                        child: const Text('계약금 전송'),
                                                                                        onPressed: () async {
                                                                                          //////////////////////
                                                                                          var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                          print(price);
                                                                                          pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                          await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                            print("하이퍼");
                                                                                            print(value);
                                                                                            if(value.isEmpty){
                                                                                              await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                                pd.close();
                                                                                                if (value == 'true') {
                                                                                                  await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                                      buttonText: "확인");
                                                                                                }else{
                                                                                                  await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                                      buttonText: "확인");
                                                                                                }
                                                                                              });
                                                                                            }else{
                                                                                              pd.close();
                                                                                              await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                                  buttonText: "확인");
                                                                                            }
                                                                                            // pd.close();
                                                                                          });

                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      ),

                                                                                      FlatButton(
                                                                                        child: const Text('cancel'),
                                                                                        onPressed:() {
                                                                                          // 다이얼로그 닫기
                                                                                          Navigator.of(context).pop();
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                }
                                                                            );
                                                                            print(value.name);
                                                                          });
                                                                        }
                                                                      });

                                                                    },
                                                                    child: const Text('구매 요청'),
                                                                  ):SizedBox(),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                    SizedBox(
                                                      height: 3.h,
                                                    ),
                                                    Flexible(
                                                      flex: 50,
                                                      fit: FlexFit.tight,
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            7)),
                                                            color: Color(
                                                                0xfff7fbfc)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 5.w,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                      softWrap:
                                                                          true,
                                                                      style: TextStyle(
                                                                          color: const Color(
                                                                              0xff676767),
                                                                          fontWeight:
                                                                              FontWeight
                                                                                  .w400,
                                                                          fontFamily:
                                                                              "NotoSansKR",
                                                                          fontStyle:
                                                                              FontStyle
                                                                                  .normal,
                                                                          fontSize:
                                                                              13.sp),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 9.h,
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  SizedBox(
                                                                    width: 5.w,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                      softWrap:
                                                                      true,
                                                                      style: TextStyle(
                                                                          color: const Color(
                                                                              0xff676767),
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                          fontFamily:
                                                                          "NotoSansKR",
                                                                          fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                          fontSize:
                                                                          13.sp),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox();
                                }),
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale && snapshot.data[index].type == "채소류"
                                      ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 11.h,
                                        right: 15.w,
                                        bottom: 2.h),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        primary: const Color(0x99f7fbfc),
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                        ),
                                      ),
                                      child: Container(
                                        height: 133.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0xffe2eef0),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.w,
                                              top: 7.h,
                                              right: 12.w,
                                              bottom: 13.h),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  flex: 64,
                                                  fit: FlexFit.tight,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'images/main_img_3.png',
                                                        width: 40.h,
                                                        height: 40.h,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 15
                                                                      .w),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    snapshot
                                                                        .data[index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color: const Color(0xff313131),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 16.sp),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                    5.h,
                                                                  ),
                                                                  Text(
                                                                    '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                    style: TextStyle(
                                                                        color: const Color(0xff797979),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 13.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            (org == '3')?
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary:
                                                                const Color(
                                                                    0xff54c9a8),
                                                                onPrimary: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                // /////////////////구매요청//////////////////////
                                                                var bytes = utf8.encode(snapshot.data[index].userId);
                                                                var fromId = sha256.convert(bytes);

                                                                // print(fromId);
                                                                // print(snapshot.data[index].id);
                                                                // print(userId);
                                                                // print(snapshot.data[index].totalPrice);
                                                                // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                  print(value);
                                                                  if(value == 'true'){
                                                                    await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                        buttonText: "확인");
                                                                  }else{
                                                                    getUserInfo(fromId).then((value) {
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('구매 요청'),
                                                                              content: SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: <Widget>[
                                                                                    const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                        color:  Color(0xff222222),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontFamily: "NotoSansKR",
                                                                                        fontStyle:  FontStyle.normal,
                                                                                        fontSize: 16.0
                                                                                    ),)),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                        style: TextStyle(
                                                                                            fontSize: 18.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매도인(갑)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : ${value.name}"),
                                                                                              Text("생년월일 : ${value.birth}"),
                                                                                              Text("구매자 주소 : ${value.address}"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매수인(을)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : $userName"),
                                                                                              Text("생년월일 : $userBirth"),
                                                                                              Text("구매자 주소 : $userAddress"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("소재지 : ${snapshot.data[index].location}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("품목 : ${snapshot.data[index].kind}"),
                                                                                        SizedBox(width: 40.w,),
                                                                                        Text("품종 : ${snapshot.data[index].type}"),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    const Text("계약일 : --"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("갑의 연락처 : ${value.phone}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("을의 연락처 : $userPhone"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Divider(),
                                                                                    const Text('제1조(매매대금)'),
                                                                                    const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제2조 (계약금)'),
                                                                                    const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제3조 (목적물의 확인)'),
                                                                                    const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                    const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제5조 (목적물의 관리)'),
                                                                                    const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제6조 (목적물의 반출)'),
                                                                                    const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제7조 (위험부담)'),
                                                                                    const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제8조 (담보책임)'),
                                                                                    const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제9조 (계약해제)'),
                                                                                    const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                    const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제11조 (통지방법)'),
                                                                                    const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제12조 (위약금)'),
                                                                                    const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제13조 (관할법원)'),
                                                                                    const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),


                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[FlatButton(
                                                                                child: const Text('계약금 전송'),
                                                                                onPressed: () async {
                                                                                  //////////////////////
                                                                                  var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                  print(price);
                                                                                  pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                  await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                    print("하이퍼");
                                                                                    print(value);
                                                                                    if(value.isEmpty){
                                                                                      await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                        pd.close();
                                                                                        if (value == 'true') {
                                                                                          await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                              buttonText: "확인");
                                                                                        }else{
                                                                                          await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                              buttonText: "확인");
                                                                                        }
                                                                                      });
                                                                                    }else{
                                                                                      pd.close();
                                                                                      await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                          buttonText: "확인");
                                                                                    }
                                                                                    // pd.close();
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),

                                                                                FlatButton(
                                                                                  child: const Text('cancel'),
                                                                                  onPressed:() {
                                                                                    // 다이얼로그 닫기
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }
                                                                      );
                                                                      print(value.name);
                                                                    });
                                                                  }
                                                                });

                                                              },
                                                              child: const Text('구매 요청'),
                                                            ):SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 3.h,
                                              ),
                                              Flexible(
                                                flex: 50,
                                                fit: FlexFit.tight,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          7)),
                                                      color: Color(
                                                          0xfff7fbfc)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 9.h,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                }),
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale && snapshot.data[index].type == "양념채소류"
                                      ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 11.h,
                                        right: 15.w,
                                        bottom: 2.h),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        primary: const Color(0x99f7fbfc),
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                        ),
                                      ),
                                      child: Container(
                                        height: 133.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0xffe2eef0),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.w,
                                              top: 7.h,
                                              right: 12.w,
                                              bottom: 13.h),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  flex: 64,
                                                  fit: FlexFit.tight,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'images/main_img_3.png',
                                                        width: 40.h,
                                                        height: 40.h,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 15
                                                                      .w),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    snapshot
                                                                        .data[index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color: const Color(0xff313131),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 16.sp),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                    5.h,
                                                                  ),
                                                                  Text(
                                                                    '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                    style: TextStyle(
                                                                        color: const Color(0xff797979),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 13.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            (org == '3')?
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary:
                                                                const Color(
                                                                    0xff54c9a8),
                                                                onPrimary: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                // /////////////////구매요청//////////////////////
                                                                var bytes = utf8.encode(snapshot.data[index].userId);
                                                                var fromId = sha256.convert(bytes);

                                                                // print(fromId);
                                                                // print(snapshot.data[index].id);
                                                                // print(userId);
                                                                // print(snapshot.data[index].totalPrice);
                                                                // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                  print(value);
                                                                  if(value == 'true'){
                                                                    await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                        buttonText: "확인");
                                                                  }else{
                                                                    getUserInfo(fromId).then((value) {
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('구매 요청'),
                                                                              content: SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: <Widget>[
                                                                                    const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                        color:  Color(0xff222222),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontFamily: "NotoSansKR",
                                                                                        fontStyle:  FontStyle.normal,
                                                                                        fontSize: 16.0
                                                                                    ),)),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                        style: TextStyle(
                                                                                            fontSize: 18.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매도인(갑)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : ${value.name}"),
                                                                                              Text("생년월일 : ${value.birth}"),
                                                                                              Text("구매자 주소 : ${value.address}"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매수인(을)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : $userName"),
                                                                                              Text("생년월일 : $userBirth"),
                                                                                              Text("구매자 주소 : $userAddress"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("소재지 : ${snapshot.data[index].location}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("품목 : ${snapshot.data[index].kind}"),
                                                                                        SizedBox(width: 40.w,),
                                                                                        Text("품종 : ${snapshot.data[index].type}"),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    const Text("계약일 : --"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("갑의 연락처 : ${value.phone}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("을의 연락처 : $userPhone"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Divider(),
                                                                                    const Text('제1조(매매대금)'),
                                                                                    const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제2조 (계약금)'),
                                                                                    const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제3조 (목적물의 확인)'),
                                                                                    const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                    const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제5조 (목적물의 관리)'),
                                                                                    const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제6조 (목적물의 반출)'),
                                                                                    const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제7조 (위험부담)'),
                                                                                    const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제8조 (담보책임)'),
                                                                                    const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제9조 (계약해제)'),
                                                                                    const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                    const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제11조 (통지방법)'),
                                                                                    const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제12조 (위약금)'),
                                                                                    const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제13조 (관할법원)'),
                                                                                    const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),


                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[FlatButton(
                                                                                child: const Text('계약금 전송'),
                                                                                onPressed: () async {
                                                                                  //////////////////////
                                                                                  var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                  print(price);
                                                                                  pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                  await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                    print("하이퍼");
                                                                                    print(value);
                                                                                    if(value.isEmpty){
                                                                                      await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                        pd.close();
                                                                                        if (value == 'true') {
                                                                                          await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                              buttonText: "확인");
                                                                                        }else{
                                                                                          await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                              buttonText: "확인");
                                                                                        }
                                                                                      });
                                                                                    }else{
                                                                                      pd.close();
                                                                                      await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                          buttonText: "확인");
                                                                                    }
                                                                                    // pd.close();
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),

                                                                                FlatButton(
                                                                                  child: const Text('cancel'),
                                                                                  onPressed:() {
                                                                                    // 다이얼로그 닫기
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }
                                                                      );
                                                                      print(value.name);
                                                                    });
                                                                  }
                                                                });

                                                              },
                                                              child: const Text('구매 요청'),
                                                            ):SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 3.h,
                                              ),
                                              Flexible(
                                                flex: 50,
                                                fit: FlexFit.tight,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          7)),
                                                      color: Color(
                                                          0xfff7fbfc)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 9.h,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                }),
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale && snapshot.data[index].type == "잡곡류"
                                      ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 11.h,
                                        right: 15.w,
                                        bottom: 2.h),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        primary: const Color(0x99f7fbfc),
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                        ),
                                      ),
                                      child: Container(
                                        height: 133.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0xffe2eef0),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.w,
                                              top: 7.h,
                                              right: 12.w,
                                              bottom: 13.h),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  flex: 64,
                                                  fit: FlexFit.tight,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'images/main_img_3.png',
                                                        width: 40.h,
                                                        height: 40.h,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 15
                                                                      .w),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    snapshot
                                                                        .data[index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color: const Color(0xff313131),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 16.sp),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                    5.h,
                                                                  ),
                                                                  Text(
                                                                    '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                    style: TextStyle(
                                                                        color: const Color(0xff797979),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 13.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            (org == '3')?
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary:
                                                                const Color(
                                                                    0xff54c9a8),
                                                                onPrimary: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                // /////////////////구매요청//////////////////////
                                                                var bytes = utf8.encode(snapshot.data[index].userId);
                                                                var fromId = sha256.convert(bytes);

                                                                // print(fromId);
                                                                // print(snapshot.data[index].id);
                                                                // print(userId);
                                                                // print(snapshot.data[index].totalPrice);
                                                                // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                  print(value);
                                                                  if(value == 'true'){
                                                                    await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                        buttonText: "확인");
                                                                  }else{
                                                                    getUserInfo(fromId).then((value) {
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('구매 요청'),
                                                                              content: SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: <Widget>[
                                                                                    const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                        color:  Color(0xff222222),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontFamily: "NotoSansKR",
                                                                                        fontStyle:  FontStyle.normal,
                                                                                        fontSize: 16.0
                                                                                    ),)),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                        style: TextStyle(
                                                                                            fontSize: 18.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매도인(갑)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : ${value.name}"),
                                                                                              Text("생년월일 : ${value.birth}"),
                                                                                              Text("구매자 주소 : ${value.address}"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매수인(을)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : $userName"),
                                                                                              Text("생년월일 : $userBirth"),
                                                                                              Text("구매자 주소 : $userAddress"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("소재지 : ${snapshot.data[index].location}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("품목 : ${snapshot.data[index].kind}"),
                                                                                        SizedBox(width: 40.w,),
                                                                                        Text("품종 : ${snapshot.data[index].type}"),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    const Text("계약일 : --"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("갑의 연락처 : ${value.phone}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("을의 연락처 : $userPhone"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Divider(),
                                                                                    const Text('제1조(매매대금)'),
                                                                                    const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제2조 (계약금)'),
                                                                                    const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제3조 (목적물의 확인)'),
                                                                                    const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                    const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제5조 (목적물의 관리)'),
                                                                                    const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제6조 (목적물의 반출)'),
                                                                                    const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제7조 (위험부담)'),
                                                                                    const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제8조 (담보책임)'),
                                                                                    const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제9조 (계약해제)'),
                                                                                    const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                    const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제11조 (통지방법)'),
                                                                                    const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제12조 (위약금)'),
                                                                                    const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제13조 (관할법원)'),
                                                                                    const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),


                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[FlatButton(
                                                                                child: const Text('계약금 전송'),
                                                                                onPressed: () async {
                                                                                  //////////////////////
                                                                                  var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                  print(price);
                                                                                  pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                  await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                    print("하이퍼");
                                                                                    print(value);
                                                                                    if(value.isEmpty){
                                                                                      await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                        pd.close();
                                                                                        if (value == 'true') {
                                                                                          await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                              buttonText: "확인");
                                                                                        }else{
                                                                                          await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                              buttonText: "확인");
                                                                                        }
                                                                                      });
                                                                                    }else{
                                                                                      pd.close();
                                                                                      await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                          buttonText: "확인");
                                                                                    }
                                                                                    // pd.close();
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),

                                                                                FlatButton(
                                                                                  child: const Text('cancel'),
                                                                                  onPressed:() {
                                                                                    // 다이얼로그 닫기
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }
                                                                      );
                                                                      print(value.name);
                                                                    });
                                                                  }
                                                                });

                                                              },
                                                              child: const Text('구매 요청'),
                                                            ):SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 3.h,
                                              ),
                                              Flexible(
                                                flex: 50,
                                                fit: FlexFit.tight,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          7)),
                                                      color: Color(
                                                          0xfff7fbfc)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 9.h,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                }),
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale && snapshot.data[index].type == "기호과채류"
                                      ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 11.h,
                                        right: 15.w,
                                        bottom: 2.h),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        primary: const Color(0x99f7fbfc),
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                        ),
                                      ),
                                      child: Container(
                                        height: 133.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0xffe2eef0),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.w,
                                              top: 7.h,
                                              right: 12.w,
                                              bottom: 13.h),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  flex: 64,
                                                  fit: FlexFit.tight,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'images/main_img_3.png',
                                                        width: 40.h,
                                                        height: 40.h,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 15
                                                                      .w),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    snapshot
                                                                        .data[index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color: const Color(0xff313131),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 16.sp),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                    5.h,
                                                                  ),
                                                                  Text(
                                                                    '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                    style: TextStyle(
                                                                        color: const Color(0xff797979),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 13.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            (org == '3')?
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary:
                                                                const Color(
                                                                    0xff54c9a8),
                                                                onPrimary: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                // /////////////////구매요청//////////////////////
                                                                var bytes = utf8.encode(snapshot.data[index].userId);
                                                                var fromId = sha256.convert(bytes);

                                                                // print(fromId);
                                                                // print(snapshot.data[index].id);
                                                                // print(userId);
                                                                // print(snapshot.data[index].totalPrice);
                                                                // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                  print(value);
                                                                  if(value == 'true'){
                                                                    await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                        buttonText: "확인");
                                                                  }else{
                                                                    getUserInfo(fromId).then((value) {
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('구매 요청'),
                                                                              content: SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: <Widget>[
                                                                                    const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                        color:  Color(0xff222222),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontFamily: "NotoSansKR",
                                                                                        fontStyle:  FontStyle.normal,
                                                                                        fontSize: 16.0
                                                                                    ),)),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                        style: TextStyle(
                                                                                            fontSize: 18.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매도인(갑)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : ${value.name}"),
                                                                                              Text("생년월일 : ${value.birth}"),
                                                                                              Text("구매자 주소 : ${value.address}"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매수인(을)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : $userName"),
                                                                                              Text("생년월일 : $userBirth"),
                                                                                              Text("구매자 주소 : $userAddress"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("소재지 : ${snapshot.data[index].location}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("품목 : ${snapshot.data[index].kind}"),
                                                                                        SizedBox(width: 40.w,),
                                                                                        Text("품종 : ${snapshot.data[index].type}"),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    const Text("계약일 : --"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("갑의 연락처 : ${value.phone}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("을의 연락처 : $userPhone"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Divider(),
                                                                                    const Text('제1조(매매대금)'),
                                                                                    const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제2조 (계약금)'),
                                                                                    const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제3조 (목적물의 확인)'),
                                                                                    const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                    const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제5조 (목적물의 관리)'),
                                                                                    const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제6조 (목적물의 반출)'),
                                                                                    const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제7조 (위험부담)'),
                                                                                    const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제8조 (담보책임)'),
                                                                                    const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제9조 (계약해제)'),
                                                                                    const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                    const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제11조 (통지방법)'),
                                                                                    const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제12조 (위약금)'),
                                                                                    const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제13조 (관할법원)'),
                                                                                    const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),


                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[FlatButton(
                                                                                child: const Text('계약금 전송'),
                                                                                onPressed: () async {
                                                                                  //////////////////////
                                                                                  var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                  print(price);
                                                                                  pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                  await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                    print("하이퍼");
                                                                                    print(value);
                                                                                    if(value.isEmpty){
                                                                                      await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                        pd.close();
                                                                                        if (value == 'true') {
                                                                                          await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                              buttonText: "확인");
                                                                                        }else{
                                                                                          await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                              buttonText: "확인");
                                                                                        }
                                                                                      });
                                                                                    }else{
                                                                                      pd.close();
                                                                                      await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                          buttonText: "확인");
                                                                                    }
                                                                                    // pd.close();
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),

                                                                                FlatButton(
                                                                                  child: const Text('cancel'),
                                                                                  onPressed:() {
                                                                                    // 다이얼로그 닫기
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }
                                                                      );
                                                                      print(value.name);
                                                                    });
                                                                  }
                                                                });

                                                              },
                                                              child: const Text('구매 요청'),
                                                            ):SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 3.h,
                                              ),
                                              Flexible(
                                                flex: 50,
                                                fit: FlexFit.tight,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          7)),
                                                      color: Color(
                                                          0xfff7fbfc)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 9.h,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                }),
                            ListView.builder(
                                itemCount: snapshot.data.length,
                                itemBuilder: (context, index) {
                                  return snapshot.data[index].onSale && snapshot.data[index].type == "기타"
                                      ? Padding(
                                    padding: EdgeInsets.only(
                                        left: 15.w,
                                        top: 11.h,
                                        right: 15.w,
                                        bottom: 2.h),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        primary: const Color(0x99f7fbfc),
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                        ),
                                      ),
                                      child: Container(
                                        height: 133.h,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(19.0),
                                          color: Colors.white,
                                          boxShadow: const [
                                            BoxShadow(
                                                color: Color(0xffe2eef0),
                                                offset: Offset(0, 3),
                                                blurRadius: 6,
                                                spreadRadius: 0)
                                          ],
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              left: 12.w,
                                              top: 7.h,
                                              right: 12.w,
                                              bottom: 13.h),
                                          child: Column(
                                            children: [
                                              Flexible(
                                                  flex: 64,
                                                  fit: FlexFit.tight,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        'images/main_img_3.png',
                                                        width: 40.h,
                                                        height: 40.h,
                                                        fit: BoxFit.fill,
                                                      ),
                                                      Expanded(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(
                                                                  left: 15
                                                                      .w),
                                                              child:
                                                              Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                                children: [
                                                                  Text(
                                                                    snapshot
                                                                        .data[index]
                                                                        .title,
                                                                    style: TextStyle(
                                                                        color: const Color(0xff313131),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 16.sp),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                    5.h,
                                                                  ),
                                                                  Text(
                                                                    '매매 금액 : ${snapshot.data[index].totalPrice}원',
                                                                    style: TextStyle(
                                                                        color: const Color(0xff797979),
                                                                        fontWeight: FontWeight.w400,
                                                                        fontFamily: "NotoSansKR",
                                                                        fontStyle: FontStyle.normal,
                                                                        fontSize: 13.sp),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            (org == '3')?
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                primary:
                                                                const Color(
                                                                    0xff54c9a8),
                                                                onPrimary: Colors.white,
                                                              ),
                                                              onPressed: () async {
                                                                // /////////////////구매요청//////////////////////
                                                                var bytes = utf8.encode(snapshot.data[index].userId);
                                                                var fromId = sha256.convert(bytes);

                                                                // print(fromId);
                                                                // print(snapshot.data[index].id);
                                                                // print(userId);
                                                                // print(snapshot.data[index].totalPrice);
                                                                // pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                await IsTransactionRequest(snapshot.data[index].id).then((value) async {
                                                                  print(value);
                                                                  if(value == 'true'){
                                                                    await showCustomDialog(context, '거래 진행중인 매물입니다.',
                                                                        buttonText: "확인");
                                                                  }else{
                                                                    getUserInfo(fromId).then((value) {
                                                                      showDialog(
                                                                          context: context,
                                                                          barrierDismissible: false,  // 사용자가 다이얼로그 바깥을 터치하면 닫히지 않음
                                                                          builder: (BuildContext context) {
                                                                            return AlertDialog(
                                                                              title: const Text('구매 요청'),
                                                                              content: SingleChildScrollView(
                                                                                child: ListBody(
                                                                                  children: <Widget>[
                                                                                    const Center(child: Text("농산물 포전매매 표준계약서",style: TextStyle(
                                                                                        color:  Color(0xff222222),
                                                                                        fontWeight: FontWeight.w500,
                                                                                        fontFamily: "NotoSansKR",
                                                                                        fontStyle:  FontStyle.normal,
                                                                                        fontSize: 16.0
                                                                                    ),)),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text("아래 목적물을 포전매매 함에 있어 매도인(이하 “갑”이라고 한다)과 매수인(이하 “을”이라고 한다)은 다음과 같이 계약을 체결하고 신의성실의 원칙에 따라 이를 이행하여야 한다.",
                                                                                        style: TextStyle(
                                                                                            fontSize: 18.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매도인(갑)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : ${value.name}"),
                                                                                              Text("생년월일 : ${value.birth}"),
                                                                                              Text("구매자 주소 : ${value.address}"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        const Text('매수인(을)'),
                                                                                        SizedBox(width: 20.w,),
                                                                                        Expanded(
                                                                                          child: Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Text("성명 : $userName"),
                                                                                              Text("생년월일 : $userBirth"),
                                                                                              Text("구매자 주소 : $userAddress"),
                                                                                            ],
                                                                                          ),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("소재지 : ${snapshot.data[index].location}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("품목 : ${snapshot.data[index].kind}"),
                                                                                        SizedBox(width: 40.w,),
                                                                                        Text("품종 : ${snapshot.data[index].type}"),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약 면적(평 수) : ${snapshot.data[index].area}평"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("최종 출거일 : ${snapshot.data[index].departureDate}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("총 매매대금 : ${snapshot.data[index].totalPrice}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    const Text("계약일 : --"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("계약금 : ${(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("잔금 : ${int.parse(snapshot.data[index].totalPrice) -(double.parse(snapshot.data[index].totalPrice) * 0.3).floor()}원"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    Text("갑의 연락처 : ${value.phone}"),
                                                                                    SizedBox(height: 5.h,),
                                                                                    Text("을의 연락처 : $userPhone"),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Text('<주의사항> 농수산물유통 및 가격안정에 관한 법률 제90조제1항제2호에 따라 이 표준계약서와 다른 계약서를 사용하면서 ‘표준계약서’로 거짓표시 하거나, ‘농림축산식품부’ 및 ‘농림축산식품부 표식’을 사용하는 매수인에게는 1천만원 이하의 과태료가 부과됩니다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.w300),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 20.h,),
                                                                                    const Divider(),
                                                                                    const Text('제1조(매매대금)'),
                                                                                    const Text('① 총 매매대금은 위 금액이며, 잔금지급은 포전매매의 특성을 감안하여 해당농작물의 평균적 생육기간의 2/3가 경과하기 전까지 이루어지는 것이 양당사자에게 공평하다. 잔금지급기일은 위 기재일이다. 단 매도인과 매수인이 협의하여 중도금을 약정할 수 있다.\n② 을이 위 조항에서 규정한 잔금지급기일 이전에 해당농작물을 반출하고자 할 경우에 잔금을 지급하고 반출하여야 한다.\n③ 이 계약에서 정한 매매단위별 단가로서 당사자가 별도로 약정한 경우에는 그 방법을 따른다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제2조 (계약금)'),
                                                                                    const Text('① 포전매매는 선도거래의 성격으로서 계약금이 총 매매대금의 30% 이상 지급되어야 계약당사자 쌍방에게 형평에 맞으며 이 건 계약금은 위 기재금액으로 한다.\n② 계약금이 지급된 이 건 계약을 해약하고자 할 때 이행에 착수하기 전까지 갑은 받은 계약금의 배액을 상환하고, 을은 계약금을 포기함으로써 해약할 수 있으며, 계약금은 총 매매대금에 포함하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제3조 (목적물의 확인)'),
                                                                                    const Text('① 을이 포전매매목적물의 현황확인을 위하여 갑에게 위 목적물표시상 소재지의 지적도 및 토지대장제출을 요청할 경우, 갑은 이에 응하여야 한다.\n② 공부(토지대장, 토지등기부 등)상의 명의인과 갑이 다를 경우에 그 사유를 을에게 소명하여야 한다.\n③ 을은 직접 목적물에 대한 생육상태를 확인하고 계약하여야 하며, 을의 미확인으로 인해 발생한 손해에 대해 갑은 책임을 지지 아니한다. 다만 갑은 본인이 알고 있는 목적물에 대한 중요한 정보(농작물의 종자에 대한 정보, 위해조수출몰, 농지가 맹지여서 화물차의 진입이 불가능한 여부, 연작피해를 방지하기 위한 연작여부 등)를 계약 전에 알리지 아니한 경우에는 그러하지 아니하다.\n④ 계약면적은 공부상 면적을 기준으로 하되 실면적과 차이가 있을 경우 위성위치추적시스템(GPS) 측량기를 이용해서 재배면적을 측량할 수 있다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제4조 (목적물의 인도, 거래표지판 설치)'),
                                                                                    const Text('① 갑은 매매대금의 잔금수령과 동시에 을에게 목적물을 포전상태로 인도하기로 한다.\n② 갑의 인도로 목적물의 소유권은 을에게 이전되며, 목적물이 을에게 인도되었음을 외부에 알리고, 재해 등이 발생한 경우의 손실부담에 대한 법률관계를 분명히 하기 위하여 팻말을 부착하는 등의 거래내용표지판을 설치하며, 그 실행은 갑과 을이 협의하여 하기로 한다.\n③ 거래표지판에는 계약당사자의 성명, 품목, 계약면적, 계약체결일 및 반출예정일 등을 기재한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제5조 (목적물의 관리)'),
                                                                                    const Text('① 갑은 약정 반출일까지 선량한 관리자의 주의로 목적물을 관리하여야 하며 그 비용은 갑이 부담한다.\n② 갑이 목적물을 관리하는 내용은 용수, 시비, 방제, 제초 등으로 통상적으로 해당 목적물에 대해 시행하는 정도의 관리를 그 범위로 한다.\n③ 갑이 실시하는 통상적인 관리범위를 넘어서 실시하도록 을이 요청한 경우에 그 비용은 을의 부담으로 하며, 이로 인해 발생된 결과에 대해서 을이 받아들이기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제6조 (목적물의 반출)'),
                                                                                    const Text('① 예상하지 못한 기상변화 등으로 인하여 목적물성장이 늦어진 경우에 을의 목적물반출은 후작의 경작에 지장이 없는 범위에서 당사자의 협의하에 반출일연장을 허용할 수 있다.\n② 목적물의 수확ㆍ반출비용은 을이 부담한다.                                             \n③ 목적물반출일 이전에 을이 반출지연사유와 반출연장일을 서면으로 통지한 경우에 갑은 1회당 10일의 범위 내에서 최대 2회까지 허용하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n④ 반출일 연장으로 인하여 갑에게 관리비용이 추가된 경우에는 을이 변상하여야 한다.\n⑤ 연장된 반출일이 지나도록 목적물을 수거하지 않을 경우에 남아있는 목적물은 갑이 임의로 처리한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제7조 (위험부담)'),
                                                                                    const Text('① 천재지변, 예기치 못한 기상재해 그 밖에 불가항력적인 사유로 인하여 목적물이 멸실, 훼손된 경우에 그 목적물의 손실은 갑이 잔금을 수령한 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n② 병충해 등으로 인한 목적물의 손상에 대해서는 통상의 관리를 크게 넘는 정도의 병충해침습의 경우, 관리상의 잘못이 아닌, 종자 등의 결함으로 인하여 목적물에 중대한 결점이 발생한 경우, 당사자 쌍방에게 책임 없는 사유로 발생한 조수 등 위해 동식물로 인해 발생한 목적물에 대한 손실의 경우에 그 목적물의 손실은 갑의 잔금 수령 후에는 을의 부담으로 하며, 그 이전에는 갑의 부담으로 한다.\n③ 위 제2항의 경우에 위해조수에 의한 피해가 사전 미고지로  조수피해예방조치를 강구할 수 있는 기회를 가지지 못하여 발생한 경우에는 갑에게 책임이 있다.\n④ 목적물의 가격 폭락 및 폭등은 포전매매계약의 특성상 대금감액 또는 증액의 사유가 되지 아니 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제8조 (담보책임)'),
                                                                                    const Text('계약체결 후 계약의 양당사자에게 책임이 없는 사유로 인하여 목적물의 품질, 수량, 계약면적 등에 하자가 발생한 경우에 계약해제, 대금감액, 손해배상 등의 담보책임을 지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제9조 (계약해제)'),
                                                                                    const Text('① 당사자 쌍방에게 책임 있는 사유로 계약을 해제하는 경우에는 이행의 최고(독촉)를 하지 않고서 계약해제 할 수 있다. 단 매수인에게 유책사유 없이 매수인이 대금지급을 불이행한 경우에 매도인은 매수인에게 상당한 기간을 정하여 최고한 후 계약해제할 수 있다.\n② 갑에게 책임 있는 계약해제 사유는 다음 각호로 한다.\n 1. 이행거절로 볼 수 있는 행위를 한 때(이중매매 등)\n 2. 갑이 통상적인 관리행위를 하지 않음이 명백한 경우\n 3. 긴급을 요하는 사유가 발생하여 을에게 통지하여 을의 판단이 필요할 때 이를 게을리 하여 을에게 큰 손해를 야기케 한 경우\n③ 을에게 책임 있는 계약해제 사유는 다음 각 호로 한다.\n 1. 매매대금지급기일을 위반하였을 경우\n④ 계약해제로 인한 계약관계해소 후 갑에 의한 목적물의 처분은 부당이득반환, 원상회복과 연계되지 않고 독자적으로 할 수 있기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제10조 (농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)'),
                                                                                    const Text('① 농수산물유통 및 가격안정에 관한 법률 제53조 제2항에서 정하고 있는 약정반출일로부터 10일 이내 반출하지 아니할 때 그 기간 즉 반출약정일 후 10일이 지난날에 계약이 해제된 것으로 본다는 뜻은 법률규정에 의하여 계약해제가 이루어졌음을 의미하며 그 밖의 위약금, 손해배상 등에 관하여는 기존의 약정에 따르기로 한다.\n② 농수산물유통 및 가격안정에 관한 법률 제53조제2항의 단서에 의하여 을이 반출 지연 사유와 반출예정일을 서면으로 통지한 경우에도 그 반출연장기간은 최초에 정한 반출약정일로부터 20일을 경과할 수 없으며 반출기간연장도 2회에 한정하기로 한다. 다만 서면으로 통지하는 것에 갈음하여 제11조(통지방법)의 통지방법을 사용할 수 있다.\n③ 반출지연에 따른 손해는 별도의 위약금약정으로 정하기로 한다.\n※ 농수산물유통 및 가격안정에 관한 법률 제53조 ② 제1항에 따른 농산물의 포전매매의 계약은 특약이 없으면 매수인이 그 농산물을 계약서에 적힌 반출 약정일부터 10일 이내에 반출하지 아니한 경우에는 그 기간이 지난 날에 계약이 해제된 것으로 본다. 다만, 매수인이 반출 약정일이 지나기 전에 반출 지연 사유와 반출 예정일을 서면으로 통지한 경우에는 그러하지 아니하다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제11조 (통지방법)'),
                                                                                    const Text('① 목적물의 관리 과정에 긴급히 처리하여야 할 문제가 발생하여 상호연락이 필요한 경우를 대비하여 연락처를 지정하여야 한다.\n② 이 연락처에 2일(48시간) 내에 3회(1일 2회 이내)이상 연락하였음에도 연락되지 아니할 경우에 계약당사자 쌍방은 특별한 경우가 아니면 이의를 제기하지 않기로 한다.\n③ 전항의 연락에 대한 수단으로서 서면으로 하는 것을 원칙으로 하지만 당사자가 휴대폰문자, 이메일 또는 팩스를 이용하기로 약정할 수 있다.\n④ 통지와 관련되어 발생한 손해는 이 계약내용을 준수하는 한 책임지지 않기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제12조 (위약금)'),
                                                                                    const Text('① 제9조(계약해제)에서 규정한 계약해제로 인하여 발생한 손해에 대한 위약금은 총매매대금으로 한다. 제10조(농수산물유통 및 가격안정에 관한 법률 제53조에 따른 특약사항)에서 규정한 손해발생의 경우에도 그 위약금은 총매매대금으로 한다.\n② 제3조 제3항, 제6조 제4항, 제7조 제3항, 제10조 제3항을 위반한 경우의 위약금은 계약금 상당액을 기준으로 하며, 계약당사자가 별도의 약정을 할 수 있고, 그 내용은 이 계약서 전면 개별약정 기재사항에 기재하기로 한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),
                                                                                    SizedBox(height: 10.h,),
                                                                                    const Text('제13조 (관할법원)'),
                                                                                    const Text('이 계약에 관한 소송의 관할법원은 목적물의 표시상 소재지를 관할하는 법원으로 한다.\n이 계약을 증명하기 위해서 계약서 2통을 작성하여 갑과 을이 서명날인한 후 각 1통씩 보관한다.',
                                                                                        style: TextStyle(
                                                                                            fontSize: 11.0,
                                                                                            fontWeight: FontWeight.bold),
                                                                                        textAlign: TextAlign.justify),


                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              actions: <Widget>[FlatButton(
                                                                                child: const Text('계약금 전송'),
                                                                                onPressed: () async {
                                                                                  //////////////////////
                                                                                  var price = (int.parse(snapshot.data[index].totalPrice) * 0.3).floor();
                                                                                  print(price);
                                                                                  pd.show(max: 100, msg: "구매요청..계약금전송..");

                                                                                  await transferTokenBlock(org,userId,fromId,price).then((value) async {
                                                                                    print("하이퍼");
                                                                                    print(value);
                                                                                    if(value.isEmpty){
                                                                                      await transactionRequest(snapshot.data[index].id,fromId,userId).then((value) async {
                                                                                        pd.close();
                                                                                        if (value == 'true') {
                                                                                          await showCustomDialog(context, '계약금이 전송되었습니다. 구매 요청 완료.',
                                                                                              buttonText: "확인");
                                                                                        }else{
                                                                                          await showCustomDialog(context, '구매 요청에 실패하였습니다.(mysql)',
                                                                                              buttonText: "확인");
                                                                                        }
                                                                                      });
                                                                                    }else{
                                                                                      pd.close();
                                                                                      await showCustomDialog(context, '잔액이 부족합니다.',
                                                                                          buttonText: "확인");
                                                                                    }
                                                                                    // pd.close();
                                                                                  });

                                                                                  Navigator.of(context).pop();
                                                                                },
                                                                              ),

                                                                                FlatButton(
                                                                                  child: const Text('cancel'),
                                                                                  onPressed:() {
                                                                                    // 다이얼로그 닫기
                                                                                    Navigator.of(context).pop();
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            );
                                                                          }
                                                                      );
                                                                      print(value.name);
                                                                    });
                                                                  }
                                                                });

                                                              },
                                                              child: const Text('구매 요청'),
                                                            ):SizedBox(),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                              SizedBox(
                                                height: 3.h,
                                              ),
                                              Flexible(
                                                flex: 50,
                                                fit: FlexFit.tight,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius
                                                          .all(Radius
                                                          .circular(
                                                          7)),
                                                      color: Color(
                                                          0xfff7fbfc)),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .all(5.0),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '품종명 : ${snapshot.data[index].kind} | 소재지 : ${snapshot.data[index].location} | 재배 방식 : ${snapshot.data[index].method} ',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 9.h,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                          children: [
                                                            SizedBox(
                                                              width: 5.w,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '평수 : ${snapshot.data[index].area}평 | 출거일 : ${snapshot.data[index].departureDate}',
                                                                softWrap:
                                                                true,
                                                                style: TextStyle(
                                                                    color: const Color(
                                                                        0xff676767),
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                    fontFamily:
                                                                    "NotoSansKR",
                                                                    fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                    fontSize:
                                                                    13.sp),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : SizedBox();
                                }),
                          ]),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ));
  }
}
