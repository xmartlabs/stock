import 'package:rxdart/rxdart.dart';
import 'package:stock/src/source_of_truth.dart';

class CachedSourceOfTruthWithDefaultValue<Key, T>
    extends CachedSourceOfTruth<Key, T> {
  CachedSourceOfTruthWithDefaultValue([this._defaultValue]);

  final T? _defaultValue;

  @override
  Stream<T?> reader(Key key) => super.reader(key).flatMap((response) async* {
        yield response ?? _defaultValue;
      });
}
