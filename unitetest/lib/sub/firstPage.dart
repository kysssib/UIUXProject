import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unitetest/stationLoader.dart';

//-------------------------------------------------------------------------------------------------------
//#박소진(페이지 레이아웃)
//#이재훈(역 도착 정보)
//#김유성(휴대폰 현 위치 최단역 이름, 코드 융합)

class FirstApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>  _FirstApp();
}

class _FirstApp extends State<FirstApp> {
//-------------------------------------------------------------------------------------------------------
  String _apiKey = '71734f4e70646c7736315059747155'; // API key

  TextEditingController _stationController = TextEditingController(); // 검색할 역 이름을 입력받는 컨트롤러
  List<dynamic> _upResults = []; //상행 리스트
  List<dynamic> _dnResults = []; //하행 리스트
  String stationName = '';
  bool functionController = false;

  //역 이름 불러오기
  Future<String> nowStation() async{
    stationName = await kakaoStation(5000);
    if(functionController == false){
      searchStation(stationName);
    }
    return stationName;
  }

  // 역 이름으로 실시간 도착 정보를 검색하는 함수
  Future<dynamic> searchStation(String stationName) async {
    functionController = true;
    var url = Uri.parse('http://swopenapi.seoul.go.kr/api/subway/$_apiKey/json/realtimeStationArrival/0/5/$stationName'); // 요청 URL 생성
    var response = await http.get(url); // API에 GET 요청 보내기

    final result = jsonDecode(response.body);
    List<dynamic> arrivals = result['realtimeArrivalList'];
    List<dynamic> filteredUpArrivals = []; //임시 상행 리스트
    List<dynamic> filteredDnArrivals = []; //임시 하행 리스트

    for (var arrival in arrivals) {
      if (arrival['updnLine'] == '상행') {
        filteredUpArrivals.add(arrival); //상행 편 지하철 정보 추가
      } else if (arrival['updnLine'] == '하행') {
        filteredDnArrivals.add(arrival); //하행 편 지하철 정보 추가
      }
    }

    setState(() {
      _upResults.clear();
      _dnResults.clear();// 이전 데이터를 지우고
      // _results.add(result['realtimeArrivalList'][0]['barvlDt']); // 도착예정시간을 저장.
      //전역 변수에 추가
      _upResults.addAll(filteredUpArrivals);
      _dnResults.addAll(filteredDnArrivals);
    });
  }

//-------------------------------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(height: 0),
            //제목
            Container(
              child: Text('내 주변 실시간 지하철 정보',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            SizedBox(height: 20),
            //역 이름
//-------------------------------------------------------------------------------------------------------
            FutureBuilder(
              // getStation이 Future<String>을 반환하기 때문에 `.then((stationName) => stationName)`을 추가
              // Future<dynamic>이 반환, 아래 snapshot.data as String에서 String으로 타입을 변환
              future: nowStation(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) { //Future가 연결 대기 중
                  return Text('Loading...', style: Theme.of(context).textTheme.headlineLarge,);
                } else if (snapshot.hasError) { //Future 비정상 실행
                  return Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.headlineLarge,);
                } else {
                  if (snapshot.hasData) { //Future에 데이터가 들어오면
                    // snapshot.data이 dynamic 타입, as String으로 String으로 타입을 변환
                    String text = snapshot.data as String;
                    //정보에 맞게 처리
                    if (text == "error 0"){return Text("위치 정보를\n불러올 수 없습니다.",style: Theme.of(context).textTheme.headlineLarge,);}
                    else if (text == "error 1"){return Text("근처 역 없음",style: Theme.of(context).textTheme.headlineLarge,);}
                    else{return Text("$text역",style: Theme.of(context).textTheme.headlineLarge,);
                    }
                  } else { //Future에 데이터가 안 들어왔으면
                    return Text('Loading...', style: Theme.of(context).textTheme.headlineLarge,); //CircularProgressIndicator(); //LoadIndicator
                  }
                }
              },
            ),
//-------------------------------------------------------------------------------------------------------
            SizedBox(height: 45),
            //상, 하행 정보 표시 필드
            GestureDetector(
              child: Container(
                width: double.infinity,
                height: 490,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          spreadRadius: 10,
                          blurRadius: 20,
                          offset: Offset(0, -2)
                      )
                    ]
                ),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    //갱신 버튼
                    Positioned(
                        top: 20, right: 20,
                        child: IconButton(onPressed: () {
                          setState(() { });//정보 갱신 후 다시 그리기
                        },
                          icon: Image.asset('assets/images/repeat.png', width: 40, height: 40,),)
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        //상행 정보 출력
                        Container(
                          width: 150,
                          height: 360,
                          //상행 정보
                          child: Column(
                            children: [
                              Text('상행',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 70),
                              //도착 정보가 들어왔을 시, 각 길이만큼의 정보가 차있는지 판단 후 정보 추출
                              SizedBox(child: Text(
                                (_upResults.isNotEmpty ? (_upResults[0]['barvlDt'] == '0' ? _upResults[0]['arvlMsg2'] : _upResults[0]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                              SizedBox(height: 40),
                              SizedBox(child: Text(
                                (_upResults.isNotEmpty && _upResults.length > 1 ? (_upResults[1]['barvlDt']=='0' ? _upResults[1]['arvlMsg2'] : _upResults[1]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                              SizedBox(height: 40),
                              SizedBox(child: Text(
                                (_upResults.isNotEmpty && _upResults.length > 2 ? (_upResults[2]['barvlDt']=='0' ? _upResults[2]['arvlMsg2'] : _upResults[2]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                            ],
                          ),
                        ),
                        //중앙선
                        Container(
                          height: 360,
                          width: 1,
                          color: Colors.black38,
                          margin: EdgeInsets.only(bottom: 20),
                        ),
                        //하행 정보 출력
                        Container(
                          width: 150,
                          height: 360,
                          //하행 정보
                          child: Column(
                            children: [
                              Text('하행',
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 70),
                              //도착 정보가 들어왔을 시, 각 길이만큼의 정보가 차있는지 판단 후 정보 추출
                              SizedBox(child: Text(
                                (_dnResults.isNotEmpty && _dnResults.length > 0 ? (_dnResults[0]['barvlDt']=='0' ? _dnResults[0]['arvlMsg2'] : _dnResults[0]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                              SizedBox(height: 40),
                              SizedBox(child: Text(
                                (_dnResults.isNotEmpty && _dnResults.length > 1 ? (_dnResults[1]['barvlDt']=='0' ? _dnResults[1]['arvlMsg2'] : _dnResults[1]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                              SizedBox(height: 40),
                              SizedBox(child: Text(
                                (_dnResults.isNotEmpty && _dnResults.length > 2 ? (_dnResults[2]['barvlDt']=='0' ? _dnResults[2]['arvlMsg2'] : _dnResults[2]['barvlDt']) : ''),
                                style: Theme.of(context).textTheme.bodyText2,
                              ),),
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              /*
              onHorizontalDragDown: (details) {

              },

              onHorizontalDragUpdate: (details) {

              },
              */
              // onHorizontalDragEnd: (details) {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => SecondApp()),
              //   );
              // },
            )
          ],
        ),
      ),
    );
  }
}