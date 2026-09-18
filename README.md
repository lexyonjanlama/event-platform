# Event Management & Ticketing Platform

A Flutter-based **Event Management and Ticketing Platform** designed to simplify event creation, discovery, registration, ticketing, and QR-based event check-in.

The platform provides separate experiences for **organizers** and **participants**, with Firebase used for authentication, database management, and cloud storage.

## Features

### 👤 Participant

* Create an account and log in securely
* Browse available events
* View detailed event information
* Search and explore events
* Register for events
* Access event tickets
* Generate QR codes for event check-in
* View registered events

### 🧑‍💼 Organizer

* Create and manage events
* Add event details such as title, description, category, date, time, venue, and capacity
* Upload event banner images
* View created events
* Manage event information
* Monitor event registrations
* Scan participant QR codes for check-in

### 🎫 Ticketing & QR Check-in

* Digital event tickets
* Unique QR codes for registered participants
* QR scanning for event entry
* Registration and check-in management

### 🔐 Authentication & Roles

* Firebase Authentication
* Participant and Organizer roles
* Role-based application experience
* Secure user profile management

### 🎨 UI & Experience

* Modern Flutter interface
* Responsive layouts
* Light and dark mode
* Simple event discovery and management experience

## Technology Stack

| Technology              | Purpose                                |
| ----------------------- | -------------------------------------- |
| Flutter                 | Cross-platform application development |
| Dart                    | Programming language                   |
| Firebase Authentication | User authentication                    |
| Cloud Firestore         | Database                               |
| Firebase Storage        | Image/file storage                     |
| Provider                | State management                       |
| GoRouter                | Navigation                             |
| QR Flutter              | QR code generation                     |
| Mobile Scanner          | QR code scanning                       |
| Image Picker            | Image selection                        |
| Intl                    | Date and time formatting               |
| UUID                    | Unique identifiers                     |

## Event Data Model

Each event contains information such as:

```text
eventId
title
description
category
date
startTime
endTime
venue
organizerId
capacity
status
bannerUrl
createdAt
```

## User Roles

### Participant

Participants can discover events, register for events, access their digital tickets, and use QR codes for event check-in.

### Organizer

Organizers can create and manage events, view event information, and verify participant entry through QR scanning.

## Project Structure

```text
lib/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
└── main.dart
```

> The project structure may evolve as new features are added.

## Getting Started

### Prerequisites

Make sure you have installed:

* Flutter SDK
* Dart SDK
* Android Studio / Android SDK
* VS Code or another Flutter-compatible IDE
* A Firebase project

### Installation

Clone the repository:

```bash
git clone https://github.com/lexyonjanlama/event-platform.git
```

Navigate to the project:

```bash
cd event-platform
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Firebase Configuration

This project uses Firebase services including:

* Firebase Authentication
* Cloud Firestore
* Firebase Storage

Before running the project, configure Firebase for your development environment using the FlutterFire CLI.

```bash
flutterfire configure
```

Make sure your Firebase project has the required Authentication, Firestore, and Storage services enabled.

## Development

Check the project for issues:

```bash
flutter analyze
```

Run the application:

```bash
flutter run
```

## Current Development Status

🚧 **Project Status: In Development**

Core authentication and role-based access are implemented. Event management, ticketing, registration, and QR check-in features are being developed progressively.

## Future Improvements

* Event search and advanced filtering
* Event categories
* Improved organizer analytics
* Registration management
* Ticket cancellation
* Event notifications
* Attendance statistics
* Enhanced QR security
* Payment integration
* Event reviews and feedback

## Purpose

This project is developed as an academic software project to demonstrate the development of a real-world Flutter application using Firebase, role-based access, cloud data management, event registration, digital ticketing, and QR-based check-in.

## Author

**Lex Yonjan Lama**

GitHub: [@lexyonjanlama](https://github.com/lexyonjanlama)

---

⭐ If you find this project useful, consider giving it a star on GitHub.
