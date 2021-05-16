
# Flutter Lazy ListView

  
<p  align="center"><img  src="https://raw.githubusercontent.com/yasaswick/flutter_lazy_listview/master/assets/logo.png"  height="250"  alt="Logo" />

  

[![Build Actions Status](https://github.com/yasaswick/flutter_lazy_listview/workflows/Dart/badge.svg)](https://github.com/yasaswick/flutter_lazy_listview/actions)

  
A light-weight minimalist dart packackage for lazy loading of infinite lists.. (packed with some cool features) Uses dart streams and sliverlists under-the-hood.

## Parameters

[Controller]
This is the default DataFeedController of your data type. This is a required parameter

[onRefresh]
Async function that needs to be run when a user pulls down on the list. If null; this will disable the pull from top animations.

[noDataBuilder]
This can be used to build a widget or a placeholder when there is no data.

[emptyListBuilder]
This can be used to build a widget or a placeholder when the list is empty.

[errorBuilder]
This can be used to build a widget or a placeholder when there is a error in the list.

[offSet]
The offset from the bottom where the onReachingend funtion to be called. default is 250.

[onReachingEnd]
The async function which will be called when the user scrolls towards the end of the list. (depends on the offset as well)

[itemBuilder]
The default item builder.refer the example

[separatorBuilder]
The default separator builder. To use this you must use [FlutterLazyListView<YourModel>.separated]


## Screenshot

![Lazy loading list](https://raw.githubusercontent.com/yasaswick/flutter_lazy_listview/master/assets/gif.gif)![Pull to Refresh](https://raw.githubusercontent.com/yasaswick/flutter_lazy_listview/master/assets/pull.gif)![Separator Builder](https://raw.githubusercontent.com/yasaswick/flutter_lazy_listview/master/assets/separator.gif)
  

## Usage

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lazy_listview/flutter_lazy_listview.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

//Data feed controller
  var _controller = DataFeedController<YourMode;>();

  //Async function which loads next data
  //
  //You can add your api calls etc.
  _addDummyMessages() async {
    List<YourModel> list = [];
   
   //append data to the controller
    await Future.delayed(Duration(seconds: 3), () {
      _controller.appendData(list);
    });
  }

  @override
  void initState() {
    super.initState();
    _addDummyMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FlutterLazyListView<YourModel>(
                dataFeedController: _controller,
                offset: 250,
                onReachingEnd: () async {
			// async function which is called when scrolls to end
                  await _addDummyMessages();
                },
                itemBuilder: (BuildContext c, YourModel m, int d) {
                  return YourWidget();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```
  

## Authors

  

Yasas Wickramarathne