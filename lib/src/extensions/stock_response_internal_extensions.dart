// ignore_for_file: public_member_api_docs

import 'package:stock/src/errors.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';

extension StockResponseExtensions<T> on StockResponse<T> {
  StockResponse<R> swapType<R>() {
    if (this is StockResponseData<T>) {
      return StockResponse.data(origin, requireData() as R);
    } else if (isError) {
      final errorResponse = this as StockResponseError<T>;
      return StockResponse.error(
        origin,
        errorResponse.error,
        errorResponse.stackTrace,
      );
    } else if (isLoading) {
      return StockResponse.loading(origin);
    } else {
      throw StockError(
        'Type error swapType expect either Success, Error or Loading but was '
        'given $runtimeType',
      );
    }
  }
}

extension StockResponseStreamExtensions<T> on Stream<StockResponse<T?>> {
  Stream<StockResponse<T>> whereDataNotNull() => where(
        (event) => !event.isData || event.requireData() != null,
      ).map((event) => event.swapType<T>());
}
