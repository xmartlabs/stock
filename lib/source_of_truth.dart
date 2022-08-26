import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/src/key_value.dart';
import 'package:stock/src/source_of_truth_impl.dart';
import 'package:stock/store.dart';
import 'package:stock/store_extensions.dart';

///
/// [SourceOfTruth], as its name implies, is the persistence API which [Store] uses to serve values to
/// the collectors. If provided, [Store] will only return values received from [SourceOfTruth] back
/// to the collectors.
///
/// In other words, values coming from the [Fetcher] will always be sent to the [SourceOfTruth]
/// and will be read back via [reader] to then be returned to the collector.
///
/// This round-trip ensures the data is consistent across the application in case the [Fetcher] does
/// not return all fields or returns a different class type than the app uses. It is particularly
/// useful if your application has a local observable database which is directly modified by the app, 
/// as Store can observe these changes and update the collectors even before value is synced to the
/// backend.
///
/// [SourceOfTruth] takes care of making any source (no matter if it has flowing reads or not) into
/// a common flowing API.
///
/// A source of truth is usually backed by local storage. Its purpose is to eliminate the need
/// for waiting on a network update before local modifications are available (via [Store.stream]).
///
/// For maximal simplicity, [writer]'s record type ([T]] and [reader]'s record type
/// ([T]) are identical. However, sometimes reading one type of objects from network and
/// transforming them to another type when placing them in local storage is needed.
/// For this case you can use the [mapTo] and [mapToUsingMapper] extensions.
///
abstract class SourceOfTruth<Key, T> {
  /// Creates a source of truth that is accessed via [reader] and [writer].
  ///
  /// The [reader] function is used to read records from the source of truth
  /// The [writer] function is used to write records to the source of truth
  factory SourceOfTruth({
    required Stream<T?> Function(Key key) reader,
    required Future<void> Function(Key key, T? output) writer,
  }) =>
      SourceOfTruthImpl(reader, writer);

  /// Used by [Store] to read records from the source of truth for the given [key].
  Stream<T?> reader(Key key);

  /// Used by [Store] to write records **coming in from the fetcher (network)** to the source of
  /// truth.
  ///
  /// **Note:** [Store] currently does not support updating the source of truth with local user
  /// updates (i.e writing record of type [T]). However, any changes in the local database
  /// will still be visible via [Store.stream] APIs as long as you are using a local storage that
  /// supports observability (e.g. Floor, Drift, Realm).
  Future<void> write(Key key, T? value);
}

// A memory cache implementation of a [SourceOfTruth], which stores the latest value and notify ones.
class CachedSourceOfTruth<Key, T> implements SourceOfTruth<Key, T> {
  final _streamController = StreamController<KeyValue<Key, T?>>.broadcast();

  late Map<Key, T?> _cachedValues;

  CachedSourceOfTruth([Map<Key, T?>? cachedValues]) {
    _cachedValues = {if (cachedValues != null) ...cachedValues};
  }

  @protected
  @visibleForTesting
  void setCachedValue(Key key, T? value) => _cachedValues[key] = value;

  @override
  Stream<T?> reader(Key key) async* {
    yield _cachedValues[key];
    yield* _streamController.stream
        .where((event) => event.key == key)
        .map((event) => event.value);
  }

  @override
  Future<void> write(Key key, T? value) async {
    setCachedValue(key, value);
    _streamController.add(KeyValue(key, value));
  }
}
