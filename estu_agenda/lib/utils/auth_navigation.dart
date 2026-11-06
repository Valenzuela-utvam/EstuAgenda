import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

Future<void> cerrarSesion(BuildContext context) async {
  try {
    await FirebaseAuth.instance.signOut();
  } on FirebaseAuthException catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message ?? 'No se pudo cerrar la sesión.'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}
