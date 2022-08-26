import 'package:rxdart/rxdart.dart';
import 'package:stock/source_of_truth.dart';

class CachedSourceOfTruthWithDefaultValue<Key, T>
    extends CachedSourceOfTruth<Key, T> {
  final T? _defaultValue;

  CachedSourceOfTruthWithDefaultValue([this._defaultValue]);

  @override
  Stream<T?> reader(Key key) => super.reader(key).flatMap((response) async* {
        yield response ?? _defaultValue;
      });
}
