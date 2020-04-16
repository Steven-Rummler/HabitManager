import 'package:flutter/material.dart';
import 'package:habitmanager/database.dart';
import 'package:habitmanager/databaseModel.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habitmanager/data.dart';
import 'package:habitmanager/listHabit.dart';
import 'package:habitmanager/theme.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

import 'habitModel.dart';

Future selectNotification(String payload) async {
  print("Notification select with payload: $payload.");
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initializationSettings = InitializationSettings(
      initializationSettingsAndroid, initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  build(context) {
    return FutureBuilder(
      future: openHabitsDatabase(),
      builder: (context, AsyncSnapshot<Database> snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) =>
                    DatabaseHabitModel(snapshot.data) as HabitModel,
              ),
              ChangeNotifierProvider(
                create: (context) => DataModel(),
              ),
            ],
            child: MaterialApp(
              title: 'Habit Manager',
              theme: themeData,
              initialRoute: '/',
              routes: {
                '/': (context) => HabitListRoute(),
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            child: Center(
              child: Text('Unable to open database.'),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
