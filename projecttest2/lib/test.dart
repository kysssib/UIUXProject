import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class KakaoMapPage extends StatefulWidget {
  @override
  _KakaoMapPageState createState() => _KakaoMapPageState();
}

class _KakaoMapPageState extends State<KakaoMapPage> {
  late String url;

  @override
  void initState() {
    super.initState();
    String appKey = "fe85ce059fe1e217d3e2e66ded3668e6";
    String baseUrl =
        "https://map.kakao.com/?appKey={appKey}&map_type=TYPE_MAP&target=coord&x=126.9784305&y=37.5666102&level=3";
    url = baseUrl.replaceAll("{appKey}", appKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(url)),
      ),
    );
  }
}
