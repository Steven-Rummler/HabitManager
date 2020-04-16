import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitmanager/habit.dart';
import 'package:habitmanager/data.dart';

Future<Habit> addOrEditHabitDialog(BuildContext context,
    [Habit habitToEdit]) async {
  Habit _habit = Habit(0, "", "", "", "");

  const FIELD_HINT = "hint";
  const FIELD_LABEL = "label";
  const FIELD_NAME = "fieldName";
  const FIELD_ONCHANGED = "onChanged";

  var _fieldSpecs = [
    {
      FIELD_NAME: "title",
      FIELD_LABEL: "Title",
      FIELD_HINT: "Title for habit",
      FIELD_ONCHANGED: (String value) {
        _habit.title = value;
      }
    },
    {
      FIELD_NAME: "description",
      FIELD_LABEL: "Description",
      FIELD_HINT: "Additional details",
      FIELD_ONCHANGED: (String value) {
        _habit.description = value;
      }
    },
  ];

  List<Widget> _actionsForDialog(BuildContext context) {
    return <Widget>[
      FlatButton(
        child: Text('CANCEL'),
        onPressed: () {
          Navigator.of(context).pop(null);
        },
      ),
      FlatButton(
        child: Text(habitToEdit != null ? 'EDIT' : 'ADD'),
        onPressed: () {
          Navigator.of(context).pop(_habit);
        },
      ),
    ];
  }

  List<Widget> _fieldsForDialog(BuildContext context) {
    var fields = <Widget>[];

    _fieldSpecs.forEach((fieldSpec) {
      fields.add(Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: TextEditingController()
                ..text = _habit.getField(fieldSpec[FIELD_NAME]),
              autofocus: true,
              decoration: InputDecoration(
                labelText: fieldSpec[FIELD_LABEL],
                hintText: fieldSpec[FIELD_HINT],
              ),
              onChanged: fieldSpec[FIELD_ONCHANGED],
            ),
          ),
        ],
      ));
    });

    fields.add(Row(children: <Widget>[
      Consumer<DataModel>(builder: (context, data, child) {
        return Expanded(
          child: DropdownButton(
            hint: Text('Please choose a location'),
            // Not necessary for Option 1
            value: data.times,
            onChanged: (newValue) {
              data.changeTimes(newValue);
              _habit.times = newValue;
            },
            items: data.timesList.map((time) {
              return DropdownMenuItem(
                child: new Text(time),
                value: time,
              );
            }).toList(),
          ),
        );
      })
    ]));

    fields.add(Row(children: <Widget>[
      Consumer<DataModel>(builder: (context, data, child) {
        return Expanded(
          child: DropdownButton(
            hint: Text('Please choose a location'),
            // Not necessary for Option 1
            value: data.days,
            onChanged: (newValue) {
              data.changeDays(newValue);
              _habit.days = newValue;
            },
            items: data.daysList.map((day) {
              return DropdownMenuItem(
                child: new Text(day),
                value: day,
              );
            }).toList(),
          ),
        );
      })
    ]));

    return fields;
  }

  if (habitToEdit != null) {
    _habit.id = habitToEdit.id;
    _habit.title = habitToEdit.title;
    _habit.description = habitToEdit.description;
    _habit.times = habitToEdit.times;
    _habit.days = habitToEdit.days;
  } else {
    _habit.times = "Morning";
    _habit.days = "Daily";
  }

  DataModel data = DataModel();
  data.changeTimes("Morning");
  data.changeDays("Daily");

  return showDialog<Habit>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('${habitToEdit != null ? "Edit" : "Create"} Habit Info:'),
        content: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              children: _fieldsForDialog(context),
            ),
          ),
        ),
        actions: _actionsForDialog(context),
      );
    },
  );
}
