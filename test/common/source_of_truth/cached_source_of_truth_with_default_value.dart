import 'package:rxdart/rxdart.dart';
import 'package:stock/south_of_truth.dart';

class CachedSourceOfTruthWithDefaultValue<Key, T>
    extends CachedSourceOfTruth<Key, T> {
  final T? _defaultValue;

  CachedSourceOfTruthWithDefaultValue([this._defaultValue]);

  @override
  Stream<T?> generateReader(Key key) =>
      super.generateReader(key).flatMap((response) async* {
        yield response ?? _defaultValue;
      });
}
