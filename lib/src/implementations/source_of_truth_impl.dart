// ignore_for_file: public_member_api_docs

import 'package:stock/src/source_of_truth.dart';

final class SourceOfTruthImpl<Key, T> implements SourceOfTruth<Key, T> {
  SourceOfTruthImpl(this._reader, this._writer, this._delete, this._deleteAll);

  final Stream<T?> Function(Key key) _reader;
  final Future<void> Function(Key key, T? output) _writer;
  final Future<void> Function(Key key)? _delete;
  final Future<void> Function()? _deleteAll;

  @override
  Stream<T?> reader(Key key) => _reader(key);

  @override
  Future<void> write(Key key, T? value) => _writer(key, value);

  @override
  Future<void> delete(Key key) async => await _delete?.call(key);

  @override
  Future<void> deleteAll() async => await _deleteAll?.call();
}

final class WriteWrappedSourceOfTruth<Key, T>
    extends CachedSourceOfTruth<Key, T> {
  WriteWrappedSourceOfTruth(this._realSourceOfTruth);

  final SourceOfTruth<Key, T>? _realSourceOfTruth;

  @override
  Future<void> write(Key key, T? value) async {
    await _realSourceOfTruth?.write(key, value);
    await super.write(key, value);
  }
}
