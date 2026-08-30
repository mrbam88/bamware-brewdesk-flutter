// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discovery_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscoveryState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoveryState()';
}


}

/// @nodoc
class $DiscoveryStateCopyWith<$Res>  {
$DiscoveryStateCopyWith(DiscoveryState _, $Res Function(DiscoveryState) __);
}


/// Adds pattern-matching-related methods to [DiscoveryState].
extension DiscoveryStatePatterns on DiscoveryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiscoveryLocating value)?  locating,TResult Function( DiscoverySearching value)?  searching,TResult Function( DiscoveryLoaded value)?  loaded,TResult Function( DiscoveryFailed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiscoveryLocating() when locating != null:
return locating(_that);case DiscoverySearching() when searching != null:
return searching(_that);case DiscoveryLoaded() when loaded != null:
return loaded(_that);case DiscoveryFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiscoveryLocating value)  locating,required TResult Function( DiscoverySearching value)  searching,required TResult Function( DiscoveryLoaded value)  loaded,required TResult Function( DiscoveryFailed value)  failed,}){
final _that = this;
switch (_that) {
case DiscoveryLocating():
return locating(_that);case DiscoverySearching():
return searching(_that);case DiscoveryLoaded():
return loaded(_that);case DiscoveryFailed():
return failed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiscoveryLocating value)?  locating,TResult? Function( DiscoverySearching value)?  searching,TResult? Function( DiscoveryLoaded value)?  loaded,TResult? Function( DiscoveryFailed value)?  failed,}){
final _that = this;
switch (_that) {
case DiscoveryLocating() when locating != null:
return locating(_that);case DiscoverySearching() when searching != null:
return searching(_that);case DiscoveryLoaded() when loaded != null:
return loaded(_that);case DiscoveryFailed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<Venue> staleVenues)?  locating,TResult Function( LatLng center,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)?  searching,TResult Function( LatLng center,  List<Venue> venues,  CoverageLevel coverage,  LocationFailureReason? locationFailure)?  loaded,TResult Function( LatLng center,  DiscoveryFailure failure,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiscoveryLocating() when locating != null:
return locating(_that.staleVenues);case DiscoverySearching() when searching != null:
return searching(_that.center,_that.locationFailure,_that.staleVenues);case DiscoveryLoaded() when loaded != null:
return loaded(_that.center,_that.venues,_that.coverage,_that.locationFailure);case DiscoveryFailed() when failed != null:
return failed(_that.center,_that.failure,_that.locationFailure,_that.staleVenues);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<Venue> staleVenues)  locating,required TResult Function( LatLng center,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)  searching,required TResult Function( LatLng center,  List<Venue> venues,  CoverageLevel coverage,  LocationFailureReason? locationFailure)  loaded,required TResult Function( LatLng center,  DiscoveryFailure failure,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)  failed,}) {final _that = this;
switch (_that) {
case DiscoveryLocating():
return locating(_that.staleVenues);case DiscoverySearching():
return searching(_that.center,_that.locationFailure,_that.staleVenues);case DiscoveryLoaded():
return loaded(_that.center,_that.venues,_that.coverage,_that.locationFailure);case DiscoveryFailed():
return failed(_that.center,_that.failure,_that.locationFailure,_that.staleVenues);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<Venue> staleVenues)?  locating,TResult? Function( LatLng center,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)?  searching,TResult? Function( LatLng center,  List<Venue> venues,  CoverageLevel coverage,  LocationFailureReason? locationFailure)?  loaded,TResult? Function( LatLng center,  DiscoveryFailure failure,  LocationFailureReason? locationFailure,  List<Venue> staleVenues)?  failed,}) {final _that = this;
switch (_that) {
case DiscoveryLocating() when locating != null:
return locating(_that.staleVenues);case DiscoverySearching() when searching != null:
return searching(_that.center,_that.locationFailure,_that.staleVenues);case DiscoveryLoaded() when loaded != null:
return loaded(_that.center,_that.venues,_that.coverage,_that.locationFailure);case DiscoveryFailed() when failed != null:
return failed(_that.center,_that.failure,_that.locationFailure,_that.staleVenues);case _:
  return null;

}
}

}

