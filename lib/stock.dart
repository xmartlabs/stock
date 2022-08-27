import 'dart:async';

import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/stock_impl.dart';
import 'package:stock/stock_response.dart';

/// A [Stock] is responsible for managing a particular data request.
///
/// When you create an implementation of a [Stock], you provide it with a [Fetcher], a function that defines how data will be fetched over network.
///
/// This [SourceOfTruth] is either a real database or an in memory source of truth.
/// Its purpose is to eliminate the need for waiting on a network update before local modifications are available (via [Stock.stream]).
///
abstract class Stock<Key, T> {
  factory Stock({
    required Fetcher<Key, T> fetcher,
    required SourceOfTruth<Key, T>? sourceOfTruth,
  }) =>
      StockImpl<Key, T>(fetcher: fetcher, sourceOfTruth: sourceOfTruth);

  /// Returns a [Stream] for the given key.
  /// [refresh] is used to ensure a fresh value from the [Fetcher],
  /// If it's `false`, [Stock] will try to return the [SourceOfTruth] data,
  /// and if it doesn't exist, [Stock] will request fresh data using the [Fetcher].
  Stream<StockResponse<T>> stream(Key key, {refresh = true});

  /// Helper factory that will return fresh data for [key] while updating your cache
  Future<T> fresh(Key key);

  /// Returns data for [key] if it is cached otherwise will return
  /// fresh/network data (updating your cache).
  Future<T> get(Key key);
}
