// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue_detail_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VenueDetail {

 Venue get venue; List<VenuePhoto> get photos;
/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueDetailCopyWith<VenueDetail> get copyWith => _$VenueDetailCopyWithImpl<VenueDetail>(this as VenueDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueDetail&&(identical(other.venue, venue) || other.venue == venue)&&const DeepCollectionEquality().equals(other.photos, photos));
}


@override
int get hashCode => Object.hash(runtimeType,venue,const DeepCollectionEquality().hash(photos));

@override
String toString() {
  return 'VenueDetail(venue: $venue, photos: $photos)';
}


}

/// @nodoc
abstract mixin class $VenueDetailCopyWith<$Res>  {
  factory $VenueDetailCopyWith(VenueDetail value, $Res Function(VenueDetail) _then) = _$VenueDetailCopyWithImpl;
@useResult
$Res call({
 Venue venue, List<VenuePhoto> photos
});


$VenueCopyWith<$Res> get venue;

}
/// @nodoc
class _$VenueDetailCopyWithImpl<$Res>
    implements $VenueDetailCopyWith<$Res> {
  _$VenueDetailCopyWithImpl(this._self, this._then);

  final VenueDetail _self;
  final $Res Function(VenueDetail) _then;

/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venue = null,Object? photos = null,}) {
  return _then(_self.copyWith(
venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<VenuePhoto>,
  ));
}
/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res> get venue {
  
  return $VenueCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}


/// Adds pattern-matching-related methods to [VenueDetail].
extension VenueDetailPatterns on VenueDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueDetail value)  $default,){
final _that = this;
switch (_that) {
case _VenueDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueDetail value)?  $default,){
final _that = this;
switch (_that) {
case _VenueDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Venue venue,  List<VenuePhoto> photos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueDetail() when $default != null:
return $default(_that.venue,_that.photos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Venue venue,  List<VenuePhoto> photos)  $default,) {final _that = this;
switch (_that) {
case _VenueDetail():
return $default(_that.venue,_that.photos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Venue venue,  List<VenuePhoto> photos)?  $default,) {final _that = this;
switch (_that) {
case _VenueDetail() when $default != null:
return $default(_that.venue,_that.photos);case _:
  return null;

}
}

}

/// @nodoc


class _VenueDetail implements VenueDetail {
  const _VenueDetail({required this.venue, required this.photos});
  

@override final  Venue venue;
@override final  List<VenuePhoto> photos;

/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueDetailCopyWith<_VenueDetail> get copyWith => __$VenueDetailCopyWithImpl<_VenueDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueDetail&&(identical(other.venue, venue) || other.venue == venue)&&const DeepCollectionEquality().equals(other.photos, photos));
}


@override
int get hashCode => Object.hash(runtimeType,venue,const DeepCollectionEquality().hash(photos));

@override
String toString() {
  return 'VenueDetail(venue: $venue, photos: $photos)';
}


}

/// @nodoc
abstract mixin class _$VenueDetailCopyWith<$Res> implements $VenueDetailCopyWith<$Res> {
  factory _$VenueDetailCopyWith(_VenueDetail value, $Res Function(_VenueDetail) _then) = __$VenueDetailCopyWithImpl;
@override @useResult
$Res call({
 Venue venue, List<VenuePhoto> photos
});


@override $VenueCopyWith<$Res> get venue;

}
/// @nodoc
class __$VenueDetailCopyWithImpl<$Res>
    implements _$VenueDetailCopyWith<$Res> {
  __$VenueDetailCopyWithImpl(this._self, this._then);

  final _VenueDetail _self;
  final $Res Function(_VenueDetail) _then;

/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venue = null,Object? photos = null,}) {
  return _then(_VenueDetail(
venue: null == venue ? _self.venue : venue // ignore: cast_nullable_to_non_nullable
as Venue,photos: null == photos ? _self.photos : photos // ignore: cast_nullable_to_non_nullable
as List<VenuePhoto>,
  ));
}

/// Create a copy of VenueDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueCopyWith<$Res> get venue {
  
  return $VenueCopyWith<$Res>(_self.venue, (value) {
    return _then(_self.copyWith(venue: value));
  });
}
}

// dart format on