/// @nodoc


class DiscoveryLocating extends DiscoveryState {
  const DiscoveryLocating({this.staleVenues = const <Venue>[]}): super._();
  

@JsonKey() final  List<Venue> staleVenues;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryLocatingCopyWith<DiscoveryLocating> get copyWith => _$DiscoveryLocatingCopyWithImpl<DiscoveryLocating>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryLocating&&const DeepCollectionEquality().equals(other.staleVenues, staleVenues));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(staleVenues));

@override
String toString() {
  return 'DiscoveryState.locating(staleVenues: $staleVenues)';
}


}

/// @nodoc
abstract mixin class $DiscoveryLocatingCopyWith<$Res> implements $DiscoveryStateCopyWith<$Res> {
  factory $DiscoveryLocatingCopyWith(DiscoveryLocating value, $Res Function(DiscoveryLocating) _then) = _$DiscoveryLocatingCopyWithImpl;
@useResult
$Res call({
 List<Venue> staleVenues
});




}
/// @nodoc
class _$DiscoveryLocatingCopyWithImpl<$Res>
    implements $DiscoveryLocatingCopyWith<$Res> {
  _$DiscoveryLocatingCopyWithImpl(this._self, this._then);

  final DiscoveryLocating _self;
  final $Res Function(DiscoveryLocating) _then;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? staleVenues = null,}) {
  return _then(DiscoveryLocating(
staleVenues: null == staleVenues ? _self.staleVenues : staleVenues // ignore: cast_nullable_to_non_nullable
as List<Venue>,
  ));
}


}

/// @nodoc


class DiscoverySearching extends DiscoveryState {
  const DiscoverySearching({required this.center, this.locationFailure, this.staleVenues = const <Venue>[]}): super._();
  

 final  LatLng center;
 final  LocationFailureReason? locationFailure;
@JsonKey() final  List<Venue> staleVenues;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoverySearchingCopyWith<DiscoverySearching> get copyWith => _$DiscoverySearchingCopyWithImpl<DiscoverySearching>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoverySearching&&(identical(other.center, center) || other.center == center)&&(identical(other.locationFailure, locationFailure) || other.locationFailure == locationFailure)&&const DeepCollectionEquality().equals(other.staleVenues, staleVenues));
}


@override
int get hashCode => Object.hash(runtimeType,center,locationFailure,const DeepCollectionEquality().hash(staleVenues));

@override
String toString() {
  return 'DiscoveryState.searching(center: $center, locationFailure: $locationFailure, staleVenues: $staleVenues)';
}


}

/// @nodoc
abstract mixin class $DiscoverySearchingCopyWith<$Res> implements $DiscoveryStateCopyWith<$Res> {
  factory $DiscoverySearchingCopyWith(DiscoverySearching value, $Res Function(DiscoverySearching) _then) = _$DiscoverySearchingCopyWithImpl;
@useResult
$Res call({
 LatLng center, LocationFailureReason? locationFailure, List<Venue> staleVenues
});




}
/// @nodoc
class _$DiscoverySearchingCopyWithImpl<$Res>
    implements $DiscoverySearchingCopyWith<$Res> {
  _$DiscoverySearchingCopyWithImpl(this._self, this._then);

  final DiscoverySearching _self;
  final $Res Function(DiscoverySearching) _then;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? center = null,Object? locationFailure = freezed,Object? staleVenues = null,}) {
  return _then(DiscoverySearching(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as LatLng,locationFailure: freezed == locationFailure ? _self.locationFailure : locationFailure // ignore: cast_nullable_to_non_nullable
as LocationFailureReason?,staleVenues: null == staleVenues ? _self.staleVenues : staleVenues // ignore: cast_nullable_to_non_nullable
as List<Venue>,
  ));
}


}

/// @nodoc


class DiscoveryLoaded extends DiscoveryState {
  const DiscoveryLoaded({required this.center, required this.venues, required this.coverage, this.locationFailure}): super._();
  

