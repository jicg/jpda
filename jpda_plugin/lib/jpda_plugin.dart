import 'dart:async';

import 'package:flutter/services.dart';

class JpdaPlugin {
  static final MethodChannel _channel = const MethodChannel('jpda_plugin')
    ..setMethodCallHandler(_handler);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> openScanEditText(String type) async {
    final bool ret = await _channel.invokeMethod('openScanEditText', type);
    return ret;
  }

  static Future<bool> closeScanEditText()  async{
    final bool ret = await _channel.invokeMethod('closeScanEditText');

    return ret;
  }

  // 接收
  static final StreamController<Map> _responseScanController =
      new StreamController.broadcast();

  /// Response from share
  static Stream<Map> get scanResponse => _responseScanController.stream;

  static Future<dynamic> _handler(MethodCall methodCall) {
    if("scanRestult"==methodCall.method) {
      _responseScanController.add(methodCall.arguments);
    }
    return Future.value(true);
  }

  static void dispose() {
    _responseScanController.close();
  }


}
