import 'dart:async';

import 'package:flutter/widgets.dart';

class SourceOfTruth<Key, Output> {
  Stream<Output?> Function(Key key) reader;
  Future<void> Function(Key key, Output? output) writer;

  SourceOfTruth({required this.reader, required this.writer});
}

class CachedSourceOfTruth<Key, T> implements SourceOfTruth<Key, T> {
  final _streamController = StreamController<T?>.broadcast();

  late Map<Key, T?> _cachedValues;

  @override
  late Stream<T?> Function(Key key) reader;
  @override
  late Future<void> Function(Key key, T? output) writer;

  CachedSourceOfTruth([Map<Key, T?>? cachedValues]) {
    _cachedValues = {if (cachedValues != null) ...cachedValues};
    reader = generateReader;
    writer = generateWriter;
  }

  @protected
  @visibleForTesting
  void setCachedValue(Key key, T? t) => _cachedValues[key] = t;

  @protected
  Stream<T?> generateReader(Key key) async* {
    yield _cachedValues[key];
    yield* _streamController.stream;
  }

  @protected
  Future<void> generateWriter(Key key, T? value) async {
    setCachedValue(key, value);
    _streamController.add(value);
  }
}
