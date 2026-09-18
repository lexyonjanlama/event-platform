import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import 'qr_scanner_screen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() =>
      _CheckInScreenState();
}

class _CheckInScreenState
    extends State<CheckInScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          context.read<AuthProvider>().appUser;

      if (user != null) {
        context
            .read<EventProvider>()
            .startListening(user.uid);
      }
    });
  }

  void _openScanner(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          event: event,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider =
        context.watch<EventProvider>();

    final events = eventProvider.events;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Check-in',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: eventProvider.isLoading &&
                events.isEmpty
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : eventProvider.errorMessage != null &&
                    events.isEmpty
                ? _ErrorState(
                    message:
                        eventProvider.errorMessage!,
                    onRetry: () {
                      final user = context
                          .read<AuthProvider>()
                          .appUser;

                      if (user != null) {
                        context
                            .read<EventProvider>()
                            .startListening(user.uid);
                      }
                    },
                  )
                : events.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding:
                            const EdgeInsets.all(20),
                        itemCount: events.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 14),
                        itemBuilder:
                            (context, index) {
                          final event =
                              events[index];

                          return _EventCheckInCard(
                            event: event,
                            onTap: () {
                              _openScanner(event);
                            },
                          );
                        },
                      ),
      ),
    );
  }
}

class _EventCheckInCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCheckInCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.event_rounded,
                      color: colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.category,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${event.date.day.toString().padLeft(2, '0')}/'
                    '${event.date.month.toString().padLeft(2, '0')}/'
                    '${event.date.year}',
                  ),
                  const SizedBox(width: 20),
                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${event.startTime} - ${event.endTime}',
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      event.venue,
                      overflow:
                          TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.qr_code_scanner_rounded,
                  ),
                  label: const Text(
                    'Start Check-in',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'No events available',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create an event first before starting check-in.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
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

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load events',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}