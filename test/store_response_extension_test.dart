import 'package:flutter_test/flutter_test.dart';
import 'package:stock/errors.dart';
import 'package:stock/src/extensions/store_response_extensions.dart';
import 'package:stock/store_response.dart';

void main() {
  group('Require data extensions', () {
    test('requireData of an error throws the exception', () async {
      final customEx = Exception("Custom ex");
      expect(
        StoreResponse.error(ResponseOrigin.fetcher, customEx).requireData,
        throwsA((e) => e == customEx),
      );
    });
    test('requireData of a loading response throws a exception', () async {
      expect(
        const StoreResponse.loading(ResponseOrigin.fetcher).requireData,
        throwsA((e) => e is StockError),
      );
    });
    test('requireData of a data returns the data', () async {
      expect(
        StoreResponse.data(ResponseOrigin.fetcher, 1).requireData(),
        equals(1),
      );
    });
  });
  group('Get data extensions', () {
    test('getData of an error returns null', () async {
      final customEx = Exception("Custom ex");
      expect(
        StoreResponse.error(ResponseOrigin.fetcher, customEx).data,
        equals(null),
      );
    });
    test('getData of a loading response returns null', () async {
      expect(
        const StoreResponse.loading(ResponseOrigin.fetcher).data,
        equals(null),
      );
    });
    test('getData of a data response returns the data', () async {
      expect(
        StoreResponse.data(ResponseOrigin.fetcher, 1).data,
        equals(1),
      );
    });
  });
  group('Property extensions', () {
    test('Loading returns true if loading', () async {
      expect(
        StoreResponse.error(ResponseOrigin.fetcher, Error()).isLoading,
        equals(false),
      );
      expect(
        StoreResponse.data(ResponseOrigin.fetcher, 1).isLoading,
        equals(false),
      );
      expect(
        const StoreResponse.loading(ResponseOrigin.fetcher).isLoading,
        equals(true),
      );
    });
    test('Error returns true if the response is an error', () async {
      expect(
        StoreResponse.error(ResponseOrigin.fetcher, Error()).isError,
        equals(true),
      );
      expect(
        StoreResponse.data(ResponseOrigin.fetcher, 1).isError,
        equals(false),
      );
      expect(
        const StoreResponse.loading(ResponseOrigin.fetcher).isError,
        equals(false),
      );
    });
  });
}
