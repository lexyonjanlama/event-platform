import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/event.dart';
import '../models/ticket_type.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  // ============================================================
  // ORGANIZER EVENTS
  // ============================================================

  List<Event> _events = [];

  StreamSubscription<List<Event>>?
      _eventsSubscription;

  // ============================================================
  // PARTICIPANT EVENTS
  // ============================================================

  List<Event> _publishedEvents = [];

  StreamSubscription<List<Event>>?
      _publishedEventsSubscription;

  // ============================================================
  // COMMON STATE
  // ============================================================

  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Event> get events => _events;

  List<Event> get publishedEvents => _publishedEvents;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // ORGANIZER - WATCH MY EVENTS
  // ============================================================

  void startListening(String organizerId) {
    _eventsSubscription?.cancel();

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _eventsSubscription = _eventService
        .watchOrganizerEvents(organizerId)
        .listen(
      (events) {
        _events = events;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;

        _errorMessage =
            'Unable to load events. Please try again.';

        notifyListeners();

        debugPrint(
          'EVENT STREAM ERROR: $error',
        );
      },
    );
  }

  // ============================================================
  // PARTICIPANT - WATCH PUBLISHED EVENTS
  // ============================================================

  void startListeningToPublishedEvents() {
    _publishedEventsSubscription?.cancel();

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _publishedEventsSubscription = _eventService
        .watchPublishedEvents()
        .listen(
      (events) {
        _publishedEvents = events;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;

        _errorMessage =
            'Unable to load events. Please try again.';

        notifyListeners();

        debugPrint(
          'PUBLISHED EVENT STREAM ERROR: $error',
        );
      },
    );
  }

  // ============================================================
  // ORGANIZER - CREATE EVENT
  // ============================================================

  Future<bool> createEvent(Event event) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _eventService.createEvent(event);

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to create event. Please try again.';

      debugPrint(
        'CREATE EVENT ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ORGANIZER - CREATE EVENT + TICKET TYPES
  // ============================================================

  Future<bool> createEventWithTicketTypes({
    required Event event,
    required List<TicketType> ticketTypes,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _eventService.createEventWithTicketTypes(
        event: event,
        ticketTypes: ticketTypes,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to create event and ticket types. '
          'Please try again.';

      debugPrint(
        'CREATE EVENT WITH TICKET TYPES ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ORGANIZER - UPDATE EVENT
  // ============================================================

  Future<bool> updateEvent(Event event) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _eventService.updateEvent(event);

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to update event. Please try again.';

      debugPrint(
        'UPDATE EVENT ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ORGANIZER - DELETE EVENT
  // ============================================================

  Future<bool> deleteEvent(String eventId) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _eventService.deleteEvent(eventId);

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to delete event. Please try again.';

      debugPrint(
        'DELETE EVENT ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET SINGLE EVENT
  // ============================================================

  Future<Event?> getEvent(String eventId) async {
    try {
      _errorMessage = null;

      return await _eventService.getEvent(
        eventId,
      );
    } catch (e) {
      _errorMessage =
          'Unable to load event. Please try again.';

      debugPrint(
        'GET EVENT ERROR: $e',
      );

      notifyListeners();

      return null;
    }
  }

  // ============================================================
  // CLEAR ORGANIZER EVENTS
  // ============================================================

  void clearEvents() {
    _events = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR PARTICIPANT EVENTS
  // ============================================================

  void clearPublishedEvents() {
    _publishedEvents = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _publishedEventsSubscription?.cancel();

    super.dispose();
  }
}