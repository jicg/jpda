import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

abstract class DioModel extends ChangeNotifier {
  set baseUrl(String value);

  Dio get dio;

  bool get hasBaseUrl;

  String get baseUrl;

  set token(String value);

  Future<Response<T>> login<T>(String email, String sign);
}

class DioModelIPhone extends DioModel {
  Dio _dio = new Dio()..options.headers["client"] = "mobile";

  Dio get dio => _dio;

  bool get hasBaseUrl => (_dio.options.baseUrl ?? "").isNotEmpty;

  set baseUrl(String value) {
    _dio.options.baseUrl = value;
  }

  String get baseUrl => _dio.options.baseUrl;

  set token(String value) {
    _dio.options.headers["token"] = value;
  }

  @override
  Future<Response<T>> login<T>(String email, String sign) async {
    return  _dio.post<T>("/login", queryParameters: {email: email, sign: sign});
  }
}
