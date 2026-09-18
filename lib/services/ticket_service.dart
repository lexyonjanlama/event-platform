import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/ticket.dart';
import '../models/ticket_type.dart';

class TicketService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> get _tickets =>
      _firestore.collection('tickets');

  CollectionReference<Map<String, dynamic>> get _ticketTypes =>
      _firestore.collection('ticketTypes');

  Future<String> createTicket(
    Ticket ticket,
  ) async {
    final document = _tickets.doc();

    final ticketWithId = ticket.copyWith(
      ticketId: document.id,
      createdAt: DateTime.now(),
    );

    await document.set(
      ticketWithId.toMap(),
    );

    return document.id;
  }

  // Registers a participant and creates individual tickets
  // inside one Firestore transaction.
  Future<List<Ticket>> registerTickets({
    required TicketType ticketType,
    required int quantity,
    required String participantId,
    required String participantName,
  }) async {
    if (quantity <= 0) {
      throw Exception(
        'Please select at least one ticket.',
      );
    }

    final ticketTypeReference =
        _ticketTypes.doc(ticketType.ticketTypeId);

    return _firestore.runTransaction(
      (transaction) async {
        // IMPORTANT:
        // All reads happen before any writes.
        final ticketTypeSnapshot =
            await transaction.get(ticketTypeReference);

        if (!ticketTypeSnapshot.exists ||
            ticketTypeSnapshot.data() == null) {
          throw Exception(
            'Ticket type is no longer available.',
          );
        }

        final currentTicketType =
            TicketType.fromMap(
          ticketTypeSnapshot.id,
          ticketTypeSnapshot.data()!,
        );

        if (!currentTicketType.isActive) {
          throw Exception(
            'This ticket type is currently unavailable.',
          );
        }

        final remaining =
            currentTicketType.remaining;

        if (quantity > remaining) {
          throw Exception(
            'Only $remaining ticket(s) are remaining.',
          );
        }

        final now = Timestamp.now();

        final tickets = <Ticket>[];

        // Increase sold count atomically.
        transaction.update(
          ticketTypeReference,
          {
            'sold':
                currentTicketType.sold + quantity,
            'updatedAt': now,
          },
        );

        // Create one ticket document per ticket.
        for (int i = 0; i < quantity; i++) {
          final ticketDocument = _tickets.doc();

          final ticketId = ticketDocument.id;

          final qrCode =
              'TKT-${_uuid.v4()}';

          final ticket = Ticket(
            ticketId: ticketId,
            eventId: currentTicketType.eventId,
            participantId: participantId,
            participantName: participantName,
            ticketTypeId:
                currentTicketType.ticketTypeId,
            ticketTypeName:
                currentTicketType.name,
            price: currentTicketType.price,
            status: 'active',
            qrCode: qrCode,
            createdAt: now.toDate(),
          );

          transaction.set(
            ticketDocument,
            ticket.toMap(),
          );

          tickets.add(ticket);
        }

        return tickets;
      },
    );
  }

  Stream<List<Ticket>> watchParticipantTickets(
    String participantId,
  ) {
    return _tickets
        .where(
          'participantId',
          isEqualTo: participantId,
        )
        .snapshots()
        .map((snapshot) {
      final tickets = snapshot.docs
          .map(
            (doc) => Ticket.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      tickets.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime(1970);

        final bDate =
            b.createdAt ?? DateTime(1970);

        return bDate.compareTo(aDate);
      });

      return tickets;
    });
  }

  Stream<List<Ticket>> watchEventTickets(
    String eventId,
  ) {
    return _tickets
        .where(
          'eventId',
          isEqualTo: eventId,
        )
        .snapshots()
        .map((snapshot) {
      final tickets = snapshot.docs
          .map(
            (doc) => Ticket.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      tickets.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime(1970);

        final bDate =
            b.createdAt ?? DateTime(1970);

        return bDate.compareTo(aDate);
      });

      return tickets;
    });
  }

  Future<Ticket?> getTicket(
    String ticketId,
  ) async {
    final document =
        await _tickets.doc(ticketId).get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return Ticket.fromMap(
      document.id,
      document.data()!,
    );
  }

  Future<Ticket?> getTicketByQrCode(
    String qrCode,
  ) async {
    final snapshot = await _tickets
        .where(
          'qrCode',
          isEqualTo: qrCode,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final document = snapshot.docs.first;

    return Ticket.fromMap(
      document.id,
      document.data(),
    );
  }

  Future<void> updateTicket(
    Ticket ticket,
  ) async {
    await _tickets
        .doc(ticket.ticketId)
        .update(
          ticket.toMap(),
        );
  }

  Future<void> cancelTicket(
    String ticketId,
  ) async {
    await _tickets
        .doc(ticketId)
        .update({
      'status': 'cancelled',
    });
  }

  Future<void> markTicketAsUsed(
    String ticketId,
  ) async {
    await _tickets
        .doc(ticketId)
        .update({
      'status': 'used',
      'checkedInAt': Timestamp.now(),
    });
  }

  Future<void> deleteTicket(
    String ticketId,
  ) async {
    await _tickets
        .doc(ticketId)
        .delete();
  }
}