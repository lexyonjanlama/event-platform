import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ticket.dart';

class TicketScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketScreen({
    super.key,
    required this.ticket,
  });

  Color _statusColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

  String _statusLabel() {
    if (ticket.status.isEmpty) {
      return 'Unknown';
    }

    return ticket.status[0].toUpperCase() +
        ticket.status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Ticket',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            32,
          ),
          child: Column(
            children: [
              // Ticket header
              Card(
                elevation: 0,
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.confirmation_number_rounded,
                          size: 32,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Event Ticket',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        ticket.ticketTypeName,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius:
                              BorderRadius.circular(24),
                        ),
                        child: Text(
                          _statusLabel(),
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // QR Code
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Your QR Code',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Show this QR code at the event entrance.',
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

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outlineVariant,
                          ),
                        ),
                        child: QrImageView(
                          data: ticket.qrCode,
                          version: QrVersions.auto,
                          size: 240,
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        ticket.qrCode,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Ticket information
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ticket Information',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 18),

                      _InfoRow(
                        icon: Icons.person_outline_rounded,
                        label: 'Participant',
                        value: ticket.participantName,
                      ),

                      const SizedBox(height: 14),

                      _InfoRow(
                        icon:
                            Icons.confirmation_number_outlined,
                        label: 'Ticket Type',
                        value: ticket.ticketTypeName,
                      ),

                      const SizedBox(height: 14),

                      _InfoRow(
                        icon: Icons.payments_outlined,
                        label: 'Price',
                        value:
                            'Rs. ${ticket.price.toStringAsFixed(0)}',
                      ),

                      const SizedBox(height: 14),

                      _InfoRow(
                        icon: Icons.fingerprint_rounded,
                        label: 'Ticket ID',
                        value: ticket.ticketId,
                      ),

                      const SizedBox(height: 14),

                      _InfoRow(
                        icon: Icons.event_outlined,
                        label: 'Event ID',
                        value: ticket.eventId,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Check-in information
              if (ticket.checkedInAt != null)
                Card(
                  elevation: 0,
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary,
                    ),
                    title: const Text(
                      'Checked In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Checked in at ${_formatDate(ticket.checkedInAt!)}',
                    ),
                  ),
                ),

              if (ticket.status == 'active')
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                    'Keep this QR code ready for check-in.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : date.hour > 12
            ? date.hour - 12
            : date.hour;

    final minute =
        date.minute.toString().padLeft(2, '0');

    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '$hour:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
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
          size: 20,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 90,
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
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}