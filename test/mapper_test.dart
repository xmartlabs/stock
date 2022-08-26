import 'package:flutter_test/flutter_test.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/store_extensions.dart';
import 'package:stock/type_mapper.dart';

void main() {
  group("Mapper test", () {
    test('SOT of type is converted to the new type using mapper', () async {
      final sot = CachedSourceOfTruth<int, int>();
      final newSot = sot.mapToUsingMapper(_IntStringMapper());

      newSot.write(1, '2');
      expect(await sot.reader(1).first, 2);
      expect(await newSot.reader(1).first, '2');

      sot.write(1, 3);
      expect(await sot.reader(1).first, 3);
      expect(await newSot.reader(1).first, '3');
    });

    test('SOT of type is converted to the new type using functions', () async {
      final sot = CachedSourceOfTruth<int, int>();
      final newSot = sot.mapTo((value) => value.toString(), int.parse);

      newSot.write(1, '2');
      expect(await sot.reader(1).first, 2);
      expect(await newSot.reader(1).first, '2');

      sot.write(1, 3);
      expect(await sot.reader(1).first, 3);
      expect(await newSot.reader(1).first, '3');
    });
  });
}

class _IntStringMapper implements StoreTypeMapper<int, String> {
  @override
  String fromInput(int value) => value.toString();

  @override
  int fromOutput(String value) => int.parse(value);
}
