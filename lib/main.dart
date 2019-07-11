import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jpda/pages/comm/base/query_where.dart';
import 'package:jpda/pages/comm/query_product.dart';
import 'package:jpda/pages/comm/query_sku.dart';
import 'package:jpda/pages/comm/query_store.dart';
import 'package:jpda/pages/home.dart';
import 'package:jpda/pages/login/baseurl.dart';
import 'package:jpda/pages/login/login.dart';
import 'package:jpda/pages/pandian/home.dart';
import 'package:jpda/pages/product/home.dart';
import 'package:jpda/pages/stock/home.dart';
import 'package:jpda/pages/welcome/first.dart';
import 'package:jpda/comm/jpda.dart';

void main() {
  JPda.initGetIt();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new MyApp());
  });
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
      routes: routes,
    );
  }
}

final routes = {
  "/first": (context) => FirstPage(),
  "/login": (context) => LoginPage(),
  "/": (context) => MainPage(),
  "/baseurl": (context) => BaseUrlPage(),
  "/product/home": (_) => ProductHome(),
  "/pandian/home": (_) => PanDianPage(),
  "/pandian/query": (_) => QueryPage(),
  "/stock/home": (_) => StockHome(),
  "/stock/query": (_) => QueryPage(),
  "/comm/query/product": (_) => QueryProductPage(),
  "/comm/query/store": (_) => QueryStorePage(),
  "/comm/query/sku": (_) => QuerySkuPage(),
};
