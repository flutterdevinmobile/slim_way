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

abstract class WeeklyWeight
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = WeeklyWeightTable();

  static const db = WeeklyWeightRepository._();

  @override
  int? id;

  int userId;

  _i2.User? user;

  DateTime weekStart;

  double weight;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WeeklyWeight',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'weekStart': weekStart.toJson(),
      'weight': weight,
      'createdAt': createdAt.toJson(),
    };
  }

  static WeeklyWeightInclude include({_i2.UserInclude? user}) {
    return WeeklyWeightInclude._(user: user);
  }

  static WeeklyWeightIncludeList includeList({
    _i1.WhereExpressionBuilder<WeeklyWeightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WeeklyWeightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WeeklyWeightTable>? orderByList,
    WeeklyWeightInclude? include,
  }) {
    return WeeklyWeightIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WeeklyWeight.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(WeeklyWeight.t),
      include: include,
    );
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

class WeeklyWeightUpdateTable extends _i1.UpdateTable<WeeklyWeightTable> {
  WeeklyWeightUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> weekStart(DateTime value) =>
      _i1.ColumnValue(
        table.weekStart,
        value,
      );

  _i1.ColumnValue<double, double> weight(double value) => _i1.ColumnValue(
    table.weight,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class WeeklyWeightTable extends _i1.Table<int?> {
  WeeklyWeightTable({super.tableRelation}) : super(tableName: 'weekly_weight') {
    updateTable = WeeklyWeightUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    weekStart = _i1.ColumnDateTime(
      'weekStart',
      this,
    );
    weight = _i1.ColumnDouble(
      'weight',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final WeeklyWeightUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  _i2.UserTable? _user;

  late final _i1.ColumnDateTime weekStart;

  late final _i1.ColumnDouble weight;

  late final _i1.ColumnDateTime createdAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: WeeklyWeight.t.userId,
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
    weekStart,
    weight,
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

class WeeklyWeightInclude extends _i1.IncludeObject {
  WeeklyWeightInclude._({_i2.UserInclude? user}) {
    _user = user;
  }

  _i2.UserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => WeeklyWeight.t;
}

class WeeklyWeightIncludeList extends _i1.IncludeList {
  WeeklyWeightIncludeList._({
    _i1.WhereExpressionBuilder<WeeklyWeightTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WeeklyWeight.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => WeeklyWeight.t;
}

class WeeklyWeightRepository {
  const WeeklyWeightRepository._();

  final attachRow = const WeeklyWeightAttachRowRepository._();

  /// Returns a list of [WeeklyWeight]s matching the given query parameters.
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
  Future<List<WeeklyWeight>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WeeklyWeightTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WeeklyWeightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WeeklyWeightTable>? orderByList,
    _i1.Transaction? transaction,
    WeeklyWeightInclude? include,
  }) async {
    return session.db.find<WeeklyWeight>(
      where: where?.call(WeeklyWeight.t),
      orderBy: orderBy?.call(WeeklyWeight.t),
      orderByList: orderByList?.call(WeeklyWeight.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [WeeklyWeight] matching the given query parameters.
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
  Future<WeeklyWeight?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WeeklyWeightTable>? where,
    int? offset,
    _i1.OrderByBuilder<WeeklyWeightTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WeeklyWeightTable>? orderByList,
    _i1.Transaction? transaction,
    WeeklyWeightInclude? include,
  }) async {
    return session.db.findFirstRow<WeeklyWeight>(
      where: where?.call(WeeklyWeight.t),
      orderBy: orderBy?.call(WeeklyWeight.t),
      orderByList: orderByList?.call(WeeklyWeight.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [WeeklyWeight] by its [id] or null if no such row exists.
  Future<WeeklyWeight?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    WeeklyWeightInclude? include,
  }) async {
    return session.db.findById<WeeklyWeight>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [WeeklyWeight]s in the list and returns the inserted rows.
  ///
  /// The returned [WeeklyWeight]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<WeeklyWeight>> insert(
    _i1.Session session,
    List<WeeklyWeight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<WeeklyWeight>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [WeeklyWeight] and returns the inserted row.
  ///
  /// The returned [WeeklyWeight] will have its `id` field set.
  Future<WeeklyWeight> insertRow(
    _i1.Session session,
    WeeklyWeight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<WeeklyWeight>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [WeeklyWeight]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<WeeklyWeight>> update(
    _i1.Session session,
    List<WeeklyWeight> rows, {
    _i1.ColumnSelections<WeeklyWeightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<WeeklyWeight>(
      rows,
      columns: columns?.call(WeeklyWeight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WeeklyWeight]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WeeklyWeight> updateRow(
    _i1.Session session,
    WeeklyWeight row, {
    _i1.ColumnSelections<WeeklyWeightTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<WeeklyWeight>(
      row,
      columns: columns?.call(WeeklyWeight.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WeeklyWeight] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WeeklyWeight?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<WeeklyWeightUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<WeeklyWeight>(
      id,
      columnValues: columnValues(WeeklyWeight.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WeeklyWeight]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<WeeklyWeight>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<WeeklyWeightUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<WeeklyWeightTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WeeklyWeightTable>? orderBy,
    _i1.OrderByListBuilder<WeeklyWeightTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<WeeklyWeight>(
      columnValues: columnValues(WeeklyWeight.t.updateTable),
      where: where(WeeklyWeight.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WeeklyWeight.t),
      orderByList: orderByList?.call(WeeklyWeight.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [WeeklyWeight]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<WeeklyWeight>> delete(
    _i1.Session session,
    List<WeeklyWeight> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<WeeklyWeight>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [WeeklyWeight].
  Future<WeeklyWeight> deleteRow(
    _i1.Session session,
    WeeklyWeight row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WeeklyWeight>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<WeeklyWeight>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<WeeklyWeightTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<WeeklyWeight>(
      where: where(WeeklyWeight.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WeeklyWeightTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<WeeklyWeight>(
      where: where?.call(WeeklyWeight.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class WeeklyWeightAttachRowRepository {
  const WeeklyWeightAttachRowRepository._();

  /// Creates a relation between the given [WeeklyWeight] and [User]
  /// by setting the [WeeklyWeight]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    WeeklyWeight weeklyWeight,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (weeklyWeight.id == null) {
      throw ArgumentError.notNull('weeklyWeight.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $weeklyWeight = weeklyWeight.copyWith(userId: user.id);
    await session.db.updateRow<WeeklyWeight>(
      $weeklyWeight,
      columns: [WeeklyWeight.t.userId],
      transaction: transaction,
    );
  }
}
