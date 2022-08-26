import 'source_of_truth.dart';

abstract class StoreConverter<T0, T1> {
  T1 fromT0(T0 t0);

  T0 fromT1(T1 t1);
}

extension SourceOfTruthExtensions<Key, Output1> on SourceOfTruth<Key, Output1> {
  SourceOfTruth<Key, Output2> mapTo<Output2>(
    StoreConverter<Output1, Output2> converter,
  ) =>
      SourceOfTruth<Key, Output2>(
        reader: (key) => reader(key)
            .map((value) => value == null ? null : converter.fromT0(value)),
        writer: (key, value) =>
            writer(key, value == null ? null : converter.fromT1(value)),
      );
}
