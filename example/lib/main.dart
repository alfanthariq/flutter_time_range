import 'package:flutter/material.dart';
import 'package:flutter_time_range/flutter_time_range.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final _messangerKey = GlobalKey<ScaffoldMessengerState>();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: _navigatorKey,
        scaffoldMessengerKey: _messangerKey,
        title: 'Test Time Range Picker',
        home: Scaffold(
          appBar: AppBar(
            title: Text("Time Range Picker"),
          ),
          body: TextButton(
            child: Text("Show Dialog"),
            onPressed: () {
              showTimeRangePicker(_navigatorKey.currentState.overlay.context);
            },
          ),
        ));
  }

  Future<void> showTimeRangePicker(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Choose event time"),
            content: TimeRangePicker(
              initialFromHour: DateTime.now().hour,
              initialFromMinutes: DateTime.now().minute,
              initialToHour: DateTime.now().hour,
              initialToMinutes: DateTime.now().minute,
              backText: "Back",
              nextText: "Next",
              cancelText: "Cancel",
              selectText: "Select",
              onSelect: (from, to) {
                _messangerKey.currentState.showSnackBar(
                    SnackBar(content: Text("From : $from, To : $to")));
                Navigator.pop(context);
              },
              onCancel: () => Navigator.pop(context),
            ),
          );
        });
  }
}