 final  LatLng center;
 final  List<Venue> venues;
 final  CoverageLevel coverage;
 final  LocationFailureReason? locationFailure;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryLoadedCopyWith<DiscoveryLoaded> get copyWith => _$DiscoveryLoadedCopyWithImpl<DiscoveryLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryLoaded&&(identical(other.center, center) || other.center == center)&&const DeepCollectionEquality().equals(other.venues, venues)&&(identical(other.coverage, coverage) || other.coverage == coverage)&&(identical(other.locationFailure, locationFailure) || other.locationFailure == locationFailure));
}


@override
int get hashCode => Object.hash(runtimeType,center,const DeepCollectionEquality().hash(venues),coverage,locationFailure);

@override
String toString() {
  return 'DiscoveryState.loaded(center: $center, venues: $venues, coverage: $coverage, locationFailure: $locationFailure)';
}


}

/// @nodoc
abstract mixin class $DiscoveryLoadedCopyWith<$Res> implements $DiscoveryStateCopyWith<$Res> {
  factory $DiscoveryLoadedCopyWith(DiscoveryLoaded value, $Res Function(DiscoveryLoaded) _then) = _$DiscoveryLoadedCopyWithImpl;
@useResult
$Res call({
 LatLng center, List<Venue> venues, CoverageLevel coverage, LocationFailureReason? locationFailure
});




}
/// @nodoc
class _$DiscoveryLoadedCopyWithImpl<$Res>
    implements $DiscoveryLoadedCopyWith<$Res> {
  _$DiscoveryLoadedCopyWithImpl(this._self, this._then);

  final DiscoveryLoaded _self;
  final $Res Function(DiscoveryLoaded) _then;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? center = null,Object? venues = null,Object? coverage = null,Object? locationFailure = freezed,}) {
  return _then(DiscoveryLoaded(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as LatLng,venues: null == venues ? _self.venues : venues // ignore: cast_nullable_to_non_nullable
as List<Venue>,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as CoverageLevel,locationFailure: freezed == locationFailure ? _self.locationFailure : locationFailure // ignore: cast_nullable_to_non_nullable
as LocationFailureReason?,
  ));
}


}

/// @nodoc


class DiscoveryFailed extends DiscoveryState {
  const DiscoveryFailed({required this.center, required this.failure, this.locationFailure, this.staleVenues = const <Venue>[]}): super._();
  

 final  LatLng center;
 final  DiscoveryFailure failure;
 final  LocationFailureReason? locationFailure;
@JsonKey() final  List<Venue> staleVenues;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryFailedCopyWith<DiscoveryFailed> get copyWith => _$DiscoveryFailedCopyWithImpl<DiscoveryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryFailed&&(identical(other.center, center) || other.center == center)&&(identical(other.failure, failure) || other.failure == failure)&&(identical(other.locationFailure, locationFailure) || other.locationFailure == locationFailure)&&const DeepCollectionEquality().equals(other.staleVenues, staleVenues));
}


@override
int get hashCode => Object.hash(runtimeType,center,failure,locationFailure,const DeepCollectionEquality().hash(staleVenues));

@override
String toString() {
  return 'DiscoveryState.failed(center: $center, failure: $failure, locationFailure: $locationFailure, staleVenues: $staleVenues)';
}


}

/// @nodoc
abstract mixin class $DiscoveryFailedCopyWith<$Res> implements $DiscoveryStateCopyWith<$Res> {
  factory $DiscoveryFailedCopyWith(DiscoveryFailed value, $Res Function(DiscoveryFailed) _then) = _$DiscoveryFailedCopyWithImpl;
@useResult
$Res call({
 LatLng center, DiscoveryFailure failure, LocationFailureReason? locationFailure, List<Venue> staleVenues
});


$DiscoveryFailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$DiscoveryFailedCopyWithImpl<$Res>
    implements $DiscoveryFailedCopyWith<$Res> {
  _$DiscoveryFailedCopyWithImpl(this._self, this._then);

  final DiscoveryFailed _self;
  final $Res Function(DiscoveryFailed) _then;

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? center = null,Object? failure = null,Object? locationFailure = freezed,Object? staleVenues = null,}) {
  return _then(DiscoveryFailed(
center: null == center ? _self.center : center // ignore: cast_nullable_to_non_nullable
as LatLng,failure: null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as DiscoveryFailure,locationFailure: freezed == locationFailure ? _self.locationFailure : locationFailure // ignore: cast_nullable_to_non_nullable
as LocationFailureReason?,staleVenues: null == staleVenues ? _self.staleVenues : staleVenues // ignore: cast_nullable_to_non_nullable
as List<Venue>,
  ));
}

