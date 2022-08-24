import 'package:stock/errors.dart';
import 'package:stock/store_response.dart';

extension StoreResponseExtensions<T> on StoreResponse<T> {
  StoreResponse<R> swapType<R>() {
    return map(
      data: (response) => StoreResponse.data(origin, response.value as R),
      loading: (_) => StoreResponse.loading(origin),
      error: (response) =>
          StoreResponse.error(origin, response.error, response.stackTrace),
    );
  }

  T requireData() => map(
        data: (response) => response.value,
        loading: (_) => throw StockError('There is no data in loading'),
        error: (response) => throw response.error,
      );

  T? get data => map(
        data: (response) => response.value,
        loading: (_) => null,
        error: (response) => null,
      );

  bool get isLoading => this is StoreResponseLoading;

  bool get isError => this is StoreResponseError;
}

extension StoreResponseStreamExtensions<T> on Stream<StoreResponse<T?>> {
  Stream<StoreResponse<T>> whereDataNotNull() => where(
        (event) =>
            event is StoreResponseData<T?> ? event.requireData() != null : true,
      ).map((event) => event.swapType<T>());
}
