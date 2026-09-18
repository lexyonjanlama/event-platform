
import 'package:cloud_firestore/cloud_firestore.dart';

class TicketType {
  final String ticketTypeId;
  final String eventId;
  final String name;
  final String description;
  final double price;
  final int quantity;
  final int sold;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TicketType({
    required this.ticketTypeId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.price,
    required this.quantity,
    required this.sold,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  int get remaining {
    final value = quantity - sold;
    return value < 0 ? 0 : value;
  }

  bool get isSoldOut {
    return remaining <= 0;
  }

  factory TicketType.fromMap(
    String ticketTypeId,
    Map<String, dynamic> map,
  ) {
    return TicketType(
      ticketTypeId: ticketTypeId,
      eventId: map['eventId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: _doubleFromValue(map['price']),
      quantity: _intFromValue(map['quantity']),
      sold: _intFromValue(map['sold']),
      isActive: map['isActive'] ?? true,
      createdAt:
          _nullableDateFromFirestore(map['createdAt']),
      updatedAt:
          _nullableDateFromFirestore(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'name': name,
      'description': description,
      'price': price,
      'quantity': quantity,
      'sold': sold,
      'isActive': isActive,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  TicketType copyWith({
    String? ticketTypeId,
    String? eventId,
    String? name,
    String? description,
    double? price,
    int? quantity,
    int? sold,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TicketType(
      ticketTypeId:
          ticketTypeId ?? this.ticketTypeId,
      eventId: eventId ?? this.eventId,
      name: name ?? this.name,
      description:
          description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sold: sold ?? this.sold,
      isActive:
          isActive ?? this.isActive,
      createdAt:
          createdAt ?? this.createdAt,
      updatedAt:
          updatedAt ?? this.updatedAt,
    );
  }

  static double _doubleFromValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  static int _intFromValue(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static DateTime? _nullableDateFromFirestore(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}

