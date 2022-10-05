import 'package:mockito/mockito.dart';
import 'package:stock/src/errors.dart';
import 'package:stock/src/extensions/stock_response_internal_extensions.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';
import 'package:test/test.dart';

import 'common_mocks.mocks.dart';

void main() {
  group('Require data extensions', () {
    test('requireData of an error throws the exception', () async {
      final customEx = Exception('Custom ex');
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, customEx)
            .requireData,
        throwsA((dynamic e) => e == customEx),
      );
    });
    test('requireData of a loading response throws a exception', () async {
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).requireData,
        throwsA(
          (dynamic e) =>
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

  group('Require error extensions', () {
    test('requireError of an error throws the exception', () async {
      final customEx = Exception('Custom ex');
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, customEx)
            .requireError(),
        equals(customEx),
      );
    });
    test('requireError of a loading response throws a exception', () async {
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher)
            .requireError,
        throwsA(
          (dynamic e) =>
              e is StockError &&
              e.toString().contains('Response is not an StockResponseError'),
        ),
      );
    });
    test('requireError of a data response throws a exception', () async {
      expect(
        const StockResponseData<dynamic>(ResponseOrigin.fetcher, 1)
            .requireError,
        throwsA(
          (dynamic e) =>
              e is StockError &&
              e.toString().contains('Response is not an StockResponseError'),
        ),
      );
    });
  });

  group('throwIfError extension', () {
    test('throwIfError of an error throws the exception', () async {
      final customEx = Exception('Custom ex');
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, customEx)
            .throwIfError,
        throwsA((dynamic e) => e == customEx),
      );
    });
    test('throwIfError of a loading response does not do anything', () async {
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher)
          .throwIfError();
    });
    test('throwIfError of a data returns the data', () async {
      const StockResponse.data(ResponseOrigin.fetcher, 1).throwIfError();
    });
  });

  group('Get data extensions', () {
    test('getData of an error returns null', () async {
      final customEx = Exception('Custom ex');
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, customEx)
            .getDataOrNull(),
        equals(null),
      );
    });
    test('getData of a loading response returns null', () async {
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher)
            .getDataOrNull(),
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
        StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).isLoading,
        equals(false),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isLoading,
        equals(false),
      );
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).isLoading,
        equals(true),
      );
    });
    test('Data returns true if it is a data event', () async {
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).isData,
        equals(false),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isData,
        equals(true),
      );
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).isData,
        equals(false),
      );
    });
    test('Error returns true if the response is an error', () async {
      expect(
        StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).isError,
        equals(true),
      );
      expect(
        const StockResponse.data(ResponseOrigin.fetcher, 1).isError,
        equals(false),
      );
      expect(
        const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).isError,
        equals(false),
      );
    });
  });

  group('Unknown type', () {
    test('Require data throws error if the type is not recognized', () async {
      expect(
        _FakeType().requireData,
        throwsA(
          (dynamic e) =>
              e is StockError &&
              e.toString().contains('Unknown StockResponse type:'),
        ),
      );
    });

    test('Swap type throws error if the type is not recognized', () async {
      expect(
        _FakeType().swapType,
        throwsA(
          (dynamic e) =>
              e is StockError &&
              e.toString() ==
                  'StockError: Type error swapType expect either Success, '
                      'Error or Loading but was given _FakeType',
        ),
      );
    });
  });

  group('Map', () {
    test('Map for loading', () {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).map(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('Map for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).map(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('Map for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).map(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });

    test('Map with unknown type', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      expect(
        () {
          _FakeType().map(
            onLoading: (_) => mockLoadingCallback(),
            onData: (_) => mockDataCallback(),
            onError: (_) => mockErrorCallback(),
          );
        },
        throwsA(
          (dynamic e) =>
              e is StockError &&
              e.message.startsWith('Unknown StockResponse type: '),
        ),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });
  });

  group('MaybeMap', () {
    test('MaybeMap for loading', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).maybeMap(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
        orElse: () => throw Exception('Should not be called'),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MaybeMap for loading with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).maybeMap(
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
        orElse: mockLoadingCallback,
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MaybeMap for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).maybeMap(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
        orElse: () => throw Exception('Should not be called'),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('MaybeMap for data with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).maybeMap(
        onLoading: (_) => mockLoadingCallback(),
        onError: (_) => mockErrorCallback(),
        orElse: mockDataCallback,
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('MaybeMap for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).maybeMap(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
        orElse: () => throw Exception('Should not be called'),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });

    test('MaybeMap for error with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).maybeMap(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        orElse: mockErrorCallback,
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });
  });

  group('When', () {
    test('When for loading', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).when(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('When for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).when(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('When for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).when(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });
  });

  group('MaybeWhen', () {
    test('MaybeWhen for loading', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).maybeWhen(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
        orElse: (_) => throw Exception('Should not be called'),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MaybeWhen for loading with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).maybeWhen(
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
        orElse: (_) => mockLoadingCallback(),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MaybeWhen for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).maybeWhen(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
        orElse: (_) => throw Exception('Should not be called'),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('MaybeWhen for data with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).maybeWhen(
        onLoading: (_) => mockLoadingCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
        orElse: (_) => mockDataCallback(),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('MaybeWhen for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).maybeWhen(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
        orElse: (_) => throw Exception('Should not be called'),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });

    test('MaybeWhen for error with else', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).maybeWhen(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        orElse: (_) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });
  });

  group('WhenOrNull', () {
    test('WhenOrNull for loading', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      when(mockLoadingCallback.call()).thenAnswer((_) => 1);

      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).whenOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('WhenOrNull for loading without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      final value = const StockResponseLoading<dynamic>(ResponseOrigin.fetcher)
          .whenOrNull(
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('WhenOrNull for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).whenOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('WhenOrNull for data without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      final value =
          const StockResponse.data(ResponseOrigin.fetcher, 1).whenOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockLoadingCallback());
      verifyNever(mockErrorCallback());
    });

    test('WhenOrNull for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).whenOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
        onError: (_, __, ___) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });

    test('WhenOrNull for error without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final value = StockResponseError<dynamic>(ResponseOrigin.fetcher, Error())
          .whenOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_, __) => mockDataCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
    });
  });

  group('MapOrNull', () {
    test('MapOrNull for loading', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      when(mockLoadingCallback.call()).thenAnswer((_) => 1);

      const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).mapOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verify(mockLoadingCallback()).called(1);
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MapOrNull for loading without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      final value =
          const StockResponseLoading<dynamic>(ResponseOrigin.fetcher).mapOrNull(
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verifyNever(mockErrorCallback());
    });

    test('MapOrNull for data', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      const StockResponse.data(ResponseOrigin.fetcher, 1).mapOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verify(mockDataCallback()).called(1);
      verifyNever(mockErrorCallback());
    });

    test('MapOrNull for data without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockErrorCallback = MockCallbackInt();
      final value =
          const StockResponse.data(ResponseOrigin.fetcher, 1).mapOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onError: (_) => mockErrorCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockLoadingCallback());
      verifyNever(mockErrorCallback());
    });

    test('MapOrNull for error', () async {
      final mockLoadingCallback = MockCallbackVoid();
      final mockDataCallback = MockCallbackVoid();
      final mockErrorCallback = MockCallbackVoid();
      StockResponseError<dynamic>(ResponseOrigin.fetcher, Error()).mapOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
        onError: (_) => mockErrorCallback(),
      );
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
      verify(mockErrorCallback()).called(1);
    });

    test('MapOrNull for error without callback', () async {
      final mockLoadingCallback = MockCallbackInt();
      final mockDataCallback = MockCallbackInt();
      final value = StockResponseError<dynamic>(ResponseOrigin.fetcher, Error())
          .mapOrNull(
        onLoading: (_) => mockLoadingCallback(),
        onData: (_) => mockDataCallback(),
      );
      expect(value, equals(null));
      verifyNever(mockLoadingCallback());
      verifyNever(mockLoadingCallback());
      verifyNever(mockDataCallback());
    });
  });
}

// ignore: one_member_abstracts
abstract class Callback<T> {
  T call();
}

//abstract class CallbackVoid implements Callback<void> {}
abstract class CallbackVoid implements Callback<void> {}

abstract class CallbackInt implements Callback<int> {}

class _FakeType implements StockResponse<int> {
  @override
  ResponseOrigin get origin => ResponseOrigin.fetcher;
}
