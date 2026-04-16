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

abstract class DailyLog
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = DailyLogTable();

  static const db = DailyLogRepository._();

  @override
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

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DailyLog',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
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

  static DailyLogInclude include({_i2.UserInclude? user}) {
    return DailyLogInclude._(user: user);
  }

  static DailyLogIncludeList includeList({
    _i1.WhereExpressionBuilder<DailyLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyLogTable>? orderByList,
    DailyLogInclude? include,
  }) {
    return DailyLogIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyLog.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DailyLog.t),
      include: include,
    );
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

class DailyLogUpdateTable extends _i1.UpdateTable<DailyLogTable> {
  DailyLogUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> date(DateTime value) => _i1.ColumnValue(
    table.date,
    value,
  );

  _i1.ColumnValue<double, double> foodCal(double value) => _i1.ColumnValue(
    table.foodCal,
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

  _i1.ColumnValue<int, int> waterMl(int? value) => _i1.ColumnValue(
    table.waterMl,
    value,
  );

  _i1.ColumnValue<double, double> walkCal(double value) => _i1.ColumnValue(
    table.walkCal,
    value,
  );

  _i1.ColumnValue<double, double> netCal(double value) => _i1.ColumnValue(
    table.netCal,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class DailyLogTable extends _i1.Table<int?> {
  DailyLogTable({super.tableRelation}) : super(tableName: 'daily_logs') {
    updateTable = DailyLogUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    date = _i1.ColumnDateTime(
      'date',
      this,
    );
    foodCal = _i1.ColumnDouble(
      'foodCal',
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
    waterMl = _i1.ColumnInt(
      'waterMl',
      this,
    );
    walkCal = _i1.ColumnDouble(
      'walkCal',
      this,
    );
    netCal = _i1.ColumnDouble(
      'netCal',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final DailyLogUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  _i2.UserTable? _user;

  late final _i1.ColumnDateTime date;

  late final _i1.ColumnDouble foodCal;

  late final _i1.ColumnDouble protein;

  late final _i1.ColumnDouble fat;

  late final _i1.ColumnDouble carbs;

  late final _i1.ColumnInt waterMl;

  late final _i1.ColumnDouble walkCal;

  late final _i1.ColumnDouble netCal;

  late final _i1.ColumnDateTime createdAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: DailyLog.t.userId,
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
    date,
    foodCal,
    protein,
    fat,
    carbs,
    waterMl,
    walkCal,
    netCal,
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

class DailyLogInclude extends _i1.IncludeObject {
  DailyLogInclude._({_i2.UserInclude? user}) {
    _user = user;
  }

  _i2.UserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => DailyLog.t;
}

class DailyLogIncludeList extends _i1.IncludeList {
  DailyLogIncludeList._({
    _i1.WhereExpressionBuilder<DailyLogTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DailyLog.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DailyLog.t;
}

class DailyLogRepository {
  const DailyLogRepository._();

  final attachRow = const DailyLogAttachRowRepository._();

  /// Returns a list of [DailyLog]s matching the given query parameters.
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
  Future<List<DailyLog>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyLogTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyLogTable>? orderByList,
    _i1.Transaction? transaction,
    DailyLogInclude? include,
  }) async {
    return session.db.find<DailyLog>(
      where: where?.call(DailyLog.t),
      orderBy: orderBy?.call(DailyLog.t),
      orderByList: orderByList?.call(DailyLog.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [DailyLog] matching the given query parameters.
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
  Future<DailyLog?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyLogTable>? where,
    int? offset,
    _i1.OrderByBuilder<DailyLogTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DailyLogTable>? orderByList,
    _i1.Transaction? transaction,
    DailyLogInclude? include,
  }) async {
    return session.db.findFirstRow<DailyLog>(
      where: where?.call(DailyLog.t),
      orderBy: orderBy?.call(DailyLog.t),
      orderByList: orderByList?.call(DailyLog.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [DailyLog] by its [id] or null if no such row exists.
  Future<DailyLog?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    DailyLogInclude? include,
  }) async {
    return session.db.findById<DailyLog>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [DailyLog]s in the list and returns the inserted rows.
  ///
  /// The returned [DailyLog]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DailyLog>> insert(
    _i1.Session session,
    List<DailyLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DailyLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DailyLog] and returns the inserted row.
  ///
  /// The returned [DailyLog] will have its `id` field set.
  Future<DailyLog> insertRow(
    _i1.Session session,
    DailyLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DailyLog>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DailyLog]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DailyLog>> update(
    _i1.Session session,
    List<DailyLog> rows, {
    _i1.ColumnSelections<DailyLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DailyLog>(
      rows,
      columns: columns?.call(DailyLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyLog]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DailyLog> updateRow(
    _i1.Session session,
    DailyLog row, {
    _i1.ColumnSelections<DailyLogTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DailyLog>(
      row,
      columns: columns?.call(DailyLog.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DailyLog] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<DailyLog?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<DailyLogUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<DailyLog>(
      id,
      columnValues: columnValues(DailyLog.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [DailyLog]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<DailyLog>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<DailyLogUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<DailyLogTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DailyLogTable>? orderBy,
    _i1.OrderByListBuilder<DailyLogTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<DailyLog>(
      columnValues: columnValues(DailyLog.t.updateTable),
      where: where(DailyLog.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DailyLog.t),
      orderByList: orderByList?.call(DailyLog.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [DailyLog]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DailyLog>> delete(
    _i1.Session session,
    List<DailyLog> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DailyLog>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DailyLog].
  Future<DailyLog> deleteRow(
    _i1.Session session,
    DailyLog row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DailyLog>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DailyLog>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DailyLogTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DailyLog>(
      where: where(DailyLog.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DailyLogTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DailyLog>(
      where: where?.call(DailyLog.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class DailyLogAttachRowRepository {
  const DailyLogAttachRowRepository._();

  /// Creates a relation between the given [DailyLog] and [User]
  /// by setting the [DailyLog]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    DailyLog dailyLog,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (dailyLog.id == null) {
      throw ArgumentError.notNull('dailyLog.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $dailyLog = dailyLog.copyWith(userId: user.id);
    await session.db.updateRow<DailyLog>(
      $dailyLog,
      columns: [DailyLog.t.userId],
      transaction: transaction,
    );
  }
}
