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

abstract class Walk implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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

  static final t = WalkTable();

  static const db = WalkRepository._();

  @override
  int? id;

  int userId;

  _i2.User? user;

  int steps;

  double distanceKm;

  double calories;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Walk',
      if (id != null) 'id': id,
      'userId': userId,
      if (user != null) 'user': user?.toJsonForProtocol(),
      'steps': steps,
      'distanceKm': distanceKm,
      'calories': calories,
      'createdAt': createdAt.toJson(),
    };
  }

  static WalkInclude include({_i2.UserInclude? user}) {
    return WalkInclude._(user: user);
  }

  static WalkIncludeList includeList({
    _i1.WhereExpressionBuilder<WalkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalkTable>? orderByList,
    WalkInclude? include,
  }) {
    return WalkIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Walk.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Walk.t),
      include: include,
    );
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

class WalkUpdateTable extends _i1.UpdateTable<WalkTable> {
  WalkUpdateTable(super.table);

  _i1.ColumnValue<int, int> userId(int value) => _i1.ColumnValue(
    table.userId,
    value,
  );

  _i1.ColumnValue<int, int> steps(int value) => _i1.ColumnValue(
    table.steps,
    value,
  );

  _i1.ColumnValue<double, double> distanceKm(double value) => _i1.ColumnValue(
    table.distanceKm,
    value,
  );

  _i1.ColumnValue<double, double> calories(double value) => _i1.ColumnValue(
    table.calories,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );
}

class WalkTable extends _i1.Table<int?> {
  WalkTable({super.tableRelation}) : super(tableName: 'walks') {
    updateTable = WalkUpdateTable(this);
    userId = _i1.ColumnInt(
      'userId',
      this,
    );
    steps = _i1.ColumnInt(
      'steps',
      this,
    );
    distanceKm = _i1.ColumnDouble(
      'distanceKm',
      this,
    );
    calories = _i1.ColumnDouble(
      'calories',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final WalkUpdateTable updateTable;

  late final _i1.ColumnInt userId;

  _i2.UserTable? _user;

  late final _i1.ColumnInt steps;

  late final _i1.ColumnDouble distanceKm;

  late final _i1.ColumnDouble calories;

  late final _i1.ColumnDateTime createdAt;

  _i2.UserTable get user {
    if (_user != null) return _user!;
    _user = _i1.createRelationTable(
      relationFieldName: 'user',
      field: Walk.t.userId,
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
    steps,
    distanceKm,
    calories,
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

class WalkInclude extends _i1.IncludeObject {
  WalkInclude._({_i2.UserInclude? user}) {
    _user = user;
  }

  _i2.UserInclude? _user;

  @override
  Map<String, _i1.Include?> get includes => {'user': _user};

  @override
  _i1.Table<int?> get table => Walk.t;
}

class WalkIncludeList extends _i1.IncludeList {
  WalkIncludeList._({
    _i1.WhereExpressionBuilder<WalkTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Walk.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Walk.t;
}

class WalkRepository {
  const WalkRepository._();

  final attachRow = const WalkAttachRowRepository._();

  /// Returns a list of [Walk]s matching the given query parameters.
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
  Future<List<Walk>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalkTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalkTable>? orderByList,
    _i1.Transaction? transaction,
    WalkInclude? include,
  }) async {
    return session.db.find<Walk>(
      where: where?.call(Walk.t),
      orderBy: orderBy?.call(Walk.t),
      orderByList: orderByList?.call(Walk.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [Walk] matching the given query parameters.
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
  Future<Walk?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalkTable>? where,
    int? offset,
    _i1.OrderByBuilder<WalkTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<WalkTable>? orderByList,
    _i1.Transaction? transaction,
    WalkInclude? include,
  }) async {
    return session.db.findFirstRow<Walk>(
      where: where?.call(Walk.t),
      orderBy: orderBy?.call(Walk.t),
      orderByList: orderByList?.call(Walk.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [Walk] by its [id] or null if no such row exists.
  Future<Walk?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
    WalkInclude? include,
  }) async {
    return session.db.findById<Walk>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [Walk]s in the list and returns the inserted rows.
  ///
  /// The returned [Walk]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Walk>> insert(
    _i1.Session session,
    List<Walk> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Walk>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Walk] and returns the inserted row.
  ///
  /// The returned [Walk] will have its `id` field set.
  Future<Walk> insertRow(
    _i1.Session session,
    Walk row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Walk>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Walk]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Walk>> update(
    _i1.Session session,
    List<Walk> rows, {
    _i1.ColumnSelections<WalkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Walk>(
      rows,
      columns: columns?.call(Walk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Walk]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Walk> updateRow(
    _i1.Session session,
    Walk row, {
    _i1.ColumnSelections<WalkTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Walk>(
      row,
      columns: columns?.call(Walk.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Walk] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Walk?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<WalkUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Walk>(
      id,
      columnValues: columnValues(Walk.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Walk]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Walk>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<WalkUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<WalkTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<WalkTable>? orderBy,
    _i1.OrderByListBuilder<WalkTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Walk>(
      columnValues: columnValues(Walk.t.updateTable),
      where: where(Walk.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Walk.t),
      orderByList: orderByList?.call(Walk.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Walk]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Walk>> delete(
    _i1.Session session,
    List<Walk> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Walk>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Walk].
  Future<Walk> deleteRow(
    _i1.Session session,
    Walk row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Walk>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Walk>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<WalkTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Walk>(
      where: where(Walk.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<WalkTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Walk>(
      where: where?.call(Walk.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class WalkAttachRowRepository {
  const WalkAttachRowRepository._();

  /// Creates a relation between the given [Walk] and [User]
  /// by setting the [Walk]'s foreign key `userId` to refer to the [User].
  Future<void> user(
    _i1.Session session,
    Walk walk,
    _i2.User user, {
    _i1.Transaction? transaction,
  }) async {
    if (walk.id == null) {
      throw ArgumentError.notNull('walk.id');
    }
    if (user.id == null) {
      throw ArgumentError.notNull('user.id');
    }

    var $walk = walk.copyWith(userId: user.id);
    await session.db.updateRow<Walk>(
      $walk,
      columns: [Walk.t.userId],
      transaction: transaction,
    );
  }
}
