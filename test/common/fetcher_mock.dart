class MockFutureFetcher<Key, Output> {
  MockFutureFetcher(Future<Output> Function(Key key) factory) {
    this.factory = (key) {
      invocations++;
      return factory(key);
    };
  }

  int invocations = 0;

  late Future<Output> Function(Key key) factory;
}
