import 'package:cloud_firestore/cloud_firestore.dart';

class Ticket {
  final String ticketId;
  final String eventId;
  final String participantId;
  final String participantName;
  final String ticketTypeId;
  final String ticketTypeName;
  final double price;
  final String status;
  final String qrCode;
  final DateTime? createdAt;
  final DateTime? checkedInAt;

  const Ticket({
    required this.ticketId,
    required this.eventId,
    required this.participantId,
    required this.participantName,
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.price,
    required this.status,
    required this.qrCode,
    this.createdAt,
    this.checkedInAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ticketId': ticketId,
      'eventId': eventId,
      'participantId': participantId,
      'participantName': participantName,
      'ticketTypeId': ticketTypeId,
      'ticketTypeName': ticketTypeName,
      'price': price,
      'status': status,
      'qrCode': qrCode,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      'checkedInAt': checkedInAt != null
          ? Timestamp.fromDate(checkedInAt!)
          : null,
    };
  }

  factory Ticket.fromMap(
    String documentId,
    Map<String, dynamic> map,
  ) {
    return Ticket(
      ticketId: map['ticketId'] ?? documentId,
      eventId: map['eventId'] ?? '',
      participantId: map['participantId'] ?? '',
      participantName: map['participantName'] ?? '',
      ticketTypeId: map['ticketTypeId'] ?? '',
      ticketTypeName: map['ticketTypeName'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      status: map['status'] ?? 'active',
      qrCode: map['qrCode'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      checkedInAt: map['checkedInAt'] is Timestamp
          ? (map['checkedInAt'] as Timestamp).toDate()
          : null,
    );
  }

  Ticket copyWith({
    String? ticketId,
    String? eventId,
    String? participantId,
    String? participantName,
    String? ticketTypeId,
    String? ticketTypeName,
    double? price,
    String? status,
    String? qrCode,
    DateTime? createdAt,
    DateTime? checkedInAt,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      eventId: eventId ?? this.eventId,
      participantId:
          participantId ?? this.participantId,
      participantName:
          participantName ?? this.participantName,
      ticketTypeId:
          ticketTypeId ?? this.ticketTypeId,
      ticketTypeName:
          ticketTypeName ?? this.ticketTypeName,
      price: price ?? this.price,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
    );
  }

  bool get isActive => status == 'active';

  bool get isUsed => status == 'used';

  bool get isCancelled => status == 'cancelled';
}

