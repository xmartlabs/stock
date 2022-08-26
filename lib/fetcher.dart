import 'package:stock/src/factory_fetcher.dart';

abstract class Fetcher<Key, Output> {
  Fetcher._();

  static Fetcher<Key, Output> ofFuture<Key, Output>(
    Future<Output> Function(Key key) futureFactory,
  ) =>
      FutureFetcher(futureFactory);

  static Fetcher<Key, Output> ofStream<Key, Output>(
    Stream<Output> Function(Key key) streamFactory,
  ) =>
      StreamFetcher(streamFactory);
}
