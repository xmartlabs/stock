import 'package:mockito/mockito.dart';
import 'package:stock/src/stock.dart';
import 'package:test/test.dart';

import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';
import 'common_mocks.mocks.dart';

void main() {
  group('Fresh tests', () {
    test('Sot is not called when fresh is invoked', () async {
      final fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = createMockedSourceOfTruthFromMethods<int, int>(
        (key) => Stream.value(-1),
        (key, output) => Future.value(),
      );

      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await stock.fresh(1);
      expect(result, equals(1));
      verifyNever(sourceOfTruth.reader(any));
      verify(sourceOfTruth.write(any, any)).called(1);
    });
  });
  group('Get tests', () {
    test('Fetcher is not called when get is invoked and sot has data',
        () async {
      final fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = createMockedSourceOfTruthFromMethods<int, int>(
        (key) => Stream.value(-1),
        (key, output) => Future.value(),
      );
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await stock.get(1);
      expect(result, equals(-1));
      verifyNever(fetcher.factory);
      verify(sourceOfTruth.reader(any)).called(1);
      verifyNever(sourceOfTruth.write(any, any));
    });

    test('Fetcher is called when get is invoked and sot has not data',
        () async {
      final fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await stock.get(1);
      expect(result, equals(1));
      verify(fetcher.factory).called(1);
      verify(sourceOfTruth.reader(any)).called(1);
      verify(sourceOfTruth.write(any, any)).called(1);
    });
  });
}
