// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:mutex/mutex.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/src/extensions/future_stream_internal_extensions.dart';
import 'package:stock/src/extensions/stock_response_internal_extensions.dart';
import 'package:stock/src/fetcher.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/implementations/source_of_truth_impl.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_request.dart';
import 'package:stock/src/stock_response.dart';
import 'package:stock/src/stock_response_extensions.dart';

@visibleForTesting
typedef SessionStreamKey = double;

class StockImpl<Key, Output> implements Stock<Key, Output> {
  StockImpl({
    required Fetcher<Key, Output> fetcher,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
  })  : _fetcher = fetcher as FactoryFetcher<Key, Output>,
        _sourceOfTruth = sourceOfTruth;

  final FactoryFetcher<Key, Output> _fetcher;
  final SourceOfTruth<Key, Output>? _sourceOfTruth;

  @visibleForTesting
  final Map<Key, Set<SessionStreamKey>> sessionFetcherPendingRequests = {};
  @visibleForTesting
  final Map<Key, Set<SessionStreamKey>> currentStreamSessions = {};
  final _notifyPendingRequestsLock = Mutex();

  @override
  Future<Output> fresh(Key key) =>
      _generateCombinedNetworkAndSourceOfTruthStream(
        StockRequest(key: key, refresh: true),
        WriteWrappedSourceOfTruth(_sourceOfTruth),
      )
          .where((event) => event is! StockResponseLoading)
          .where((event) => event.origin == ResponseOrigin.fetcher)
          .first
          .then((value) => value.requireData());

  @override
  Future<Output> get(Key key) => stream(key, refresh: false)
      .where((event) => event is! StockResponseLoading)
      .first
      .then((value) => value.requireData());

  @override
  Stream<StockResponse<Output>> stream(Key key, {bool refresh = true}) =>
      streamFromRequest(
        StockRequest(
          key: key,
          refresh: refresh,
        ),
      );

  @override
  Future<void> clear(Key key) async => _sourceOfTruth?.delete(key);

  @override
  Future<void> clearAll() async => _sourceOfTruth?.deleteAll();

  Stream<StockResponse<Output>> streamFromRequest(StockRequest<Key> request) =>
      _generateCombinedNetworkAndSourceOfTruthStream(
        request,
        _sourceOfTruth == null ? CachedSourceOfTruth() : _sourceOfTruth!,
      );

  Stream<StockResponse<Output>> _generateCombinedNetworkAndSourceOfTruthStream(
    StockRequest<Key> request,
    SourceOfTruth<Key, Output> sourceOfTruth,
  ) async* {
    final sessionKey = Random.secure().nextDouble();

    final controller = StreamController<StockResponse<Output?>>.broadcast();
    final syncLock = Mutex();
    await syncLock.acquire();

    final fetcherSubscription = _generateNetworkStream(
      dataStreamController: controller,
      request: request,
      sourceOfTruth: sourceOfTruth,
      emitMutex: syncLock,
      sessionStreamKey: sessionKey,
    );

    final sourceOfTruthSubscription = _generateSourceOfTruthStreamSubscription(
      request: request,
      sourceOfTruth: sourceOfTruth,
      dataStreamController: controller,
      dbLock: syncLock,
      sessionStreamKey: sessionKey,
    );

    yield* controller.stream.whereDataNotNull().doOnCancel(() async {
      currentStreamSessions[request.key]?.remove(sessionKey);
      await fetcherSubscription.cancel();
      await sourceOfTruthSubscription.cancel();
    }).doOnListen(
      () => _notifyPendingRequestsLock.protect(() async {
        currentStreamSessions[request.key] =
            (currentStreamSessions[request.key] ?? {})..add(sessionKey);
      }),
    );
  }

  StreamSubscription<void> _generateNetworkStream({
    required StockRequest<Key> request,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
    required Mutex emitMutex,
    required StreamController<StockResponse<Output?>> dataStreamController,
    required SessionStreamKey sessionStreamKey,
  }) =>
      Stream.fromFuture(
        _shouldStartNetworkStream(request, dataStreamController),
      )
          .flatMap(
            (shouldFetchNewValue) => _startNetworkFlow(
              shouldFetchNewValue,
              dataStreamController,
              request,
            ),
          )
          .listen(
            (response) => emitMutex.protect(() async {
              if (response is StockResponseData<Output>) {
                await _notifyPendingRequestsLock.protect(
                  () async => _setupSessionPendingRequest(
                    request,
                    currentStreamSessions[request.key]!,
                  ),
                );
                final writerResult = await sourceOfTruth
                    ?.write(request.key, response.value)
                    .mapToResponse(ResponseOrigin.fetcher);
                if (writerResult is StockResponseError) {
                  dataStreamController.add(writerResult.swapType());
                  await _notifyPendingRequestsLock.protect(
                    () async => sessionFetcherPendingRequests[request.key]
                        ?.remove(sessionStreamKey),
                  );
                }
              } else {
                dataStreamController.add(response);
              }
            }),
          );

  void _setupSessionPendingRequest(
    StockRequest<Key> request,
    Set<SessionStreamKey> currentSessions,
  ) =>
      sessionFetcherPendingRequests[request.key] =
          (sessionFetcherPendingRequests[request.key] ?? {})
            ..addAll(currentSessions);

  Stream<StockResponse<Output>> _startNetworkFlow(
    bool shouldFetchNewValue,
    StreamController<StockResponse<dynamic>> dataStreamController,
    StockRequest<Key> request,
  ) {
    if (shouldFetchNewValue) {
      dataStreamController
          .add(StockResponseLoading<Output>(ResponseOrigin.fetcher));
      return _fetcher
          .factory(request.key)
          .mapToResponse(ResponseOrigin.fetcher);
    } else {
      return Rx.never<StockResponse<Output>>();
    }
  }

  Future<bool> _shouldStartNetworkStream(
    StockRequest<Key> request,
    StreamController<StockResponse<Output?>> dataStreamController,
  ) async {
    if (request.refresh) {
      return true;
    }
    return dataStreamController.stream
        .where((event) => event.origin == ResponseOrigin.sourceOfTruth)
        .where((event) => !event.isLoading)
        .first
        .then((value) => value.getDataOrNull() == null);
  }

  StreamSubscription<void> _generateSourceOfTruthStreamSubscription({
    required StockRequest<Key> request,
    required SourceOfTruth<Key, Output> sourceOfTruth,
    required Mutex dbLock,
    required StreamController<StockResponse<Output?>> dataStreamController,
    required SessionStreamKey sessionStreamKey,
  }) {
    var initialSyncDone = false;
    final sourceOfTruthSubscription = sourceOfTruth
        .reader(request.key)
        .mapToResponse(ResponseOrigin.sourceOfTruth)
        .listen((response) async {
      if (response is StockResponseData<Output?>) {
        final fetcherData = await _notifyPendingRequestsLock.protect(
          () async =>
              sessionFetcherPendingRequests[request.key]
                  ?.remove(sessionStreamKey) ??
              false,
        );
        dataStreamController.add(
          StockResponseData(
            fetcherData ? ResponseOrigin.fetcher : response.origin,
            response.value,
          ),
        );
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
