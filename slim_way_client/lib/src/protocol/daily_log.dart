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

abstract class DailyLog implements _i1.SerializableModel {
  DailyLog._({
    this.id,
    required this.userId,
    this.user,
    required this.date,
    required this.foodCal,
    this.protein,
    this.fat,
    this.carbs,
    this.waterMl,
    required this.walkCal,
    required this.netCal,
    required this.createdAt,
  });

  factory DailyLog({
    int? id,
    required int userId,
    _i2.User? user,
    required DateTime date,
    required double foodCal,
    double? protein,
    double? fat,
    double? carbs,
    int? waterMl,
    required double walkCal,
    required double netCal,
    required DateTime createdAt,
  }) = _DailyLogImpl;

  factory DailyLog.fromJson(Map<String, dynamic> jsonSerialization) {
    return DailyLog(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      foodCal: (jsonSerialization['foodCal'] as num).toDouble(),
      protein: (jsonSerialization['protein'] as num?)?.toDouble(),
      fat: (jsonSerialization['fat'] as num?)?.toDouble(),
      carbs: (jsonSerialization['carbs'] as num?)?.toDouble(),
      waterMl: jsonSerialization['waterMl'] as int?,
      walkCal: (jsonSerialization['walkCal'] as num).toDouble(),
      netCal: (jsonSerialization['netCal'] as num).toDouble(),
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

  DateTime date;

  double foodCal;

  double? protein;

  double? fat;

  double? carbs;

  int? waterMl;

  double walkCal;

  double netCal;

  DateTime createdAt;

  /// Returns a shallow copy of this [DailyLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DailyLog copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    DateTime? date,
    double? foodCal,
    double? protein,
    double? fat,
    double? carbs,
    int? waterMl,
    double? walkCal,
    double? netCal,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DailyLog',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'date': date.toJson(),
      'foodCal': foodCal,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      if (waterMl != null) 'waterMl': waterMl,
      'walkCal': walkCal,
      'netCal': netCal,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DailyLogImpl extends DailyLog {
  _DailyLogImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required DateTime date,
    required double foodCal,
    double? protein,
    double? fat,
    double? carbs,
    int? waterMl,
    required double walkCal,
    required double netCal,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         date: date,
         foodCal: foodCal,
         protein: protein,
         fat: fat,
         carbs: carbs,
         waterMl: waterMl,
         walkCal: walkCal,
         netCal: netCal,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [DailyLog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DailyLog copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    DateTime? date,
    double? foodCal,
    Object? protein = _Undefined,
    Object? fat = _Undefined,
    Object? carbs = _Undefined,
    Object? waterMl = _Undefined,
    double? walkCal,
    double? netCal,
    DateTime? createdAt,
  }) {
    return DailyLog(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      date: date ?? this.date,
      foodCal: foodCal ?? this.foodCal,
      protein: protein is double? ? protein : this.protein,
      fat: fat is double? ? fat : this.fat,
      carbs: carbs is double? ? carbs : this.carbs,
      waterMl: waterMl is int? ? waterMl : this.waterMl,
      walkCal: walkCal ?? this.walkCal,
      netCal: netCal ?? this.netCal,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
