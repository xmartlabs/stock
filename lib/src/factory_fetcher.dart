import 'package:stock/fetcher.dart';

class FactoryFetcher<Key, Output> implements Fetcher<Key, Output> {
  Stream<Output> Function(Key key) factory;

  FactoryFetcher(this.factory);
}

class FutureFetcher<Key, Output> extends FactoryFetcher<Key, Output> {
  FutureFetcher(Future<Output> Function(Key key) factory)
      : super((key) => Stream.fromFuture(factory(key)));
}

class StreamFetcher<Key, Output> extends FactoryFetcher<Key, Output> {
  StreamFetcher(factory) : super(factory);
}
