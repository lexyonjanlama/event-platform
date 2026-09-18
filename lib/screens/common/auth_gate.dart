import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';
import '../organizer/organizer_dashboard.dart';
import '../participant/participant_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    final user = authProvider.appUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Unable to load your profile.',
          ),
        ),
      );
    }

    switch (user.role) {
      case 'organizer':
        return const OrganizerDashboard();

      case 'admin':
        return const AdminDashboard();

      case 'participant':
      default:
        return const ParticipantHome();
    }
  }
}