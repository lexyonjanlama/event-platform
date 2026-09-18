import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';
import '../models/ticket_type.dart';

class EventService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _events =>
      _firestore.collection('events');

  CollectionReference<Map<String, dynamic>> get _ticketTypes =>
      _firestore.collection('ticketTypes');

  // ============================================================
  // ORGANIZER - CREATE EVENT
  // ============================================================

  Future<String> createEvent(Event event) async {
    final document = _events.doc();

    final eventWithId = event.copyWith(
      eventId: document.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await document.set(
      eventWithId.toMap(),
    );

    return document.id;
  }

  // ============================================================
  // ORGANIZER - CREATE EVENT WITH TICKET TYPES
  // ============================================================

  Future<String> createEventWithTicketTypes({
    required Event event,
    required List<TicketType> ticketTypes,
  }) async {
    final eventDocument = _events.doc();

    final now = DateTime.now();

    final eventWithId = event.copyWith(
      eventId: eventDocument.id,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _firestore.batch();

    // Create event.
    batch.set(
      eventDocument,
      eventWithId.toMap(),
    );

    // Create all ticket types.
    for (final ticketType in ticketTypes) {
      final ticketDocument = _ticketTypes.doc();

      final ticketTypeWithId = ticketType.copyWith(
        ticketTypeId: ticketDocument.id,
        eventId: eventDocument.id,
        createdAt: now,
        updatedAt: now,
      );

      batch.set(
        ticketDocument,
        ticketTypeWithId.toMap(),
      );
    }

    await batch.commit();

    return eventDocument.id;
  }

  // ============================================================
  // ORGANIZER - WATCH MY EVENTS
  // ============================================================

  Stream<List<Event>> watchOrganizerEvents(
    String organizerId,
  ) {
    return _events
        .where(
          'organizerId',
          isEqualTo: organizerId,
        )
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map(
            (doc) => Event.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      // Newest created event first.
      events.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime(1970);

        final bDate =
            b.createdAt ?? DateTime(1970);

        return bDate.compareTo(aDate);
      });

      return events;
    });
  }

  // ============================================================
  // PARTICIPANT - WATCH PUBLISHED EVENTS
  // ============================================================

  Stream<List<Event>> watchPublishedEvents() {
    return _events
        .where(
          'status',
          isEqualTo: 'published',
        )
        .snapshots()
        .map((snapshot) {
      final events = snapshot.docs
          .map(
            (doc) => Event.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      // Upcoming/earlier event date first.
      events.sort((a, b) {
        return a.date.compareTo(b.date);
      });

      return events;
    });
  }

  // ============================================================
  // GET SINGLE EVENT
  // ============================================================

  Future<Event?> getEvent(
    String eventId,
  ) async {
    final document =
        await _events.doc(eventId).get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return Event.fromMap(
      document.id,
      document.data()!,
    );
  }

  // ============================================================
  // ORGANIZER - UPDATE EVENT
  // ============================================================

  Future<void> updateEvent(
    Event event,
  ) async {
    final updatedEvent = event.copyWith(
      updatedAt: DateTime.now(),
    );

    await _events
        .doc(event.eventId)
        .update(
          updatedEvent.toMap(),
        );
  }

  // ============================================================
  // ORGANIZER - DELETE EVENT
  // ============================================================

  Future<void> deleteEvent(
    String eventId,
  ) async {
    await _events
        .doc(eventId)
        .delete();
  }
}