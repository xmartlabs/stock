import 'package:meta/meta.dart';
import 'package:stock/src/fetcher.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock.dart';

/// Holder for responses from Stock.
///
/// Instead of using regular error channels (a.k.a. throwing exceptions), Stock
/// uses this holder class to represent each response. This allows the [Stream]
/// to keep flowing even if an error happens so that if there is an observable
/// single source of truth, the application can keep observing it.
sealed class StockResponse<Output> {
  const StockResponse._(this.origin);

  /// Loading event dispatched by [Stock] to signal the [Fetcher] is currently
  /// running.
  const factory StockResponse.loading(ResponseOrigin origin) =
      StockResponseLoading<Output>;

  /// Data dispatched by [Stock]
  const factory StockResponse.data(ResponseOrigin origin, Output value) =
      StockResponseData<Output>;

  /// Error dispatched by a pipeline
  const factory StockResponse.error(
    ResponseOrigin origin,
    Object error, [
    StackTrace? stackTrace,
  ]) = StockResponseError<Output>;

  /// The origin of the response
  final ResponseOrigin origin;
}

/// Loading event dispatched by [Stock] to signal the [Fetcher] is currently
/// running.
@immutable
final class StockResponseLoading<T> extends StockResponse<T> {
  /// StockResponseLoading constructor
  const StockResponseLoading(super.origin) : super._();

  @override
  String toString() => 'StockResponse<$T>.loading(origin: $origin)';

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StockResponseLoading<T> &&
            origin == other.origin);
  }

  @override
  int get hashCode => Object.hash(runtimeType, origin.hashCode);
}

/// Data dispatched by [Stock]
@immutable
final class StockResponseData<T> extends StockResponse<T> {
  /// StockResponseData constructor
  const StockResponseData(super.origin, this.value) : super._();

  /// The data value
  final T value;

  @override
  String toString() => 'StockResponse<$T>.data(origin: $origin, value: $value)';

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is StockResponseData<T> &&
          other.origin == origin &&
          other.value == value);

  @override
  int get hashCode => Object.hash(runtimeType, origin.hashCode, value.hashCode);
}

/// Error dispatched by a pipeline
@immutable
final class StockResponseError<T> extends StockResponse<T> {
  /// StockResponseError constructor
  const StockResponseError(super.origin, this.error, [this.stackTrace])
      : super._();

  /// The error
  final Object error;

  /// The error stacktrace
  final StackTrace? stackTrace;

  @override
  String toString() =>
      'StockResponse<$T>.error(origin: $origin, error: $error, '
      'stackTrace: $stackTrace)';

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other.runtimeType == runtimeType &&
          other is StockResponseError<T> &&
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

/// Represents the origin for a [StockResponse].
enum ResponseOrigin {
  /// [StockResponse] is sent from the [SourceOfTruth]
  sourceOfTruth,

  /// [StockResponse] is sent from a [Fetcher],
  fetcher,
}
