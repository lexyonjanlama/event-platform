import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../services/ticket_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<Ticket> _eventTickets = [];

  StreamSubscription<List<Ticket>>?
      _eventTicketsSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Ticket> get eventTickets => _eventTickets;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // ANALYTICS
  // ============================================================

  int get totalTickets => _eventTickets.length;

  int get checkedInTickets {
    return _eventTickets
        .where((ticket) => ticket.status == 'used')
        .length;
  }

  int get activeTickets {
    return _eventTickets
        .where((ticket) => ticket.status == 'active')
        .length;
  }

  int get cancelledTickets {
    return _eventTickets
        .where((ticket) => ticket.status == 'cancelled')
        .length;
  }

  double get totalRevenue {
    return _eventTickets.fold(
      0.0,
      (total, ticket) => total + ticket.price,
    );
  }

  double get attendancePercentage {
    if (totalTickets == 0) {
      return 0;
    }

    return (checkedInTickets / totalTickets) * 100;
  }

  int remainingCapacity(int capacity) {
    final remaining = capacity - totalTickets;

    return remaining < 0 ? 0 : remaining;
  }

  // ============================================================
  // WATCH EVENT TICKETS
  // ============================================================

  void startListeningToEventTickets(
    String eventId,
  ) {
    _eventTicketsSubscription?.cancel();

    _eventTickets = [];
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _eventTicketsSubscription = _ticketService
        .watchEventTickets(eventId)
        .listen(
      (tickets) {
        _eventTickets = tickets;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;

        _errorMessage =
            'Unable to load analytics. Please try again.';

        notifyListeners();

        debugPrint(
          'ANALYTICS STREAM ERROR: $error',
        );
      },
    );
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void clearAnalytics() {
    _eventTickets = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _eventTicketsSubscription?.cancel();

    super.dispose();
  }
}