// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_spots.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SavedSpots {

 List<Venue> get venues; List<String> get failedIds;
/// Create a copy of SavedSpots
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedSpotsCopyWith<SavedSpots> get copyWith => _$SavedSpotsCopyWithImpl<SavedSpots>(this as SavedSpots, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedSpots&&const DeepCollectionEquality().equals(other.venues, venues)&&const DeepCollectionEquality().equals(other.failedIds, failedIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(venues),const DeepCollectionEquality().hash(failedIds));

@override
String toString() {
  return 'SavedSpots(venues: $venues, failedIds: $failedIds)';
}


}

/// @nodoc
abstract mixin class $SavedSpotsCopyWith<$Res>  {
  factory $SavedSpotsCopyWith(SavedSpots value, $Res Function(SavedSpots) _then) = _$SavedSpotsCopyWithImpl;
@useResult
$Res call({
 List<Venue> venues, List<String> failedIds
});




}
/// @nodoc
class _$SavedSpotsCopyWithImpl<$Res>
    implements $SavedSpotsCopyWith<$Res> {
  _$SavedSpotsCopyWithImpl(this._self, this._then);

  final SavedSpots _self;
  final $Res Function(SavedSpots) _then;

/// Create a copy of SavedSpots
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venues = null,Object? failedIds = null,}) {
  return _then(_self.copyWith(
venues: null == venues ? _self.venues : venues // ignore: cast_nullable_to_non_nullable
as List<Venue>,failedIds: null == failedIds ? _self.failedIds : failedIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedSpots].
extension SavedSpotsPatterns on SavedSpots {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedSpots value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedSpots() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedSpots value)  $default,){
final _that = this;
switch (_that) {
case _SavedSpots():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedSpots value)?  $default,){
final _that = this;
switch (_that) {
case _SavedSpots() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Venue> venues,  List<String> failedIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedSpots() when $default != null:
return $default(_that.venues,_that.failedIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Venue> venues,  List<String> failedIds)  $default,) {final _that = this;
switch (_that) {
case _SavedSpots():
return $default(_that.venues,_that.failedIds);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Venue> venues,  List<String> failedIds)?  $default,) {final _that = this;
switch (_that) {
case _SavedSpots() when $default != null:
return $default(_that.venues,_that.failedIds);case _:
  return null;

}
}

}

/// @nodoc


class _SavedSpots extends SavedSpots {
  const _SavedSpots({required this.venues, required this.failedIds}): super._();
  

@override final  List<Venue> venues;
@override final  List<String> failedIds;

/// Create a copy of SavedSpots
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedSpotsCopyWith<_SavedSpots> get copyWith => __$SavedSpotsCopyWithImpl<_SavedSpots>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedSpots&&const DeepCollectionEquality().equals(other.venues, venues)&&const DeepCollectionEquality().equals(other.failedIds, failedIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(venues),const DeepCollectionEquality().hash(failedIds));

@override
String toString() {
  return 'SavedSpots(venues: $venues, failedIds: $failedIds)';
}


}

/// @nodoc
abstract mixin class _$SavedSpotsCopyWith<$Res> implements $SavedSpotsCopyWith<$Res> {
  factory _$SavedSpotsCopyWith(_SavedSpots value, $Res Function(_SavedSpots) _then) = __$SavedSpotsCopyWithImpl;
@override @useResult
$Res call({
 List<Venue> venues, List<String> failedIds
});




}
/// @nodoc
class __$SavedSpotsCopyWithImpl<$Res>
    implements _$SavedSpotsCopyWith<$Res> {
  __$SavedSpotsCopyWithImpl(this._self, this._then);

  final _SavedSpots _self;
  final $Res Function(_SavedSpots) _then;

/// Create a copy of SavedSpots
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venues = null,Object? failedIds = null,}) {
  return _then(_SavedSpots(
venues: null == venues ? _self.venues : venues // ignore: cast_nullable_to_non_nullable
as List<Venue>,failedIds: null == failedIds ? _self.failedIds : failedIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
