import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stock/store.dart';

import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';
import 'common_mocks.mocks.dart';

void main() {
  group("Fresh tests", () {
    test('Sot is not called when fresh is invoked', () async {
      var fetcher = MockFutureFetcher<int, int>();
      final sourceOfTruth = MockSourceOfTruth<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      when(sourceOfTruth.reader).thenReturn((key) => Stream.value(-1));
      when(sourceOfTruth.writer).thenReturn((key, value) async {});
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await store.fresh(1);
      expect(result, equals(1));
      verifyNever(sourceOfTruth.reader);
      verify(sourceOfTruth.writer).called(1);
    });
  });
  group("Get tests", () {
    test('Fetcher is not called when get is invoked and sot has data',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      final sourceOfTruth = MockSourceOfTruth<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      when(sourceOfTruth.reader).thenReturn((key) => Stream.value(-1));
      when(sourceOfTruth.writer).thenReturn((key, value) async {});
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await store.get(1);
      expect(result, equals(-1));
      verifyNever(fetcher.factory);
      verify(sourceOfTruth.reader).called(1);
      verifyNever(sourceOfTruth.writer);
    });

    test('Fetcher is called when get is invoked and sot has not data',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await store.get(1);
      expect(result, equals(1));
      verify(fetcher.factory).called(1);
      verify(sourceOfTruth.reader).called(1);
      verify(sourceOfTruth.writer).called(1);
    });
  });
}
