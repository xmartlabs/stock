import 'package:stock/store_response.dart';

extension ResponseExtensions<T> on StoreResponse<T> {
  StoreResponse<T> removeStacktraceIfNeeded() => this is StoreResponseError<T>
      ? (this as StoreResponseError<T>).copyWith(stackTrace: null)
      : this;
}
