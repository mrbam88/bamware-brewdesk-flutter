// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'location_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocationResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocationResult()';
}


}

/// @nodoc
class $LocationResultCopyWith<$Res>  {
$LocationResultCopyWith(LocationResult _, $Res Function(LocationResult) __);
}


/// Adds pattern-matching-related methods to [LocationResult].
extension LocationResultPatterns on LocationResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LocationAcquired value)?  acquired,TResult Function( LocationUnavailable value)?  unavailable,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LocationAcquired() when acquired != null:
return acquired(_that);case LocationUnavailable() when unavailable != null:
return unavailable(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LocationAcquired value)  acquired,required TResult Function( LocationUnavailable value)  unavailable,}){
final _that = this;
switch (_that) {
case LocationAcquired():
return acquired(_that);case LocationUnavailable():
return unavailable(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LocationAcquired value)?  acquired,TResult? Function( LocationUnavailable value)?  unavailable,}){
final _that = this;
switch (_that) {
case LocationAcquired() when acquired != null:
return acquired(_that);case LocationUnavailable() when unavailable != null:
return unavailable(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( LatLng position)?  acquired,TResult Function( LocationFailureReason reason)?  unavailable,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LocationAcquired() when acquired != null:
return acquired(_that.position);case LocationUnavailable() when unavailable != null:
return unavailable(_that.reason);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( LatLng position)  acquired,required TResult Function( LocationFailureReason reason)  unavailable,}) {final _that = this;
switch (_that) {
case LocationAcquired():
return acquired(_that.position);case LocationUnavailable():
return unavailable(_that.reason);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( LatLng position)?  acquired,TResult? Function( LocationFailureReason reason)?  unavailable,}) {final _that = this;
switch (_that) {
case LocationAcquired() when acquired != null:
return acquired(_that.position);case LocationUnavailable() when unavailable != null:
return unavailable(_that.reason);case _:
  return null;

}
}

}

/// @nodoc


class LocationAcquired implements LocationResult {
  const LocationAcquired(this.position);
  

 final  LatLng position;

/// Create a copy of LocationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationAcquiredCopyWith<LocationAcquired> get copyWith => _$LocationAcquiredCopyWithImpl<LocationAcquired>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationAcquired&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString() {
  return 'LocationResult.acquired(position: $position)';
}


}

/// @nodoc
abstract mixin class $LocationAcquiredCopyWith<$Res> implements $LocationResultCopyWith<$Res> {
  factory $LocationAcquiredCopyWith(LocationAcquired value, $Res Function(LocationAcquired) _then) = _$LocationAcquiredCopyWithImpl;
@useResult
$Res call({
 LatLng position
});




}
/// @nodoc
class _$LocationAcquiredCopyWithImpl<$Res>
    implements $LocationAcquiredCopyWith<$Res> {
  _$LocationAcquiredCopyWithImpl(this._self, this._then);

  final LocationAcquired _self;
  final $Res Function(LocationAcquired) _then;

/// Create a copy of LocationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(LocationAcquired(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as LatLng,
  ));
}


}

/// @nodoc


class LocationUnavailable implements LocationResult {
  const LocationUnavailable(this.reason);
  

 final  LocationFailureReason reason;

/// Create a copy of LocationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocationUnavailableCopyWith<LocationUnavailable> get copyWith => _$LocationUnavailableCopyWithImpl<LocationUnavailable>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocationUnavailable&&(identical(other.reason, reason) || other.reason == reason));
}


@override
int get hashCode => Object.hash(runtimeType,reason);

@override
String toString() {
  return 'LocationResult.unavailable(reason: $reason)';
}


}

/// @nodoc
abstract mixin class $LocationUnavailableCopyWith<$Res> implements $LocationResultCopyWith<$Res> {
  factory $LocationUnavailableCopyWith(LocationUnavailable value, $Res Function(LocationUnavailable) _then) = _$LocationUnavailableCopyWithImpl;
@useResult
$Res call({
 LocationFailureReason reason
});




}
/// @nodoc
class _$LocationUnavailableCopyWithImpl<$Res>
    implements $LocationUnavailableCopyWith<$Res> {
  _$LocationUnavailableCopyWithImpl(this._self, this._then);

  final LocationUnavailable _self;
  final $Res Function(LocationUnavailable) _then;

/// Create a copy of LocationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? reason = null,}) {
  return _then(LocationUnavailable(
null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as LocationFailureReason,
  ));
}


}

// dart format on
