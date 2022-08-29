/// Used to notify unexpected errors
class StockError extends Error {
  final String message;

  StockError(this.message);

  @override
  String toString() => "StockError: $message";
}
