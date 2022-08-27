import 'package:stock/errors.dart';
import 'package:stock/stock_response.dart';

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

  T requireData() {
    if (this is StockResponseData<T>) {
      return (this as StockResponseData<T>).value;
    } else if (isError) {
      throw (this as StockResponseError<T>).error;
    } else if (isLoading) {
      throw StockError('There is no data in loading');
    } else {
      throw StockError('Unknown type');
    }
  }

  T? get data => this is StockResponseData<T>
      ? (this as StockResponseData<T>).value
      : null;

  bool get isLoading => this is StockResponseLoading;

  bool get isError => this is StockResponseError;
}

extension StockResponseStreamExtensions<T> on Stream<StockResponse<T?>> {
  Stream<StockResponse<T>> whereDataNotNull() => where(
        (event) =>
            event is StockResponseData<T?> ? event.requireData() != null : true,
      ).map((event) => event.swapType<T>());
}
