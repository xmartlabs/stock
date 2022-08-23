// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'store_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$StoreResponse<Output> {
  ResponseOrigin get origin => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ResponseOrigin origin, Output value) data,
    required TResult Function(ResponseOrigin origin) loading,
    required TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoreResponseData<Output> value) data,
    required TResult Function(StoreResponseLoading<Output> value) loading,
    required TResult Function(StoreResponseError<Output> value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $StoreResponseCopyWith<Output, StoreResponse<Output>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StoreResponseCopyWith<Output, $Res> {
  factory $StoreResponseCopyWith(StoreResponse<Output> value,
          $Res Function(StoreResponse<Output>) then) =
      _$StoreResponseCopyWithImpl<Output, $Res>;
  $Res call({ResponseOrigin origin});
}

/// @nodoc
class _$StoreResponseCopyWithImpl<Output, $Res>
    implements $StoreResponseCopyWith<Output, $Res> {
  _$StoreResponseCopyWithImpl(this._value, this._then);

  final StoreResponse<Output> _value;
  // ignore: unused_field
  final $Res Function(StoreResponse<Output>) _then;

  @override
  $Res call({
    Object? origin = freezed,
  }) {
    return _then(_value.copyWith(
      origin: origin == freezed
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as ResponseOrigin,
    ));
  }
}

/// @nodoc
abstract class _$$StoreResponseDataCopyWith<Output, $Res>
    implements $StoreResponseCopyWith<Output, $Res> {
  factory _$$StoreResponseDataCopyWith(_$StoreResponseData<Output> value,
          $Res Function(_$StoreResponseData<Output>) then) =
      __$$StoreResponseDataCopyWithImpl<Output, $Res>;
  @override
  $Res call({ResponseOrigin origin, Output value});
}

/// @nodoc
class __$$StoreResponseDataCopyWithImpl<Output, $Res>
    extends _$StoreResponseCopyWithImpl<Output, $Res>
    implements _$$StoreResponseDataCopyWith<Output, $Res> {
  __$$StoreResponseDataCopyWithImpl(_$StoreResponseData<Output> _value,
      $Res Function(_$StoreResponseData<Output>) _then)
      : super(_value, (v) => _then(v as _$StoreResponseData<Output>));

  @override
  _$StoreResponseData<Output> get _value =>
      super._value as _$StoreResponseData<Output>;

  @override
  $Res call({
    Object? origin = freezed,
    Object? value = freezed,
  }) {
    return _then(_$StoreResponseData<Output>(
      origin == freezed
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as ResponseOrigin,
      value == freezed
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as Output,
    ));
  }
}

/// @nodoc

class _$StoreResponseData<Output>
    with _ResponseWithOrigin
    implements StoreResponseData<Output> {
  _$StoreResponseData(this.origin, this.value);

  @override
  final ResponseOrigin origin;
  @override
  final Output value;

  @override
  String toString() {
    return 'StoreResponse<$Output>.data(origin: $origin, value: $value)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreResponseData<Output> &&
            const DeepCollectionEquality().equals(other.origin, origin) &&
            const DeepCollectionEquality().equals(other.value, value));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(origin),
      const DeepCollectionEquality().hash(value));

  @JsonKey(ignore: true)
  @override
  _$$StoreResponseDataCopyWith<Output, _$StoreResponseData<Output>>
      get copyWith => __$$StoreResponseDataCopyWithImpl<Output,
          _$StoreResponseData<Output>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ResponseOrigin origin, Output value) data,
    required TResult Function(ResponseOrigin origin) loading,
    required TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)
        error,
  }) {
    return data(origin, value);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return data?.call(origin, value);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(origin, value);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoreResponseData<Output> value) data,
    required TResult Function(StoreResponseLoading<Output> value) loading,
    required TResult Function(StoreResponseError<Output> value) error,
  }) {
    return data(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
  }) {
    return data?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
    required TResult orElse(),
  }) {
    if (data != null) {
      return data(this);
    }
    return orElse();
  }
}

