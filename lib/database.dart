import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:habitmanager/uuid.dart';

const databaseFilename = "habits.db";
const tableHabit = "habit";
const tableHabitRecord = "habitRecord";

Future<Database> openHabitsDatabase() async {
  var db = openDatabase(
    join(await getDatabasesPath(), databaseFilename),
    onCreate: (db, version) async {
      await db.execute(
        """
          CREATE TABLE $tableHabit(
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            times TEXT,
            days TEXT)
          """,
      );
      await db.execute(
        """
          CREATE TABLE $tableHabitRecord(
            id INTEGER PRIMARY KEY,
            habitId INTEGER,
            success INTEGER)
          """,
      );
    },
    version: 3,
  );

  var database = await db;
  await _updateMaxId(database);

  return db;
}

Future<void> _updateMaxId(Database db) async {
  try {
    var column = "max(id)";
    var maxId = 0;
    var maxId2 = 0;

    var results = await db.query(tableHabit, columns: [column]);
    var results2 = await db.query(tableHabitRecord, columns: [column]);

    if (results.length > 0) {
      maxId = results[0][column];
    }

    if (results2.length > 0) {
      maxId2 = results2[0][column];
    }

    if (results.length > 0) {
      var id = results[0][column];

      if (id > maxId) {
        maxId = id;
      }
    }

    if (results2.length > 0) {
      var id2 = results2[0][column];

      if (id2 > maxId2) {
        maxId2 = id2;
      }
    }

    if (maxId > maxId2)
      setId(maxId);
    else
      setId(maxId2);
  } catch (e) {
    print("Unable to query max ID (perhaps tables don't exist?)");
  }
}
