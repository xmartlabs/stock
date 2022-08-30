import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/type_mapper.dart';

/// [SourceOfTruth] useful extensions.
extension SourceOfTruthExtensions<Key, Input> on SourceOfTruth<Key, Input> {
  /// Transforms a [SourceOfTruth] of [Key], [Input] into a [SourceOfTruth] of
  /// [Key], [Output].
  SourceOfTruth<Key, Output> mapToUsingMapper<Output>(
    StockTypeMapper<Input, Output> mapper,
  ) =>
      mapTo(mapper.fromInput, mapper.fromOutput);

  /// Transforms a [SourceOfTruth] of [Key], [Input] into a [SourceOfTruth] of
  /// [Key], [Output].
  SourceOfTruth<Key, Output> mapTo<Output>(
    Output Function(Input) fromInput,
    Input Function(Output) fromOutput,
  ) =>
      SourceOfTruth<Key, Output>(
        reader: (key) =>
            reader(key).map((value) => value == null ? null : fromInput(value)),
        writer: (key, value) =>
            write(key, value == null ? null : fromOutput(value)),
      );
}
