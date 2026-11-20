import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/horario_screen.dart';
import 'wearable/wearable_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MiApp());
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EsTuAgenda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1D969F)),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  late final Stream<User?> _authState = FirebaseAuth.instance
      .authStateChanges();
  final WearableSyncService _wearableSync = WearableSyncService();
  String? _wearableUserId;
  bool _hasSyncedAuthState = false;

  void _syncWearableAccount(String? userId) {
    if (_hasSyncedAuthState && userId == _wearableUserId) return;
    _hasSyncedAuthState = true;
    _wearableUserId = userId;
    unawaited(_wearableSync.setUser(userId));
  }

  @override
  void dispose() {
    unawaited(_wearableSync.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('No se pudo verificar la sesión de usuario.'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        _syncWearableAccount(user?.uid);
        return user == null ? const LoginScreen() : const HorarioScreen();
      },
    );
  }
}
