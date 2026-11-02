import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'state/progress_controller.dart';
import 'state/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final notifications = NotificationService();
  await notifications.init();

  runApp(KeepMovingApp(prefs: prefs, notifications: notifications));
}

class KeepMovingApp extends StatelessWidget {
  const KeepMovingApp({
    super.key,
    required this.prefs,
    required this.notifications,
  });

  final SharedPreferences prefs;
  final NotificationService notifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProgressController(prefs)),
        ChangeNotifierProvider(
          create: (_) => SessionController(onReminder: notifications.showReminder),
        ),
      ],
      child: MaterialApp(
        title: 'KeepMoving',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
