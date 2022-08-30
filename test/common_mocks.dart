import 'package:mockito/annotations.dart';
import 'package:stock/src/implementations/factory_fetcher.dart';
import 'package:stock/src/source_of_truth.dart';

@GenerateMocks([
  FutureFetcher,
  StreamFetcher,
  SourceOfTruth,
])
void main() {}
