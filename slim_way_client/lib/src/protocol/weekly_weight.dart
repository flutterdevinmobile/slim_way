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

abstract class WeeklyWeight implements _i1.SerializableModel {
  WeeklyWeight._({
    this.id,
    required this.userId,
    this.user,
    required this.weekStart,
    required this.weight,
    required this.createdAt,
  });

  factory WeeklyWeight({
    int? id,
    required int userId,
    _i2.User? user,
    required DateTime weekStart,
    required double weight,
    required DateTime createdAt,
  }) = _WeeklyWeightImpl;

  factory WeeklyWeight.fromJson(Map<String, dynamic> jsonSerialization) {
    return WeeklyWeight(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      weekStart: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['weekStart'],
      ),
      weight: (jsonSerialization['weight'] as num).toDouble(),
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

  DateTime weekStart;

  double weight;

  DateTime createdAt;

  /// Returns a shallow copy of this [WeeklyWeight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WeeklyWeight copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    DateTime? weekStart,
    double? weight,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WeeklyWeight',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'weekStart': weekStart.toJson(),
      'weight': weight,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WeeklyWeightImpl extends WeeklyWeight {
  _WeeklyWeightImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required DateTime weekStart,
    required double weight,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         weekStart: weekStart,
         weight: weight,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [WeeklyWeight]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WeeklyWeight copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    DateTime? weekStart,
    double? weight,
    DateTime? createdAt,
  }) {
    return WeeklyWeight(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      weekStart: weekStart ?? this.weekStart,
      weight: weight ?? this.weight,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
