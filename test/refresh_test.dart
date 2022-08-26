import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/source_of_truth/source_of_truth_with_error.dart';
import 'common/store_test_extensions.dart';
import 'common_mocks.mocks.dart';

void main() {
  group('Refresh tests', () {
    test('Fetcher is not called if sot has data and refresh is false',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(1, refresh: false);
      expect(
          resultList,
          equals([
            const StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
          ]));
      verifyNever(fetcher.factory);
    });

    test('Fetcher is called if sot has data and refresh is true', () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(1, refresh: true);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            const StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            const StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
      verify(fetcher.factory).called(1);
    });

    test('Fetcher is called if sot has not data and refresh is false',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth = CachedSourceOfTruth<int, int>(null);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(1, refresh: false);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            const StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
      verify(fetcher.factory).called(1);
    });

    test('Fetcher is called if sot returns an error and refresh is false',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(null, throwReadErrorCount: 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList =
          await store.getFreshResultRemovingErrorStackTraces(1, refresh: false);
      expect(
          resultList,
          equals([
            StoreResponseError<int>(ResponseOrigin.sourceOfTruth,
                SourceOfTruthWithError.readException),
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            const StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
      verify(fetcher.factory).called(1);
    });

    test('Fetcher is called if sot returns an error and refresh is true',
        () async {
      var fetcher = MockFutureFetcher<int, int>();
      when(fetcher.factory).thenReturn((key) => Stream.value(1));
      final sourceOfTruth =
          SourceOfTruthWithError<int, int>(null, throwReadErrorCount: 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList =
          await store.getFreshResultRemovingErrorStackTraces(1, refresh: true);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponseError<int>(ResponseOrigin.sourceOfTruth,
                SourceOfTruthWithError.readException),
            const StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
      verify(fetcher.factory).called(1);
    });
  });
}
