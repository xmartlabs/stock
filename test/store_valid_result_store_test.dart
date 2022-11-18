import 'package:stock/src/fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/source_of_truth/source_of_truth_with_delay.dart';
import 'common/stock_test_extensions.dart';

void main() {
  group('Valid results', () {
    test('Source of truth and fetcher are called', () async {
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(1);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
    });

    test('Source of truth data is returned before fetcher data', () async {
      final sourceOfTruth = DelayedSourceOfTruth<int, int>(-1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(
        1,
        delay: const Duration(milliseconds: 500),
      );
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
    });

    test('Source of truth and stream fetcher are called', () async {
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final fetcher =
          Fetcher.ofStream((int key) => Stream.fromIterable([1, 2, 3]));
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(1);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
          const StockResponse.data(ResponseOrigin.fetcher, 2),
          const StockResponse.data(ResponseOrigin.fetcher, 3),
        ]),
      );
    });

    test('Test a stock with only a stream fetcher', () async {
      final fetcher =
          Fetcher.ofStream((int key) => Stream.fromIterable([1, 2, 3]));
      final stock = Stock<int, int>(fetcher: fetcher);

      final resultList = await stock.getFreshResult(1);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
          const StockResponse.data(ResponseOrigin.fetcher, 2),
          const StockResponse.data(ResponseOrigin.fetcher, 3),
        ]),
      );
    });
  });
}
