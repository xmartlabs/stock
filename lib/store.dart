import 'dart:async';

import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/store_impl.dart';
import 'package:stock/store_response.dart';

abstract class Store<Key, Output> {
  factory Store({
    required Fetcher<Key, Output> fetcher,
    required SourceOfTruth<Key, Output>? sourceOfTruth,
  }) =>
      StoreImpl<Key, Output>(fetcher: fetcher, sourceOfTruth: sourceOfTruth);

  Stream<StoreResponse<Output>> stream(Key key, {refresh = true});

  Future<Output> fresh(Key key);

  Future<Output> get(Key key);
}
