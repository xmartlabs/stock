import 'package:mockito/annotations.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/source_of_truth.dart';

import 'stock_response_extension_test.dart';

@GenerateMocks([
  CallbackVoid,
  CallbackInt,
  FutureFetcher,
  StreamFetcher,
  SourceOfTruth,
])
void main() {}
