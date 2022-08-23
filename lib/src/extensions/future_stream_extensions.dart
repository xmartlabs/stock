import 'package:rxdart/rxdart.dart';
import 'package:stock/store_response.dart';

extension StreamExtensions<T> on Stream<T> {
  Stream<StoreResponse<T>> mapToResponse(ResponseOrigin origin) =>
      map((data) => StoreResponse.data(origin, data))
          .onErrorReturnWith((error, stacktrace) {
        return StoreResponse.error(origin, error, stacktrace);
      });
}

extension FutureExtensions<T> on Future<T> {
  Future<StoreResponse<T>> mapToResponse(ResponseOrigin origin) async {
    try {
      return StoreResponse.data(origin, await this);
    } catch (error, stacktrace) {
      return StoreResponse.error(origin, error, stacktrace);
    }
  }
}
