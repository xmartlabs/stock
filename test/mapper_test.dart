import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock_extensions.dart';
import 'package:stock/src/type_mapper.dart';
import 'package:test/test.dart';

void main() {
  group('Mapper test', () {
    test('SOT of type is converted to the new type using mapper', () async {
      final sot = CachedSourceOfTruth<int, int>();
      final newSot = sot.mapToUsingMapper(_IntStringMapper());

      await newSot.write(1, '2');
      expect(await sot.reader(1).first, 2);
      expect(await newSot.reader(1).first, '2');

      await sot.write(1, 3);
      expect(await sot.reader(1).first, 3);
      expect(await newSot.reader(1).first, '3');
    });

    test('SOT of type is converted to the new type using functions', () async {
      final sot = CachedSourceOfTruth<int, int>();
      final newSot = sot.mapTo((value) => value.toString(), int.parse);

      await newSot.write(1, '2');
      expect(await sot.reader(1).first, 2);
      expect(await newSot.reader(1).first, '2');

      await sot.write(1, 3);
      expect(await sot.reader(1).first, 3);
      expect(await newSot.reader(1).first, '3');
    });
  });
}

class _IntStringMapper implements StockTypeMapper<int, String> {
  @override
  String fromInput(int value) => value.toString();

  @override
  int fromOutput(String value) => int.parse(value);
}
