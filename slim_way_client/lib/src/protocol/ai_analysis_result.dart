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

abstract class AiAnalysisResult implements _i1.SerializableModel {
  AiAnalysisResult._({
    this.nameUz,
    this.nameEn,
    this.nameRu,
    required this.calories,
    this.protein,
    this.fat,
    this.carbs,
  });

  factory AiAnalysisResult({
    String? nameUz,
    String? nameEn,
    String? nameRu,
    required double calories,
    double? protein,
    double? fat,
    double? carbs,
  }) = _AiAnalysisResultImpl;

  factory AiAnalysisResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AiAnalysisResult(
      nameUz: jsonSerialization['nameUz'] as String?,
      nameEn: jsonSerialization['nameEn'] as String?,
      nameRu: jsonSerialization['nameRu'] as String?,
      calories: (jsonSerialization['calories'] as num).toDouble(),
      protein: (jsonSerialization['protein'] as num?)?.toDouble(),
      fat: (jsonSerialization['fat'] as num?)?.toDouble(),
      carbs: (jsonSerialization['carbs'] as num?)?.toDouble(),
    );
  }

  String? nameUz;

  String? nameEn;

  String? nameRu;

  double calories;

  double? protein;

  double? fat;

  double? carbs;

  /// Returns a shallow copy of this [AiAnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AiAnalysisResult copyWith({
    String? nameUz,
    String? nameEn,
    String? nameRu,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AiAnalysisResult',
      if (nameUz != null) 'nameUz': nameUz,
      if (nameEn != null) 'nameEn': nameEn,
      if (nameRu != null) 'nameRu': nameRu,
      'calories': calories,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AiAnalysisResultImpl extends AiAnalysisResult {
  _AiAnalysisResultImpl({
    String? nameUz,
    String? nameEn,
    String? nameRu,
    required double calories,
    double? protein,
    double? fat,
    double? carbs,
  }) : super._(
         nameUz: nameUz,
         nameEn: nameEn,
         nameRu: nameRu,
         calories: calories,
         protein: protein,
         fat: fat,
         carbs: carbs,
       );

  /// Returns a shallow copy of this [AiAnalysisResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AiAnalysisResult copyWith({
    Object? nameUz = _Undefined,
    Object? nameEn = _Undefined,
    Object? nameRu = _Undefined,
    double? calories,
    Object? protein = _Undefined,
    Object? fat = _Undefined,
    Object? carbs = _Undefined,
  }) {
    return AiAnalysisResult(
      nameUz: nameUz is String? ? nameUz : this.nameUz,
      nameEn: nameEn is String? ? nameEn : this.nameEn,
      nameRu: nameRu is String? ? nameRu : this.nameRu,
      calories: calories ?? this.calories,
      protein: protein is double? ? protein : this.protein,
      fat: fat is double? ? fat : this.fat,
      carbs: carbs is double? ? carbs : this.carbs,
    );
  }
}
