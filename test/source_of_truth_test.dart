import 'package:flutter_test/flutter_test.dart';
import 'package:stock/src/source_of_truth.dart';

import 'common/stock_test_extensions.dart';

void main() {
  group("Cached SOT", () {
    test('Multiple requests to the same SOT', () async {
      final sot = CachedSourceOfTruth<int, int>();
      await sot.write(1, 1);
      final oneResultListener = ResultListener(sot.reader(1));
      final twoResultListener = ResultListener(sot.reader(2));
      // Wait for initialization time
      await Future.delayed(const Duration(milliseconds: 100));

      await sot.write(1, 2);
      await sot.write(2, 3);
      await sot.write(2, 4);

      await Future.delayed(const Duration(milliseconds: 100));
      final oneResult = await oneResultListener.stopAndGetResult();
      final twoResult = await twoResultListener.stopAndGetResult();

      expect(oneResult, equals([1, 2]));
      expect(twoResult, equals([null, 3, 4]));
    });
  });
}
