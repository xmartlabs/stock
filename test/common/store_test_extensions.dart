import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'response_extensions.dart';

extension StoreExtensions<Key, Output> on Store<Key, Output> {
  Future<List<StoreResponse<Output>>> getFreshResult(
    Key key, {
    refresh = true,
    Duration delay = const Duration(milliseconds: 300),
  }) async {
    List<StoreResponse<Output>> resultList = [];
    final subscription = stream(key, refresh: refresh)
        .listen((element) => resultList.add(element));
    await Future.delayed(delay);
    await subscription.cancel();
    return resultList;
  }

  Future<List<StoreResponse<Output>>> getFreshResultRemovingErrorStackTraces(
    Key key, {
    refresh = true,
    Duration delay = const Duration(milliseconds: 300),
  }) =>
      getFreshResult(key, refresh: refresh, delay: delay).then((value) =>
          value.map((items) => items.removeStacktraceIfNeeded()).toList());
}
