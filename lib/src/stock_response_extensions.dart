import 'package:stock/src/errors.dart';
import 'package:stock/src/extensions/stock_response_internal_extensions.dart';
import 'package:stock/src/stock_response.dart';

/// Useful [StockResponse] extensions.
extension StockResponseExtensions<T> on StockResponse<T> {
  /// Returns the available data or throws error if there is no data.
  T requireData() => switch (this) {
        StockResponseLoading<T>() =>
          throw StockError('There is no data in loading'),
        StockResponseData<T>(value: final value) => value,
        // ignore: only_throw_errors
        StockResponseError<T>(error: final error) => throw error,
      };

  /// If there is data available, returns it; otherwise returns null.
  T? getDataOrNull() => switch (this) {
        StockResponseData<T>(value: final value) => value,
        _ => null
      };

  /// Returns the available data or throws error if there is no data.
  Object requireError() => switch (this) {
        StockResponseError<T>(error: final error) => error,
        _ => throw StockError(
            'Response is not an StockResponseError. Response: $this',
          ),
      };

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

  /// Invokes [onData] to transform the StockResponse<T> into a StockResponse<E>
  /// If the response is StockResponseError or StockResponseLoading, the
  /// original StockResponse is returned but with a new type [E].
  /// If the response is StockResponseData, the [onData] is invoked to transform
  /// the data into a new data of type [E].
  StockResponse<E> mapData<E>(
    E Function(StockResponseData<T> value) onData,
  ) =>
      this is StockResponseData<T>
          ? StockResponse.data(origin, onData(this as StockResponseData<T>))
          : swapType<E>();

  /// Invokes [onData] if the response is successful, [onLoading] if the
  /// response is loading, and [onError] if the response is an error.
  E map<E>({
    required E Function(StockResponseLoading<T> value) onLoading,
    required E Function(StockResponseData<T> value) onData,
    required E Function(StockResponseError<T> value) onError,
  }) =>
      switch (this) {
        StockResponseLoading<T>() => onLoading(this as StockResponseLoading<T>),
        StockResponseData<T>() => onData(this as StockResponseData<T>),
        StockResponseError<T>() => onError(this as StockResponseError<T>),
      };

  /// Invokes [onData] or [orElse] as fallback if the response is successful,
  /// [onLoading] or [orElse] as fallback if the response is loading, and
  /// [onError] or [orElse] as fallback if the response is an error.
  E maybeMap<E>({
    required E Function() orElse,
    E Function(StockResponseLoading<T> value)? onLoading,
    E Function(StockResponseData<T> value)? onData,
    E Function(StockResponseError<T> value)? onError,
  }) =>
      map(
        onLoading: onLoading ?? (_) => orElse(),
        onData: onData ?? (_) => orElse(),
        onError: onError ?? (_) => orElse(),
      );

  /// Invokes [onData] if the response is successful,
  /// [onLoading] if the response is loading, and
  /// [onError] if the response is an error.
  /// If the callback is not provided, null is returned.
  E? mapOrNull<E>({
    E Function(StockResponseLoading<T> value)? onLoading,
    E Function(StockResponseData<T> value)? onData,
    E Function(StockResponseError<T> value)? onError,
  }) =>
      maybeMap(
        onLoading: onLoading,
        onData: onData,
        onError: onError,
        orElse: () => null,
      );

  /// Invokes [onData] if the response is successful, [onLoading] if the
  /// response is loading, and [onError] if the response is an error.
  E when<E>({
    required E Function(ResponseOrigin origin) onLoading,
    required E Function(ResponseOrigin origin, T data) onData,
    required E Function(
      ResponseOrigin origin,
      Object error,
      StackTrace? stackTrace,
    ) onError,
  }) =>
      map(
        onLoading: (value) => onLoading(value.origin),
        onData: (value) => onData(value.origin, value.value),
        onError: (value) => onError(
          value.origin,
          value.error,
          value.stackTrace,
        ),
      );

  /// Invokes [onData] if the response is successful,
  /// [onLoading] if the response is loading, and
  /// [onError] if the response is an error.
  /// If the callback is not provided, null is returned.
  E? whenOrNull<E>({
    E Function(ResponseOrigin origin)? onLoading,
    E Function(ResponseOrigin origin, T data)? onData,
    E Function(
      ResponseOrigin origin,
      Object error,
      StackTrace? stackTrace,
    )? onError,
  }) =>
      maybeWhen(
        onLoading: onLoading,
        onData: onData,
        onError: onError,
        orElse: (origin) => null,
      );

  /// Invokes [onData] or [orElse] as fallback if the response is successful,
  /// [onLoading] or [orElse] as fallback if the response is loading, and
  /// [onError] or [orElse] as fallback if the response is an error.
  E maybeWhen<E>({
    required E Function(ResponseOrigin origin) orElse,
    E Function(ResponseOrigin origin)? onLoading,
    E Function(ResponseOrigin origin, T data)? onData,
    E Function(
      ResponseOrigin origin,
      Object error,
      StackTrace? stackTrace,
    )? onError,
  }) =>
      when(
        onLoading: onLoading ?? (origin) => orElse(origin),
        onData: onData ?? (origin, _) => orElse(origin),
        onError: onError ?? (origin, _, __) => orElse(origin),
      );
}
