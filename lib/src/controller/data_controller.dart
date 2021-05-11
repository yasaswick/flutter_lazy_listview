part of flutter_lazy_listview;

/// DataFeed Controller
///
/// This class is used to organize all the stream controllers used.
class DataFeedController<T> {
  List<T> data = [];

  ///Stream controller for data feed
  final _dataFeed = StreamController<List<T>>.broadcast();

  ///Stream controller for status feed
  final _statusFeed = StreamController<ConnectionStatus>.broadcast();

  ///Exposing data feed
  ///
  ///This exposes data stream
  StreamSink<List<T>> get dataFeedSink => _dataFeed.sink;
  Stream<List<T>> get dataFeedStream => _dataFeed.stream;

  ///Exposing status feed
  ///
  ///This exposes status stream
  StreamSink<ConnectionStatus> get statusSink => _statusFeed.sink;
  Stream<ConnectionStatus> get statusStream => _statusFeed.stream;

  ///Appends data
  ///
  ///This appends data to the existing list and adds to the stream
  void appendData(List<T> value) {
    data.addAll(value);
    _dataFeed.sink.add(data);
  }

  ///Find and replace the objects by index
  ///
  ///Use this to change any object by its index
  void replaceData(int index, T value) {
    if (data.length > index) {
      data[index] = value;
      _dataFeed.sink.add(data);
    }
  }

  ///Adds an empty array to the stream
  void flushData() {
    _dataFeed.sink.add([]);
  }

  ///Dispose method to close all stream controllers
  void dispose() {
    _dataFeed.close();
    _statusFeed.close();
  }
}
