import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/south_of_truth.dart';
import 'package:stock/src/extensions/future_stream_extensions.dart';
import 'package:stock/src/extensions/store_response_extensions.dart';
import 'package:stock/src/factory_fetcher.dart';
import 'package:stock/src/wrapped_source_of_truth.dart';
import 'package:stock/store.dart';
import 'package:stock/store_request.dart';
import 'package:stock/store_response.dart';

class RealStore<Key, Output> implements Store<Key, Output> {
  final Fetcher<Key, Output> _fetcher;
  final SourceOfTruth<Key, Output>? _sourceOfTruth;

  final Map<Key, int> _writingMap = {};
  final _writingLock = Mutex();

  RealStore({
    required Fetcher<Key, Output> fetcher,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
  })  : _fetcher = fetcher,
        _sourceOfTruth = sourceOfTruth;

  @override
  Future<Output> fresh(Key key) =>
      _generateCombinedNetworkAndSouthOfTruthStream(
        StoreRequest(key: key, refresh: true),
        WriteWrappedSourceOfTruth(_sourceOfTruth),
        _fetcher as FactoryFetcher<Key, Output>,
      )
          .where((event) => event is! StoreResponseLoading)
          .where((event) => event.origin == ResponseOrigin.fetcher)
          .first
          .then((value) => value.requireData());

  @override
  Future<Output> get(Key key) => stream(key, refresh: false)
      .where((event) => event is! StoreResponseLoading)
      .first
      .then((value) => value.requireData());

  @override
  Stream<StoreResponse<Output>> stream(Key key, {refresh = true}) =>
      streamFromRequest(StoreRequest(
        key: key,
        refresh: refresh,
      ));

  Stream<StoreResponse<Output>> streamFromRequest(StoreRequest<Key> request) =>
      _generateCombinedNetworkAndSouthOfTruthStream(
        request,
        _sourceOfTruth == null ? CachedSourceOfTruth() : _sourceOfTruth!,
        _fetcher as FactoryFetcher<Key, Output>,
      );

  Stream<StoreResponse<Output>> _generateCombinedNetworkAndSouthOfTruthStream(
    StoreRequest<Key> request,
    SourceOfTruth<Key, Output> sourceOfTruth,
    FactoryFetcher<Key, Output> fetcher,
  ) async* {
    StreamController<StoreResponse<Output?>> controller =
        StreamController.broadcast();
    final dbLock = Mutex();
    await dbLock.acquire();

    final fetcherSubscription = _generateNetworkStream(
      dataStreamController: controller,
      request: request,
      sourceOfTruth: sourceOfTruth,
      fetcher: fetcher,
      emitMutex: dbLock,
    );

    final sourceOfTruthSubscription = _generateSourceOfTruthStreamSubscription(
      request: request,
      sourceOfTruth: sourceOfTruth,
      dataStreamController: controller,
      dbLock: dbLock,
    );

    yield* controller.stream.whereDataNotNull().doOnCancel(() async {
      await fetcherSubscription.cancel();
      await sourceOfTruthSubscription.cancel();
    });
  }

  StreamSubscription _generateNetworkStream({
    required StoreRequest<Key> request,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
    required FactoryFetcher<Key, Output> fetcher,
    required Mutex emitMutex,
    required StreamController<StoreResponse<Output?>> dataStreamController,
  }) =>
      Stream.fromFuture(
              _shouldStartNetworkStream(request, dataStreamController))
          .flatMap((shouldFetchNewValue) => _startNetworkFlow(
              shouldFetchNewValue, dataStreamController, fetcher, request))
          .listen((response) => emitMutex.protect(() async {
                if (response is StoreResponseData<Output>) {
                  await _writingLock
                      .protect(() async => _incrementWritingMap(request, 1));
                  var writerResult = await sourceOfTruth
                      ?.writer(request.key, response.value)
                      .mapToResponse(ResponseOrigin.fetcher);
                  if (writerResult is StoreResponseError) {
                    dataStreamController.add(writerResult.swapType());
                    await _writingLock
                        .protect(() async => _incrementWritingMap(request, -1));
                  }
                } else {
                  dataStreamController.add(response);
                }
              }));

  int _incrementWritingMap(StoreRequest<Key> request, int increment) =>
      _writingMap[request.key] = (_writingMap[request.key] ?? 0) + increment;

  Stream<StoreResponse<Output>> _startNetworkFlow(
      bool shouldFetchNewValue,
      StreamController<StoreResponse<dynamic>> dataStreamController,
      FactoryFetcher<Key, Output> fetcher,
      StoreRequest<Key> request) {
    if (shouldFetchNewValue) {
      dataStreamController
          .add(StoreResponseLoading<Output>(ResponseOrigin.fetcher));
      return fetcher.factory(request.key).mapToResponse(ResponseOrigin.fetcher);
    } else {
      return Rx.never<StoreResponse<Output>>();
    }
  }

  Future<bool> _shouldStartNetworkStream(StoreRequest<Key> request,
      StreamController<StoreResponse<Output?>> dataStreamController) async {
    if (request.refresh) {
      return true;
    }
    return await dataStreamController.stream
        .where((event) => event.origin == ResponseOrigin.sourceOfTruth)
        .where((event) => !event.isLoading)
        .first
        .then((value) => value.getData() == null);
  }

  StreamSubscription _generateSourceOfTruthStreamSubscription({
    required StoreRequest<Key> request,
    required SourceOfTruth<Key, Output> sourceOfTruth,
    required Mutex dbLock,
    required StreamController<StoreResponse<Output?>> dataStreamController,
  }) {
    var releaseLock = true;
    final sourceOfTruthSubscription = sourceOfTruth
        .reader(request.key)
        .mapToResponse(ResponseOrigin.sourceOfTruth)
        .listen((response) async {
      if (response is StoreResponseData<Output?>) {
        final fetcherData = await _writingLock.protect(() async {
          final writingKeyData = (_writingMap[request.key] ?? -1) > 0;
          if (writingKeyData) {
            _incrementWritingMap(request, -1);
          }
          return writingKeyData;
        });
        dataStreamController.add(StoreResponseData(
          fetcherData ? ResponseOrigin.fetcher : response.origin,
          response.value,
        ));
      } else {
        dataStreamController.add(response.swapType());
      }
      if (dbLock.isLocked && releaseLock) {
        releaseLock = false;
        dbLock.release();
      }
    });
    return sourceOfTruthSubscription;
  }
}
