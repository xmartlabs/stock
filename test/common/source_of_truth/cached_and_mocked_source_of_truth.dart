import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/src/source_of_truth.dart';

import '../../common_mocks.mocks.dart';
import 'cached_source_of_truth_with_default_value.dart';

MockSourceOfTruth<Key, Value> createMockedSourceOfTruthFromMethods<Key, Value>(
  Stream<Value?> Function(Key key) reader,
  Future<void> Function(Key key, Value? output) writer,
) {
  final sourceOfTruth = MockSourceOfTruth<Key, Value>();
  when(sourceOfTruth.reader(any)).thenAnswer(
    (invocation) => reader(invocation.positionalArguments[0] as Key),
  );
  when(sourceOfTruth.write(any, any)).thenAnswer(
    (invocation) => writer(
      invocation.positionalArguments[0] as Key,
      invocation.positionalArguments[1] as Value?,
    ),
  );
  return sourceOfTruth;
}

MockSourceOfTruth<Key, Value> createMockedSourceOfTruth<Key, Value>([
  Value? defaultValue,
]) {
  final cachedSot =
      CachedSourceOfTruthWithDefaultValue<Key, Value>(defaultValue);
  return createMockedSourceOfTruthFromMethods(
    cachedSot.reader,
    cachedSot.write,
  );
}

MockSourceOfTruth<int, int>
    createMockedSourceOfTruthWithDefaultNegativeIntKey() {
  final sot = _NegativeKeyIntSource();
  return createMockedSourceOfTruthFromMethods(sot.reader, sot.write);
}

class _NegativeKeyIntSource extends CachedSourceOfTruth<int, int> {
  _NegativeKeyIntSource();

  @override
  Stream<int?> reader(int key) => super.reader(key).flatMap((response) async* {
        yield response ?? -key;
      });
}
