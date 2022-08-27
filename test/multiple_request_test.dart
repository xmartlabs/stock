import 'package:flutter_test/flutter_test.dart';
import 'package:stock/src/fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';

import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';
import 'common/stock_test_extensions.dart';

void main() {
  group('Multiple requests', () {
    test('Two simple requests with cached data', () async {
      final sourceOfTruth =
          createMockedSourceOfTruthWithDefaultNegativeIntKey();
      final fetcher = Fetcher.ofFuture((int key) async => key);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      var resultList = await stock.getFreshResultRemovingErrorStackTraces(1);
      expect(
          resultList,
          equals([
            const StockResponseLoading<int>(ResponseOrigin.fetcher),
            const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
            const StockResponse.data(ResponseOrigin.fetcher, 1),
          ]));

      resultList = await stock.getFreshResultRemovingErrorStackTraces(2);
      expect(
          resultList,
          equals([
            const StockResponseLoading<int>(ResponseOrigin.fetcher),
            const StockResponse.data(ResponseOrigin.sourceOfTruth, -2),
            const StockResponse.data(ResponseOrigin.fetcher, 2),
          ]));
    });
  });
}
