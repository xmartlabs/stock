/// Converts the [Input] type to the [Output] and vice versa.
/// Used to transform DB entity to network entity and vice versa.
abstract interface class StockTypeMapper<Input, Output> {
  /// Transform a [Input] into a [Output]
  Output fromInput(Input value);

  /// Transform a [Output] into a [Input]
  Input fromOutput(Output value);
}
