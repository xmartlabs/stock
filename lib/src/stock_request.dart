import 'package:stock/src/fetcher.dart';
import 'package:stock/src/source_of_truth.dart';
import 'package:stock/src/stock.dart';

/// Represents a single [Stock] request
///
/// The [key] is a unique identifier for your data
///
/// If [refresh] is `true`, [Stock] will always get fresh value from fetcher.
/// If it's `false`, [Stock] will try to return the [SourceOfTruth] data,
/// and if it doesn't exist, [Stock] will request fresh data using the [Fetcher].
///
class StockRequest<Key> {
  Key key;
  bool refresh;

  StockRequest({
    required this.key,
    required this.refresh,
  });
}
