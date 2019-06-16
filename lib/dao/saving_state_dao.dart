import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ISavingStateDao {
  Future<void> init() async => {};

  bool initializeCompleted() => false;

  Future<Map<int, bool>> currentState() async => new Map();

  Future<void> updateState(Map<int, bool> updatedState) async => {};

  Future<void> deleteAllRecords() async => {};
}

class SavingStateDaoSqfliteImpl implements ISavingStateDao {
  static const int SAVED = 1;
  static const int NOT_SAVED = 0;

  static const DB_NAME = "365DaySavings";
  Database db;
  bool isInitializeCompleted = false;

  @override
  Future<void> init() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, DB_NAME);
    try {
      await Directory(databasesPath).create(recursive: true);
    } catch (_) {}
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      db
          .execute('CREATE TABLE ' +
              DayRecord.TABLE_NAME +
              ' (' +
              DayRecord.COLUMN_DAY +
              ' INTEGER PRIMARY KEY, ' +
              DayRecord.COLUMN_SAVED +
              ' INTEGER)')
          .then((v) => {
                new List.generate(365, (i) => i + 1).forEach((i) => {
                      db.insert(DayRecord.TABLE_NAME, {
                        DayRecord.COLUMN_DAY: i,
                        DayRecord.COLUMN_SAVED: NOT_SAVED
                      })
                    })
              });
    }).then((db) {
      isInitializeCompleted = true;
      return db;
    });
    return db;
  }

  @override
  bool initializeCompleted() {
    return isInitializeCompleted;
  }

  @override
  Future<Map<int, bool>> currentState() async {
    List<Map<String, dynamic>> allRecords = await db.query(DayRecord.TABLE_NAME,
        columns: [DayRecord.COLUMN_DAY, DayRecord.COLUMN_SAVED]);
    return Map.fromIterable(allRecords.map((m) => DayRecord.fromMap(m)),
        key: (r) => r.day, value: (r) => r.saved == SAVED);
  }

  @override
  Future<void> updateState(Map<int, bool> updatedState) async {
    if (updatedState.isEmpty) {
      return null;
    }
    var updateFutures = updatedState.entries
        .map((e) => db.update(
            DayRecord.TABLE_NAME,
            {
              DayRecord.COLUMN_SAVED: SAVED,
            },
            where: '${DayRecord.COLUMN_DAY} = ?',
            whereArgs: [e.key]))
        .toList();
    return Future.wait(updateFutures);
  }

  @override
  Future<void> deleteAllRecords() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, DB_NAME);
    return deleteDatabase(path).then((v) => init());
  }
}

class DayRecord {
  static const TABLE_NAME = "SavingState";

  static const String COLUMN_DAY = 'day';
  static const String COLUMN_SAVED = 'saved';
  int day;
  int saved;

  DayRecord({this.day, this.saved});

  Map<String, dynamic> toMap() {
    return {COLUMN_DAY: day, COLUMN_SAVED: saved};
  }

  DayRecord.fromMap(Map<String, dynamic> map) {
    day = map[COLUMN_DAY];
    saved = map[COLUMN_SAVED];
  }
}
