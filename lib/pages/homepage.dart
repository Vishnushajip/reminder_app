import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderApp extends StatefulWidget {
  @override
  _ReminderAppState createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
  String? selectedDay = 'Monday';
  TimeOfDay selectedTime = TimeOfDay.now();
  String? selectedActivity = 'Wake up';

  @override
  void initState() {
    super.initState();
    initializeNotifications();
  }

  Future<void> initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin!.initialize(initializationSettings);
  }

  Future<void> scheduleNotification(
      String day, TimeOfDay time, String activity) async {
    tz.initializeTimeZones();
    final location = tz.getLocation('Asia/Kolkata');
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      location,
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin!.zonedSchedule(
      0,
      'Reminder',
      'Time for $activity on $day!',
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: Text('Monday'),
              value: selectedDay,
              items: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? day) {
                if (day != null) {
                  setState(() {
                    selectedDay = day;
                  });
                }
              },
            ),

            SizedBox(height: 16),

            DropdownButton<TimeOfDay>(
              hint: Text('Select Time'),
              value: selectedTime,
              items: List.generate(
                24,
                    (hour) => DropdownMenuItem<TimeOfDay>(
                  value: TimeOfDay(hour: hour, minute: 0),
                  child: Text('$hour:00'),
                ),
              ),
              onChanged: (TimeOfDay? time) {
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
            ),

            SizedBox(height: 16),

            DropdownButton<String>(
              hint: Text('Select Activity'),
              value: selectedActivity,
              items: [
                'Wake up',
                'Go to gym',
                'Breakfast',
                'Meetings',
                'Lunch',
                'Quick nap',
                'Go to library',
                'Dinner',
                'Go to sleep',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? activity) {
                if (activity != null) {
                  setState(() {
                    selectedActivity = activity;
                  });
                }
              },
            ),

            SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                if (selectedDay != null &&
                    selectedTime != null &&
                    selectedActivity != null) {
                  scheduleNotification(
                      selectedDay!, selectedTime, selectedActivity!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Reminder set for $selectedDay at ${selectedTime.format(context)}'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select day, time, and activity.'),
                    ),
                  );
                }
              },
              child: Text('Set Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
