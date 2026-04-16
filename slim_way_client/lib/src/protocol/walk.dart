/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'user.dart' as _i2;
import 'package:slim_way_client/src/protocol/protocol.dart' as _i3;

abstract class Walk implements _i1.SerializableModel {
  Walk._({
    this.id,
    required this.userId,
    this.user,
    required this.steps,
    required this.distanceKm,
    required this.calories,
    required this.createdAt,
  });

  factory Walk({
    int? id,
    required int userId,
    _i2.User? user,
    required int steps,
    required double distanceKm,
    required double calories,
    required DateTime createdAt,
  }) = _WalkImpl;

  factory Walk.fromJson(Map<String, dynamic> jsonSerialization) {
    return Walk(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      steps: jsonSerialization['steps'] as int,
      distanceKm: (jsonSerialization['distanceKm'] as num).toDouble(),
      calories: (jsonSerialization['calories'] as num).toDouble(),
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int userId;

  _i2.User? user;

  int steps;

  double distanceKm;

  double calories;

  DateTime createdAt;

  /// Returns a shallow copy of this [Walk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Walk copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    int? steps,
    double? distanceKm,
    double? calories,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Walk',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalkImpl extends Walk {
  _WalkImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required int steps,
    required double distanceKm,
    required double calories,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         steps: steps,
         distanceKm: distanceKm,
         calories: calories,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Walk]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Walk copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    int? steps,
    double? distanceKm,
    double? calories,
    DateTime? createdAt,
  }) {
    return Walk(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      steps: steps ?? this.steps,
      distanceKm: distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
