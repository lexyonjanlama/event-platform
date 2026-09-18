import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ticket.dart';
import '../models/ticket_type.dart';
import '../services/ticket_service.dart';

class TicketProvider extends ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<Ticket> _tickets = [];

  StreamSubscription<List<Ticket>>?
      _ticketsSubscription;

  bool _isLoading = false;
  String? _errorMessage;

  List<Ticket> get tickets => _tickets;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void startListeningToParticipantTickets(
    String participantId,
  ) {
    _ticketsSubscription?.cancel();

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _ticketsSubscription = _ticketService
        .watchParticipantTickets(participantId)
        .listen(
      (tickets) {
        _tickets = tickets;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;

        _errorMessage =
            'Unable to load tickets. Please try again.';

        notifyListeners();

        debugPrint(
          'PARTICIPANT TICKET STREAM ERROR: $error',
        );
      },
    );
  }

  Future<bool> createTicket(
    Ticket ticket,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketService.createTicket(ticket);

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to create ticket. Please try again.';

      debugPrint(
        'CREATE TICKET ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<List<Ticket>?> registerTickets({
    required TicketType ticketType,
    required int quantity,
    required String participantId,
    required String participantName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      final tickets =
          await _ticketService.registerTickets(
        ticketType: ticketType,
        quantity: quantity,
        participantId: participantId,
        participantName: participantName,
      );

      return tickets;
    } catch (e) {
      _errorMessage =
          e.toString().replaceFirst(
                'Exception: ',
                '',
              );

      debugPrint(
        'REGISTER TICKETS ERROR: $e',
      );

      return null;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<Ticket?> getTicket(
    String ticketId,
  ) async {
    try {
      _errorMessage = null;

      return await _ticketService.getTicket(
        ticketId,
      );
    } catch (e) {
      _errorMessage =
          'Unable to load ticket. Please try again.';

      debugPrint(
        'GET TICKET ERROR: $e',
      );

      notifyListeners();

      return null;
    }
  }

  Future<Ticket?> getTicketByQrCode(
    String qrCode,
  ) async {
    try {
      _errorMessage = null;

      return await _ticketService.getTicketByQrCode(
        qrCode,
      );
    } catch (e) {
      _errorMessage =
          'Unable to find ticket. Please try again.';

      debugPrint(
        'GET TICKET BY QR ERROR: $e',
      );

      notifyListeners();

      return null;
    }
  }

  Future<bool> updateTicket(
    Ticket ticket,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketService.updateTicket(
        ticket,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to update ticket. Please try again.';

      debugPrint(
        'UPDATE TICKET ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> cancelTicket(
    String ticketId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketService.cancelTicket(
        ticketId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to cancel ticket. Please try again.';

      debugPrint(
        'CANCEL TICKET ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> markTicketAsUsed(
    String ticketId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketService.markTicketAsUsed(
        ticketId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to check in ticket. Please try again.';

      debugPrint(
        'MARK TICKET USED ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> deleteTicket(
    String ticketId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketService.deleteTicket(
        ticketId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to delete ticket. Please try again.';

      debugPrint(
        'DELETE TICKET ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  void clearTickets() {
    _tickets = [];
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _ticketsSubscription?.cancel();

    super.dispose();
  }
}