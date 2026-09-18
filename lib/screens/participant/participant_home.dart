
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/theme_provider.dart';
import 'event_details_screen.dart';
import 'my_tickets_screen.dart';

class ParticipantHome extends StatefulWidget {
  const ParticipantHome({super.key});

  @override
  State<ParticipantHome> createState() =>
      _ParticipantHomeState();
}

class _ParticipantHomeState
    extends State<ParticipantHome> {
  final TextEditingController _searchController =
      TextEditingController();

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<EventProvider>()
          .startListeningToPublishedEvents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filteredEvents(
    List<Event> events,
  ) {
    final searchText =
        _searchController.text.trim().toLowerCase();

    return events.where((event) {
      final matchesSearch =
          searchText.isEmpty ||
              event.title
                  .toLowerCase()
                  .contains(searchText) ||
              event.description
                  .toLowerCase()
                  .contains(searchText) ||
              event.venue
                  .toLowerCase()
                  .contains(searchText);

      final matchesCategory =
          _selectedCategory == 'All' ||
              event.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _categories(
    List<Event> events,
  ) {
    final categories = events
        .map((event) => event.category)
        .where(
          (category) => category.isNotEmpty,
        )
        .toSet()
        .toList();

    categories.sort();

    return ['All', ...categories];
  }

  void _openEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventDetailsScreen(
          event: event,
        ),
      ),
    );
  }

  void _openMyTickets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const MyTicketsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider =
        context.watch<AuthProvider>();

    final user = authProvider.appUser;

    final eventProvider =
        context.watch<EventProvider>();

    final themeProvider =
        context.watch<ThemeProvider>();

    final events =
        eventProvider.publishedEvents;

    final filteredEvents =
        _filteredEvents(events);

    final categories =
        _categories(events);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Platform',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
            tooltip: 'My Tickets',
            onPressed: _openMyTickets,
            icon: const Icon(
              Icons.confirmation_number_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              context
                  .read<AuthProvider>()
                  .signOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context
                .read<EventProvider>()
                .startListeningToPublishedEvents();

            await Future.delayed(
              const Duration(
                milliseconds: 500,
              ),
            );
          },
          child: CustomScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    24,
                    20,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${user?.name ?? 'Participant'} 👋',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Discover events happening around you.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: TextField(
                    controller:
                        _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Search events...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                      ),
                      suffixIcon:
                          _searchController
                                  .text
                                  .isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    _searchController
                                        .clear();

                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons
                                        .clear_rounded,
                                  ),
                                )
                              : null,
                      filled: true,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    bottom: 8,
                  ),
                  child: SizedBox(
                    height: 42,
                    child: ListView.separated(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      scrollDirection:
                          Axis.horizontal,
                      itemCount:
                          categories.length,
                      separatorBuilder:
                          (_, _) =>
                              const SizedBox(
                        width: 8,
                      ),
                      itemBuilder:
                          (context, index) {
                        final category =
                            categories[index];

                        final isSelected =
                            category ==
                                _selectedCategory;

                        return ChoiceChip(
                          label:
                              Text(category),
                          selected:
                              isSelected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory =
                                  category;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    12,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Upcoming Events',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight:
                                  FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (!eventProvider.isLoading)
                        Text(
                          '${filteredEvents.length}',
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
              if (eventProvider.isLoading &&
                  events.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child:
                        CircularProgressIndicator(),
                  ),
                )
              else if (
                  eventProvider.errorMessage !=
                          null &&
                      events.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _ErrorState(
                    message: eventProvider
                        .errorMessage!,
                    onRetry: () {
                      context
                          .read<EventProvider>()
                          .startListeningToPublishedEvents();
                    },
                  ),
                )
              else if (filteredEvents.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    hasSearch:
                        _searchController
                                .text
                                .trim()
                                .isNotEmpty ||
                            _selectedCategory !=
                                'All',
                  ),
                )
              else
                SliverPadding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    24,
                  ),
                  sliver:
                      SliverList.separated(
                    itemCount:
                        filteredEvents.length,
                    separatorBuilder:
                        (_, _) =>
                            const SizedBox(
                      height: 16,
                    ),
                    itemBuilder:
                        (context, index) {
                      final event =
                          filteredEvents[index];

                      return _EventCard(
                        event: event,
                        onTap: () {
                          _openEventDetails(
                            event,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat(
      'EEE, dd MMM yyyy',
    ).format(event.date);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8,
              child: event.bannerUrl
                      .trim()
                      .isNotEmpty
                  ? Image.network(
                      event.bannerUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const _BannerPlaceholder();
                      },
                    )
                  : const _BannerPlaceholder(),
            ),
            Padding(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  if (event.category
                      .trim()
                      .isNotEmpty)
                    Text(
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
                                .primary,
                            fontWeight:
                                FontWeight.bold,
                            letterSpacing:
                                0.8,
                          ),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _EventInfoRow(
                    icon:
                        Icons.calendar_today_rounded,
                    text: formattedDate,
                  ),
                  const SizedBox(height: 8),
                  _EventInfoRow(
                    icon:
                        Icons.access_time_rounded,
                    text:
                        '${event.startTime} - ${event.endTime}',
                  ),
                  const SizedBox(height: 8),
                  _EventInfoRow(
                    icon:
                        Icons.location_on_rounded,
                    text: event.venue,
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onTap,
                      child: const Text(
                        'View Details',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventInfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfoRow({
    required this.icon,
    required this.text,
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
        Expanded(
          child: Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ),
      ],
    );
  }
}

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
          size: 56,
          color: Theme.of(context)
              .colorScheme
              .onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyState
    extends StatelessWidget {
  final bool hasSearch;

  const _EmptyState({
    required this.hasSearch,
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
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.event_busy_rounded,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch
                  ? 'No events found'
                  : 'No upcoming events',
              textAlign: TextAlign.center,
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
              hasSearch
                  ? 'Try changing your search or category filter.'
                  : 'Published events will appear here.',
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
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

