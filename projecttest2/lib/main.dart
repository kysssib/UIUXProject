//flutter pub add http
//flutter pub add geolocator
//flutter pub add permission_handler
//flutter pub add flutter_inappwebview
//andriod - app - src - main - AndroidManifest.xml
//  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
//  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>

import 'package:flutter/material.dart';
import 'stationLoader.dart';
import 'FirstPage.dart';
import 'SecondPage.dart';

void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  TabController? controller;
  String? stationName;
  List<double>? nowLOC;

  @override
  void initState(){
    super.initState();
    controller = TabController(length:2, vsync: this);
  }

  @override
  void dispose(){
    controller!.dispose();
    super.dispose();
  }

  void onTabTapped(int index) async { //탭 눌릴 때 불리는 함수
    stationName = await kakaoStation(2000);
    setState(() {}); // 업데이트 된 stationName을 반영
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Demo'),
      ),
      body: Center(
        child: TabBarView(
          controller: controller,
          children: <Widget> [FirstApp(String: stationName), SecondApp()],
        )
      ),
      bottomNavigationBar: TabBar(
        tabs: <Tab>[
          Tab(icon: Icon(Icons.looks_one, color: Colors.blue)),
          Tab(icon: Icon(Icons.looks_two, color: Colors.blue)),
        ], controller: controller,
        onTap: onTabTapped,
      ),
    );
  }
}