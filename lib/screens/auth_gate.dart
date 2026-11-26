import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../state/progress_controller.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

/// Shows AuthScreen or HomeScreen depending on login state, and tells
/// ProgressController who is signed in so it can sync.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  StreamSubscription<User?>? _sub;

  @override
  void initState() {
    super.initState();
    final progress = context.read<ProgressController>();
    _sub = context
        .read<AuthService>()
        .authStateChanges
        .listen((user) => progress.bindUser(user?.uid));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: context.read<AuthService>().authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snap.data == null ? const AuthScreen() : const HomeScreen();
      },
    );
  }
}
