import 'package:mockito/annotations.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/src/factory_fetcher.dart';

@GenerateMocks([
  FutureFetcher,
  StreamFetcher,
  SourceOfTruth,
])
void main() {}
