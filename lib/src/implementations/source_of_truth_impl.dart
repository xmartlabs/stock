import 'package:stock/src/source_of_truth.dart';

class SourceOfTruthImpl<Key, T> implements SourceOfTruth<Key, T> {
  final Stream<T?> Function(Key key) _reader;
  final Future<void> Function(Key key, T? output) _writer;

  SourceOfTruthImpl(this._reader, this._writer);

  @override
  Stream<T?> reader(Key key) => _reader(key);

  @override
  Future<void> write(Key key, T? value) => _writer(key, value);
}

class WriteWrappedSourceOfTruth<Key, T> extends CachedSourceOfTruth<Key, T> {
  final SourceOfTruth<Key, T>? _realSourceOfTruth;

  WriteWrappedSourceOfTruth(this._realSourceOfTruth);

  @override
  Future<void> write(Key key, T? value) async {
    await _realSourceOfTruth?.write(key, value);
    await super.write(key, value);
  }
}
