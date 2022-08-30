import 'package:stock/src/stock_response.dart';
import 'package:test/test.dart';

void main() {
  group('StockResponseLoading', () {
    test('toString()', () async {
      expect(
        const StockResponseLoading<int>(ResponseOrigin.fetcher).toString(),
        equals(
          'StockResponse<int>.loading(origin: ResponseOrigin.fetcher)',
        ),
      );
    });
    test('equal', () async {
      const fetcher1 = StockResponseLoading<int>(ResponseOrigin.fetcher);
      const fetcher2 = StockResponseLoading<int>(ResponseOrigin.fetcher);
      const sot1 = StockResponseLoading<int>(ResponseOrigin.sourceOfTruth);
      expect(fetcher1 == sot1, equals(false));
      expect(fetcher1 == fetcher2, equals(true));
    });
    test('hashcode', () async {
      const fetcher1 = StockResponseLoading<int>(ResponseOrigin.fetcher);
      const fetcher2 = StockResponseLoading<int>(ResponseOrigin.fetcher);
      const sot1 = StockResponseLoading<int>(ResponseOrigin.sourceOfTruth);
      expect(fetcher1.hashCode == sot1.hashCode, equals(false));
      expect(fetcher1.hashCode == fetcher2.hashCode, equals(true));
    });
    group('StockResponseData', () {
      test('toString()', () async {
        expect(
          const StockResponseData(ResponseOrigin.fetcher, '1').toString(),
          equals(
            'StockResponse<String>.data(origin: ResponseOrigin.fetcher, '
            'value: 1)',
          ),
        );
      });
      test('equal', () async {
        const fetcher1 = StockResponseData(ResponseOrigin.fetcher, 1);
        const fetcher1Copy = StockResponseData(ResponseOrigin.fetcher, 1);
        const fetcher2 = StockResponseData(ResponseOrigin.fetcher, 2);
        const sot1 = StockResponseData(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1 == sot1, equals(false));
        expect(fetcher1 == fetcher1Copy, equals(true));
        expect(fetcher1 == fetcher2, equals(false));
      });
      test('hashcode', () async {
        const fetcher1 = StockResponseData(ResponseOrigin.fetcher, 1);
        const fetcher1Copy = StockResponseData(ResponseOrigin.fetcher, 1);
        const fetcher2 = StockResponseData(ResponseOrigin.fetcher, 2);
        const sot1 = StockResponseData(ResponseOrigin.sourceOfTruth, 1);
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
            'StockResponse<String>.error(origin: ResponseOrigin.fetcher, '
            'error: error, stackTrace: null)',
          ),
        );
      });
      test('equal', () async {
        const fetcher1 = StockResponseError<String>(ResponseOrigin.fetcher, 1);
        const fetcher1Tmp =
            StockResponseError<String>(ResponseOrigin.fetcher, 1);
        const fetcher2 = StockResponseError<String>(ResponseOrigin.fetcher, 2);
        const sot1 =
            StockResponseError<String>(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1 == sot1, equals(false));
        expect(fetcher1 == fetcher1Tmp, equals(true));
        expect(fetcher1 == fetcher2, equals(false));
      });
      test('hashcode', () async {
        const fetcher1 = StockResponseError<String>(ResponseOrigin.fetcher, 1);
        const fetcher1Tmp =
            StockResponseError<String>(ResponseOrigin.fetcher, 1);
        const fetcher2 = StockResponseError<String>(ResponseOrigin.fetcher, 2);
        const sot1 =
            StockResponseError<String>(ResponseOrigin.sourceOfTruth, 1);
        expect(fetcher1.hashCode == sot1.hashCode, equals(false));
        expect(fetcher1.hashCode == fetcher1Tmp.hashCode, equals(true));
        expect(fetcher1.hashCode == fetcher2.hashCode, equals(false));
      });
    });
  });
}
