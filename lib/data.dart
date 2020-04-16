import 'package:flutter/material.dart';

class DataModel extends ChangeNotifier {
  String times = "Morning";
  String days = "Daily";

  List<String> timesList = [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  List<String> daysList = ['Daily', 'Weekdays', 'Weekends', 'Monday'];

  void changeTimes(String newTimes) {
    times = newTimes;
    notifyListeners();
  }

  void changeDays(String newDays) {
    days = newDays;
    notifyListeners();
  }

  void resetFields() {
    times = "Morning";
    days = "Daily";
  }
}
