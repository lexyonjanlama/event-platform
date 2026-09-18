import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/theme_provider.dart';
import 'check_in_screen.dart';
import 'create_event_screen.dart';
import 'my_events_screen.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() =>
      _OrganizerDashboardState();
}

class _OrganizerDashboardState
    extends State<OrganizerDashboard> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider =
          context.read<AuthProvider>();
      final eventProvider =
          context.read<EventProvider>();

      final organizerId =
          authProvider.appUser?.uid;

      if (organizerId != null) {
        eventProvider.startListening(
          organizerId,
        );
      }
    });
  }

  void _openMyEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyEventsScreen(),
      ),
    );
  }

  void _openCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateEventScreen(),
      ),
    );
  }

  void _openCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CheckInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();
    final eventProvider =
        context.watch<EventProvider>();
    final themeProvider =
        context.watch<ThemeProvider>();

    final user = authProvider.appUser;

    final eventCount =
        eventProvider.events.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Organizer Dashboard',
        ),
        actions: [
          IconButton(
            tooltip: themeProvider.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
            onPressed: () {
              context
                  .read<ThemeProvider>()
                  .toggleTheme();
            },
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () async {
              await context
                  .read<AuthProvider>()
                  .signOut();
            },
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome, ${user?.name ?? 'Organizer'} 👋',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your events and track your attendees.',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon:
                          Icons.event_outlined,
                      title: 'My Events',
                      value:
                          eventCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _StatCard(
                      icon:
                          Icons.people_outline,
                      title: 'Registrations',
                      value: '0',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _openMyEvents,
                icon: const Icon(
                  Icons.event_note_outlined,
                ),
                label: const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Text(
                    'My Events',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openCreateEvent,
                icon: const Icon(
                  Icons.add,
                ),
                label: const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                  child: Text(
                    'Create Event',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Quick Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.analytics_outlined,
                  ),
                  title: const Text(
                    'Event Analytics',
                  ),
                  subtitle: const Text(
                    'Track registrations and attendance.',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Analytics will be available soon.',
                        ),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.qr_code_scanner,
                  ),
                  title: const Text(
                    'Check-in',
                  ),
                  subtitle: const Text(
                    'Scan attendee tickets at your events.',
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: _openCheckIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 30,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}