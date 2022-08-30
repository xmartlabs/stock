import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';

/// Fetcher is used by [Stock] to fetch network records of the type [T]
/// for a given key of the type [Key]. The return type is [Stream] to
/// allow for multiple results per request.
///
/// Note: [Stock] does not catch exceptions thrown by a [Fetcher].
/// Use [StockResponseError] to communicate expected errors.
///
/// See [ofFuture] for easily translating from a regular `Future` function.
/// See [ofStream], for easily translating to [StockResponse] (and
/// automatically transforming exceptions into [StockResponseError].
abstract class Fetcher<Key, T> {
  Fetcher._();

  /// "Creates" a [Fetcher] from a [futureFactory] and translates the results
  /// into a [StockResponse].
  ///
  /// Emitted values will be wrapped in [StockResponseData]. If an exception
  /// disrupts the stream then it will be wrapped in [StockResponseError]
  ///
  /// Use when creating a [Stock] that fetches objects in a single response per
  /// request network protocol (e.g Http).
  static Fetcher<Key, Output> ofFuture<Key, Output>(
    Future<Output> Function(Key key) futureFactory,
  ) =>
      FutureFetcher(futureFactory);

  /// "Creates" a [Fetcher] from a [streamFactory] and translates the results
  /// into a [StockResponse].
  ///
  /// Emitted values will be wrapped in [StockResponseData]. If an exception
  /// disrupts the flow then it will be wrapped in [StockResponseError].
  ///
  /// Use when creating a [Stock] that fetches objects in a multiple responses
  /// per request network protocol (e.g Web Sockets).
  static Fetcher<Key, Output> ofStream<Key, Output>(
    Stream<Output> Function(Key key) streamFactory,
  ) =>
      StreamFetcher(streamFactory);
}
