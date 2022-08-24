import 'dart:async';

import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/store_impl.dart';
import 'package:stock/store_response.dart';

/// A [Store] is responsible for managing a particular data request.
///
/// When you create an implementation of a [Store], you provide it with a [Fetcher], a function that defines how data will be fetched over network.
///
/// This [SourceOfTruth] is either a real database or an in memory source of truth.
/// It's purpose is to eliminate the need for waiting on network update before local modifications are available (via [Store.stream]).
///
abstract class Store<Key, T> {
  factory Store({
    required Fetcher<Key, T> fetcher,
    required SourceOfTruth<Key, T>? sourceOfTruth,
  }) =>
      StoreImpl<Key, T>(fetcher: fetcher, sourceOfTruth: sourceOfTruth);

  /// Return a [Stream] for the given key.
  /// [refresh] is used to ensure a fresh value from the [Fetcher],
  /// If it's `false`, [Store] will try to return the [SourceOfTruth] data,
  /// and if it doesn't exist, [Store] will request a fresh data using the [Fetcher].
  Stream<StoreResponse<T>> stream(Key key, {refresh = true});

  /// Helper factory that will return fresh data for [key] while updating your caches
  Future<T> fresh(Key key);

  /// Returns data for [key] if it is cached otherwise will return
  /// fresh/network data (updating your caches).
  Future<T> get(Key key);
}
