import 'package:stock/src/factory_fetcher.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

/// Fetcher is used by [Store] to fetch network records of the type [Output]
/// for a given key of the type [Key]. The return type is [Stream] to
/// allow for multiple result per request.
///
/// Note: Store does not catch exceptions thrown by a [Fetcher].
/// Use [StoreResponseError] to communicate expected errors.
///
/// See [ofFuture] for easily translating from a regular `Future` function.
/// See [ofStream], for easily translating to [StoreResponse] (and
/// automatically transforming exceptions into [StoreResponseError].
class Fetcher<Key, Output> {
  /// "Creates" a [Fetcher] from a [futureFactory] and translate the results to a [StoreResponse].
  ///
  /// Emitted values will be wrapped in [StoreResponseData]. if an exception disrupts the stream then
  /// it will be wrapped in [StoreResponseError]
  ///
  /// Use when creating a [Store] that fetches objects in a single response per request
  /// network protocol (e.g Http).
  static Fetcher<Key, Output> ofFuture<Key, Output>(
          Future<Output> Function(Key key) futureFactory) =>
      FutureFetcher(futureFactory);

  /// "Creates" a [Fetcher] from a [streamFactory] and translate the results to a [StoreResponse].
  ///
  /// Emitted values will be wrapped in [StoreResponseData]. if an exception disrupts the flow then
  /// it will be wrapped in [StoreResponseError].
  ///
  /// Use when creating a [Store] that fetches objects in a multiple responses per request
  /// network protocol (e.g Web Sockets).
  static Fetcher<Key, Output> ofStream<Key, Output>(
          Stream<Output> Function(Key key) streamFactory) =>
      StreamFetcher(streamFactory);
}
