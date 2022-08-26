import 'dart:async';

import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'response_extensions.dart';

extension StoreExtensions<Key, Output> on Store<Key, Output> {
  Future<List<StoreResponse<Output>>> getFreshResult(
    Key key, {
    refresh = true,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    final resultListener = ResultListener(stream(key, refresh: refresh));
    await Future.delayed(delay);
    return await resultListener.stopAndGetResult();
  }

  Future<List<StoreResponse<Output>>> getFreshResultRemovingErrorStackTraces(
    Key key, {
    refresh = true,
    Duration delay = const Duration(milliseconds: 100),
  }) =>
      getFreshResult(key, refresh: refresh, delay: delay).then((value) =>
          value.map((items) => items.removeStacktraceIfNeeded()).toList());
}

class ResultListener<T> {
  final Stream<T> _stream;
  final List<T> _resultList = [];
  StreamSubscription<T>? _subscription;

  ResultListener(this._stream, {bool startListener = true}) {
    if (startListener) {
      listenChanges();
    }
  }

  void listenChanges() {
    _subscription = _stream.listen(_resultList.add);
  }

  Future<List<T>> stopAndGetResult() async {
    _subscription?.cancel();
    return _resultList;
  }
}
