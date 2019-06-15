import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ISavingStateDao {
  Future<void> init() async => {};

  Future<Map<int, bool>> currentState() async => new Map();

  void updateState(Map<int, bool> updatedState) => {};
}

class SavingStateDaoSqfliteImpl implements ISavingStateDao {
  static const int SAVED = 1;
  static const int NOT_SAVED = 0;

  static const DB_NAME = "365DaySavings";
  Database db;

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
    });
    return null;
  }

  @override
  Future<Map<int, bool>> currentState() async {
    List<Map<String, dynamic>> allRecords = await db.query(DayRecord.TABLE_NAME,
        columns: [DayRecord.COLUMN_DAY, DayRecord.COLUMN_SAVED]);
    return Map.fromIterable(allRecords.map((m) => DayRecord.fromMap(m)),
        key: (r) => r.day, value: (r) => r.saved == SAVED);
  }

  @override
  void updateState(Map<int, bool> updatedState) {
    updatedState.forEach((id, saved) => db.update(DayRecord.TABLE_NAME, {
          DayRecord.COLUMN_DAY: id,
          DayRecord.COLUMN_SAVED: saved == true ? 1 : 0
        }));
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