/// Create a copy of DiscoveryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscoveryFailureCopyWith<$Res> get failure {
  
  return $DiscoveryFailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

/// @nodoc
mixin _$DiscoveryFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoveryFailure()';
}


}

/// @nodoc
class $DiscoveryFailureCopyWith<$Res>  {
$DiscoveryFailureCopyWith(DiscoveryFailure _, $Res Function(DiscoveryFailure) __);
}


/// Adds pattern-matching-related methods to [DiscoveryFailure].
extension DiscoveryFailurePatterns on DiscoveryFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DiscoveryOffline value)?  offline,TResult Function( DiscoveryEngineDown value)?  engine,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DiscoveryOffline() when offline != null:
return offline(_that);case DiscoveryEngineDown() when engine != null:
return engine(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DiscoveryOffline value)  offline,required TResult Function( DiscoveryEngineDown value)  engine,}){
final _that = this;
switch (_that) {
case DiscoveryOffline():
return offline(_that);case DiscoveryEngineDown():
return engine(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DiscoveryOffline value)?  offline,TResult? Function( DiscoveryEngineDown value)?  engine,}){
final _that = this;
switch (_that) {
case DiscoveryOffline() when offline != null:
return offline(_that);case DiscoveryEngineDown() when engine != null:
return engine(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  offline,TResult Function( String? message)?  engine,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DiscoveryOffline() when offline != null:
return offline();case DiscoveryEngineDown() when engine != null:
return engine(_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  offline,required TResult Function( String? message)  engine,}) {final _that = this;
switch (_that) {
case DiscoveryOffline():
return offline();case DiscoveryEngineDown():
return engine(_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  offline,TResult? Function( String? message)?  engine,}) {final _that = this;
switch (_that) {
case DiscoveryOffline() when offline != null:
return offline();case DiscoveryEngineDown() when engine != null:
return engine(_that.message);case _:
  return null;

}
}

}

/// @nodoc


class DiscoveryOffline implements DiscoveryFailure {
  const DiscoveryOffline();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryOffline);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'DiscoveryFailure.offline()';
}


}




/// @nodoc


class DiscoveryEngineDown implements DiscoveryFailure {
  const DiscoveryEngineDown({this.message});
  

 final  String? message;

/// Create a copy of DiscoveryFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscoveryEngineDownCopyWith<DiscoveryEngineDown> get copyWith => _$DiscoveryEngineDownCopyWithImpl<DiscoveryEngineDown>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscoveryEngineDown&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'DiscoveryFailure.engine(message: $message)';
}


}

/// @nodoc
abstract mixin class $DiscoveryEngineDownCopyWith<$Res> implements $DiscoveryFailureCopyWith<$Res> {
  factory $DiscoveryEngineDownCopyWith(DiscoveryEngineDown value, $Res Function(DiscoveryEngineDown) _then) = _$DiscoveryEngineDownCopyWithImpl;
@useResult
$Res call({
 String? message
});




}
/// @nodoc
class _$DiscoveryEngineDownCopyWithImpl<$Res>
    implements $DiscoveryEngineDownCopyWith<$Res> {
  _$DiscoveryEngineDownCopyWithImpl(this._self, this._then);

  final DiscoveryEngineDown _self;
  final $Res Function(DiscoveryEngineDown) _then;

/// Create a copy of DiscoveryFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = freezed,}) {
  return _then(DiscoveryEngineDown(
message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
