import 'package:mockito/annotations.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';

@GenerateMocks([
  FutureFetcher,
  StreamFetcher,
  SourceOfTruth,
])
void main() {}
