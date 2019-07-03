import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jpda/router/Routes.dart';
import 'package:jpda/comm/jpda.dart';

void main() {
  JPda.initGetIt();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //去掉debug图标
      title: '采集器',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/",
      onGenerateRoute: onGenerateRoute,
    );
  }
}
