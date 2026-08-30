// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovery_filters.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoveryFilters {

 String get query; bool get laptopFriendly; WifiLevel? get minWifi; OutletsLevel? get minOutlets; WorkVenueType? get venueType;
/// Create a copy of DiscoveryFilters
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryFiltersCopyWith<DiscoveryFilters> get copyWith => _$DiscoveryFiltersCopyWithImpl<DiscoveryFilters>(this as DiscoveryFilters, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.laptopFriendly, laptopFriendly) || other.laptopFriendly == laptopFriendly)&&(identical(other.minWifi, minWifi) || other.minWifi == minWifi)&&(identical(other.minOutlets, minOutlets) || other.minOutlets == minOutlets)&&(identical(other.venueType, venueType) || other.venueType == venueType));
}


@override
int get hashCode => Object.hash(runtimeType,query,laptopFriendly,minWifi,minOutlets,venueType);

@override
String toString() {
  return 'DiscoveryFilters(query: $query, laptopFriendly: $laptopFriendly, minWifi: $minWifi, minOutlets: $minOutlets, venueType: $venueType)';
}


}

/// @nodoc
abstract mixin class $DiscoveryFiltersCopyWith<$Res>  {
  factory $DiscoveryFiltersCopyWith(DiscoveryFilters value, $Res Function(DiscoveryFilters) _then) = _$DiscoveryFiltersCopyWithImpl;
@useResult
$Res call({
 String query, bool laptopFriendly, WifiLevel? minWifi, OutletsLevel? minOutlets, WorkVenueType? venueType
});




}
/// @nodoc
class _$DiscoveryFiltersCopyWithImpl<$Res>
    implements $DiscoveryFiltersCopyWith<$Res> {
  _$DiscoveryFiltersCopyWithImpl(this._self, this._then);

  final DiscoveryFilters _self;
  final $Res Function(DiscoveryFilters) _then;

/// Create a copy of DiscoveryFilters
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? laptopFriendly = null,Object? minWifi = freezed,Object? minOutlets = freezed,Object? venueType = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,laptopFriendly: null == laptopFriendly ? _self.laptopFriendly : laptopFriendly // ignore: cast_nullable_to_non_nullable
as bool,minWifi: freezed == minWifi ? _self.minWifi : minWifi // ignore: cast_nullable_to_non_nullable
as WifiLevel?,minOutlets: freezed == minOutlets ? _self.minOutlets : minOutlets // ignore: cast_nullable_to_non_nullable
as OutletsLevel?,venueType: freezed == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as WorkVenueType?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscoveryFilters].
extension DiscoveryFiltersPatterns on DiscoveryFilters {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscoveryFilters value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscoveryFilters() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscoveryFilters value)  $default,){
final _that = this;
switch (_that) {
case _DiscoveryFilters():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscoveryFilters value)?  $default,){
final _that = this;
switch (_that) {
case _DiscoveryFilters() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  bool laptopFriendly,  WifiLevel? minWifi,  OutletsLevel? minOutlets,  WorkVenueType? venueType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscoveryFilters() when $default != null:
return $default(_that.query,_that.laptopFriendly,_that.minWifi,_that.minOutlets,_that.venueType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  bool laptopFriendly,  WifiLevel? minWifi,  OutletsLevel? minOutlets,  WorkVenueType? venueType)  $default,) {final _that = this;
switch (_that) {
case _DiscoveryFilters():
return $default(_that.query,_that.laptopFriendly,_that.minWifi,_that.minOutlets,_that.venueType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  bool laptopFriendly,  WifiLevel? minWifi,  OutletsLevel? minOutlets,  WorkVenueType? venueType)?  $default,) {final _that = this;
switch (_that) {
case _DiscoveryFilters() when $default != null:
return $default(_that.query,_that.laptopFriendly,_that.minWifi,_that.minOutlets,_that.venueType);case _:
  return null;

}
}

}

/// @nodoc


class _DiscoveryFilters extends DiscoveryFilters {
  const _DiscoveryFilters({this.query = '', this.laptopFriendly = false, this.minWifi, this.minOutlets, this.venueType}): super._();
  

@override@JsonKey() final  String query;
@override@JsonKey() final  bool laptopFriendly;
@override final  WifiLevel? minWifi;
@override final  OutletsLevel? minOutlets;
@override final  WorkVenueType? venueType;

/// Create a copy of DiscoveryFilters
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscoveryFiltersCopyWith<_DiscoveryFilters> get copyWith => __$DiscoveryFiltersCopyWithImpl<_DiscoveryFilters>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscoveryFilters&&(identical(other.query, query) || other.query == query)&&(identical(other.laptopFriendly, laptopFriendly) || other.laptopFriendly == laptopFriendly)&&(identical(other.minWifi, minWifi) || other.minWifi == minWifi)&&(identical(other.minOutlets, minOutlets) || other.minOutlets == minOutlets)&&(identical(other.venueType, venueType) || other.venueType == venueType));
}


@override
int get hashCode => Object.hash(runtimeType,query,laptopFriendly,minWifi,minOutlets,venueType);

@override
String toString() {
  return 'DiscoveryFilters(query: $query, laptopFriendly: $laptopFriendly, minWifi: $minWifi, minOutlets: $minOutlets, venueType: $venueType)';
}


}

/// @nodoc
abstract mixin class _$DiscoveryFiltersCopyWith<$Res> implements $DiscoveryFiltersCopyWith<$Res> {
  factory _$DiscoveryFiltersCopyWith(_DiscoveryFilters value, $Res Function(_DiscoveryFilters) _then) = __$DiscoveryFiltersCopyWithImpl;
@override @useResult
$Res call({
 String query, bool laptopFriendly, WifiLevel? minWifi, OutletsLevel? minOutlets, WorkVenueType? venueType
});




}
/// @nodoc
class __$DiscoveryFiltersCopyWithImpl<$Res>
    implements _$DiscoveryFiltersCopyWith<$Res> {
  __$DiscoveryFiltersCopyWithImpl(this._self, this._then);

  final _DiscoveryFilters _self;
  final $Res Function(_DiscoveryFilters) _then;

/// Create a copy of DiscoveryFilters
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? laptopFriendly = null,Object? minWifi = freezed,Object? minOutlets = freezed,Object? venueType = freezed,}) {
  return _then(_DiscoveryFilters(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,laptopFriendly: null == laptopFriendly ? _self.laptopFriendly : laptopFriendly // ignore: cast_nullable_to_non_nullable
as bool,minWifi: freezed == minWifi ? _self.minWifi : minWifi // ignore: cast_nullable_to_non_nullable
as WifiLevel?,minOutlets: freezed == minOutlets ? _self.minOutlets : minOutlets // ignore: cast_nullable_to_non_nullable
as OutletsLevel?,venueType: freezed == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as WorkVenueType?,
  ));
}


}

// dart format on
