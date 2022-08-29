import 'package:stock/errors.dart';
import 'package:stock/store_response.dart';

extension StoreResponseExtensions<T> on StoreResponse<T> {
  StoreResponse<R> swapType<R>() {
    if (this is StoreResponseData<T>) {
      return StoreResponse.data(origin, requireData() as R);
    } else if (isError) {
      var errorResponse = this as StoreResponseError<T>;
      return StoreResponse.error(
        origin,
        errorResponse.error,
        errorResponse.stackTrace,
      );
    } else if (isLoading) {
      return StoreResponse.loading(origin);
    } else {
      throw StockError(
        'Type error swapType expect either Success, Error or Loading but was given $runtimeType',
      );
    }
  }

  T requireData() {
    if (this is StoreResponseData<T>) {
      return (this as StoreResponseData<T>).value;
    } else if (isError) {
      throw (this as StoreResponseError<T>).error;
    } else if (isLoading) {
      throw StockError('There is no data in loading');
    } else {
      throw StockError(
        'Type error requireData expect either Success, Error but was given $runtimeType',
      );
    }
  }

  T? get data => this is StoreResponseData<T>
      ? (this as StoreResponseData<T>).value
      : null;

  bool get isLoading => this is StoreResponseLoading;

  bool get isError => this is StoreResponseError;
}

extension StoreResponseStreamExtensions<T> on Stream<StoreResponse<T?>> {
  Stream<StoreResponse<T>> whereDataNotNull() => where(
        (event) =>
            event is StoreResponseData<T?> ? event.requireData() != null : true,
      ).map((event) => event.swapType<T>());
}
