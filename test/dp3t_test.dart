import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dp3t/dp3t.dart';

void main() {
  const MethodChannel channel = MethodChannel('dp3t');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Dp3t.platformVersion, '42');
  });
}
