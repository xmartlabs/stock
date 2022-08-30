// ignore_for_file: public_member_api_docs

import 'package:rxdart/rxdart.dart';
import 'package:stock/src/stock_response.dart';

extension StreamExtensions<T> on Stream<T> {
  Stream<StockResponse<T>> mapToResponse(ResponseOrigin origin) =>
      map((data) => StockResponse.data(origin, data))
          .onErrorReturnWith((error, stacktrace) {
        return StockResponse.error(origin, error, stacktrace);
      });
}

extension FutureExtensions<T> on Future<T> {
  Future<StockResponse<T>> mapToResponse(ResponseOrigin origin) async {
    try {
      return StockResponse.data(origin, await this);
    } catch (error, stacktrace) {
      return StockResponse.error(origin, error, stacktrace);
    }
  }
}
