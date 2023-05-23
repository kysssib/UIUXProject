import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: SubwayApp(),
    );
  }
}

class SubwayApp extends StatefulWidget{
  @override
  State<StatefulWidget> createState() =>  _SubwayApp();
}

class _SubwayApp extends State<SubwayApp>{
  // String _result='';
  String _apiKey = '71734f4e70646c7736315059747155'; // API key

  TextEditingController _stationController = TextEditingController(); // 검색할 역 이름을 입력받는 컨트롤러
  List<dynamic> _upResults = [];
  List<dynamic> _dnResults = [];
  // 역 이름으로 실시간 도착 정보를 검색하는 함수
  Future<dynamic> searchStation(String stationName) async {
    var url = Uri.parse('http://swopenapi.seoul.go.kr/api/subway/$_apiKey/json/realtimeStationArrival/0/5/$stationName'); // 요청 URL 생성
    var response = await http.get(url); // API에 GET 요청 보내기

    final result = jsonDecode(response.body);
    List<dynamic> arrivals = result['realtimeArrivalList'];
    List<dynamic> filteredUpArrivals = [];
    List<dynamic> filteredDnArrivals = [];

    for (var arrival in arrivals) {
      if (arrival['updnLine'] == '상행') {
        filteredUpArrivals.add(arrival);
      } else if (arrival['updnLine'] == '하행') {
        filteredDnArrivals.add(arrival);
      }
    }

    setState(() {
      _upResults.clear();
      _dnResults.clear();// 이전 데이터를 지우고
      // _results.add(result['realtimeArrivalList'][0]['barvlDt']); // 도착예정시간을 저장.
      _upResults.addAll(filteredUpArrivals);
      _dnResults.addAll(filteredDnArrivals);
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Seoul Subway Arrivals'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _stationController,
              decoration: InputDecoration(
                labelText: '역 이름',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                searchStation(_stationController.text); // 검색 버튼을 누르면 검색 함수 호출
              },
              child: Text('검색'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Column(
                      children: _upResults.map((item) {
                        if (item['barvlDt'] == '0') {
                          return Text('상행정보: ${item['arvlMsg2']}');
                        } else {
                          return Text('상행 도착예정시간은  ${item['barvlDt']}초 입니다.');
                        }
                      }).toList(),// 하행 결과를 매핑하여 출력
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      children: _dnResults.map((item) {

                        if (item['barvlDt'] == '0') {
                          return Text('하행 정보: ${item['arvlMsg2']}');
                        } else {
                          return Text('하행 도착예정시간은  ${item['barvlDt']}초 입니다.');
                        }
                      }).toList(),// 하행 결과를 매핑하여 출력
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}