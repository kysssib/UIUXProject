import 'package:flutter/material.dart';
import 'package:unitetest/sub/firstPage.dart';
import 'GoogleMap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 화면 우측 상단에 디버그 표시 제거
      title: 'Flutter',
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFF2E3856), // 배경색 설정
          textTheme: const TextTheme(
              //앱 이름 출력 스타일
              subtitle1: TextStyle(
                fontFamily: 'NotoSans',
                fontSize: 16,
                color: Colors.white38,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              //역 이름 출력 스타일
              headlineLarge: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10),
              //상하행 제목 스타일
              bodyText1 : TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3),
              //도착 정보 스타일
              bodyText2: TextStyle(
                  fontFamily: 'NotoSans',
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2)
          )
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyHomePage();
  }
}

class _MyHomePage extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: <Widget>[
          FirstApp(),
          GoogleMapBody(initialLatitude: 0.0, initialLongitude: 0.0,)],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }
}