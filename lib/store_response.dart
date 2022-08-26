import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stock/fetcher.dart';
import 'package:stock/source_of_truth.dart';
import 'package:stock/store.dart';

part 'store_response.freezed.dart';

/// Holder for responses from Store.
///
/// Instead of using regular error channels (a.k.a. throwing exceptions), Store uses this holder
/// class to represent each response. This allows the [Stream] to keep flowing even if an error happens
/// so that if there is an observable single source of truth, the application can keep observing it.
@freezed
class StoreResponse<Output> with _$StoreResponse<Output> {
  /// Loading event dispatched by [Store] to signal the [Fetcher] is currently running.
  @With<_ResponseWithOrigin>()
  const factory StoreResponse.loading(ResponseOrigin origin) =
      StoreResponseLoading<Output>;

  /// Data dispatched by [Store]
  @With<_ResponseWithOrigin>()
  factory StoreResponse.data(ResponseOrigin origin, Output value) =
      StoreResponseData<Output>;

  /// Error dispatched by a pipeline
  @With<_ResponseWithOrigin>()
  const factory StoreResponse.error(ResponseOrigin origin, Object error,
      [StackTrace? stackTrace]) = StoreResponseError<Output>;
}

mixin _ResponseWithOrigin {
  ResponseOrigin get origin;
}

/// Represents the origin for a [StoreResponse].
enum ResponseOrigin {
  /// [StoreResponse] is sent from the [SourceOfTruth]
  sourceOfTruth,

  /// [StoreResponse] is sent from a [Fetcher],
  fetcher,
}
