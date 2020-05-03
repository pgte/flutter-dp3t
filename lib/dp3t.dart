import 'dart:async';
import 'package:flutter/services.dart';

class Dp3t {
  static const MethodChannel _channel = const MethodChannel('dp3t');

  static Future<void> reset() async {
    await _channel.invokeMethod('reset');
  }

  static Future<void> initializeManually({
    String appId,
    String reportBaseUrl,
    String bucketBaseUrl,
    String jwtPublicKey
  }) async {
    await _channel.invokeMethod('initializeManually', {
      "appId": appId,
      "reportBaseUrl": reportBaseUrl,
      "bucketBaseUrl": bucketBaseUrl,
      "jwtPublicKey": jwtPublicKey
    });
  }

  static Future<void> initializeWithDiscovery({
    String appId,
    bool dev
  }) async {
    await _channel.invokeMethod('initializeWithDiscovery', {
      "appId": appId,
      "environment": dev ? 'dev' : 'prod'
    });
  }

  static Future<void> startTracing() async {
    await _channel.invokeMethod('startTracing');
  }

  static Future<void> stopTracing() async {
    await _channel.invokeMethod('stopTracing');
  }

  static Future<Map> status() async {
    return await _channel.invokeMethod('status');
  }

  static Future<void> iWasExposed({DateTime onset, String authentication }) async {
    String onsetString = (onset.microsecondsSinceEpoch / 1000000).round().toString();
    await _channel.invokeMethod('iWasExposed', {
      "onset": onsetString,
      "authentication": authentication
    });
  }
}
