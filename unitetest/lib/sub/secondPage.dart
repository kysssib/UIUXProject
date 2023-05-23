import 'package:flutter/material.dart';

class SecondApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(onPressed: (){
                  Navigator.pop(context);
                },
                    icon: Image.asset('assets/images/repeat.png', color: Colors.red))
              ],
            )
        ),
      ),
    );
  }
}