import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/store.dart';

/// Represents a single store request
///
/// The [key] a unique identifier for your data
///
/// If [refresh] is `true`, [Store] will always get fresh value from fetcher.
/// If it's `false`, [Store] will try to return the [SourceOfTruth] data,
/// and if it doesn't exist, [Store] will request a fresh data using the [Fetcher].
///
class StoreRequest<Key> {
  Key key;
  bool refresh;

  StoreRequest({
    required this.key,
    required this.refresh,
  });
}
