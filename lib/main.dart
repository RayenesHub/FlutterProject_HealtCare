import 'package:flutter/material.dart';
import 'package:healthcare/views/user/SignIn.dart';
import 'package:healthcare/views/user/SignUp.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // init notifications + permissions
  await NotificationService.instance.init();
  await NotificationService.instance.requestPermissions(
    // set to true only if you added SCHEDULE_EXACT_ALARM in AndroidManifest and want precise alarms
    requestExactAlarm: false,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WellCare',
      theme: ThemeData(
        // If you’re on Material 3, prefer colorScheme; this still works fine:
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // Start page
      home: _LifecycleGate(child: SignIn()),
      // home: const TestNotificationPage(),


      // Routes
      routes: {
        '/signUp': (context) => SignUp(),
      },
    );
  }
}

/// A small wrapper to listen to app lifecycle and schedule/cancel reminders.
class _LifecycleGate extends StatefulWidget {
  final Widget child;
  const _LifecycleGate({super.key, required this.child});

  @override
  State<_LifecycleGate> createState() => _LifecycleGateState();
}

class _LifecycleGateState extends State<_LifecycleGate>
    with WidgetsBindingObserver {
  // final Duration _inactivityDelay = const Duration(hours: 1);
  final Duration _inactivityDelay = const Duration(minutes: 1);


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      // User returned -> cancel pending reminder
      NotificationService.instance.cancelReminder();
      break;

    case AppLifecycleState.inactive:
    case AppLifecycleState.paused:
    case AppLifecycleState.hidden: // NEW in recent Flutter versions
      // App not visible / backgrounded -> schedule reminder
      NotificationService.instance
          .scheduleInactivityReminder(const Duration(minutes: 1));
      break;

    case AppLifecycleState.detached:
      // App is terminating; nothing special here
      break;
  }
}

  @override
  Widget build(BuildContext context) => widget.child;
}
