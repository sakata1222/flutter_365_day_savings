import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ISavingStateDao {
  Future<void> init() => null;

  bool initializeCompleted() => false;

  Future<Map<int, bool>> currentState() => null;

  Future<void> updateState(Map<int, bool> updatedState) => null;

  Future<void> deleteAllRecords() => null;
}

class SavingStateDaoSqfliteImpl implements ISavingStateDao {
  static const int SAVED = 1;
  static const int NOT_SAVED = 0;

  static const DB_NAME = "365DaySavings";
  Database db;
  bool isInitializeCompleted = false;

  @override
  Future<void> init() {
    return getDatabasesPath()
        .then((dbDir) {
          try {
            Directory(dbDir).deleteSync(recursive: true);
          } catch (_) {}
          return dbDir;
        })
        .then((dbDir) => join(dbDir, DB_NAME))
        .then((dbPath) {
          return openDatabase(dbPath, version: 1,
              onCreate: (Database db, int version) {
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
            this.db = db;
            isInitializeCompleted = true;
          });
        });
  }

  @override
  bool initializeCompleted() {
    return isInitializeCompleted;
  }

  @override
  Future<Map<int, bool>> currentState() {
    return db.query(DayRecord.TABLE_NAME, columns: [
      DayRecord.COLUMN_DAY,
      DayRecord.COLUMN_SAVED
    ]).then((allRecords) => Map.fromIterable(
        allRecords.map((m) => DayRecord.fromMap(m)),
        key: (r) => r.day,
        value: (r) => r.saved == SAVED));
  }

  @override
  Future<void> updateState(Map<int, bool> updatedState) {
    if (updatedState.isEmpty) {
      return null;
    }
    var updateFutures = updatedState.entries
        .where((e) => e.value)
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
  Future<void> deleteAllRecords() {
    return db
        .close()
        .then((v) => getDatabasesPath())
        .then((path) => join(path, DB_NAME))
        .then((db) => deleteDatabase(db))
        .then((db) => init());
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
