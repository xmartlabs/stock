import 'package:stock/src/errors.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';

extension StockResponseExtensions<T> on StockResponse<T> {
  StockResponse<R> swapType<R>() {
    if (this is StockResponseData<T>) {
      return StockResponse.data(origin, requireData() as R);
    } else if (isError) {
      var errorResponse = this as StockResponseError<T>;
      return StockResponse.error(
        origin,
        errorResponse.error,
        errorResponse.stackTrace,
      );
    } else if (isLoading) {
      return StockResponse.loading(origin);
    } else {
      throw StockError('Unknown type');
    }
  }
}

extension StockResponseStreamExtensions<T> on Stream<StockResponse<T?>> {
  Stream<StockResponse<T>> whereDataNotNull() => where(
        (event) =>
            event is StockResponseData<T?> ? event.requireData() != null : true,
      ).map((event) => event.swapType<T>());
}
