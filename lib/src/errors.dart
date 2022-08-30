/// Used to notify unexpected errors
class StockError extends Error {
  /// Constructor
  StockError(this.message);

  /// The error message
  final String message;

  @override
  String toString() => 'StockError: $message';
}
