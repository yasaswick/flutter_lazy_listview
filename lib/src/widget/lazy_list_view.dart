part of flutter_lazy_listview;

//typedef for item builder
typedef Widget ItemBuilder<T>(BuildContext context, T data, int index);

class FlutterLazyListView<T> extends StatefulWidget {
  ///Data feed controller
  ///
  ///[DataFeedController] of generic type
  final DataFeedController<T> dataFeedController;

  ///Item builder

  final ItemBuilder<T> itemBuilder;

  ///Async method to load next page when end is reached
  final Function onReachingEnd;

  ///Offset to use to trigger [onReachEnd] method
  final double offset;

  ///Progress builder;
  ///
  ///Widget which is displayed while the async[onReachEnd] is awaiting
  final Widget progressBuilder;

  ///Error Widget builder;
  ///
  ///Widget which is displayed when there is an error is stream builder
  final Widget errorBuilder;

  ///Empty list widget builder
  ///
  ///Widget which is displayed when list is empty
  final Widget emptyListBuilder;

  ///No data widget builder
  ///
  ///Widget which is displayed when no data is present
  final Widget noDataBuilder;

  const FlutterLazyListView(
      {@required this.dataFeedController,
      @required this.itemBuilder,
      @required this.onReachingEnd,
      this.offset = 150,
      this.progressBuilder,
      this.errorBuilder,
      this.emptyListBuilder,
      this.noDataBuilder})
      : assert(onReachingEnd != null),
        assert(itemBuilder != null),
        assert(dataFeedController != null);

  @override
  _FlutterLazyListViewState createState() => _FlutterLazyListViewState<T>();
}

class _FlutterLazyListViewState<T> extends State<FlutterLazyListView<T>> {
  bool _isRequestCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<T>>(
          stream: widget.dataFeedController.dataFeedStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              if (data.isEmpty) {
                return widget.emptyListBuilder ??
                    Center(child: Text('Empty List'));
              } else {
                return NotificationListener<ScrollNotification>(
                  onNotification: (info) => _onNotification(info),
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _itemBuilder(context, data[index], index);
                          },
                          childCount: snapshot.data.length,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: StreamBuilder(
                            initialData: ConnectionStatus.COMPLETED,
                            stream: widget.dataFeedController.statusStream,
                            builder: (context, snapshot) {
                              switch (snapshot.data) {
                                case ConnectionStatus.BUSY:
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 25),
                                    child: widget.progressBuilder ??
                                        CupertinoActivityIndicator(),
                                  );
                                  break;
                                default:
                                  return Container();
                              }
                            }),
                      )
                    ],
                  ),
                );
              }
            } else {
              // _loadData();
              return widget.emptyListBuilder ??
                  Center(
                    child: widget.noDataBuilder ?? Text('No data'),
                  );
            }
          }),
    );
  }

  Widget _itemBuilder(BuildContext context, T data, int index) {
    return widget.itemBuilder(context, data, index);
  }

  bool _onNotification(ScrollNotification notification) {
    if (Axis.vertical == notification.metrics.axis) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent <
                notification.metrics.pixels &&
            notification.metrics.maxScrollExtent -
                    notification.metrics.pixels <=
                widget.offset) {
          _loadData();
        }
        return true;
      }
    }
    return false;
  }

  _loadData() async {
    if (_isRequestCompleted) {
      _isRequestCompleted = false;
      widget.dataFeedController.statusSink.add(ConnectionStatus.BUSY);
      print('loaded');
      await widget.onReachingEnd();
      _isRequestCompleted = true;
      widget.dataFeedController.statusSink.add(ConnectionStatus.COMPLETED);
    }
  }
}
