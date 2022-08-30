import 'package:rxdart/transformers.dart';

import 'cached_source_of_truth_with_default_value.dart';

class DelayedSourceOfTruth<Key, T>
    extends CachedSourceOfTruthWithDefaultValue<Key, T> {
  DelayedSourceOfTruth([
    T? cachedValue,
    this.readDelayTime = const Duration(milliseconds: 100),
    this.writeDelayTime = const Duration(milliseconds: 100),
  ]) : super(cachedValue);

  final Duration readDelayTime;
  final Duration writeDelayTime;

  @override
  Stream<T?> reader(Key key) => super.reader(key).flatMap((response) async* {
        await Future<void>.delayed(readDelayTime);
        yield response;
      });

  @override
  Future<void> write(Key key, T? value) async {
    await Future<void>.delayed(readDelayTime);
    await super.write(key, value);
  }
}
