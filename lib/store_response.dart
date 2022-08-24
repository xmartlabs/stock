import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/store.dart';

/// Holder for responses from Store.
///
/// Instead of using regular error channels (a.k.a. throwing exceptions), Store uses this holder
/// class to represent each response. This allows the [Stream] to keep running even if an error happens
/// so that if there is an observable single source of truth, application can keep observing it.
class StoreResponse<Output> {
  final ResponseOrigin origin;

  const StoreResponse._(this.origin);

  /// Loading event dispatched by [Store] to signal the [Fetcher] is in progress.
  const factory StoreResponse.loading(ResponseOrigin origin) =
      StoreResponseLoading<Output>;

  /// Data dispatched by [Store]
  const factory StoreResponse.data(ResponseOrigin origin, Output value) =
      StoreResponseData<Output>;

  /// Error dispatched by a pipeline
  const factory StoreResponse.error(ResponseOrigin origin, Object error,
      [StackTrace? stackTrace]) = StoreResponseError<Output>;
}

class StoreResponseLoading<T> extends StoreResponse<T> {
  const StoreResponseLoading(origin) : super._(origin);

  @override
  String toString() => 'StoreResponse<$T>.loading(origin: $origin)';

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StoreResponseLoading<T> &&
            origin == other.origin);
  }

  @override
  int get hashCode => Object.hash(runtimeType, origin.hashCode);
}

class StoreResponseData<T> extends StoreResponse<T> {
  final T value;

  const StoreResponseData(ResponseOrigin origin, this.value) : super._(origin);

  @override
  String toString() => 'StoreResponse<$T>.data(origin: $origin, value: $value)';

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is StoreResponseData<T> &&
          other.origin == origin &&
          other.value == value);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        origin.hashCode,
        value.hashCode,
      );
}

class StoreResponseError<T> extends StoreResponse<T> {
  final Object error;
  final StackTrace? stackTrace;

  const StoreResponseError(ResponseOrigin origin, this.error, [this.stackTrace])
      : super._(origin);

  @override
  String toString() =>
      'StoreResponse<$T>.error(origin: $origin, error: $error, stackTrace: $stackTrace)';

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is StoreResponseError<T> &&
          other.origin == origin &&
          other.error == error &&
          other.stackTrace == stackTrace);

  @override
  int get hashCode => Object.hash(
        runtimeType,
        origin.hashCode,
        error.hashCode,
        stackTrace.hashCode,
      );
}

/// Represents the origin for a [StoreResponse].
enum ResponseOrigin {
  /// [StoreResponse] is sent from the cache
  cache,

  /// [StoreResponse] is sent from the [SourceOfTruth]
  sourceOfTruth,

  /// [StoreResponse] is sent from a [Fetcher],
  fetcher,
}
