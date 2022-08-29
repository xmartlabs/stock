import 'package:flutter_test/flutter_test.dart';
import 'package:stock/src/errors.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';

void main() {
  group('Require data extensions', () {
    test('requireData of an error throws the exception', () async {
      final customEx = Exception("Custom ex");
      expect(
        StockResponse.error(ResponseOrigin.fetcher, customEx).requireData,
        throwsA((e) => e == customEx),
      );
    });
    test('requireData of a loading response throws a exception', () async {
      expect(
        const StockResponse.loading(ResponseOrigin.fetcher).requireData,
        throwsA(
          (e) =>
              e is StockError &&
              e.toString() == 'StockError: There is no data in loading',
        ),
      );
    });
    test('requireData of a data returns the data', () async {
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).requireData(),
        equals(1),
      );
    });
  });
  group('Get data extensions', () {
    test('getData of an error returns null', () async {
      final customEx = Exception("Custom ex");
      expect(
        StockResponse.error(ResponseOrigin.fetcher, customEx).getDataOrNull(),
        equals(null),
      );
    });
    test('getData of a loading response returns null', () async {
      expect(
        const StockResponse.loading(ResponseOrigin.fetcher).getDataOrNull(),
        equals(null),
      );
    });
    test('getData of a data response returns the data', () async {
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).getDataOrNull(),
        equals(1),
      );
    });
  });
  group('Property extensions', () {
    test('Loading returns true if loading', () async {
      expect(
        StockResponse.error(ResponseOrigin.fetcher, Error()).isLoading,
        equals(false),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isLoading,
        equals(false),
      );
      expect(
        const StockResponse.loading(ResponseOrigin.fetcher).isLoading,
        equals(true),
      );
    });
    test('Error returns true if the response is an error', () async {
      expect(
        StockResponse.error(ResponseOrigin.fetcher, Error()).isError,
        equals(true),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isError,
        equals(false),
      );
      expect(
        const StockResponse.loading(ResponseOrigin.fetcher).isError,
        equals(false),
      );
    });
  });
}
