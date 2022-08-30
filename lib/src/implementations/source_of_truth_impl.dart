// ignore_for_file: public_member_api_docs

import 'package:stock/src/source_of_truth.dart';

class SourceOfTruthImpl<Key, T> implements SourceOfTruth<Key, T> {
  SourceOfTruthImpl(this._reader, this._writer);

  final Stream<T?> Function(Key key) _reader;
  final Future<void> Function(Key key, T? output) _writer;

  @override
  Stream<T?> reader(Key key) => _reader(key);

  @override
  Future<void> write(Key key, T? value) => _writer(key, value);
}

class WriteWrappedSourceOfTruth<Key, T> extends CachedSourceOfTruth<Key, T> {
  WriteWrappedSourceOfTruth(this._realSourceOfTruth);

  final SourceOfTruth<Key, T>? _realSourceOfTruth;

  @override
  Future<void> write(Key key, T? value) async {
    await _realSourceOfTruth?.write(key, value);
    await super.write(key, value);
  }
}
