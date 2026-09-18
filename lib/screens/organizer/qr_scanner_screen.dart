import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../models/event.dart';
import '../../models/ticket.dart';
import '../../providers/ticket_provider.dart';

class QrScannerScreen extends StatefulWidget {
  final Event event;

  const QrScannerScreen({
    super.key,
    required this.event,
  });

  @override
  State<QrScannerScreen> createState() =>
      _QrScannerScreenState();
}

class _QrScannerScreenState
    extends State<QrScannerScreen> {
  final MobileScannerController _scannerController =
      MobileScannerController();

  bool _isProcessing = false;

  Future<void> _handleQrCode(String code) async {
    if (_isProcessing) {
      return;
    }

    if (code.trim().isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    final ticketProvider =
        context.read<TicketProvider>();

    final ticket =
        await ticketProvider.getTicketByQrCode(
      code.trim(),
    );

    if (!mounted) {
      return;
    }

    if (ticket == null) {
      await _showResultDialog(
        title: 'Invalid Ticket',
        message:
            'No ticket was found for this QR code.',
        icon: Icons.cancel_rounded,
        isSuccess: false,
      );

      return;
    }

    if (ticket.eventId != widget.event.eventId) {
      await _showResultDialog(
        title: 'Wrong Event',
        message:
            'This ticket belongs to another event.',
        icon: Icons.event_busy_rounded,
        isSuccess: false,
      );

      return;
    }

    if (ticket.status == 'used') {
      await _showResultDialog(
        title: 'Already Used',
        message:
            'This ticket has already been checked in.',
        icon: Icons.check_circle_rounded,
        isSuccess: false,
      );

      return;
    }

    if (ticket.status == 'cancelled') {
      await _showResultDialog(
        title: 'Cancelled Ticket',
        message:
            'This ticket has been cancelled and cannot be used.',
        icon: Icons.block_rounded,
        isSuccess: false,
      );

      return;
    }

    if (ticket.status != 'active') {
      await _showResultDialog(
        title: 'Invalid Ticket',
        message:
            'This ticket is not active and cannot be checked in.',
        icon: Icons.warning_rounded,
        isSuccess: false,
      );

      return;
    }

    await _confirmCheckIn(ticket);
  }

  Future<void> _confirmCheckIn(Ticket ticket) async {
    final shouldCheckIn = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Confirm Check-in',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.verified_rounded,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                ticket.participantName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ticket.ticketTypeName,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Do you want to mark this ticket as checked in?',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Check In'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldCheckIn != true) {
      _resumeScanner();
      return;
    }

    final ticketProvider =
        context.read<TicketProvider>();

    final success =
        await ticketProvider.markTicketAsUsed(
      ticket.ticketId,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      await _showResultDialog(
        title: 'Check-in Successful',
        message:
            '${ticket.participantName} has been checked in successfully.',
        icon: Icons.check_circle_rounded,
        isSuccess: true,
      );
    } else {
      await _showResultDialog(
        title: 'Check-in Failed',
        message:
            ticketProvider.errorMessage ??
                'Unable to check in this ticket.',
        icon: Icons.error_rounded,
        isSuccess: false,
      );
    }
  }

  Future<void> _showResultDialog({
    required String title,
    required String message,
    required IconData icon,
    required bool isSuccess,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colorScheme =
            Theme.of(dialogContext).colorScheme;

        return AlertDialog(
          icon: Icon(
            icon,
            size: 52,
            color: isSuccess
                ? colorScheme.primary
                : colorScheme.error,
          ),
          title: Text(title),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (mounted) {
      _resumeScanner();
    }
  }

  void _resumeScanner() {
    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
    });

    _scannerController.start();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scan Ticket',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Flash',
            onPressed: () {
              _scannerController.toggleTorch();
            },
            icon: const Icon(
              Icons.flash_on_rounded,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) {
                return;
              }

              final barcode =
                  capture.barcodes.first;

              final code = barcode.rawValue;

              if (code != null) {
                _handleQrCode(code);
              }
            },
          ),

          // Dark overlay
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.45,
                ),
              ),
            ),
          ),

          // Scanner frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.primary,
                  width: 4,
                ),
                borderRadius:
                    BorderRadius.circular(24),
              ),
            ),
          ),

          // Instructions
          Positioned(
            left: 24,
            right: 24,
            bottom: 40,
            child: Column(
              children: [
                Text(
                  widget.event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  _isProcessing
                      ? 'Processing ticket...'
                      : 'Place the ticket QR code inside the frame',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.65,
                    ),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isProcessing
                            ? 'Please wait'
                            : 'Ready to scan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}