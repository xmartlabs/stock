import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

void main() {
  group('StockResponseLoading', () {
    test('toString()', () async {
      expect(
        const StockResponseLoading(ResponseOrigin.fetcher).toString(),
        equals(
          'StockResponse<dynamic>.loading(origin: ResponseOrigin.fetcher)',
        ),
      );
    });
    test('equal', () async {
      final fetcher1 = const StockResponseLoading(ResponseOrigin.fetcher);
      final fetcher2 = const StockResponseLoading(ResponseOrigin.fetcher);
      final sot1 = const StockResponseLoading(
        ResponseOrigin.sourceOfTruth,
      );
      expect(fetcher1 == sot1, equals(false));
      expect(fetcher1 == fetcher2, equals(true));
    });
    test('hashcode', () async {
      final fetcher1 = const StockResponseLoading(ResponseOrigin.fetcher);
      final fetcher2 = const StockResponseLoading(ResponseOrigin.fetcher);
      final sot1 = const StockResponseLoading(ResponseOrigin.sourceOfTruth);
      expect(fetcher1.hashCode == sot1.hashCode, equals(false));
      expect(fetcher1.hashCode == fetcher2.hashCode, equals(true));
    });
    group('StockResponseData', () {
      test('toString()', () async {
        expect(
          const StockResponseData(ResponseOrigin.fetcher, '1').toString(),
          equals(
            'StockResponse<String>.data(origin: ResponseOrigin.fetcher, value: 1)',
          ),
        );
      });
      test('equal', () async {
        final fetcher1 = const StockResponseData(ResponseOrigin.fetcher, 1);
        final fetcher1Copy = const StockResponseData(ResponseOrigin.fetcher, 1);
        final fetcher2 = const StockResponseData(ResponseOrigin.fetcher, 2);
        final sot1 = const StockResponseData(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1 == sot1, equals(false));
        expect(fetcher1 == fetcher1Copy, equals(true));
        expect(fetcher1 == fetcher2, equals(false));
      });
      test('hashcode', () async {
        final fetcher1 = const StockResponseData(ResponseOrigin.fetcher, 1);
        final fetcher1Copy = const StockResponseData(ResponseOrigin.fetcher, 1);
        final fetcher2 = const StockResponseData(ResponseOrigin.fetcher, 2);
        final sot1 = const StockResponseData(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1.hashCode == sot1.hashCode, equals(false));
        expect(fetcher1.hashCode == fetcher1Copy.hashCode, equals(true));
        expect(fetcher1.hashCode == fetcher2.hashCode, equals(false));
      });
    });
    group('StockResponseError', () {
      test('toString()', () async {
        expect(
          const StockResponseError<String>(ResponseOrigin.fetcher, 'error')
              .toString(),
          equals(
            'StockResponse<String>.error(origin: ResponseOrigin.fetcher, error: error, stackTrace: null)',
          ),
        );
      });
      test('equal', () async {
        final fetcher1 = const StockResponseError(ResponseOrigin.fetcher, 1);
        final fetcher1Tmp = const StockResponseError(ResponseOrigin.fetcher, 1);
        final fetcher2 = const StockResponseError(ResponseOrigin.fetcher, 2);
        final sot1 = const StockResponseError(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1 == sot1, equals(false));
        expect(fetcher1 == fetcher1Tmp, equals(true));
        expect(fetcher1 == fetcher2, equals(false));
      });
      test('hashcode', () async {
        final fetcher1 = const StockResponseError(ResponseOrigin.fetcher, 1);
        final fetcher1Tmp = const StockResponseError(ResponseOrigin.fetcher, 1);
        final fetcher2 = const StockResponseError(ResponseOrigin.fetcher, 2);
        final sot1 = const StockResponseError(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1.hashCode == sot1.hashCode, equals(false));
        expect(fetcher1.hashCode == fetcher1Tmp.hashCode, equals(true));
        expect(fetcher1.hashCode == fetcher2.hashCode, equals(false));
      });
    });
  });
}
