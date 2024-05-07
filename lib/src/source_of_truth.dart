import 'dart:async';

import 'package:meta/meta.dart';
import 'package:stock/src/common/key_value.dart';
import 'package:stock/src/fetcher.dart';
import 'package:stock/src/implementations/source_of_truth_impl.dart';
import 'package:stock/src/stock.dart';
import 'package:stock/src/stock_extensions.dart';

///
/// [SourceOfTruth], as its name implies, is the persistence API which [Stock]
/// uses to serve values to the collectors.
/// If provided, [Stock] will only return values received from [SourceOfTruth]
/// back to the collectors.
///
/// In other words, values coming from the [Fetcher] will always be sent to the
/// [SourceOfTruth] and will be read back via [reader] to then be returned to
/// the collector.
///
/// This round-trip ensures the data is consistent across the application in
/// case the [Fetcher] does  not return all fields or returns a different class
/// type than the app uses. It is particularly  useful if your application has a
/// local observable database which is directly modified by the app, as [Stock]
/// can observe these changes and update the collectors even before value is
/// synced to the backend.
///
/// [SourceOfTruth] takes care of making any source (no matter if it has
/// flowing  reads or not) into a common flowing API.
///
/// A source of truth is usually backed by local storage. Its purpose is to
/// eliminate the need for waiting on a network update before local
/// modifications are available (via [Stock.stream]).
///
/// For maximal simplicity, [write]'s record type ([T]] and [reader]'s record
/// type ([T]) are identical. However, sometimes reading one type of objects
/// from network and transforming them to another type when placing them in
/// local storage is needed.
/// For this case you can use the [mapTo] and [mapToUsingMapper] extensions.
///
abstract interface class SourceOfTruth<Key, T> {
  /// Creates a source of truth that is accessed via [reader], [writer],
  /// [delete] and [deleteAll].
  ///
  /// The [reader] function is used to read records from the source of truth
  /// The [writer] function is used to write records to the source of truth
  /// The [delete] function for deleting records in the source of truth.
  /// The [deleteAll] function for deleting all records in the source of truth
  factory SourceOfTruth({
    required Stream<T?> Function(Key key) reader,
    required Future<void> Function(Key key, T? output) writer,
    Future<void> Function(Key key)? delete,
    Future<void> Function()? deleteAll,
  }) =>
      SourceOfTruthImpl(reader, writer, delete, deleteAll);

  /// Used by [Stock] to read records from the source of truth for the given
  /// [key].
  Stream<T?> reader(Key key);

  /// Used by [Stock] to write records **coming in from the fetcher (network)**
  /// to the source of truth.
  ///
  /// **Note:** [Stock] currently does not support updating the source of truth
  /// with local user updates (i.e writing record of type [T]). However, any
  /// changes in the local database will still be visible via [Stock.stream]
  /// APIs as long as you are using a local storage that supports observability
  /// (e.g. Floor, Drift, Realm).
  Future<void> write(Key key, T? value);

  /// Used by [Stock] to delete records in the source of truth for
  /// the given [key].
  Future<void> delete(Key key);

  /// Used by [Stock] to delete all records in the source of truth.
  Future<void> deleteAll();
}

/// A memory cache implementation of a [SourceOfTruth], which stores the latest
/// value and notify new ones.
class CachedSourceOfTruth<Key, T> implements SourceOfTruth<Key, T> {
  /// CachedSourceOfTruth constructor
  CachedSourceOfTruth([Map<Key, T?>? cachedValues]) {
    _cachedValues = {if (cachedValues != null) ...cachedValues};
  }

  final _streamController = StreamController<KeyValue<Key, T?>>.broadcast();

  late Map<Key, T?> _cachedValues;

  @protected
  @visibleForTesting

  /// Used to save the [value] value associated [key] into a memory cache.
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

  @override
  Future<void> delete(Key key) async {
    _cachedValues.remove(key);
    _streamController.add(KeyValue(key, null));
  }

  @override
  Future<void> deleteAll() async => _cachedValues.keys.toList().forEach(delete);
}
