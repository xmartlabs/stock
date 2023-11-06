import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

import 'common/fetcher_mock.dart';
import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/source_of_truth/source_of_truth_with_error.dart';
import 'common/stock_test_extensions.dart';

void main() {
  group('Refresh tests', () {
    test('Fetcher is not called if sot has data and refresh is false',
        () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(1, refresh: false);
      expect(
        resultList,
        equals([
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
        ]),
      );
      expect(mockFetcher.invocations, equals(0));
    });

    test('Fetcher is called if sot has data and refresh is true', () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);

      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(1, refresh: true);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
      expect(mockFetcher.invocations, equals(1));
    });

    test('Fetcher is called if sot has not data and refresh is false',
        () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
      final sourceOfTruth = CachedSourceOfTruth<int, int>();
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(1, refresh: false);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
      expect(mockFetcher.invocations, equals(1));
    });

    test('Fetcher is called if sot returns an error and refresh is false',
        () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(null, throwReadErrorCount: 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList =
          await stock.getFreshResultRemovingErrorStackTraces(1, refresh: false);
      expect(
        resultList,
        equals([
          StockResponseError<int>(
            ResponseOrigin.sourceOfTruth,
            SourceOfTruthWithError.readException,
          ),
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
      expect(mockFetcher.invocations, equals(1));
    });

    test('Fetcher is called if sot returns an error and refresh is true',
        () async {
      final mockFetcher = MockFutureFetcher<int, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<int, int>(mockFetcher.factory);
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(null, throwReadErrorCount: 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList =
          await stock.getFreshResultRemovingErrorStackTraces(1, refresh: true);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          StockResponseError<int>(
            ResponseOrigin.sourceOfTruth,
            SourceOfTruthWithError.readException,
          ),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
      expect(mockFetcher.invocations, equals(1));
    });
  });
}
