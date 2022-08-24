import 'package:stock/type_mapper.dart';

import 'source_of_truth.dart';

extension SourceOfTruthExtensions<Key, Input> on SourceOfTruth<Key, Input> {
  /// Transforms a [SourceOfTruth] of [Key], [Input] into a [SourceOfTruth] of [Key], [Output].
  SourceOfTruth<Key, Output> mapToUsingMapper<Output>(
          StoreTypeMapper<Input, Output> mapper) =>
      mapTo(mapper.fromInput, mapper.fromOutput);

  /// Transforms a [SourceOfTruth] of [Key], [Input] into a [SourceOfTruth] of [Key], [Output].
  SourceOfTruth<Key, Output> mapTo<Output>(Output Function(Input) fromInput,
          Input Function(Output) fromOutput) =>
      SourceOfTruth<Key, Output>(
        reader: (key) =>
            reader(key).map((value) => value == null ? null : fromInput(value)),
        writer: (key, value) =>
            write(key, value == null ? null : fromOutput(value)),
      );
}
