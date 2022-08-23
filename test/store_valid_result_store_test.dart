import 'package:flutter_test/flutter_test.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/store.dart';
import 'package:stock/store_response.dart';

import 'common/source_of_truth/cached_source_of_truth_with_default_value.dart';
import 'common/source_of_truth/source_of_truth_with_delay.dart';
import 'common/store_test_extensions.dart';

void main() {
  group("Valid results", () {
    test('South of truth and fetcher are called', () async {
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
    });

    test('South of truth data is returned before fetcher data', () async {
      final sourceOfTruth = DelayedSourceOfTruth<int, int>(-1);
      final fetcher = Fetcher.ofFuture((int key) async => 1);
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(
        1,
        delay: const Duration(milliseconds: 500),
      );
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
          ]));
    });

    test('South of truth and stream fetcher are called', () async {
      final sourceOfTruth = CachedSourceOfTruthWithDefaultValue<int, int>(-1);
      final fetcher =
          Fetcher.ofStream((int key) => Stream.fromIterable([1, 2, 3]));
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: sourceOfTruth,
      );

      final resultList = await store.getFreshResult(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.sourceOfTruth, -1),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
            StoreResponse.data(ResponseOrigin.fetcher, 2),
            StoreResponse.data(ResponseOrigin.fetcher, 3),
          ]));
    });

    test('Test a store with only a stream fetcher', () async {
      final fetcher =
          Fetcher.ofStream((int key) => Stream.fromIterable([1, 2, 3]));
      final store = Store<int, int>(
        fetcher: fetcher,
        sourceOfTruth: null,
      );

      final resultList = await store.getFreshResult(1);
      expect(
          resultList,
          equals([
            const StoreResponseLoading<int>(ResponseOrigin.fetcher),
            StoreResponse.data(ResponseOrigin.fetcher, 1),
            StoreResponse.data(ResponseOrigin.fetcher, 2),
            StoreResponse.data(ResponseOrigin.fetcher, 3),
          ]));
    });
  });
}
