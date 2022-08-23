import 'package:stock/south_of_truth.dart';

class WriteWrappedSourceOfTruth<Key, T> extends CachedSourceOfTruth<Key, T> {
  final SourceOfTruth<Key, T>? _realSourceOfTruth;

  WriteWrappedSourceOfTruth(this._realSourceOfTruth);

  @override
  Future<void> generateWriter(Key key, T? value) async {
    await _realSourceOfTruth?.writer(key, value);
    await super.generateWriter(key, value);
  }
}
