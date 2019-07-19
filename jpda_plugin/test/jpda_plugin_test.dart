import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jpda_plugin/jpda_plugin.dart';

void main() {
  const MethodChannel channel = MethodChannel('jpda_plugin');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await JpdaPlugin.platformVersion, '42');
  });
}
