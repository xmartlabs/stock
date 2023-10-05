import 'package:rxdart/transformers.dart';

import 'cached_source_of_truth_with_default_value.dart';

class SourceOfTruthWithError<Key, T>
    extends CachedSourceOfTruthWithDefaultValue<Key, T> {
  SourceOfTruthWithError(
    super.cachedValue, {
    this.throwReadErrorCount = 0,
    this.throwWriteErrorCount = 0,
  });

  static final readException = Exception('Read Test Exception');
  static final writeException = Exception('Write Test Exception');

  int throwReadErrorCount;
  int throwWriteErrorCount;

  @override
  Stream<T?> reader(Key key) => super.reader(key).flatMap((response) async* {
        if (throwReadErrorCount > 0) {
          throwReadErrorCount--;
          throw readException;
        }
        yield response;
      });

  @override
  Future<void> write(Key key, T? value) async {
    if (throwWriteErrorCount > 0) {
      throwWriteErrorCount--;
      throw writeException;
    }
    await super.write(key, value);
  }
}
