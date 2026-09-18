import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/ticket_type.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';

class TicketCheckoutScreen extends StatefulWidget {
  final Event event;
  final TicketType ticketType;
  final int quantity;

  const TicketCheckoutScreen({
    super.key,
    required this.event,
    required this.ticketType,
    required this.quantity,
  });

  @override
  State<TicketCheckoutScreen> createState() =>
      _TicketCheckoutScreenState();
}

class _TicketCheckoutScreenState
    extends State<TicketCheckoutScreen> {
  bool _isRegistering = false;

  Future<void> _confirmRegistration() async {
    if (_isRegistering) {
      return;
    }

    final authProvider =
        context.read<AuthProvider>();

    final ticketProvider =
        context.read<TicketProvider>();

    final user = authProvider.appUser;

    if (user == null) {
      _showMessage(
        'Unable to identify your account. Please log in again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    final tickets =
        await ticketProvider.registerTickets(
      ticketType: widget.ticketType,
      quantity: widget.quantity,
      participantId: user.uid,
      participantName: user.name,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isRegistering = false;
    });

    if (tickets == null || tickets.isEmpty) {
      _showMessage(
        ticketProvider.errorMessage ??
            'Unable to complete registration.',
        isError: true,
      );
      return;
    }

    await _showRegistrationSuccess(
      tickets.length,
    );
  }

  Future<void> _showRegistrationSuccess(
    int ticketCount,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Registration Successful',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(dialogContext)
                      .colorScheme
                      .primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 44,
                  color: Theme.of(dialogContext)
                      .colorScheme
                      .onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ticketCount == 1
                    ? 'Your ticket has been created successfully.'
                    : '$ticketCount tickets have been created successfully.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You can now view your ticket and QR code from My Tickets.',
                textAlign: TextAlign.center,
                style: Theme.of(dialogContext)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Theme.of(dialogContext)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pop(context);
              },
              child: const Text(
                'View My Tickets',
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context)
                  .colorScheme
                  .error
              : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.ticketType.price * widget.quantity;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // ============================================================
              // EVENT
              // ============================================================

              Text(
                'Event',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.event.title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 6),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.event.startTime} - ${widget.event.endTime}',
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
                ],
              ),

              const SizedBox(height: 24),

              // ============================================================
              // TICKET SUMMARY
              // ============================================================

              Text(
                'Ticket Summary',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius:
                                  BorderRadius.circular(12),
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
                                  widget.ticketType.name,
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
                                  'Rs. ${widget.ticketType.price.toStringAsFixed(0)} per ticket',
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      const Divider(),

                      const SizedBox(height: 12),

                      _SummaryRow(
                        label: 'Ticket Type',
                        value:
                            widget.ticketType.name,
                      ),

                      const SizedBox(height: 12),

                      _SummaryRow(
                        label: 'Price per ticket',
                        value:
                            'Rs. ${widget.ticketType.price.toStringAsFixed(0)}',
                      ),

                      const SizedBox(height: 12),

                      _SummaryRow(
                        label: 'Quantity',
                        value:
                            '${widget.quantity}',
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      const SizedBox(height: 12),

                      _SummaryRow(
                        label: 'Total Amount',
                        value:
                            'Rs. ${total.toStringAsFixed(0)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ============================================================
              // EVENT INFORMATION
              // ============================================================

              Text(
                'Event Information',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _InformationRow(
                        icon:
                            Icons.location_on_rounded,
                        title: 'Venue',
                        value:
                            widget.event.venue,
                      ),
                      const SizedBox(height: 14),
                      _InformationRow(
                        icon: Icons
                            .confirmation_number_rounded,
                        title: 'Tickets',
                        value:
                            '${widget.quantity} ${widget.quantity == 1 ? 'ticket' : 'tickets'}',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ============================================================
              // PAYMENT INFORMATION
              // ============================================================

              Text(
                'Payment',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),

              const SizedBox(height: 12),

              Card(
                elevation: 0,
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons
                            .account_balance_wallet_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Simulated Payment',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This project uses simulated payment. '
                              'No real money will be charged.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ============================================================
              // TOTAL
              // ============================================================

              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total to Pay',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'Rs. ${total.toStringAsFixed(0)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ============================================================
              // CONFIRM REGISTRATION
              // ============================================================

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _isRegistering
                      ? null
                      : _confirmRegistration,
                  icon: _isRegistering
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons
                              .check_circle_outline_rounded,
                        ),
                  label: Text(
                    _isRegistering
                        ? 'Registering...'
                        : 'Confirm Registration',
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'By continuing, you confirm your ticket selection.',
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
}

// ============================================================================
// SUMMARY ROW
// ============================================================================

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(
                fontWeight: isTotal
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isTotal
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                      : null,
                ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// INFORMATION ROW
// ============================================================================

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(
                      fontWeight:
                          FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}