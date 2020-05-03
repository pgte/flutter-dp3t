import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:dp3t/dp3t.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = '';
  String _status = '-';

  Future<void> reset() async {
    try {
      await Dp3t.reset();
      setState(() {
        _message = 'reset';
      });
    } catch (e) {
      setState(() {
        _message = "Failed to reset: '${e.message}'";;
      });
    }
  }

  Future<void> initializeManually() async {
    try {
      await Dp3t.initializeManually(
        appId: 'dummy',
        reportBaseUrl: 'http://example.com',
        bucketBaseUrl: 'http://example.com'
      );
      setState(() {
        _message = 'initialized';
      });
    } catch (e) {
      setState(() {
        _message = "Failed to initialize: '${e.message}'";
      });
    }
  }


  Future<void> initializeWithDiscovery() async {
    try {
      await Dp3t.initializeWithDiscovery(
        appId: 'dummy',
        dev: true
      );
    } catch (e) {
      setState(() {
        _message = "Failed to initialize: '${e.message}'";
      });
    }
  }

  Future<void> startTracing() async {
    try {
      await Dp3t.startTracing();
    } catch (e) {
      setState(() {
        _message = "Failed to start tracing: '${e.message}'";
      });
    }
  }

  Future<void> stopTracing() async {
    try {
      await Dp3t.stopTracing();
    } catch (e) {
      setState(() {
        _message = "Failed to stop tracing: '${e.message}'";
      });
    }
  }

  Future<void> status() async {
    String status;

    try {
      Map nativeStatus = await Dp3t.status();
      status = jsonEncode(nativeStatus);
    } catch (e) {
      status = "Failed to get status: '${e.message}'";
    }

    setState(() {
      _status = status;
    });
  }

  Future<void> iWasExposed() async {
    try {
      await Dp3t.iWasExposed(onset: DateTime.now(), authentication: 'dkseroedjqwe3343');
    } catch (e) {
      setState(() {
        _message = "Failed iWasExposed: '${e.message}'";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Contact tracing example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(_message),
              RaisedButton(
                child: Text('Reset'),
                onPressed: reset,
              ),
              RaisedButton(
                child: Text('Initialize manually'),
                onPressed: initializeManually,
              ),
              RaisedButton(
                child: Text('Initialize with discovery'),
                onPressed: initializeWithDiscovery,
              ),
              RaisedButton(
                child: Text('Start tracing'),
                onPressed: startTracing,
              ),
              RaisedButton(
                child: Text('Stop tracing'),
                onPressed: stopTracing,
              ),
              Text(_status),
              RaisedButton(
                child: Text('Get status'),
                onPressed: status,
              ),
              RaisedButton(
                child: Text('I was exposed'),
                onPressed: iWasExposed,
              ),
            ]
          ),
        ),
      ),
    );
  }
}
