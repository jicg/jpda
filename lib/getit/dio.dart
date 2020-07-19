import 'dart:convert';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:jpda/comm/exception.dart';
import 'package:jpda/comm/func.dart';
import 'package:jpda/comm/jpda.dart';
import 'package:jpda/getit/cache.dart';

abstract class DioModel {
  set baseUrl(String value);

  Dio get dio;

  bool get hasBaseUrl;

  String get baseUrl;

  Future<Response<Map>> login(String email, String pwd);

  Future<Response<Map>> query(String func, Map param, [BuildContext context]);
  Future<Map> query2(String func, Map param, [BuildContext context]);
}

class DioModelIPhone extends DioModel {
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd hh:mm:ss');
  Dio _dio = new Dio()
        ..options.connectTimeout = 1000 * 10
        ..options.headers["client"] = "mobile"
//    ..options.contentType=Headers.formUrlEncodedContentType
//    ..options.responseType=ResponseType.json
//    ..options.followRedirects=false
//    ..options.validateStatus = ((status) => true)
        ..interceptors.add(CookieManager(CookieJar()))

//    ..interceptors.add(LogInterceptor(responseBody: false))
      ;

  Dio get dio => _dio;

  bool get hasBaseUrl =>
      (_dio.options.baseUrl ?? "").isNotEmpty &&
      _dio.options.baseUrl.compareTo("http://") != 0 &&
      _dio.options.baseUrl.compareTo("https://") != 0;

  set baseUrl(String value) {
    _dio.options.baseUrl = value;
    JPda.cache.setString(CacheKeys.App_Url, value);
  }

  String get baseUrl => _dio.options.baseUrl;

  @override
  Future<Response<Map>> login(String email, String pwd) async {
    String _t = "${DateTime.now().millisecondsSinceEpoch}";
    String sign = StringUtils.generateMd5(StringUtils.generateMd5(pwd) + _t);
    Response<Map> resp = await _dio.post<Map>("/html/jpda/validate.jsp",
        queryParameters: {"u": email, "_t": _t, "sign": sign});
    resp = _handleRespNor(resp);
    resp = await _dio
        .get("/html/jpda/login.jsp", queryParameters: {"text": "safasd"});
    print("test2----- $resp");
    resp = _handleRespNor(resp);
    return resp;
  }

  @override
  Future<Response<Map>> query(String func, Map param,
      [BuildContext context]) async {
    if (param == null) {
      param = {};
    }
    param["date"] = "${dateFormat.format(DateTime.now())}";
    Response<Map> resp = await _dio.post<Map>("/html/jpda/query.jsp",
        queryParameters: {"func": func, "param": json.encode(param)});
    resp = _handleRespAuth(context, resp);
    return resp;
  }

  @override
  Future<Map> query2(String func, Map param,
      [BuildContext context]) async {
    if (param == null) {
      param = {};
    }
    param["date"] = "${dateFormat.format(DateTime.now())}";
    Response<String> resp = await _dio.post<String>("/html/jpda/query.jsp",
        queryParameters: {"func": func, "param": json.encode(param)});
    print("query2 "+resp.data);
    return _handleRespAuth2(context, resp.data);
  }
}

Response<Map> _handleRespNor(Response<Map> resp) {
  Map da = resp.data;
  int code = da["code"];
  if (code != 0) {
    throw WebException(resp.data["msg"]);
  }
  return resp;
}

Response<Map> _handleRespAuth(BuildContext context, Response<Map> resp) {
  Map da = resp.data;
  int code = da["code"];
  if (code != 0) {
    if (code == 1001) {
      if (context != null) {
        Navigator.pushNamed(context, "/login");
      }
      throw NotLoginException();
    } else {
      throw WebException(resp.data["msg"]);
    }
  }
  return resp;
}

Map _handleRespAuth2(BuildContext context, String data) {
  Map da = json.decode(data);
  int code = da["code"];
  if (code != 0) {
    if (code == 1001) {
      if (context != null) {
        Navigator.pushNamed(context, "/login");
      }
      throw NotLoginException();
    } else {
      throw WebException(da["msg"]);
    }
  }
  return da;
}
