import 'package:flutter/material.dart';
import 'package:jpda/pages/baseurl.dart';
import 'package:jpda/pages/first.dart';
import 'package:jpda/pages/home.dart';
import 'package:jpda/pages/login.dart';

//配置路由
final routes = {
  "/first": (context) => FirstPage(),
  "/login": (context) => LoginPage(),
  "/": (context) => MainPage(),
  "/baseurl":(context,{Object arguments}) => BaseUrlPage(arguments),
};

//固定写法
RouteFactory onGenerateRoute = (RouteSettings settings) {
  // 统一处理
  final String name = settings.name;
  final Function pageContentBuilder = routes[name];
  if (pageContentBuilder != null) {
    if (settings.arguments != null) {
      final Route route = MaterialPageRoute(
          builder: (context) =>
              pageContentBuilder(context, arguments: settings.arguments));
      return route;
    } else {
      final Route route =
          MaterialPageRoute(builder: (context) => pageContentBuilder(context));
      return route;
    }
  }
};
