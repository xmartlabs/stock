import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

import 'common/fetcher_mock.dart';
import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/stock_test_extensions.dart';

void main() {
  group('Stock without specific key', () {
    test('Simple request using dynamic', () async {
      final mockFetcher =
          MockFutureFetcher<dynamic, int>((key) => Future.value(1));
      final fetcher = FutureFetcher<dynamic, int>(mockFetcher.factory);
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<void, int>(-1);
      final stock = Stock<dynamic, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResult(null);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          const StockResponse.data(ResponseOrigin.fetcher, 1),
        ]),
      );
    });
  });
}
