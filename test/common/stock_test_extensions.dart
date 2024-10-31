import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:stock/src/implementations/stock_impl.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';

import 'response_extensions.dart';

extension StockExtensions<Key, Output> on Stock<Key, Output> {
  Future<List<StockResponse<Output>>> getFreshResult(
    Key key, {
    bool refresh = true,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final resultListener = ResultListener(stream(key, refresh: refresh));
    await Future<void>.delayed(delay);
    return resultListener.stopAndGetResult();
  }

  Future<List<StockResponse<Output>>> getFreshResultRemovingErrorStackTraces(
    Key key, {
    bool refresh = true,
    Duration delay = const Duration(milliseconds: 100),
  }) =>
      getFreshResult(key, refresh: refresh, delay: delay).then(
        (value) =>
            value.map((items) => items.removeStacktraceIfNeeded()).toList(),
      );

  int get currentStreamSessionCount => (this as StockImpl)
      .currentStreamSessions
      .entries
      .sumBy((e) => e.value.length);
  int get sessionFetcherPendingRequests => (this as StockImpl)
      .sessionFetcherPendingRequests
      .entries
      .sumBy((e) => e.value.length);
}

class ResultListener<T> {
  ResultListener(this._stream, {bool startListener = true}) {
    if (startListener) {
      listenChanges();
    }
  }

  final Stream<T> _stream;
  final List<T> _resultList = [];
  StreamSubscription<T>? _subscription;

  void listenChanges() {
    _subscription = _stream.listen(_resultList.add);
  }

  Future<List<T>> stopAndGetResult() async {
    await _subscription?.cancel();
    return _resultList;
  }
}
