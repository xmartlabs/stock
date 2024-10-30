import 'package:equatable/equatable.dart';

class MockIntKeyValue extends Equatable {
  const MockIntKeyValue(this.key, this.value);

  final int key;
  final int value;

  @override
  List<Object> get props => [key];
}
