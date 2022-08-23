import 'package:flutter_test/flutter_test.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'common/source_of_truth/cached_and_mocked_source_of_truth.dart';
import 'common/store_test_extensions.dart';

void main() {
  group('Multiple requests', () {
    test('Two simple requests with cached data', () async {
      final sourceOfTruth =
          createMockedSourceOfTruthWithDefaultNegativeIntKey();
      final fetcher = Fetcher.ofFuture((int key) async => key);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      var resultList = await store.getFreshResultRemovingErrorStackTraces(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));

      resultList = await store.getFreshResultRemovingErrorStackTraces(2);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -2),
            StoreResponse.data(ResponseOrigin.fetcher, 2),
          ]));
    });
  });
}
