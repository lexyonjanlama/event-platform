
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/ticket_type.dart';
import '../../providers/ticket_type_provider.dart';
import 'ticket_checkout_screen.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() =>
      _EventDetailsScreenState();
}

class _EventDetailsScreenState
    extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TicketTypeProvider>()
          .startListening(widget.event.eventId);
    });
  }

  void _showTicketSelection(
    BuildContext context,
    TicketType ticketType,
  ) {
    int quantity = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            final total =
                ticketType.price * quantity;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  20 +
                      MediaQuery.of(context)
                          .viewInsets
                          .bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Ticket',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 20),

                    // Ticket information
                    Card(
                      elevation: 0,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration:
                                  BoxDecoration(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius:
                                    BorderRadius
                                        .circular(12),
                              ),
                              child: Icon(
                                Icons
                                    .confirmation_number_rounded,
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    ticketType.name,
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    'Rs. ${ticketType.price.toStringAsFixed(0)} per ticket',
                                    style: Theme.of(
                                      context,
                                    )
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme
                                              .of(
                                            context,
                                          )
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Quantity',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Number of tickets',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge,
                        ),
                        Container(
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .outline,
                            ),
                            borderRadius:
                                BorderRadius
                                    .circular(12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed:
                                    quantity > 1
                                        ? () {
                                            setModalState(
                                              () {
                                                quantity--;
                                              },
                                            );
                                          }
                                        : null,
                                icon: const Icon(
                                  Icons.remove,
                                ),
                              ),
                              SizedBox(
                                width: 36,
                                child: Text(
                                  '$quantity',
                                  textAlign:
                                      TextAlign
                                          .center,
                                  style: Theme.of(
                                    context,
                                  )
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                ),
                              ),
                              IconButton(
                                onPressed:
                                    quantity <
                                            ticketType
                                                .remaining
                                        ? () {
                                            setModalState(
                                              () {
                                                quantity++;
                                              },
                                            );
                                          }
                                        : null,
                                icon: const Icon(
                                  Icons.add,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Divider(),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Rs. ${total.toStringAsFixed(0)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight:
                                    FontWeight.bold,
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .primary,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  TicketCheckoutScreen(
                                event: widget.event,
                                ticketType:
                                    ticketType,
                                quantity: quantity,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    final ticketProvider =
        context.watch<TicketTypeProvider>();

    final ticketTypes = ticketProvider.ticketTypes
        .where(
          (ticket) =>
              ticket.eventId == event.eventId,
        )
        .toList();

    final formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
    ).format(event.date);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ==================================================
            // BANNER
            // ==================================================

            SliverAppBar(
              pinned: true,
              expandedHeight: 240,
              backgroundColor:
                  Theme.of(context)
                      .colorScheme
                      .surface,
              foregroundColor:
                  Theme.of(context)
                      .colorScheme
                      .onSurface,
              flexibleSpace:
                  FlexibleSpaceBar(
                background: event.bannerUrl
                        .trim()
                        .isNotEmpty
                    ? Image.network(
                        event.bannerUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const
                              _BannerPlaceholder();
                        },
                      )
                    : const
                        _BannerPlaceholder(),
              ),
            ),

            // ==================================================
            // EVENT INFORMATION
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  8,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (event.category
                        .trim()
                        .isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius:
                              BorderRadius
                                  .circular(20),
                        ),
                        child: Text(
                          event.category
                              .toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                        ),
                      ),

                    const SizedBox(height: 14),

                    Text(
                      event.title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 20),

                    _EventDetailRow(
                      icon:
                          Icons.calendar_today_rounded,
                      title: 'Date',
                      value: formattedDate,
                    ),

                    const SizedBox(height: 14),

                    _EventDetailRow(
                      icon:
                          Icons.access_time_rounded,
                      title: 'Time',
                      value:
                          '${event.startTime} - ${event.endTime}',
                    ),

                    const SizedBox(height: 14),

                    _EventDetailRow(
                      icon:
                          Icons.location_on_rounded,
                      title: 'Venue',
                      value: event.venue,
                    ),

                    const SizedBox(height: 14),

                    _EventDetailRow(
                      icon:
                          Icons.people_alt_rounded,
                      title: 'Capacity',
                      value:
                          '${event.capacity} people',
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // DESCRIPTION
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About this event',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      event.description
                              .trim()
                              .isNotEmpty
                          ? event.description
                          : 'No description provided.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            height: 1.5,
                            color: Theme.of(
                              context,
                            )
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // TICKET SECTION
            // ==================================================

            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  28,
                  20,
                  12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Available Tickets',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),
                    const SizedBox(width: 8),
                    if (!ticketProvider.isLoading &&
                        ticketTypes.isNotEmpty)
                      Text(
                        '${ticketTypes.length}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Theme.of(
                                context,
                              )
                                  .colorScheme
                                  .primary,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // LOADING
            // ==================================================

            if (ticketProvider.isLoading &&
                ticketTypes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child:
                      CircularProgressIndicator(),
                ),
              )

            // ==================================================
            // ERROR
            // ==================================================

            else if (
                ticketProvider.errorMessage !=
                        null &&
                    ticketTypes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _TicketErrorState(
                  message:
                      ticketProvider.errorMessage!,
                ),
              )

            // ==================================================
            // NO TICKETS
            // ==================================================

            else if (ticketTypes.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _NoTicketsState(),
              )

            // ==================================================
            // TICKET LIST
            // ==================================================

            else
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  32,
                ),
                sliver: SliverList.separated(
                  itemCount: ticketTypes.length,
                  separatorBuilder:
                      (_, _) =>
                          const SizedBox(
                    height: 12,
                  ),
                  itemBuilder:
                      (context, index) {
                    return _TicketCard(
                      ticketType:
                          ticketTypes[index],
                      onSelect: () {
                        _showTicketSelection(
                          context,
                          ticketTypes[index],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// EVENT DETAIL ROW
// ================================================================

class _EventDetailRow
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _EventDetailRow({
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
        const SizedBox(width: 14),
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

// ================================================================
// TICKET CARD
// ================================================================

class _TicketCard
    extends StatelessWidget {
  final TicketType ticketType;
  final VoidCallback onSelect;

  const _TicketCard({
    required this.ticketType,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable =
        ticketType.isActive &&
        !ticketType.isSoldOut;

    return Card(
      elevation: 0,
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
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticketType.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      if (ticketType.description
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          ticketType.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                )
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Rs. ${ticketType.price.toStringAsFixed(0)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(
                        fontWeight:
                            FontWeight.bold,
                        color: Theme.of(context)
                            .colorScheme
                            .primary,
                      ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons
                      .confirmation_number_outlined,
                  size: 18,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  ticketType.isSoldOut
                      ? 'Sold out'
                      : '${ticketType.remaining} remaining',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium,
                ),
                const Spacer(),
                _TicketStatusBadge(
                  ticketType: ticketType,
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed:
                    isAvailable ? onSelect : null,
                child: Text(
                  isAvailable
                      ? 'Select Ticket'
                      : ticketType.isSoldOut
                          ? 'Sold Out'
                          : 'Unavailable',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// TICKET STATUS BADGE
// ================================================================

class _TicketStatusBadge
    extends StatelessWidget {
  final TicketType ticketType;

  const _TicketStatusBadge({
    required this.ticketType,
  });

  @override
  Widget build(BuildContext context) {
    String text;

    if (!ticketType.isActive) {
      text = 'Inactive';
    } else if (ticketType.isSoldOut) {
      text = 'Sold Out';
    } else {
      text = 'Available';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(
              fontWeight:
                  FontWeight.bold,
            ),
      ),
    );
  }
}

// ================================================================
// BANNER PLACEHOLDER
// ================================================================

class _BannerPlaceholder
    extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.event_rounded,
          size: 64,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
      ),
    );
  }
}

// ================================================================
// NO TICKETS STATE
// ================================================================

class _NoTicketsState
    extends StatelessWidget {
  const _NoTicketsState();

  @override
  Widget build(BuildContext context) {
    return Center(
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
              size: 60,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No tickets available',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'This event does not have any ticket types yet.',
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

// ================================================================
// TICKET ERROR STATE
// ================================================================

class _TicketErrorState
    extends StatelessWidget {
  final String message;

  const _TicketErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load tickets',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                    fontWeight:
                        FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
