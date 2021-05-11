import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FlutterLazyListViewExample(),
    );
  }
}

class FlutterLazyListViewExample extends StatefulWidget {
  @override
  _FlutterLazyListViewExampleState createState() =>
      _FlutterLazyListViewExampleState();
}

class _FlutterLazyListViewExampleState
    extends State<FlutterLazyListViewExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
