import 'package:stock/src/errors.dart';
import 'package:stock/src/stock_response.dart';

/// Useful [StockResponse] extensions.
extension StockResponseExtensions<T> on StockResponse<T> {
  /// Invoke [onData] if the response is successful, [onLoading] if the response
  /// is loading, and [onError] if the response is an error.
  E map<E>({
    required E Function(StockResponseLoading<T> value) onLoading,
    required E Function(StockResponseData<T> value) onData,
    required E Function(StockResponseError<T> value) onError,
  }) {
    if (this is StockResponseLoading<T>) {
      return onLoading(this as StockResponseLoading<T>);
    } else if (this is StockResponseData<T>) {
      return onData(this as StockResponseData<T>);
    } else if (this is StockResponseError<T>) {
      return onError(this as StockResponseError<T>);
    } else {
      throw StockError('Unknown StockResponse type: $this');
    }
  }

  /// Invoke [onData] or [orElse] as fallback if the response is successful,
  /// [onLoading] or [orElse] as fallback if the response is loading, and
  /// [onError] or [orElse] as fallback if the response is an error.
  E maybeMap<E>({
    E Function(StockResponseLoading<T> value)? onLoading,
    E Function(StockResponseData<T> value)? onData,
    E Function(StockResponseError<T> value)? onError,
    required E Function() orElse,
  }) =>
      map(
        onLoading: onLoading ?? (_) => orElse(),
        onData: onData ?? (_) => orElse(),
        onError: onError ?? (_) => orElse(),
      );

  /// Invoke [onData] if the response is successful, [onLoading] if the response
  /// is loading, and [onError] if the response is an error.
  E when<E>({
    required E Function() onLoading,
    required E Function(T data) onData,
    required E Function(Object error, StackTrace? stackTrace) onError,
  }) =>
      map(
        onLoading: (value) => onLoading(),
        onData: (value) => onData(value.value),
        onError: (value) => onError(value.error, value.stackTrace),
      );

  /// Invoke [onData] or [orElse] as fallback if the response is successful,
  /// [onLoading] or [orElse] as fallback if the response is loading, and
  /// [onError] or [orElse] as fallback if the response is an error.
  E maybeWhen<E>({
    E Function()? onLoading,
    E Function(T data)? onData,
    E Function(Object error, StackTrace? stackTrace)? onError,
    required E Function() orElse,
  }) =>
      when(
        onLoading: onLoading ?? () => orElse(),
        onData: onData ?? (_) => orElse(),
        onError: onError ?? (_, __) => orElse(),
      );

  /// Returns the available data or throws error if there is no data.
  T requireData() {
    if (this is StockResponseData<T>) {
      return (this as StockResponseData<T>).value;
    } else if (isError) {
      // ignore: only_throw_errors
      throw (this as StockResponseError<T>).error;
    } else if (isLoading) {
      throw StockError('There is no data in loading');
    } else {
      throw StockError(
        'Type error requireData expect either Success, '
        'Error but was given $runtimeType',
      );
    }
  }

  /// If there is data available, returns it; otherwise returns null.
  T? getDataOrNull() => this is StockResponseData<T>
      ? (this as StockResponseData<T>).value
      : null;

  /// If this [StockResponse] is of type [StockResponseError], throws the
  /// exception. Otherwise, does nothing.
  void throwIfError() {
    if (this is StockResponseError) {
      // ignore: only_throw_errors
      throw (this as StockResponseError).error;
    }
  }

  /// Returns if the response is a [StockResponseLoading]
  bool get isLoading => this is StockResponseLoading;

  /// Returns if the response is a [StockResponseError]
  bool get isError => this is StockResponseError;

  /// Returns if the response is a [StockResponseData]
  bool get isData => this is StockResponseData;
}
