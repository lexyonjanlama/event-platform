
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/ticket_type.dart';
import '../services/ticket_type_service.dart';

class TicketTypeProvider extends ChangeNotifier {
  final TicketTypeService _ticketTypeService =
      TicketTypeService();

  List<TicketType> _ticketTypes = [];

  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<TicketType>>?
      _ticketTypesSubscription;

  List<TicketType> get ticketTypes => _ticketTypes;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  void startListening(String eventId) {
    _ticketTypesSubscription?.cancel();

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    _ticketTypesSubscription = _ticketTypeService
        .watchEventTicketTypes(eventId)
        .listen(
      (ticketTypes) {
        _ticketTypes = ticketTypes;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage =
            'Unable to load ticket types. Please try again.';

        notifyListeners();

        debugPrint(
          'TICKET TYPE STREAM ERROR: $error',
        );
      },
    );
  }

  Future<bool> createTicketType(
    TicketType ticketType,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketTypeService.createTicketType(
        ticketType,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to create ticket type. Please try again.';

      debugPrint(
        'CREATE TICKET TYPE ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> updateTicketType(
    TicketType ticketType,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketTypeService.updateTicketType(
        ticketType,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to update ticket type. Please try again.';

      debugPrint(
        'UPDATE TICKET TYPE ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<bool> deleteTicketType(
    String ticketTypeId,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      notifyListeners();

      await _ticketTypeService.deleteTicketType(
        ticketTypeId,
      );

      return true;
    } catch (e) {
      _errorMessage =
          'Unable to delete ticket type. Please try again.';

      debugPrint(
        'DELETE TICKET TYPE ERROR: $e',
      );

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  Future<TicketType?> getTicketType(
    String ticketTypeId,
  ) async {
    try {
      _errorMessage = null;

      return await _ticketTypeService.getTicketType(
        ticketTypeId,
      );
    } catch (e) {
      _errorMessage =
          'Unable to load ticket type. Please try again.';

      debugPrint(
        'GET TICKET TYPE ERROR: $e',
      );

      notifyListeners();

      return null;
    }
  }

  void clearTicketTypes() {
    _ticketTypes = [];
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _ticketTypesSubscription?.cancel();

    super.dispose();
  }
}

