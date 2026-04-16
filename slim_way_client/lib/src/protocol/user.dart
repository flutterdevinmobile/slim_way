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

abstract class User implements _i1.SerializableModel {
  User._({
    this.id,
    this.userInfoId,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.currentWeight,
    required this.targetWeight,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.waterGlassSize,
  });

  factory User({
    int? id,
    int? userInfoId,
    required String name,
    required int age,
    required String gender,
    required int height,
    required double currentWeight,
    required double targetWeight,
    String? photoUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? waterGlassSize,
  }) = _UserImpl;

  factory User.fromJson(Map<String, dynamic> jsonSerialization) {
    return User(
      id: jsonSerialization['id'] as int?,
      userInfoId: jsonSerialization['userInfoId'] as int?,
      name: jsonSerialization['name'] as String,
      age: jsonSerialization['age'] as int,
      gender: jsonSerialization['gender'] as String,
      height: jsonSerialization['height'] as int,
      currentWeight: (jsonSerialization['currentWeight'] as num).toDouble(),
      targetWeight: (jsonSerialization['targetWeight'] as num).toDouble(),
      photoUrl: jsonSerialization['photoUrl'] as String?,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      updatedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['updatedAt'],
      ),
      waterGlassSize: jsonSerialization['waterGlassSize'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int? userInfoId;

  String name;

  int age;

  String gender;

  int height;

  double currentWeight;

  double targetWeight;

  String? photoUrl;

  DateTime createdAt;

  DateTime updatedAt;

  int? waterGlassSize;

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  User copyWith({
    int? id,
    int? userInfoId,
    String? name,
    int? age,
    String? gender,
    int? height,
    double? currentWeight,
    double? targetWeight,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? waterGlassSize,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'User',
      if (id != null) 'id': id,
      if (userInfoId != null) 'userInfoId': userInfoId,
      'name': name,
      'age': age,
      'gender': gender,
      'height': height,
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (waterGlassSize != null) 'waterGlassSize': waterGlassSize,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserImpl extends User {
  _UserImpl({
    int? id,
    int? userInfoId,
    required String name,
    required int age,
    required String gender,
    required int height,
    required double currentWeight,
    required double targetWeight,
    String? photoUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
    int? waterGlassSize,
  }) : super._(
         id: id,
         userInfoId: userInfoId,
         name: name,
         age: age,
         gender: gender,
         height: height,
         currentWeight: currentWeight,
         targetWeight: targetWeight,
         photoUrl: photoUrl,
         createdAt: createdAt,
         updatedAt: updatedAt,
         waterGlassSize: waterGlassSize,
       );

  /// Returns a shallow copy of this [User]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  User copyWith({
    Object? id = _Undefined,
    Object? userInfoId = _Undefined,
    String? name,
    int? age,
    String? gender,
    int? height,
    double? currentWeight,
    double? targetWeight,
    Object? photoUrl = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? waterGlassSize = _Undefined,
  }) {
    return User(
      id: id is int? ? id : this.id,
      userInfoId: userInfoId is int? ? userInfoId : this.userInfoId,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      photoUrl: photoUrl is String? ? photoUrl : this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      waterGlassSize: waterGlassSize is int?
          ? waterGlassSize
          : this.waterGlassSize,
    );
  }
}
