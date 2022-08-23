import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stock/south_of_truth.dart';

import '../../common_mocks.mocks.dart';
import 'cached_source_of_truth_with_default_value.dart';

SourceOfTruth<Key, Value> createMockedSourceOfTruth<Key, Value>(
    [Value? defaultValue]) {
  final cachedSourceOfTruth =
      CachedSourceOfTruthWithDefaultValue<Key, Value>(defaultValue);
  final sourceOfTruth = MockSourceOfTruth<Key, Value>();
  when(sourceOfTruth.reader).thenReturn(cachedSourceOfTruth.reader);
  when(sourceOfTruth.writer).thenReturn(cachedSourceOfTruth.writer);
  return sourceOfTruth;
}

SourceOfTruth<int, int> createMockedSourceOfTruthWithDefaultNegativeIntKey() {
  final sot = _NegativeKeyIntSource();
  final sourceOfTruth = MockSourceOfTruth<int, int>();
  when(sourceOfTruth.reader).thenReturn(sot.reader);
  when(sourceOfTruth.writer).thenReturn(sot.writer);
  return sourceOfTruth;
}

class _NegativeKeyIntSource extends CachedSourceOfTruth<int, int> {
  _NegativeKeyIntSource();

  @override
  Stream<int?> generateReader(int key) =>
      super.generateReader(key).flatMap((response) async* {
        yield response ?? -key;
      });
}
