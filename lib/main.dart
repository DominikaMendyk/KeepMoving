import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'state/progress_controller.dart';
import 'state/session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(
          create: (ctx) => ProgressController(prefs, ctx.read<FirestoreService>()),
        ),
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
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
