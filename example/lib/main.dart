import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'package:flutter_lazy_listview/flutter_lazy_listview.dart';
import 'package:faker/faker.dart';
import 'package:avatars/avatars.dart';

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
  var _controller = DataFeedController<Message>();

  //async function which loads next data
  _addDummyMessages() async {
    List<Message> list = [];
    for (var i = 0; i < 10; i++) {
      var faker = new Faker();
      list.add(Message(faker.person.name(), faker.lorem.sentence(), false));
    }
    await Future.delayed(Duration(seconds: 3), () {
      _controller.appendData(list);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _addDummyMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FlutterLazyListView<Message>.separated(
                dataFeedController: _controller,
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 2));
                },
                noDataBuilder: Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/data.png', height: 50),
                      SizedBox(
                        height: 10,
                      ),
                      Text('No data')
                    ],
                  ),
                ),
                offset: 250,
                onReachingEnd: () async {
                  await _addDummyMessages();
                },
                itemBuilder: (BuildContext c, Message m, int d) {
                  return ListTile(
                    title: Text(m.title),
                    subtitle: Text(m.message),
                    leading: Avatar(
                        name: m.title,
                        shape: AvatarShape.circle(20),
                        placeholderColors: [CupertinoColors.systemGreen]),
                    trailing: IconButton(
                        icon: Icon(
                            m.isFav ? Icons.favorite : Icons.favorite_border,
                            color: CupertinoColors.systemRed),
                        onPressed: () {
                          _controller.replaceData(
                              d, m.copyWith(isFav: !m.isFav));
                        }),
                  );
                },
                separatorBuilder:
                    (BuildContext context, Message data, int index) {
                  return Divider(
                    thickness: 1,
                    color: Colors.lightGreen,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
