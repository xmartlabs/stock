import 'package:mockito/mockito.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/stock.dart';
import 'package:test/test.dart';

import 'common/fetcher_mock.dart';
import 'common/mock_key_value.dart';
import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';

void main() {
  group('Fresh tests', () {
    test('Sot is not called when fresh is invoked', () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
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

    test('Fresh data is received when a stream is listening the same key',
        () async {
      final mockFetcher = MockFutureFetcher<MockIntKeyValue, int>(
        (key) => Future.value(key.value),
      );
      final fetcher = FutureFetcher<MockIntKeyValue, int>(mockFetcher.factory);
      final sourceOfTruth = createMockedSourceOfTruth<MockIntKeyValue, int>(-1);

      final stock = Stock<MockIntKeyValue, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final streamResult1 = <StockResponse<int>>[];
      final streamResult2 = <StockResponse<int>>[];
      stock
          .stream(const MockIntKeyValue(1, 1), refresh: true)
          .listen(streamResult1.add);
      stock
          .stream(const MockIntKeyValue(2, 20), refresh: false)
          .listen(streamResult2.add);

      await Future.delayed(const Duration(milliseconds: 50), () {});

      final freshResults = [
        await stock.fresh(const MockIntKeyValue(1, 2)),
        await stock.fresh(const MockIntKeyValue(2, 22)),
        await stock.fresh(const MockIntKeyValue(1, 3)),
      ];

      const expectedStreamResult1 = [
        StockResponseLoading<int>(ResponseOrigin.fetcher),
        StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
        StockResponse.data(ResponseOrigin.fetcher, 1),
        StockResponse.data(ResponseOrigin.fetcher, 2),
        StockResponse.data(ResponseOrigin.fetcher, 3),
      ];
      const expectedStreamResult2 = [
        StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
        StockResponse.data(ResponseOrigin.fetcher, 22),
      ];

      const expectedFreshResults = [2, 22, 3];
      expect(freshResults, expectedFreshResults);
      expect(streamResult1, equals(expectedStreamResult1));
      expect(streamResult2, equals(expectedStreamResult2));
      verify(sourceOfTruth.write(any, any)).called(4);
    });
  });

  group('Get tests', () {
    test('Fetcher is not called when get is invoked and sot has data',
        () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
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
      expect(mockFetcher.invocations, equals(0));
      verify(sourceOfTruth.reader(any)).called(1);
      verifyNever(sourceOfTruth.write(any, any));
    });

    test('Fetcher is called when get is invoked and sot has not data',
        () async {
      final mock = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mock.factory);
      final sourceOfTruth = createMockedSourceOfTruth<int, int>();
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final result = await stock.get(1);
      expect(result, equals(1));
      expect(mock.invocations, equals(1));
      verify(sourceOfTruth.reader(any)).called(1);
      verify(sourceOfTruth.write(any, any)).called(1);
    });
  });
}
