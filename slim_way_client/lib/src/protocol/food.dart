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

abstract class Food implements _i1.SerializableModel {
  Food._({
    this.id,
    required this.userId,
    this.user,
    required this.name,
    required this.calories,
    this.photoUrl,
    this.protein,
    this.fat,
    this.carbs,
    required this.createdAt,
  });

  factory Food({
    int? id,
    required int userId,
    _i2.User? user,
    required String name,
    required double calories,
    String? photoUrl,
    double? protein,
    double? fat,
    double? carbs,
    required DateTime createdAt,
  }) = _FoodImpl;

  factory Food.fromJson(Map<String, dynamic> jsonSerialization) {
    return Food(
      id: jsonSerialization['id'] as int?,
      userId: jsonSerialization['userId'] as int,
      user: jsonSerialization['user'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.User>(jsonSerialization['user']),
      name: jsonSerialization['name'] as String,
      calories: (jsonSerialization['calories'] as num).toDouble(),
      photoUrl: jsonSerialization['photoUrl'] as String?,
      protein: (jsonSerialization['protein'] as num?)?.toDouble(),
      fat: (jsonSerialization['fat'] as num?)?.toDouble(),
      carbs: (jsonSerialization['carbs'] as num?)?.toDouble(),
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

  String name;

  double calories;

  String? photoUrl;

  double? protein;

  double? fat;

  double? carbs;

  DateTime createdAt;

  /// Returns a shallow copy of this [Food]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Food copyWith({
    int? id,
    int? userId,
    _i2.User? user,
    String? name,
    double? calories,
    String? photoUrl,
    double? protein,
    double? fat,
    double? carbs,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Food',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJson(),
      'name': name,
      'calories': calories,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _FoodImpl extends Food {
  _FoodImpl({
    int? id,
    required int userId,
    _i2.User? user,
    required String name,
    required double calories,
    String? photoUrl,
    double? protein,
    double? fat,
    double? carbs,
    required DateTime createdAt,
  }) : super._(
         id: id,
         userId: userId,
         user: user,
         name: name,
         calories: calories,
         photoUrl: photoUrl,
         protein: protein,
         fat: fat,
         carbs: carbs,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Food]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Food copyWith({
    Object? id = _Undefined,
    int? userId,
    Object? user = _Undefined,
    String? name,
    double? calories,
    Object? photoUrl = _Undefined,
    Object? protein = _Undefined,
    Object? fat = _Undefined,
    Object? carbs = _Undefined,
    DateTime? createdAt,
  }) {
    return Food(
      id: id is int? ? id : this.id,
      userId: userId ?? this.userId,
      user: user is _i2.User? ? user : this.user?.copyWith(),
      name: name ?? this.name,
      calories: calories ?? this.calories,
      photoUrl: photoUrl is String? ? photoUrl : this.photoUrl,
      protein: protein is double? ? protein : this.protein,
      fat: fat is double? ? fat : this.fat,
      carbs: carbs is double? ? carbs : this.carbs,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
