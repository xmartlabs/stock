// ignore_for_file: public_member_api_docs

import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';

extension StockResponseExtensions<T> on StockResponse<T> {
  StockResponse<R> swapType<R>() => when(
        onData: (origin, data) => StockResponse.data(origin, data as R),
        onLoading: StockResponse.loading,
        onError: StockResponse.error,
      );
}

extension StockResponseStreamExtensions<T> on Stream<StockResponse<T?>> {
  Stream<StockResponse<T>> whereDataNotNull() => where(
        (event) => !event.isData || event.requireData() != null,
      ).map((event) => event.swapType<T>());
}
