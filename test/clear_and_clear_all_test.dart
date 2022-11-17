import 'package:mockito/mockito.dart';
import 'package:stock/src/stock.dart';
import 'package:test/test.dart';

import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';
import 'common_mocks.mocks.dart';

void main() {
  group('Clear tests', () {
    test('Stock Clear invokes SOT clear', () async {
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();

      final fetcher = MockFutureFetcher<int, int>();
      var timesCalled = 0;
      when(fetcher.factory).thenReturn((key) => Stream.value(++timesCalled));

      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      await stock.clear(1);
      verify(sourceOfTruth.delete(1)).called(1);
      expect(timesCalled, equals(0));
    });
  });
  group('ClearAll tests', () {
    test('Stock ClearAll invokes SOT clearAll', () async {
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();

      final fetcher = MockFutureFetcher<int, int>();
      var timesCalled = 0;
      when(fetcher.factory).thenReturn((key) => Stream.value(++timesCalled));

      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      await stock.clearAll();

      verify(sourceOfTruth.deleteAll()).called(1);
      expect(timesCalled, equals(0));
    });
  });
}
