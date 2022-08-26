import 'package:flutter_test/flutter_test.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'common/source_of_truth/source_of_truth_with_error.dart';
import 'common/store_test_extensions.dart';

void main() {
  group("Store requests with errors", () {
    test('Source of truth with read error and fetcher ok', () async {
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(-1, throwReadErrorCount: 1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResultRemovingErrorStackTraces(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponseError<int>(ResponseOrigin.sourceOfTruth,
                SourceOfTruthWithError.readException),
            const StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
    });

    test('Source of truth with write error and fetcher ok', () async {
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(-1, throwWriteErrorCount: 1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResultRemovingErrorStackTraces(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            const StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponseError<int>(
                ResponseOrigin.fetcher, SourceOfTruthWithError.writeException),
          ]));
    });

    test('Source of truth ok and fetcher with error', () async {
      final sourceOfTruth = SourceOfTruthWithError<int, int>(-1);
      final fetcherError = Exception('Fetcher error');
      final fetcher = Fetcher.ofFuture((int key) async => throw fetcherError);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResultRemovingErrorStackTraces(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            const StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponseError<int>(ResponseOrigin.fetcher, fetcherError),
          ]));
    });
  });
}
