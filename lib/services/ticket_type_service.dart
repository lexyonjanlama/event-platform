
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/ticket_type.dart';

class TicketTypeService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
      get _ticketTypes =>
          _firestore.collection('ticketTypes');

  Future<String> createTicketType(
    TicketType ticketType,
  ) async {
    final document = _ticketTypes.doc();

    final ticketTypeWithId = ticketType.copyWith(
      ticketTypeId: document.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await document.set(
      ticketTypeWithId.toMap(),
    );

    return document.id;
  }

  Stream<List<TicketType>> watchEventTicketTypes(
    String eventId,
  ) {
    return _ticketTypes
        .where(
          'eventId',
          isEqualTo: eventId,
        )
        .snapshots()
        .map((snapshot) {
      final ticketTypes = snapshot.docs
          .map(
            (doc) => TicketType.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      ticketTypes.sort((a, b) {
        final aDate =
            a.createdAt ?? DateTime(1970);

        final bDate =
            b.createdAt ?? DateTime(1970);

        return aDate.compareTo(bDate);
      });

      return ticketTypes;
    });
  }

  Future<TicketType?> getTicketType(
    String ticketTypeId,
  ) async {
    final document =
        await _ticketTypes.doc(ticketTypeId).get();

    if (!document.exists ||
        document.data() == null) {
      return null;
    }

    return TicketType.fromMap(
      document.id,
      document.data()!,
    );
  }

  Future<void> updateTicketType(
    TicketType ticketType,
  ) async {
    final updatedTicketType =
        ticketType.copyWith(
      updatedAt: DateTime.now(),
    );

    await _ticketTypes
        .doc(ticketType.ticketTypeId)
        .update(
          updatedTicketType.toMap(),
        );
  }

  Future<void> deleteTicketType(
    String ticketTypeId,
  ) async {
    await _ticketTypes
        .doc(ticketTypeId)
        .delete();
  }
}