abstract class StoreResponseData<Output>
    implements StoreResponse<Output>, _ResponseWithOrigin {
  factory StoreResponseData(final ResponseOrigin origin, final Output value) =
      _$StoreResponseData<Output>;

  @override
  ResponseOrigin get origin;
  Output get value;
  @override
  @JsonKey(ignore: true)
  _$$StoreResponseDataCopyWith<Output, _$StoreResponseData<Output>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StoreResponseLoadingCopyWith<Output, $Res>
    implements $StoreResponseCopyWith<Output, $Res> {
  factory _$$StoreResponseLoadingCopyWith(_$StoreResponseLoading<Output> value,
          $Res Function(_$StoreResponseLoading<Output>) then) =
      __$$StoreResponseLoadingCopyWithImpl<Output, $Res>;
  @override
  $Res call({ResponseOrigin origin});
}

/// @nodoc
class __$$StoreResponseLoadingCopyWithImpl<Output, $Res>
    extends _$StoreResponseCopyWithImpl<Output, $Res>
    implements _$$StoreResponseLoadingCopyWith<Output, $Res> {
  __$$StoreResponseLoadingCopyWithImpl(_$StoreResponseLoading<Output> _value,
      $Res Function(_$StoreResponseLoading<Output>) _then)
      : super(_value, (v) => _then(v as _$StoreResponseLoading<Output>));

  @override
  _$StoreResponseLoading<Output> get _value =>
      super._value as _$StoreResponseLoading<Output>;

  @override
  $Res call({
    Object? origin = freezed,
  }) {
    return _then(_$StoreResponseLoading<Output>(
      origin == freezed
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as ResponseOrigin,
    ));
  }
}

/// @nodoc

class _$StoreResponseLoading<Output>
    with _ResponseWithOrigin
    implements StoreResponseLoading<Output> {
  const _$StoreResponseLoading(this.origin);

  @override
  final ResponseOrigin origin;

  @override
  String toString() {
    return 'StoreResponse<$Output>.loading(origin: $origin)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreResponseLoading<Output> &&
            const DeepCollectionEquality().equals(other.origin, origin));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(origin));

  @JsonKey(ignore: true)
  @override
  _$$StoreResponseLoadingCopyWith<Output, _$StoreResponseLoading<Output>>
      get copyWith => __$$StoreResponseLoadingCopyWithImpl<Output,
          _$StoreResponseLoading<Output>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ResponseOrigin origin, Output value) data,
    required TResult Function(ResponseOrigin origin) loading,
    required TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)
        error,
  }) {
    return loading(origin);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return loading?.call(origin);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(origin);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoreResponseData<Output> value) data,
    required TResult Function(StoreResponseLoading<Output> value) loading,
    required TResult Function(StoreResponseError<Output> value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class StoreResponseLoading<Output>
    implements StoreResponse<Output>, _ResponseWithOrigin {
  const factory StoreResponseLoading(final ResponseOrigin origin) =
      _$StoreResponseLoading<Output>;

  @override
  ResponseOrigin get origin;
  @override
  @JsonKey(ignore: true)
  _$$StoreResponseLoadingCopyWith<Output, _$StoreResponseLoading<Output>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$StoreResponseErrorCopyWith<Output, $Res>
    implements $StoreResponseCopyWith<Output, $Res> {
  factory _$$StoreResponseErrorCopyWith(_$StoreResponseError<Output> value,
          $Res Function(_$StoreResponseError<Output>) then) =
      __$$StoreResponseErrorCopyWithImpl<Output, $Res>;
  @override
  $Res call({ResponseOrigin origin, Object error, StackTrace? stackTrace});
}

/// @nodoc
class __$$StoreResponseErrorCopyWithImpl<Output, $Res>
    extends _$StoreResponseCopyWithImpl<Output, $Res>
    implements _$$StoreResponseErrorCopyWith<Output, $Res> {
  __$$StoreResponseErrorCopyWithImpl(_$StoreResponseError<Output> _value,
      $Res Function(_$StoreResponseError<Output>) _then)
      : super(_value, (v) => _then(v as _$StoreResponseError<Output>));

  @override
  _$StoreResponseError<Output> get _value =>
      super._value as _$StoreResponseError<Output>;

  @override
  $Res call({
    Object? origin = freezed,
    Object? error = freezed,
    Object? stackTrace = freezed,
  }) {
    return _then(_$StoreResponseError<Output>(
      origin == freezed
          ? _value.origin
          : origin // ignore: cast_nullable_to_non_nullable
              as ResponseOrigin,
      error == freezed
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as Object,
      stackTrace == freezed
          ? _value.stackTrace
          : stackTrace // ignore: cast_nullable_to_non_nullable
              as StackTrace?,
    ));
  }
}

/// @nodoc

class _$StoreResponseError<Output>
    with _ResponseWithOrigin
    implements StoreResponseError<Output> {
  const _$StoreResponseError(this.origin, this.error, [this.stackTrace]);

  @override
  final ResponseOrigin origin;
  @override
  final Object error;
  @override
  final StackTrace? stackTrace;

  @override
  String toString() {
    return 'StoreResponse<$Output>.error(origin: $origin, error: $error, stackTrace: $stackTrace)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StoreResponseError<Output> &&
            const DeepCollectionEquality().equals(other.origin, origin) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            const DeepCollectionEquality()
                .equals(other.stackTrace, stackTrace));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(origin),
      const DeepCollectionEquality().hash(error),
      const DeepCollectionEquality().hash(stackTrace));

  @JsonKey(ignore: true)
  @override
  _$$StoreResponseErrorCopyWith<Output, _$StoreResponseError<Output>>
      get copyWith => __$$StoreResponseErrorCopyWithImpl<Output,
          _$StoreResponseError<Output>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(ResponseOrigin origin, Output value) data,
    required TResult Function(ResponseOrigin origin) loading,
    required TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)
        error,
  }) {
    return error(origin, this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
  }) {
    return error?.call(origin, this.error, stackTrace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(ResponseOrigin origin, Output value)? data,
    TResult Function(ResponseOrigin origin)? loading,
    TResult Function(
            ResponseOrigin origin, Object error, StackTrace? stackTrace)?
        error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(origin, this.error, stackTrace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(StoreResponseData<Output> value) data,
    required TResult Function(StoreResponseLoading<Output> value) loading,
    required TResult Function(StoreResponseError<Output> value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(StoreResponseData<Output> value)? data,
    TResult Function(StoreResponseLoading<Output> value)? loading,
    TResult Function(StoreResponseError<Output> value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class StoreResponseError<Output>
    implements StoreResponse<Output>, _ResponseWithOrigin {
  const factory StoreResponseError(
      final ResponseOrigin origin, final Object error,
      [final StackTrace? stackTrace]) = _$StoreResponseError<Output>;

  @override
  ResponseOrigin get origin;
  Object get error;
  StackTrace? get stackTrace;
  @override
  @JsonKey(ignore: true)
  _$$StoreResponseErrorCopyWith<Output, _$StoreResponseError<Output>>
      get copyWith => throw _privateConstructorUsedError;
}
