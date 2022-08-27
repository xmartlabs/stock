import 'package:stock/stock_response.dart';

extension ResponseExtensions<T> on StockResponse<T> {
  StockResponse<T> removeStacktraceIfNeeded() => this is StockResponseError<T>
      ? StockResponse.error(origin, (this as StockResponseError<T>).error)
      : this;
}
