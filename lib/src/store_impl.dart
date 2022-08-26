import 'dart:async';

import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/extensions/future_stream_extensions.dart';
import 'package:stock/src/extensions/store_response_extensions.dart';
import 'package:stock/src/factory_fetcher.dart';
import 'package:stock/src/source_of_truth_impl.dart';
import 'package:stock/store.dart';
import 'package:stock/store_request.dart';
import 'package:stock/store_response.dart';

class StoreImpl<Key, Output> implements Store<Key, Output> {
  final FactoryFetcher<Key, Output> _fetcher;
  final SourceOfTruth<Key, Output>? _sourceOfTruth;

  final Map<Key, int> _writingMap = {};
  final _writingLock = Mutex();

  StoreImpl({
    required Fetcher<Key, Output> fetcher,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
  })  : _fetcher = fetcher as FactoryFetcher<Key, Output>,
        _sourceOfTruth = sourceOfTruth;

  @override
  Future<Output> fresh(Key key) =>
      _generateCombinedNetworkAndSourceOfTruthStream(
        StoreRequest(key: key, refresh: true),
        WriteWrappedSourceOfTruth(_sourceOfTruth),
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
      _generateCombinedNetworkAndSourceOfTruthStream(
        request,
        _sourceOfTruth == null ? CachedSourceOfTruth() : _sourceOfTruth!,
      );

  Stream<StoreResponse<Output>> _generateCombinedNetworkAndSourceOfTruthStream(
    StoreRequest<Key> request,
    SourceOfTruth<Key, Output> sourceOfTruth,
  ) async* {
    final StreamController<StoreResponse<Output?>> controller =
        StreamController.broadcast();
    final syncLock = Mutex();
    await syncLock.acquire();

    final fetcherSubscription = _generateNetworkStream(
      dataStreamController: controller,
      request: request,
      sourceOfTruth: sourceOfTruth,
      emitMutex: syncLock,
    );

    final sourceOfTruthSubscription = _generateSourceOfTruthStreamSubscription(
      request: request,
      sourceOfTruth: sourceOfTruth,
      dataStreamController: controller,
      dbLock: syncLock,
    );

    yield* controller.stream.whereDataNotNull().doOnCancel(() async {
      await fetcherSubscription.cancel();
      await sourceOfTruthSubscription.cancel();
    });
  }

  StreamSubscription _generateNetworkStream({
    required StoreRequest<Key> request,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
    required Mutex emitMutex,
    required StreamController<StoreResponse<Output?>> dataStreamController,
  }) =>
      Stream.fromFuture(_shouldStartNetworkStream(
        request,
        dataStreamController,
      ))
          .flatMap((shouldFetchNewValue) => _startNetworkFlow(
                shouldFetchNewValue,
                dataStreamController,
                request,
              ))
          .listen((response) => emitMutex.protect(() async {
                if (response is StoreResponseData<Output>) {
                  await _writingLock
                      .protect(() async => _incrementWritingMap(request, 1));
                  var writerResult = await sourceOfTruth
                      ?.write(request.key, response.value)
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
    StoreRequest<Key> request,
  ) {
    if (shouldFetchNewValue) {
      dataStreamController
          .add(StoreResponseLoading<Output>(ResponseOrigin.fetcher));
      return _fetcher
          .factory(request.key)
          .mapToResponse(ResponseOrigin.fetcher);
    } else {
      return Rx.never<StoreResponse<Output>>();
    }
  }

  Future<bool> _shouldStartNetworkStream(
    StoreRequest<Key> request,
    StreamController<StoreResponse<Output?>> dataStreamController,
  ) async {
    if (request.refresh) {
      return true;
    }
    return await dataStreamController.stream
        .where((event) => event.origin == ResponseOrigin.sourceOfTruth)
        .where((event) => !event.isLoading)
        .first
        .then((value) => value.data == null);
  }

  StreamSubscription _generateSourceOfTruthStreamSubscription({
    required StoreRequest<Key> request,
    required SourceOfTruth<Key, Output> sourceOfTruth,
    required Mutex dbLock,
    required StreamController<StoreResponse<Output?>> dataStreamController,
  }) {
    var initialSyncDone = false;
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
      if (dbLock.isLocked && !initialSyncDone) {
        initialSyncDone = true;
        dbLock.release();
      }
    });
    return sourceOfTruthSubscription;
  }
}
