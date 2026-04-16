/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'user.dart' as _i2;
import 'package:slim_way_server/src/generated/protocol.dart' as _i3;

abstract class Food implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = FoodTable();

  static const db = FoodRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Food',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'name': name,
      'calories': calories,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (protein != null) 'protein': protein,
      if (fat != null) 'fat': fat,
      if (carbs != null) 'carbs': carbs,
      'createdAt': createdAt.toJson(),
    };
  }

  static FoodInclude include({_i2.UserInclude? user}) {
    return FoodInclude._(user: user);
  }

  static FoodIncludeList includeList({
    _i1.WhereExpressionBuilder<FoodTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FoodTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FoodTable>? orderByList,
    FoodInclude? include,
  }) {
    return FoodIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Food.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Food.t),
      include: include,
    );
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

class FoodUpdateTable extends _i1.UpdateTable<FoodTable> {
  FoodUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<String, String> name(String value) => _i1.ColumnValue(
    table.name,
    value,
  );

  _i1.ColumnValue<double, double> calories(double value) => _i1.ColumnValue(
    table.calories,
    value,
  );

  _i1.ColumnValue<String, String> photoUrl(String? value) => _i1.ColumnValue(
    table.photoUrl,
    value,
  );

  _i1.ColumnValue<double, double> protein(double? value) => _i1.ColumnValue(
    table.protein,
    value,
  );

  _i1.ColumnValue<double, double> fat(double? value) => _i1.ColumnValue(
    table.fat,
    value,
  );

  _i1.ColumnValue<double, double> carbs(double? value) => _i1.ColumnValue(
    table.carbs,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class FoodTable extends _i1.Table<int?> {
  FoodTable({super.tableRelation}) : super(tableName: 'foods') {
    updateTable = FoodUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    name = _i1.ColumnString(
      'name',
      this,
    );
    calories = _i1.ColumnDouble(
      'calories',
      this,
    );
    photoUrl = _i1.ColumnString(
      'photoUrl',
      this,
    );
    protein = _i1.ColumnDouble(
      'protein',
      this,
    );
    fat = _i1.ColumnDouble(
      'fat',
      this,
    );
    carbs = _i1.ColumnDouble(
      'carbs',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final FoodUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  _i2.UserTable? _user;

  late final _i1.ColumnString name;

  late final _i1.ColumnDouble calories;

  late final _i1.ColumnString photoUrl;

  late final _i1.ColumnDouble protein;

  late final _i1.ColumnDouble fat;

  late final _i1.ColumnDouble carbs;

  late final _i1.ColumnDateTime createdAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: Food.t.userId,
      foreignField: _i2.User.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.UserTable(tableRelation: foreignTableRelation),
    );
    return _user!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    userId,
    name,
    calories,
    photoUrl,
    protein,
    fat,
    carbs,
    createdAt,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'user') {
      return user;
    }
    return null;
  }
}

class FoodInclude extends _i1.IncludeObject {
  FoodInclude._({_i2.UserInclude? user}) {
    _user = user;
  }

  _i2.UserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => Food.t;
}

class FoodIncludeList extends _i1.IncludeList {
  FoodIncludeList._({
    _i1.WhereExpressionBuilder<FoodTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Food.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Food.t;
}

class FoodRepository {
  const FoodRepository._();

  final attachRow = const FoodAttachRowRepository._();

  /// Returns a list of [Food]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<Food>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FoodTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FoodTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FoodTable>? orderByList,
    _i1.Transaction? transaction,
    FoodInclude? include,
  }) async {
    return session.db.find<Food>(
      where: where?.call(Food.t),
      orderBy: orderBy?.call(Food.t),
      orderByList: orderByList?.call(Food.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Food] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Food?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FoodTable>? where,
    int? offset,
    _i1.OrderByBuilder<FoodTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<FoodTable>? orderByList,
    _i1.Transaction? transaction,
    FoodInclude? include,
  }) async {
    return session.db.findFirstRow<Food>(
      where: where?.call(Food.t),
      orderBy: orderBy?.call(Food.t),
      orderByList: orderByList?.call(Food.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Food] by its [id] or null if no such row exists.
  Future<Food?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    FoodInclude? include,
  }) async {
    return session.db.findById<Food>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Food]s in the list and returns the inserted rows.
  ///
  /// The returned [Food]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Food>> insert(
    _i1.Session session,
    List<Food> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Food>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Food] and returns the inserted row.
  ///
  /// The returned [Food] will have its `id` field set.
  Future<Food> insertRow(
    _i1.Session session,
    Food row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Food>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Food]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Food>> update(
    _i1.Session session,
    List<Food> rows, {
    _i1.ColumnSelections<FoodTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Food>(
      rows,
      columns: columns?.call(Food.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Food]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Food> updateRow(
    _i1.Session session,
    Food row, {
    _i1.ColumnSelections<FoodTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Food>(
      row,
      columns: columns?.call(Food.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Food] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Food?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<FoodUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Food>(
      id,
      columnValues: columnValues(Food.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Food]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Food>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<FoodUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<FoodTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<FoodTable>? orderBy,
    _i1.OrderByListBuilder<FoodTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Food>(
      columnValues: columnValues(Food.t.updateTable),
      where: where(Food.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Food.t),
      orderByList: orderByList?.call(Food.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Food]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Food>> delete(
    _i1.Session session,
    List<Food> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Food>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Food].
  Future<Food> deleteRow(
    _i1.Session session,
    Food row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Food>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Food>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<FoodTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Food>(
      where: where(Food.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<FoodTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Food>(
      where: where?.call(Food.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class FoodAttachRowRepository {
  const FoodAttachRowRepository._();

  /// Creates a relation between the given [Food] and [User]
  /// by setting the [Food]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    Food food,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (food.id == null) {
      throw ArgumentError.notNull('food.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $food = food.copyWith(userId: user.id);
    await session.db.updateRow<Food>(
      $food,
      columns: [Food.t.userId],
      transaction: transaction,
    );
  }
}
