import 'package:habitmanager/databaseModel.dart';

class Habit {
  static const kFieldId = "id";
  static const kFieldTitle = "title";
  static const kFieldDescription = "description";
  static const kFieldTimes = "times";
  static const kFieldDays = "days";

  int id = 0;
  var title = "";
  var description = "";
  var times = "";
  var days = "";
  double percent = 0;

  Habit(this.id, this.title, this.description, this.times, this.days);

  Habit.fromMap(Map<String, dynamic> map)
      : this.id = map[kFieldId],
        this.title = map[kFieldTitle],
        this.description = map[kFieldDescription],
        this.times = map[kFieldTimes],
        this.days = map[kFieldDays],
        this.percent = map["percent"];

  String getField(String fieldName) {
    switch (fieldName) {
      case kFieldTitle:
        return title;
      case kFieldDescription:
        return description;
      case kFieldTimes:
        return times;
      case kFieldDays:
        return days;
    }
    return null;
  }

  Map<String, dynamic> toMap() => {
        kFieldId: id,
        kFieldTitle: title,
        kFieldDescription: description,
        kFieldTimes: times,
        kFieldDays: days,
      };
}

class HabitRecord {
  static const kFieldId = "id";
  static const kFieldHabitId = "habitId";
  static const kFieldSuccess = "success";

  int id = 0;
  var habitId = 0;
  var success = true;

  HabitRecord(this.id, this.habitId, this.success);

  HabitRecord.fromMap(Map<String, dynamic> map)
      : this.id = map[kFieldId],
        this.habitId = map[kFieldHabitId],
        this.success = map[kFieldSuccess];

  Map<String, dynamic> toMap() => {
        kFieldId: id,
        kFieldHabitId: habitId,
        kFieldSuccess: success,
      };
}
