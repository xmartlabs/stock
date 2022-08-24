/// Converts the [Input] type to the [Output] and vice versa.
/// Used to transform DB entity to network entity and vise versa.
abstract class StoreTypeMapper<Input, Output> {
  Output fromInput(Input value);

  Input fromOutput(Output value);
}
