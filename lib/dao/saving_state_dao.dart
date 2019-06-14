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
          .execute(
              "CREATE TABLE State (day INTEGER PRIMARY KEY, state INTEGER)")
          .then((v) => {
                new List.generate(365, (i) => i + 1).forEach((i) => {
                      db.insert("State", {'day': i, 'state': NOT_SAVED})
                    })
              });
    });
    return null;
  }

  @override
  Future<Map<int, bool>> currentState() async {
    List<Map<String, dynamic>> allRecords = await db.query(DayRecord.TABLE_NAME,
        columns: [DayRecord.COLUMN_DAY, DayRecord.COLUMN_STATE]);
    return Map.fromIterable(allRecords.map((m) => DayRecord.fromMap(m)),
        key: (r) => r.day, value: (r) => r.state == SAVED);
  }

  @override
  void updateState(Map<int, bool> updatedState) {
    updatedState.forEach((id, state) =>
        db.update("State", {'day': id, 'state': state == true ? 1 : 0}));
  }
}

class DayRecord {
  static const TABLE_NAME = "State";

  static const String COLUMN_DAY = 'day';
  static const String COLUMN_STATE = 'state';
  int day;
  int state;

  DayRecord({this.day, this.state});

  Map<String, dynamic> toMap() {
    return {COLUMN_DAY: day, COLUMN_STATE: state};
  }

  DayRecord.fromMap(Map<String, dynamic> map) {
    day = map[COLUMN_DAY];
    state = map[COLUMN_STATE];
  }
}
