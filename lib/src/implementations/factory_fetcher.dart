// ignore_for_file: public_member_api_docs

import 'package:stock/src/fetcher.dart';

sealed class FactoryFetcher<Key, Output> extends Fetcher<Key, Output> {
  FactoryFetcher(this.factory);

  Stream<Output> Function(Key key) factory;
}

final class FutureFetcher<Key, Output> extends FactoryFetcher<Key, Output> {
  FutureFetcher(Future<Output> Function(Key key) factory)
      : super((key) => Stream.fromFuture(factory(key)));
}

final class StreamFetcher<Key, Output> extends FactoryFetcher<Key, Output> {
  StreamFetcher(super.factory);
}
