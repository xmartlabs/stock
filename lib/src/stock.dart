import 'dart:async';

import 'package:stock/src/fetcher.dart';
import 'package:stock/src/implementations/stock_impl.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock_response.dart';

/// A [Stock] is responsible for managing a particular data request.
///
/// When you create an implementation of a [Stock], you provide it with a
/// [Fetcher], a function that defines how data will be fetched over network.
///
/// This [SourceOfTruth] is either a real database or an in memory source of
/// truth. Its purpose is to eliminate the need for waiting on a network update
/// before local modifications are available (via [Stock.stream]).
///
abstract class Stock<Key, T> {
  /// Stock constructor
  factory Stock({
    required Fetcher<Key, T> fetcher,
    SourceOfTruth<Key, T>? sourceOfTruth,
  }) =>
      StockImpl<Key, T>(fetcher: fetcher, sourceOfTruth: sourceOfTruth);

  /// Returns a [Stream] for the given key.
  /// [refresh] is used to ensure a fresh value from the [Fetcher],
  /// If it's `false`, [Stock] will try to return the [SourceOfTruth] data,
  /// and if it doesn't exist, [Stock] will request fresh data using the
  /// [Fetcher].
  Stream<StockResponse<T>> stream(Key key, {bool refresh = true});

  /// Helper factory that will return fresh data for [key] while updating your
  /// cache.
  Future<T> fresh(Key key);

  /// Returns data for [key] if it is cached otherwise will return
  /// fresh/network data (updating your cache).
  Future<T> get(Key key);

  /// Purge a particular entry from memory and disk cache.
  /// Persistent storage will only be cleared if a delete function was passed to
  /// SourceOfTruth.delete when creating the [Stock].
  Future<void> clear(Key key);

  /// Purge all entries from memory and disk cache.
  /// Persistent storage will only be cleared if a deleteAll function was passed
  /// to SourceOfTruth.delete when creating the [Stock].
  Future<void> clearAll();
}
