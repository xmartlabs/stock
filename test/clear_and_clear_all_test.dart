import 'package:mockito/mockito.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:test/test.dart';

import 'common/fetcher_mock.dart';
import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';

void main() {
  group('Clear tests', () {
    test('Stock Clear invokes SOT clear', () async {
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();

      var timesCalled = 0;
      final mockFetcher =
          MockFutureFetcher<int, int>((key) => Future.value(++timesCalled));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);

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

      var timesCalled = 0;
      final mockFetcher =
          MockFutureFetcher<int, int>((key) => Future.value(++timesCalled));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);

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
