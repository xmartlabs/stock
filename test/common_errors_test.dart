import 'package:stock/src/fetcher.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

import 'common/source_of_truth/source_of_truth_with_error.dart';
import 'common/stock_test_extensions.dart';

void main() {
  group('Stock requests with errors', () {
    test('Source of truth with read error and fetcher ok', () async {
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(-1, throwReadErrorCount: 1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResultRemovingErrorStackTraces(1);
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
    });

    test('Source of truth with write error and fetcher ok', () async {
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(-1, throwWriteErrorCount: 1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResultRemovingErrorStackTraces(1);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          StockResponseError<int>(
            ResponseOrigin.fetcher,
            SourceOfTruthWithError.writeException,
          ),
        ]),
      );
    });

    test('Source of truth ok and fetcher with error', () async {
      final sourceOfTruth = SourceOfTruthWithError<int, int>(-1);
      final fetcherError = Exception('Fetcher error');
      final fetcher = Fetcher.ofFuture((int key) async => throw fetcherError);
      final stock = Stock<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await stock.getFreshResultRemovingErrorStackTraces(1);
      expect(
        resultList,
        equals([
          const StockResponseLoading<int>(ResponseOrigin.fetcher),
          const StockResponse.data(ResponseOrigin.sourceOfTruth, -1),
          StockResponseError<int>(ResponseOrigin.fetcher, fetcherError),
        ]),
      );
    });
  });
}
