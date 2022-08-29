import 'package:stock/src/errors.dart';
import 'package:stock/src/extensions/stock_response_internal_extensions.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';
import 'package:test/test.dart';

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
  group('throwIfError extension', () {
    test('throwIfError of an error throws the exception', () async {
      final customEx = Exception("Custom ex");
      expect(
        StockResponse.error(ResponseOrigin.fetcher, customEx).throwIfError,
        throwsA((e) => e == customEx),
      );
    });
    test('throwIfError of a loading response does not do anything', () async {
      const StockResponse.loading(ResponseOrigin.fetcher).throwIfError();
    });
    test('throwIfError of a data returns the data', () async {
      const StockResponse.data(ResponseOrigin.fetcher, 1).throwIfError();
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
    test('Data returns true if is a data event', () async {
      expect(
        StockResponse.error(ResponseOrigin.fetcher, Error()).isData,
        equals(false),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isData,
        equals(true),
      );
      expect(
        const StockResponse.loading(ResponseOrigin.fetcher).isData,
        equals(false),
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

  group('Unknown type', () {
    test("Require data throws error if the type is not recognized", () async {
      expect(
        _FakeType().requireData,
        throwsA(
          (e) =>
              e is StockError &&
              e.toString() ==
                  'StockError: Type error requireData expect either Success, Error but was given _FakeType',
        ),
      );
    });

    test("Swap type throws error if the type is not recognized", () async {
      expect(
        _FakeType().swapType,
        throwsA(
          (e) =>
              e is StockError &&
              e.toString() ==
                  'StockError: Type error swapType expect either Success, Error or Loading but was given _FakeType',
        ),
      );
    });
  });
}

class _FakeType implements StockResponse<int> {
  @override
  ResponseOrigin get origin => ResponseOrigin.fetcher;
}
