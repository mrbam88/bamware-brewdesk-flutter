// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'venue.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Claim {

 String get value; String get source; String? get detail; String? get observedAt; double get confidence;
/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClaimCopyWith<Claim> get copyWith => _$ClaimCopyWithImpl<Claim>(this as Claim, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Claim&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,value,source,detail,observedAt,confidence);

@override
String toString() {
  return 'Claim(value: $value, source: $source, detail: $detail, observedAt: $observedAt, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $ClaimCopyWith<$Res>  {
  factory $ClaimCopyWith(Claim value, $Res Function(Claim) _then) = _$ClaimCopyWithImpl;
@useResult
$Res call({
 String value, String source, String? detail, String? observedAt, double confidence
});




}
/// @nodoc
class _$ClaimCopyWithImpl<$Res>
    implements $ClaimCopyWith<$Res> {
  _$ClaimCopyWithImpl(this._self, this._then);

  final Claim _self;
  final $Res Function(Claim) _then;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? source = null,Object? detail = freezed,Object? observedAt = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,observedAt: freezed == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [Claim].
extension ClaimPatterns on Claim {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Claim value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Claim() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Claim value)  $default,){
final _that = this;
switch (_that) {
case _Claim():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Claim value)?  $default,){
final _that = this;
switch (_that) {
case _Claim() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String source,  String? detail,  String? observedAt,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that.value,_that.source,_that.detail,_that.observedAt,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String source,  String? detail,  String? observedAt,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _Claim():
return $default(_that.value,_that.source,_that.detail,_that.observedAt,_that.confidence);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String source,  String? detail,  String? observedAt,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _Claim() when $default != null:
return $default(_that.value,_that.source,_that.detail,_that.observedAt,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc


class _Claim extends Claim {
  const _Claim({required this.value, required this.source, this.detail, this.observedAt, this.confidence = 0}): super._();
  

@override final  String value;
@override final  String source;
@override final  String? detail;
@override final  String? observedAt;
@override@JsonKey() final  double confidence;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClaimCopyWith<_Claim> get copyWith => __$ClaimCopyWithImpl<_Claim>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Claim&&(identical(other.value, value) || other.value == value)&&(identical(other.source, source) || other.source == source)&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.observedAt, observedAt) || other.observedAt == observedAt)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}


@override
int get hashCode => Object.hash(runtimeType,value,source,detail,observedAt,confidence);

@override
String toString() {
  return 'Claim(value: $value, source: $source, detail: $detail, observedAt: $observedAt, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$ClaimCopyWith<$Res> implements $ClaimCopyWith<$Res> {
  factory _$ClaimCopyWith(_Claim value, $Res Function(_Claim) _then) = __$ClaimCopyWithImpl;
@override @useResult
$Res call({
 String value, String source, String? detail, String? observedAt, double confidence
});




}
/// @nodoc
class __$ClaimCopyWithImpl<$Res>
    implements _$ClaimCopyWith<$Res> {
  __$ClaimCopyWithImpl(this._self, this._then);

  final _Claim _self;
  final $Res Function(_Claim) _then;

/// Create a copy of Claim
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? source = null,Object? detail = freezed,Object? observedAt = freezed,Object? confidence = null,}) {
  return _then(_Claim(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,detail: freezed == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as String?,observedAt: freezed == observedAt ? _self.observedAt : observedAt // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$VenueAttributes {

 Claim get wifi; Claim get outlets; Claim get laptopPolicy; Claim get noise; Claim get seating; Claim get outdoorSeating;
/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueAttributesCopyWith<VenueAttributes> get copyWith => _$VenueAttributesCopyWithImpl<VenueAttributes>(this as VenueAttributes, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueAttributes&&(identical(other.wifi, wifi) || other.wifi == wifi)&&(identical(other.outlets, outlets) || other.outlets == outlets)&&(identical(other.laptopPolicy, laptopPolicy) || other.laptopPolicy == laptopPolicy)&&(identical(other.noise, noise) || other.noise == noise)&&(identical(other.seating, seating) || other.seating == seating)&&(identical(other.outdoorSeating, outdoorSeating) || other.outdoorSeating == outdoorSeating));
}


@override
int get hashCode => Object.hash(runtimeType,wifi,outlets,laptopPolicy,noise,seating,outdoorSeating);

@override
String toString() {
  return 'VenueAttributes(wifi: $wifi, outlets: $outlets, laptopPolicy: $laptopPolicy, noise: $noise, seating: $seating, outdoorSeating: $outdoorSeating)';
}


}

/// @nodoc
abstract mixin class $VenueAttributesCopyWith<$Res>  {
  factory $VenueAttributesCopyWith(VenueAttributes value, $Res Function(VenueAttributes) _then) = _$VenueAttributesCopyWithImpl;
@useResult
$Res call({
 Claim wifi, Claim outlets, Claim laptopPolicy, Claim noise, Claim seating, Claim outdoorSeating
});


$ClaimCopyWith<$Res> get wifi;$ClaimCopyWith<$Res> get outlets;$ClaimCopyWith<$Res> get laptopPolicy;$ClaimCopyWith<$Res> get noise;$ClaimCopyWith<$Res> get seating;$ClaimCopyWith<$Res> get outdoorSeating;

}
/// @nodoc
class _$VenueAttributesCopyWithImpl<$Res>
    implements $VenueAttributesCopyWith<$Res> {
  _$VenueAttributesCopyWithImpl(this._self, this._then);

  final VenueAttributes _self;
  final $Res Function(VenueAttributes) _then;

/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? wifi = null,Object? outlets = null,Object? laptopPolicy = null,Object? noise = null,Object? seating = null,Object? outdoorSeating = null,}) {
  return _then(_self.copyWith(
wifi: null == wifi ? _self.wifi : wifi // ignore: cast_nullable_to_non_nullable
as Claim,outlets: null == outlets ? _self.outlets : outlets // ignore: cast_nullable_to_non_nullable
as Claim,laptopPolicy: null == laptopPolicy ? _self.laptopPolicy : laptopPolicy // ignore: cast_nullable_to_non_nullable
as Claim,noise: null == noise ? _self.noise : noise // ignore: cast_nullable_to_non_nullable
as Claim,seating: null == seating ? _self.seating : seating // ignore: cast_nullable_to_non_nullable
as Claim,outdoorSeating: null == outdoorSeating ? _self.outdoorSeating : outdoorSeating // ignore: cast_nullable_to_non_nullable
as Claim,
  ));
}
/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get wifi {
  
  return $ClaimCopyWith<$Res>(_self.wifi, (value) {
    return _then(_self.copyWith(wifi: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get outlets {
  
  return $ClaimCopyWith<$Res>(_self.outlets, (value) {
    return _then(_self.copyWith(outlets: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get laptopPolicy {
  
  return $ClaimCopyWith<$Res>(_self.laptopPolicy, (value) {
    return _then(_self.copyWith(laptopPolicy: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get noise {
  
  return $ClaimCopyWith<$Res>(_self.noise, (value) {
    return _then(_self.copyWith(noise: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get seating {
  
  return $ClaimCopyWith<$Res>(_self.seating, (value) {
    return _then(_self.copyWith(seating: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get outdoorSeating {
  
  return $ClaimCopyWith<$Res>(_self.outdoorSeating, (value) {
    return _then(_self.copyWith(outdoorSeating: value));
  });
}
}


/// Adds pattern-matching-related methods to [VenueAttributes].
extension VenueAttributesPatterns on VenueAttributes {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueAttributes value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueAttributes() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueAttributes value)  $default,){
final _that = this;
switch (_that) {
case _VenueAttributes():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueAttributes value)?  $default,){
final _that = this;
switch (_that) {
case _VenueAttributes() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Claim wifi,  Claim outlets,  Claim laptopPolicy,  Claim noise,  Claim seating,  Claim outdoorSeating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueAttributes() when $default != null:
return $default(_that.wifi,_that.outlets,_that.laptopPolicy,_that.noise,_that.seating,_that.outdoorSeating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Claim wifi,  Claim outlets,  Claim laptopPolicy,  Claim noise,  Claim seating,  Claim outdoorSeating)  $default,) {final _that = this;
switch (_that) {
case _VenueAttributes():
return $default(_that.wifi,_that.outlets,_that.laptopPolicy,_that.noise,_that.seating,_that.outdoorSeating);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Claim wifi,  Claim outlets,  Claim laptopPolicy,  Claim noise,  Claim seating,  Claim outdoorSeating)?  $default,) {final _that = this;
switch (_that) {
case _VenueAttributes() when $default != null:
return $default(_that.wifi,_that.outlets,_that.laptopPolicy,_that.noise,_that.seating,_that.outdoorSeating);case _:
  return null;

}
}

}

/// @nodoc


class _VenueAttributes extends VenueAttributes {
  const _VenueAttributes({this.wifi = Claim.unknown, this.outlets = Claim.unknown, this.laptopPolicy = Claim.unknown, this.noise = Claim.unknown, this.seating = Claim.unknown, this.outdoorSeating = Claim.unknown}): super._();
  

@override@JsonKey() final  Claim wifi;
@override@JsonKey() final  Claim outlets;
@override@JsonKey() final  Claim laptopPolicy;
@override@JsonKey() final  Claim noise;
@override@JsonKey() final  Claim seating;
@override@JsonKey() final  Claim outdoorSeating;

/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueAttributesCopyWith<_VenueAttributes> get copyWith => __$VenueAttributesCopyWithImpl<_VenueAttributes>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueAttributes&&(identical(other.wifi, wifi) || other.wifi == wifi)&&(identical(other.outlets, outlets) || other.outlets == outlets)&&(identical(other.laptopPolicy, laptopPolicy) || other.laptopPolicy == laptopPolicy)&&(identical(other.noise, noise) || other.noise == noise)&&(identical(other.seating, seating) || other.seating == seating)&&(identical(other.outdoorSeating, outdoorSeating) || other.outdoorSeating == outdoorSeating));
}


@override
int get hashCode => Object.hash(runtimeType,wifi,outlets,laptopPolicy,noise,seating,outdoorSeating);

@override
String toString() {
  return 'VenueAttributes(wifi: $wifi, outlets: $outlets, laptopPolicy: $laptopPolicy, noise: $noise, seating: $seating, outdoorSeating: $outdoorSeating)';
}


}

/// @nodoc
abstract mixin class _$VenueAttributesCopyWith<$Res> implements $VenueAttributesCopyWith<$Res> {
  factory _$VenueAttributesCopyWith(_VenueAttributes value, $Res Function(_VenueAttributes) _then) = __$VenueAttributesCopyWithImpl;
@override @useResult
$Res call({
 Claim wifi, Claim outlets, Claim laptopPolicy, Claim noise, Claim seating, Claim outdoorSeating
});


@override $ClaimCopyWith<$Res> get wifi;@override $ClaimCopyWith<$Res> get outlets;@override $ClaimCopyWith<$Res> get laptopPolicy;@override $ClaimCopyWith<$Res> get noise;@override $ClaimCopyWith<$Res> get seating;@override $ClaimCopyWith<$Res> get outdoorSeating;

}
/// @nodoc
class __$VenueAttributesCopyWithImpl<$Res>
    implements _$VenueAttributesCopyWith<$Res> {
  __$VenueAttributesCopyWithImpl(this._self, this._then);

  final _VenueAttributes _self;
  final $Res Function(_VenueAttributes) _then;

/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? wifi = null,Object? outlets = null,Object? laptopPolicy = null,Object? noise = null,Object? seating = null,Object? outdoorSeating = null,}) {
  return _then(_VenueAttributes(
wifi: null == wifi ? _self.wifi : wifi // ignore: cast_nullable_to_non_nullable
as Claim,outlets: null == outlets ? _self.outlets : outlets // ignore: cast_nullable_to_non_nullable
as Claim,laptopPolicy: null == laptopPolicy ? _self.laptopPolicy : laptopPolicy // ignore: cast_nullable_to_non_nullable
as Claim,noise: null == noise ? _self.noise : noise // ignore: cast_nullable_to_non_nullable
as Claim,seating: null == seating ? _self.seating : seating // ignore: cast_nullable_to_non_nullable
as Claim,outdoorSeating: null == outdoorSeating ? _self.outdoorSeating : outdoorSeating // ignore: cast_nullable_to_non_nullable
as Claim,
  ));
}

/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get wifi {
  
  return $ClaimCopyWith<$Res>(_self.wifi, (value) {
    return _then(_self.copyWith(wifi: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get outlets {
  
  return $ClaimCopyWith<$Res>(_self.outlets, (value) {
    return _then(_self.copyWith(outlets: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get laptopPolicy {
  
  return $ClaimCopyWith<$Res>(_self.laptopPolicy, (value) {
    return _then(_self.copyWith(laptopPolicy: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get noise {
  
  return $ClaimCopyWith<$Res>(_self.noise, (value) {
    return _then(_self.copyWith(noise: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get seating {
  
  return $ClaimCopyWith<$Res>(_self.seating, (value) {
    return _then(_self.copyWith(seating: value));
  });
}/// Create a copy of VenueAttributes
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClaimCopyWith<$Res> get outdoorSeating {
  
  return $ClaimCopyWith<$Res>(_self.outdoorSeating, (value) {
    return _then(_self.copyWith(outdoorSeating: value));
  });
}
}

/// @nodoc
mixin _$Venue {

 String get id; String get name; double get lat; double get lng; String get neighborhood; String get borough; String get venueType; VenueAttributes get attributes; List<String> get vibeTags; int get workScore; String get tier; String? get address; String? get hoursRaw; int? get distanceM; String? get website; String? get phone; String? get lastVerified;
/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueCopyWith<Venue> get copyWith => _$VenueCopyWithImpl<Venue>(this as Venue, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Venue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.borough, borough) || other.borough == borough)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&const DeepCollectionEquality().equals(other.vibeTags, vibeTags)&&(identical(other.workScore, workScore) || other.workScore == workScore)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.address, address) || other.address == address)&&(identical(other.hoursRaw, hoursRaw) || other.hoursRaw == hoursRaw)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.website, website) || other.website == website)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lastVerified, lastVerified) || other.lastVerified == lastVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,lat,lng,neighborhood,borough,venueType,attributes,const DeepCollectionEquality().hash(vibeTags),workScore,tier,address,hoursRaw,distanceM,website,phone,lastVerified);

@override
String toString() {
  return 'Venue(id: $id, name: $name, lat: $lat, lng: $lng, neighborhood: $neighborhood, borough: $borough, venueType: $venueType, attributes: $attributes, vibeTags: $vibeTags, workScore: $workScore, tier: $tier, address: $address, hoursRaw: $hoursRaw, distanceM: $distanceM, website: $website, phone: $phone, lastVerified: $lastVerified)';
}


}

/// @nodoc
abstract mixin class $VenueCopyWith<$Res>  {
  factory $VenueCopyWith(Venue value, $Res Function(Venue) _then) = _$VenueCopyWithImpl;
@useResult
$Res call({
 String id, String name, double lat, double lng, String neighborhood, String borough, String venueType, VenueAttributes attributes, List<String> vibeTags, int workScore, String tier, String? address, String? hoursRaw, int? distanceM, String? website, String? phone, String? lastVerified
});


$VenueAttributesCopyWith<$Res> get attributes;

}
/// @nodoc
class _$VenueCopyWithImpl<$Res>
    implements $VenueCopyWith<$Res> {
  _$VenueCopyWithImpl(this._self, this._then);

  final Venue _self;
  final $Res Function(Venue) _then;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? lat = null,Object? lng = null,Object? neighborhood = null,Object? borough = null,Object? venueType = null,Object? attributes = null,Object? vibeTags = null,Object? workScore = null,Object? tier = null,Object? address = freezed,Object? hoursRaw = freezed,Object? distanceM = freezed,Object? website = freezed,Object? phone = freezed,Object? lastVerified = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,borough: null == borough ? _self.borough : borough // ignore: cast_nullable_to_non_nullable
as String,venueType: null == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as VenueAttributes,vibeTags: null == vibeTags ? _self.vibeTags : vibeTags // ignore: cast_nullable_to_non_nullable
as List<String>,workScore: null == workScore ? _self.workScore : workScore // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,hoursRaw: freezed == hoursRaw ? _self.hoursRaw : hoursRaw // ignore: cast_nullable_to_non_nullable
as String?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,lastVerified: freezed == lastVerified ? _self.lastVerified : lastVerified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueAttributesCopyWith<$Res> get attributes {
  
  return $VenueAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}
}


/// Adds pattern-matching-related methods to [Venue].
extension VenuePatterns on Venue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Venue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Venue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Venue value)  $default,){
final _that = this;
switch (_that) {
case _Venue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Venue value)?  $default,){
final _that = this;
switch (_that) {
case _Venue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  double lat,  double lng,  String neighborhood,  String borough,  String venueType,  VenueAttributes attributes,  List<String> vibeTags,  int workScore,  String tier,  String? address,  String? hoursRaw,  int? distanceM,  String? website,  String? phone,  String? lastVerified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.neighborhood,_that.borough,_that.venueType,_that.attributes,_that.vibeTags,_that.workScore,_that.tier,_that.address,_that.hoursRaw,_that.distanceM,_that.website,_that.phone,_that.lastVerified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  double lat,  double lng,  String neighborhood,  String borough,  String venueType,  VenueAttributes attributes,  List<String> vibeTags,  int workScore,  String tier,  String? address,  String? hoursRaw,  int? distanceM,  String? website,  String? phone,  String? lastVerified)  $default,) {final _that = this;
switch (_that) {
case _Venue():
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.neighborhood,_that.borough,_that.venueType,_that.attributes,_that.vibeTags,_that.workScore,_that.tier,_that.address,_that.hoursRaw,_that.distanceM,_that.website,_that.phone,_that.lastVerified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  double lat,  double lng,  String neighborhood,  String borough,  String venueType,  VenueAttributes attributes,  List<String> vibeTags,  int workScore,  String tier,  String? address,  String? hoursRaw,  int? distanceM,  String? website,  String? phone,  String? lastVerified)?  $default,) {final _that = this;
switch (_that) {
case _Venue() when $default != null:
return $default(_that.id,_that.name,_that.lat,_that.lng,_that.neighborhood,_that.borough,_that.venueType,_that.attributes,_that.vibeTags,_that.workScore,_that.tier,_that.address,_that.hoursRaw,_that.distanceM,_that.website,_that.phone,_that.lastVerified);case _:
  return null;

}
}

}

/// @nodoc


class _Venue extends Venue {
  const _Venue({required this.id, required this.name, required this.lat, required this.lng, required this.neighborhood, required this.borough, required this.venueType, required this.attributes, required this.vibeTags, required this.workScore, required this.tier, this.address, this.hoursRaw, this.distanceM, this.website, this.phone, this.lastVerified}): super._();
  

@override final  String id;
@override final  String name;
@override final  double lat;
@override final  double lng;
@override final  String neighborhood;
@override final  String borough;
@override final  String venueType;
@override final  VenueAttributes attributes;
@override final  List<String> vibeTags;
@override final  int workScore;
@override final  String tier;
@override final  String? address;
@override final  String? hoursRaw;
@override final  int? distanceM;
@override final  String? website;
@override final  String? phone;
@override final  String? lastVerified;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueCopyWith<_Venue> get copyWith => __$VenueCopyWithImpl<_Venue>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Venue&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.neighborhood, neighborhood) || other.neighborhood == neighborhood)&&(identical(other.borough, borough) || other.borough == borough)&&(identical(other.venueType, venueType) || other.venueType == venueType)&&(identical(other.attributes, attributes) || other.attributes == attributes)&&const DeepCollectionEquality().equals(other.vibeTags, vibeTags)&&(identical(other.workScore, workScore) || other.workScore == workScore)&&(identical(other.tier, tier) || other.tier == tier)&&(identical(other.address, address) || other.address == address)&&(identical(other.hoursRaw, hoursRaw) || other.hoursRaw == hoursRaw)&&(identical(other.distanceM, distanceM) || other.distanceM == distanceM)&&(identical(other.website, website) || other.website == website)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.lastVerified, lastVerified) || other.lastVerified == lastVerified));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,lat,lng,neighborhood,borough,venueType,attributes,const DeepCollectionEquality().hash(vibeTags),workScore,tier,address,hoursRaw,distanceM,website,phone,lastVerified);

@override
String toString() {
  return 'Venue(id: $id, name: $name, lat: $lat, lng: $lng, neighborhood: $neighborhood, borough: $borough, venueType: $venueType, attributes: $attributes, vibeTags: $vibeTags, workScore: $workScore, tier: $tier, address: $address, hoursRaw: $hoursRaw, distanceM: $distanceM, website: $website, phone: $phone, lastVerified: $lastVerified)';
}


}

/// @nodoc
abstract mixin class _$VenueCopyWith<$Res> implements $VenueCopyWith<$Res> {
  factory _$VenueCopyWith(_Venue value, $Res Function(_Venue) _then) = __$VenueCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, double lat, double lng, String neighborhood, String borough, String venueType, VenueAttributes attributes, List<String> vibeTags, int workScore, String tier, String? address, String? hoursRaw, int? distanceM, String? website, String? phone, String? lastVerified
});


@override $VenueAttributesCopyWith<$Res> get attributes;

}
/// @nodoc
class __$VenueCopyWithImpl<$Res>
    implements _$VenueCopyWith<$Res> {
  __$VenueCopyWithImpl(this._self, this._then);

  final _Venue _self;
  final $Res Function(_Venue) _then;

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? lat = null,Object? lng = null,Object? neighborhood = null,Object? borough = null,Object? venueType = null,Object? attributes = null,Object? vibeTags = null,Object? workScore = null,Object? tier = null,Object? address = freezed,Object? hoursRaw = freezed,Object? distanceM = freezed,Object? website = freezed,Object? phone = freezed,Object? lastVerified = freezed,}) {
  return _then(_Venue(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,neighborhood: null == neighborhood ? _self.neighborhood : neighborhood // ignore: cast_nullable_to_non_nullable
as String,borough: null == borough ? _self.borough : borough // ignore: cast_nullable_to_non_nullable
as String,venueType: null == venueType ? _self.venueType : venueType // ignore: cast_nullable_to_non_nullable
as String,attributes: null == attributes ? _self.attributes : attributes // ignore: cast_nullable_to_non_nullable
as VenueAttributes,vibeTags: null == vibeTags ? _self.vibeTags : vibeTags // ignore: cast_nullable_to_non_nullable
as List<String>,workScore: null == workScore ? _self.workScore : workScore // ignore: cast_nullable_to_non_nullable
as int,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as String,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,hoursRaw: freezed == hoursRaw ? _self.hoursRaw : hoursRaw // ignore: cast_nullable_to_non_nullable
as String?,distanceM: freezed == distanceM ? _self.distanceM : distanceM // ignore: cast_nullable_to_non_nullable
as int?,website: freezed == website ? _self.website : website // ignore: cast_nullable_to_non_nullable
as String?,phone: freezed == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String?,lastVerified: freezed == lastVerified ? _self.lastVerified : lastVerified // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Venue
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VenueAttributesCopyWith<$Res> get attributes {
  
  return $VenueAttributesCopyWith<$Res>(_self.attributes, (value) {
    return _then(_self.copyWith(attributes: value));
  });
}
}

/// @nodoc
mixin _$VenuePhoto {

 String get url; String? get attribution;
/// Create a copy of VenuePhoto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenuePhotoCopyWith<VenuePhoto> get copyWith => _$VenuePhotoCopyWithImpl<VenuePhoto>(this as VenuePhoto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenuePhoto&&(identical(other.url, url) || other.url == url)&&(identical(other.attribution, attribution) || other.attribution == attribution));
}


@override
int get hashCode => Object.hash(runtimeType,url,attribution);

@override
String toString() {
  return 'VenuePhoto(url: $url, attribution: $attribution)';
}


}

/// @nodoc
abstract mixin class $VenuePhotoCopyWith<$Res>  {
  factory $VenuePhotoCopyWith(VenuePhoto value, $Res Function(VenuePhoto) _then) = _$VenuePhotoCopyWithImpl;
@useResult
$Res call({
 String url, String? attribution
});




}
/// @nodoc
class _$VenuePhotoCopyWithImpl<$Res>
    implements $VenuePhotoCopyWith<$Res> {
  _$VenuePhotoCopyWithImpl(this._self, this._then);

  final VenuePhoto _self;
  final $Res Function(VenuePhoto) _then;

/// Create a copy of VenuePhoto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? attribution = freezed,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VenuePhoto].
extension VenuePhotoPatterns on VenuePhoto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenuePhoto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenuePhoto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenuePhoto value)  $default,){
final _that = this;
switch (_that) {
case _VenuePhoto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenuePhoto value)?  $default,){
final _that = this;
switch (_that) {
case _VenuePhoto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String? attribution)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenuePhoto() when $default != null:
return $default(_that.url,_that.attribution);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String? attribution)  $default,) {final _that = this;
switch (_that) {
case _VenuePhoto():
return $default(_that.url,_that.attribution);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String? attribution)?  $default,) {final _that = this;
switch (_that) {
case _VenuePhoto() when $default != null:
return $default(_that.url,_that.attribution);case _:
  return null;

}
}

}

/// @nodoc


class _VenuePhoto implements VenuePhoto {
  const _VenuePhoto({required this.url, this.attribution});
  

@override final  String url;
@override final  String? attribution;

/// Create a copy of VenuePhoto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenuePhotoCopyWith<_VenuePhoto> get copyWith => __$VenuePhotoCopyWithImpl<_VenuePhoto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenuePhoto&&(identical(other.url, url) || other.url == url)&&(identical(other.attribution, attribution) || other.attribution == attribution));
}


@override
int get hashCode => Object.hash(runtimeType,url,attribution);

@override
String toString() {
  return 'VenuePhoto(url: $url, attribution: $attribution)';
}


}

/// @nodoc
abstract mixin class _$VenuePhotoCopyWith<$Res> implements $VenuePhotoCopyWith<$Res> {
  factory _$VenuePhotoCopyWith(_VenuePhoto value, $Res Function(_VenuePhoto) _then) = __$VenuePhotoCopyWithImpl;
@override @useResult
$Res call({
 String url, String? attribution
});




}
/// @nodoc
class __$VenuePhotoCopyWithImpl<$Res>
    implements _$VenuePhotoCopyWith<$Res> {
  __$VenuePhotoCopyWithImpl(this._self, this._then);

  final _VenuePhoto _self;
  final $Res Function(_VenuePhoto) _then;

/// Create a copy of VenuePhoto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? attribution = freezed,}) {
  return _then(_VenuePhoto(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,attribution: freezed == attribution ? _self.attribution : attribution // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$VenueSearchResult {

 List<Venue> get venues; CoverageLevel get coverage;
/// Create a copy of VenueSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenueSearchResultCopyWith<VenueSearchResult> get copyWith => _$VenueSearchResultCopyWithImpl<VenueSearchResult>(this as VenueSearchResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenueSearchResult&&const DeepCollectionEquality().equals(other.venues, venues)&&(identical(other.coverage, coverage) || other.coverage == coverage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(venues),coverage);

@override
String toString() {
  return 'VenueSearchResult(venues: $venues, coverage: $coverage)';
}


}

/// @nodoc
abstract mixin class $VenueSearchResultCopyWith<$Res>  {
  factory $VenueSearchResultCopyWith(VenueSearchResult value, $Res Function(VenueSearchResult) _then) = _$VenueSearchResultCopyWithImpl;
@useResult
$Res call({
 List<Venue> venues, CoverageLevel coverage
});




}
/// @nodoc
class _$VenueSearchResultCopyWithImpl<$Res>
    implements $VenueSearchResultCopyWith<$Res> {
  _$VenueSearchResultCopyWithImpl(this._self, this._then);

  final VenueSearchResult _self;
  final $Res Function(VenueSearchResult) _then;

/// Create a copy of VenueSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? venues = null,Object? coverage = null,}) {
  return _then(_self.copyWith(
venues: null == venues ? _self.venues : venues // ignore: cast_nullable_to_non_nullable
as List<Venue>,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as CoverageLevel,
  ));
}

}


/// Adds pattern-matching-related methods to [VenueSearchResult].
extension VenueSearchResultPatterns on VenueSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenueSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenueSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenueSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _VenueSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenueSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _VenueSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Venue> venues,  CoverageLevel coverage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenueSearchResult() when $default != null:
return $default(_that.venues,_that.coverage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Venue> venues,  CoverageLevel coverage)  $default,) {final _that = this;
switch (_that) {
case _VenueSearchResult():
return $default(_that.venues,_that.coverage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Venue> venues,  CoverageLevel coverage)?  $default,) {final _that = this;
switch (_that) {
case _VenueSearchResult() when $default != null:
return $default(_that.venues,_that.coverage);case _:
  return null;

}
}

}

/// @nodoc


class _VenueSearchResult implements VenueSearchResult {
  const _VenueSearchResult({required this.venues, required this.coverage});
  

@override final  List<Venue> venues;
@override final  CoverageLevel coverage;

/// Create a copy of VenueSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenueSearchResultCopyWith<_VenueSearchResult> get copyWith => __$VenueSearchResultCopyWithImpl<_VenueSearchResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenueSearchResult&&const DeepCollectionEquality().equals(other.venues, venues)&&(identical(other.coverage, coverage) || other.coverage == coverage));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(venues),coverage);

@override
String toString() {
  return 'VenueSearchResult(venues: $venues, coverage: $coverage)';
}


}

/// @nodoc
abstract mixin class _$VenueSearchResultCopyWith<$Res> implements $VenueSearchResultCopyWith<$Res> {
  factory _$VenueSearchResultCopyWith(_VenueSearchResult value, $Res Function(_VenueSearchResult) _then) = __$VenueSearchResultCopyWithImpl;
@override @useResult
$Res call({
 List<Venue> venues, CoverageLevel coverage
});




}
/// @nodoc
class __$VenueSearchResultCopyWithImpl<$Res>
    implements _$VenueSearchResultCopyWith<$Res> {
  __$VenueSearchResultCopyWithImpl(this._self, this._then);

  final _VenueSearchResult _self;
  final $Res Function(_VenueSearchResult) _then;

/// Create a copy of VenueSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? venues = null,Object? coverage = null,}) {
  return _then(_VenueSearchResult(
venues: null == venues ? _self.venues : venues // ignore: cast_nullable_to_non_nullable
as List<Venue>,coverage: null == coverage ? _self.coverage : coverage // ignore: cast_nullable_to_non_nullable
as CoverageLevel,
  ));
}


}

// dart format on
