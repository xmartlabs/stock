import 'package:freezed_annotation/freezed_annotation.dart';

part 'store_response.freezed.dart';

@freezed
class StoreResponse<Output> with _$StoreResponse<Output> {
  @With<_ResponseWithOrigin>()
  factory StoreResponse.data(ResponseOrigin origin, Output value) =
      StoreResponseData<Output>;

  @With<_ResponseWithOrigin>()
  const factory StoreResponse.loading(ResponseOrigin origin) =
      StoreResponseLoading<Output>;

  @With<_ResponseWithOrigin>()
  const factory StoreResponse.error(ResponseOrigin origin, Object error,
      [StackTrace? stackTrace]) = StoreResponseError<Output>;
}

mixin _ResponseWithOrigin {
  ResponseOrigin get origin;
}

enum ResponseOrigin {
  cache,
  sourceOfTruth,
  fetcher,
}
