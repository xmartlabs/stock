import 'package:stock/store_response.dart';

extension ResponseExtensions<T> on StoreResponse<T> {
  StoreResponse<T> removeStacktraceIfNeeded() => this is StoreResponseError<T>
      ? StoreResponse.error(origin, (this as StoreResponseError<T>).error)
      : this;
}
