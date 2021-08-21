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

  ///Async method to load next page when end is reached
  final Function? onRefresh;

  ///Offset to use to trigger [onReachEnd] method
  final double offset;

  ///Progress builder;
  ///
  ///Widget which is displayed while the async[onReachEnd] is awaiting
  final Widget? progressBuilder;

  ///Error Widget builder;
  ///
  ///Widget which is displayed when there is an error is stream builder
  final Widget? errorBuilder;

  ///Empty list widget builder
  ///
  ///Widget which is displayed when list is empty
  final Widget? emptyListBuilder;

  ///No data widget builder
  ///
  ///Widget which is displayed when no data is present
  final Widget? noDataBuilder;

  ///No data widget builder
  ///
  ///Widget which is displayed when no data is present
  final EdgeInsets padding;

  ///No data widget builder
  ///
  ///Widget which is displayed when no data is present
  final ItemBuilder<T>? separatorBuilder;

  const FlutterLazyListView(
      {required this.dataFeedController,
      required this.itemBuilder,
      required this.onReachingEnd,
      this.offset = 150,
      this.progressBuilder,
      this.errorBuilder,
      this.emptyListBuilder,
      this.noDataBuilder,
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      this.onRefresh})
      : separatorBuilder = null;

  const FlutterLazyListView.separated(
      {required this.dataFeedController,
      required this.itemBuilder,
      required this.onReachingEnd,
      required this.separatorBuilder,
      this.offset = 150,
      this.progressBuilder,
      this.errorBuilder,
      this.emptyListBuilder,
      this.noDataBuilder,
      this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      this.onRefresh});

  @override
  _FlutterLazyListViewState createState() => _FlutterLazyListViewState<T>();
}

class _FlutterLazyListViewState<T> extends State<FlutterLazyListView<T>> {
  bool _isRequestCompleted = true;
  bool _refreshCompleted = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<List<T>>(
          stream: widget.dataFeedController.dataFeedStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;
              if (data.isEmpty) {
                return widget.emptyListBuilder ??
                    Center(child: Text('Empty List'));
              } else {
                return NotificationListener<ScrollNotification>(
                  onNotification: (info) => _onNotification(info),
                  child: CustomScrollView(
                    slivers: [
                      if (widget.onRefresh != null)
                        CupertinoSliverRefreshControl(
                          refreshTriggerPullDistance: 100.0,
                          refreshIndicatorExtent: 60.0,
                          onRefresh: () async {
                            await _refreshData();
                          },
                        ),
                      SliverPadding(
                        padding: widget.padding,
                        sliver: SliverList(
                            delegate: _getChildBuilderDelegate(
                          data: data,
                        )),
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

  SliverChildBuilderDelegate _getChildBuilderDelegate({List<T>? data}) {
    if (widget.separatorBuilder == null) {
      return SliverChildBuilderDelegate((context, index) {
        return widget.itemBuilder(context, data![index], index);
      }, childCount: data!.length);
    } else {
      return SliverChildBuilderDelegate(
        (context, index) {
          final itemIndex = index ~/ 2;
          if (index.isEven) {
            return widget.itemBuilder(context, data![itemIndex], index);
          }
          return widget.separatorBuilder!(context, data![itemIndex], index);
        },
        childCount: math.max(0, data!.length * 2 - 1),
        semanticIndexCallback: (Widget widget, int localIndex) {
          if (localIndex.isEven) {
            return localIndex ~/ 2;
          }
          return null;
        },
      );
    }
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

  Future _loadData() async {
    if (_isRequestCompleted) {
      _isRequestCompleted = false;
      widget.dataFeedController.statusSink.add(ConnectionStatus.BUSY);
      print('loaded');
      await widget.onReachingEnd();
      _isRequestCompleted = true;
      widget.dataFeedController.statusSink.add(ConnectionStatus.COMPLETED);
    }
  }

  Future _refreshData() async {
    if (_refreshCompleted && widget.onRefresh != null) {
      _refreshCompleted = false;
      await widget.onRefresh!();
      _refreshCompleted = true;
    }
  }
}
