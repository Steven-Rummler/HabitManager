import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitmanager/habitModel.dart';
import 'package:habitmanager/habit.dart';
import 'package:habitmanager/database.dart';
import 'package:habitmanager/main.dart';
import 'package:habitmanager/uuid.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';

class DatabaseHabitModel extends HabitModel {
  final Database database;

  DatabaseHabitModel(this.database);

  Future<void> addHabit(Habit habit) async {
    habit.id = nextId();
    print("Assigned the new habit an id: ${habit.id}");
    await database.insert(
      tableHabit,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    super.addHabit(habit);

    updateNotifications();
  }

  Future<List<Habit>> habits() async {
    final List<Map<String, dynamic>> maps = await database.rawQuery("""
      select h.id, h.title, h.description, h.times, h.days, avg(r.success) * 100 as percent
      from $tableHabit h
      left join $tableHabitRecord r on h.id = r.habitId
      group by h.id, h.title, h.description, h.times, h.days
      """);

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    });
  }

  Future<Habit> habitForId(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableHabit,
      where: "id = ?",
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return Habit.fromMap(maps[i]);
    }).first;
  }

  Future<void> editHabit(Habit habit) async {
    await database.update(
      tableHabit,
      habit.toMap(),
      where: "id = ?",
      whereArgs: [habit.id],
    );

    super.editHabit(habit);

    updateNotifications();
  }

  Future<void> deleteHabit(int id) async {
    await database.delete(
      tableHabit,
      where: "id = ?",
      whereArgs: [id],
    );

    super.deleteHabit(id);

    updateNotifications();
  }

  Future<void> record(int habitId, bool success) async {
    DatabaseHabitRecordModel recordModel =
        DatabaseHabitRecordModel(this.database);
    HabitRecord record = HabitRecord(nextId(), habitId, success);
    recordModel.addHabitRecord(record);

    notifyListeners();
  }

  Future<double> percent(int habitId) async {
    final test = await database.rawQuery("""
      select avg(success)
      from $tableHabitRecord
      where habitId = $habitId
      """);
    print(test.first.values.first);
    return test.first.values.first * 100;
  }

  void updateNotifications() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancelAll();
    List<Habit> habitList = await habits();
    habitList.forEach((habit) async {
      print(habit);
      int hour = 0;
      if (habit.times == "Morning")
        hour = 8;
      else if (habit.times == "Afternoon")
        hour = 14;
      else
        hour = 20;

      if (habit.days == "Daily") {
        var time = Time(hour, 0, 0);
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            '$habit.id', habit.title, habit.description);
        var iOSPlatformChannelSpecifics = IOSNotificationDetails();
        var platformChannelSpecifics = NotificationDetails(
            androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.showDailyAtTime(
            0, habit.title, habit.description, time, platformChannelSpecifics);
      } else if (habit.days == "Weekdays") {
        addNotification(habit, Day.Monday, hour);
        addNotification(habit, Day.Tuesday, hour);
        addNotification(habit, Day.Wednesday, hour);
        addNotification(habit, Day.Thursday, hour);
        addNotification(habit, Day.Friday, hour);
      } else if (habit.days == "Weekends") {
        addNotification(habit, Day.Saturday, hour);
        addNotification(habit, Day.Sunday, hour);
      } else
      /*(habit.days == "Monday")*/ {
        addNotification(habit, Day.Monday, hour);
      }
    });
  }

  void addNotification(Habit habit, Day day, int hour) async {
    var time = Time(hour, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '$habit.id$day$hour', '$habit.title', '$habit.description');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0, habit.title, habit.description, day, time, platformChannelSpecifics);
  }
}

class DatabaseHabitRecordModel extends HabitRecordModel {
  final Database database;

  DatabaseHabitRecordModel(this.database);

  Future<void> addHabitRecord(HabitRecord habitRecord) async {
    habitRecord.id = nextId();
    await database.insert(
      tableHabitRecord,
      habitRecord.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    super.addHabitRecord(habitRecord);
  }

  Future<List<HabitRecord>> habitRecords() async {
    final List<Map<String, dynamic>> maps =
        await database.query(tableHabitRecord);

    return List.generate(maps.length, (i) {
      return HabitRecord.fromMap(maps[i]);
    });
  }

  Future<HabitRecord> habitRecordForId(int id) async {
    final List<Map<String, dynamic>> maps = await database.query(
      tableHabitRecord,
      where: "id = ?",
      whereArgs: [id],
    );

    return List.generate(maps.length, (i) {
      return HabitRecord.fromMap(maps[i]);
    }).first;
  }

  Future<void> editHabitRecord(HabitRecord habitRecord) async {
    await database.update(
      tableHabitRecord,
      habitRecord.toMap(),
      where: "id = ?",
      whereArgs: [habitRecord.id],
    );

    super.editHabitRecord(habitRecord);
  }

  Future<void> deleteHabitRecord(int id) async {
    await database.delete(
      tableHabitRecord,
      where: "id = ?",
      whereArgs: [id],
    );

    super.deleteHabitRecord(id);
  }
}
