import 'package:flutter/foundation.dart';
import 'package:habitmanager/habit.dart';

abstract class HabitModel extends ChangeNotifier {
  Future<void> addHabit(Habit habit) async {
    notifyListeners();
  }

  Future<List<Habit>> habits();

  Future<Habit> habitForId(int id);

  Future<void> editHabit(Habit habit) async {
    notifyListeners();
  }

  Future<void> deleteHabit(int id) async {
    notifyListeners();
  }

  Future<void> record(int habitId, bool success);

  Future<double> percent(int habitId);
}

abstract class HabitRecordModel extends ChangeNotifier {
  Future<void> addHabitRecord(HabitRecord habitRecord) async {
    notifyListeners();
  }

  Future<List<HabitRecord>> habitRecords();

  Future<HabitRecord> habitRecordForId(int id);

  Future<void> editHabitRecord(HabitRecord habitRecord) async {
    notifyListeners();
  }

  Future<void> deleteHabitRecord(int id) async {
    notifyListeners();
  }
}
