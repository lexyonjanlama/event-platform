import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/ticket.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import 'ticket_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() =>
      _MyTicketsScreenState();
}

class _MyTicketsScreenState
    extends State<MyTicketsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user =
          context.read<AuthProvider>().appUser;

      if (user != null) {
        context
            .read<TicketProvider>()
            .startListeningToParticipantTickets(
              user.uid,
            );
      }
    });
  }

  void _openTicket(Ticket ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TicketScreen(
          ticket: ticket,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticketProvider =
        context.watch<TicketProvider>();

    final tickets = ticketProvider.tickets;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Tickets',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final user =
                context.read<AuthProvider>().appUser;

            if (user != null) {
              context
                  .read<TicketProvider>()
                  .startListeningToParticipantTickets(
                    user.uid,
                  );
            }

            await Future.delayed(
              const Duration(
                milliseconds: 500,
              ),
            );
          },
          child: ticketProvider.isLoading &&
                  tickets.isEmpty
              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )
              : ticketProvider.errorMessage !=
                          null &&
                      tickets.isEmpty
                  ? _ErrorState(
                      message: ticketProvider
                          .errorMessage!,
                      onRetry: () {
                        final user = context
                            .read<AuthProvider>()
                            .appUser;

                        if (user != null) {
                          context
                              .read<TicketProvider>()
                              .startListeningToParticipantTickets(
                                user.uid,
                              );
                        }
                      },
                    )
                  : tickets.isEmpty
                      ? const _EmptyTicketsState()
                      : ListView.separated(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(
                            20,
                            20,
                            20,
                            32,
                          ),
                          itemCount:
                              tickets.length,
                          separatorBuilder:
                              (_, _) =>
                                  const SizedBox(
                            height: 14,
                          ),
                          itemBuilder:
                              (context, index) {
                            final ticket =
                                tickets[index];

                            return _TicketCard(
                              ticket: ticket,
                              onTap: () {
                                _openTicket(
                                  ticket,
                                );
                              },
                            );
                          },
                        ),
        ),
      ),
    );
  }
}

// ============================================================================
// TICKET CARD
// ============================================================================

class _TicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        ticket.createdAt != null
            ? DateFormat(
                'dd MMM yyyy, hh:mm a',
              ).format(ticket.createdAt!)
            : 'Unknown date';

    final statusColor =
        _statusColor(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons
                          .confirmation_number_rounded,
                      color: Theme.of(context)
                          .colorScheme
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
                          ticket.ticketTypeName,
                          maxLines: 1,
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
                          'Rs. ${ticket.price.toStringAsFixed(0)}',
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
                  _StatusBadge(
                    status: ticket.status,
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Divider(),

              const SizedBox(height: 14),

              _TicketInfoRow(
                icon:
                    Icons.confirmation_number_outlined,
                label: 'Ticket ID',
                value: ticket.ticketId,
              ),

              const SizedBox(height: 10),

              _TicketInfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Participant',
                value: ticket.participantName,
              ),

              const SizedBox(height: 10),

              _TicketInfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'Registered',
                value: formattedDate,
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.qr_code_2_rounded,
                  ),
                  label: const Text(
                    'View Ticket & QR',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    switch (ticket.status) {
      case 'active':
        return colorScheme.primary;

      case 'used':
        return colorScheme.secondary;

      case 'cancelled':
        return colorScheme.error;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusBadge({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty
        ? 'Unknown'
        : status[0].toUpperCase() +
            status.substring(1);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

// ============================================================================
// TICKET INFO ROW
// ============================================================================

class _TicketInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TicketInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow:
                TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EMPTY STATE
// ============================================================================

class _EmptyTicketsState
    extends StatelessWidget {
  const _EmptyTicketsState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  0.65,
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons
                        .confirmation_number_outlined,
                    size: 72,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No tickets yet',
                    textAlign:
                        TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Register for an event and your tickets will appear here.',
                    textAlign:
                        TextAlign.center,
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
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// ERROR STATE
// ============================================================================

class _ErrorState
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context).size.height *
                  0.65,
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.all(32),
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
                    'Something went wrong',
                    textAlign:
                        TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    textAlign:
                        TextAlign.center,
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
          ),
        ),
      ],
    );
  }
}