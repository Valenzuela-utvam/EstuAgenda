import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAccountInfo extends StatelessWidget {
  const UserAccountInfo({
    super.key,
    this.horizontal = false,
    this.avatarRadius = 36,
  });

  final bool horizontal;
  final double avatarRadius;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final email = user?.email ?? '';
        final displayName = user?.displayName?.trim();
        final name = displayName != null && displayName.isNotEmpty
            ? displayName
            : email.contains('@')
            ? email.substring(0, email.indexOf('@'))
            : 'Usuario';
        final initial = name.isEmpty
            ? '?'
            : name.characters.first.toUpperCase();
        final textColor = const Color(0xFF124B51);
        final nameWidget = Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: horizontal ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: horizontal ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        );
        final emailWidget = Text(
          email.isEmpty ? 'Correo no disponible' : email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: horizontal ? TextAlign.left : TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        );
        final avatar = CircleAvatar(
          radius: avatarRadius,
          backgroundColor: const Color(0xFF1D969F).withValues(alpha: 0.15),
          child: Text(
            initial,
            style: TextStyle(
              color: const Color(0xFF1D969F),
              fontSize: avatarRadius,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        if (horizontal) {
          return Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [nameWidget, emailWidget],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            avatar,
            const SizedBox(height: 10),
            nameWidget,
            emailWidget,
          ],
        );
      },
    );
  }
}
