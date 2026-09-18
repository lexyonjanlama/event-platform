import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import 'create_event_screen.dart';
import 'manage_ticket_types_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  void _startListening() {
    final organizerId =
        context.read<AuthProvider>().appUser?.uid;

    if (organizerId != null) {
      context
          .read<EventProvider>()
          .startListening(organizerId);
    }
  }

  void _openCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateEventScreen(),
      ),
    );
  }

  void _openEditEvent(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateEventScreen(
          event: event,
        ),
      ),
    );
  }

  void _openTicketTypes(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageTicketTypesScreen(
          event: event,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Event event) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Event?'),
          content: Text(
            'Are you sure you want to delete "${event.title}"?\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    final eventProvider =
        context.read<EventProvider>();

    final success =
        await eventProvider.deleteEvent(event.eventId);

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Event deleted successfully.',
            ),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              eventProvider.errorMessage ??
                  'Unable to delete event.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider =
        context.watch<EventProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
      ),
      body: _buildBody(eventProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateEvent,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildBody(EventProvider eventProvider) {
    if (eventProvider.isLoading &&
        eventProvider.events.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (eventProvider.errorMessage != null &&
        eventProvider.events.isEmpty) {
      return _buildErrorState(eventProvider);
    }

    if (eventProvider.events.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _startListening();

        await Future.delayed(
          const Duration(milliseconds: 300),
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          100,
        ),
        itemCount: eventProvider.events.length,
        itemBuilder: (context, index) {
          final event =
              eventProvider.events[index];

          return _EventCard(
            event: event,
            onManageTickets: () {
              _openTicketTypes(event);
            },
            onEdit: () {
              _openEditEvent(event);
            },
            onDelete: () {
              _confirmDelete(event);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    EventProvider eventProvider,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              eventProvider.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _startListening,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 72,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 20),
            const Text(
              'No events yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first event to get started.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openCreateEvent,
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onManageTickets;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EventCard({
    required this.event,
    required this.onManageTickets,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(
                  status: event.status,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 16),

            _EventInfoRow(
              icon: Icons.category_outlined,
              text: event.category,
            ),

            const SizedBox(height: 8),

            _EventInfoRow(
              icon: Icons.calendar_today_outlined,
              text: _formatDate(event.date),
            ),

            const SizedBox(height: 8),

            _EventInfoRow(
              icon: Icons.access_time_outlined,
              text:
                  '${event.startTime} - ${event.endTime}',
            ),

            const SizedBox(height: 8),

            _EventInfoRow(
              icon: Icons.location_on_outlined,
              text: event.venue,
            ),

            const SizedBox(height: 8),

            _EventInfoRow(
              icon: Icons.people_outline,
              text:
                  '${event.capacity} capacity',
            ),

            const SizedBox(height: 16),

            const Divider(),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onManageTickets,
                    icon: const Icon(
                      Icons.confirmation_number_outlined,
                    ),
                    label: const Text('Tickets'),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text('Edit'),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete Event',
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey.shade200,
      ),
      child: Text(
        _formatStatus(status),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'published':
        return 'Published';
      case 'soldOut':
        return 'Sold Out';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'draft':
      default:
        return 'Draft';
    }
  }
}
