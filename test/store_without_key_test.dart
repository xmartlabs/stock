import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/store_test_extensions.dart';
import 'common_mocks.mocks.dart';

void main() {
  group('Store without specific key', () {
    test('Simple request using dynamic', () async {
      var fetcher = MockFutureFetcher<dynamic, int>();
      when(fetcher.factory).thenReturn((_) => Stream.value(1));
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<void, int>(-1);
      final store = Store<dynamic, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(null);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
    });
  });
}
