part of flutter_lazy_listview;

enum ConnectionStatus { LOADING, BUSY, ERROR, COMPLETED }

class DataFeedController<T> {
  List<T> data = [];

  //stream controller for data feed
  final _dataFeed = StreamController<List<T>>.broadcast();
  //stream controller for status feed
  final _statusFeed = StreamController<ConnectionStatus>.broadcast();

  //exposing data feed
  StreamSink<List<T>> get dataFeedSink => _dataFeed.sink;
  Stream<List<T>> get dataFeedStream => _dataFeed.stream;

  //exposing status feed
  StreamSink<ConnectionStatus> get statusSink => _statusFeed.sink;
  Stream<ConnectionStatus> get statusStream => _statusFeed.stream;

  void appendData(List<T> value) {
    data.addAll(value);
    _dataFeed.sink.add(data);
  }

  void replaceData(int index, T value) {
    if (data.length > index) {
      data[index] = value;
      _dataFeed.sink.add(data);
    }
  }

  void flushData() {
    _dataFeed.sink.add([]);
  }

  void dispose() {
    _dataFeed.close();
    _statusFeed.close();
  }
}
