import 'package:flutter/material.dart';
import 'stationLoader.dart';

class FirstApp extends StatefulWidget {
  const FirstApp({Key? key}) : super(key: key);

  @override
  _FirstAppState createState() => _FirstAppState();
}

class _FirstAppState extends State<FirstApp> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FutureBuilder(
            // getStation이 Future<String>을 반환하기 때문에 `.then((stationName) => stationName)`을 추가
            // Future<dynamic>이 반환, 아래 snapshot.data as String에서 String으로 타입을 변환
            future: kakaoStation(2000).then((stationName) => stationName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) { //Future가 값을 받는 중
                return Text('Loading...');
              } else if (snapshot.hasError) { //Future 비정상 실행
                return Text('Error: ${snapshot.error}');
              } else {
                if (snapshot.hasData) { //Future에 데이터가 들어오면
                  // snapshot.data이 dynamic 타입, as String으로 String으로 타입을 변환
                  return Text(snapshot.data as String);
                } else {
                  return Text('Loading...'); //CircularProgressIndicator(); //LoadIndicator
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
