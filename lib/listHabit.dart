import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitmanager/addHabit.dart';
import 'package:habitmanager/habit.dart';
import 'package:habitmanager/habitModel.dart';
import 'package:provider/provider.dart';

class HabitListRoute extends StatelessWidget {
  _habitList(BuildContext context, HabitModel model) {
    return FutureBuilder(
        future: model.habits(),
        builder: (context, AsyncSnapshot<List<Habit>> snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(height: 0),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) =>
                  _habitTile(context, model, snapshot.data[index]),
            );
          } else {
            return Text('Loading...');
          }
        });
  }

  Future<void> habitRecordDialog(
      BuildContext context, HabitModel model, Habit habit) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: new Text('Record Habit'),
              content: new Text('Did you successfully keep this habit today?'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      model.record(habit.id, true);
                      Navigator.of(context).pop(null);
                    },
                    child: new Text('YES')),
                new FlatButton(
                    onPressed: () {
                      model.record(habit.id, false);
                      Navigator.of(context).pop(null);
                    },
                    child: new Text('NO')),
              ],
            ));
  }

  Future<bool> editOrDeleteDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new AlertDialog(
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('EDIT')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: new Text('DELETE')),
              ],
            ));
  }

  Future<bool> confirmDeleteDialog(BuildContext context) {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) => new AlertDialog(
              title: new Text('Warning!'),
              content: new Text(
                  'Are you sure you would like to delete this habit?  This action cannot be undone.'),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: new Text('DELETE')),
                new FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: new Text('CANCEL')),
              ],
            ));
  }

  Widget _habitTile(BuildContext context, HabitModel model, Habit habit) {
    return ListTile(
      leading: Icon(Icons.date_range),
      title: Text('${habit.title}: ${habit.description}'),
      subtitle: Text(
          '${habit.days} in the ${habit.times}: ${(habit.percent != null) ? habit.percent.toStringAsFixed(1) + "% kept" : "not started"}'),
      onTap: () async {
        await habitRecordDialog(context, model, habit);
      },
      onLongPress: () async {
        bool edit = false;
        edit = await editOrDeleteDialog(context);
        if (edit) {
          var editedHabit = await addOrEditHabitDialog(context, habit);

          if (editedHabit != null) {
            model.editHabit(editedHabit);
          }
        } else {
          bool delete = false;
          delete = await confirmDeleteDialog(context);
          if (delete) model.deleteHabit(habit.id);
        }
      },
    );
  }

  build(context) {
    return Consumer<HabitModel>(builder: (context, model, child) {
      return Scaffold(
          appBar: AppBar(title: Text("Habit Manager")),
          body: Center(child: _habitList(context, model)),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var habit = await addOrEditHabitDialog(context);

              if (habit != null) {
                model.addHabit(habit);
              }

              //Display a notification
              FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
                  FlutterLocalNotificationsPlugin();
              var androidPlatformChannelSpecifics = AndroidNotificationDetails(
                  'your channel id',
                  'your channel name',
                  'your channel description',
                  importance: Importance.Max,
                  priority: Priority.High,
                  ticker: 'ticker');
              var iOSPlatformChannelSpecifics = IOSNotificationDetails();
              var platformChannelSpecifics = NotificationDetails(
                  androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
              await flutterLocalNotificationsPlugin.show(
                  0, 'plain title', 'plain body', platformChannelSpecifics,
                  payload: 'item x');
            },
            tooltip: 'New Habit',
            elevation: 0,
            child: Icon(Icons.add),
          ));
    });
  }
}
