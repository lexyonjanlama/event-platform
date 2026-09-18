import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String venue;
  final String organizerId;
  final int capacity;
  final String status;
  final String bannerUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.venue,
    required this.organizerId,
    required this.capacity,
    required this.status,
    required this.bannerUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Event.fromMap(
    String eventId,
    Map<String, dynamic> map,
  ) {
    return Event(
      eventId: eventId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      date: _dateFromFirestore(map['date']),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      venue: map['venue'] ?? '',
      organizerId: map['organizerId'] ?? '',
      capacity: (map['capacity'] ?? 0) as int,
      status: map['status'] ?? 'draft',
      bannerUrl: map['bannerUrl'] ?? '',
      createdAt: _nullableDateFromFirestore(map['createdAt']),
      updatedAt: _nullableDateFromFirestore(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'venue': venue,
      'organizerId': organizerId,
      'capacity': capacity,
      'status': status,
      'bannerUrl': bannerUrl,
      'createdAt':
          createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt':
          updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Event copyWith({
    String? eventId,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? venue,
    String? organizerId,
    int? capacity,
    String? status,
    String? bannerUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      venue: venue ?? this.venue,
      organizerId: organizerId ?? this.organizerId,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime _dateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.now();
  }

  static DateTime? _nullableDateFromFirestore(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}