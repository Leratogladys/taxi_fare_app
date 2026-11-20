# TaxiMaths

**A Flutter-based taxi fare and payment management application.**

TaxiMaths is designed to simplify fare calculations, passenger payment tracking, change management and trip records in South Africa's minibus taxi environment.

The application provides tools for managing individual trips and multi-stage journeys, with locally persisted data using Hive.

## Project Status

**Active development**

The core application includes fare calculation, payment validation, reverse calculations, multi-stage trip management, saved routes, change tracking and trip history.

The project is currently focused on improving functionality, reliability and user experience.

## Features

### 1. Fare Calculation
- Calculate total fares using passenger numbers and fare per person.
- Track the number of passengers travelling.
- Display expected trip revenue.
- Record passenger payments.

**Calculation:**

`Total Fare = Number of Passengers × Fare per Person`

### 2. Payment Management
- Record payments against passenger counts.
- Validate passenger numbers against remaining seats.
- Calculate change owed to passengers.
- Identify payment shortfalls.
- Track outstanding change.
- Mark change as given.

Partial payments are not currently supported.

### 3. Reverse Calculation
Calculate the number of passengers represented by a collected amount.

**Calculation:**

`Number of Passengers = Total Collected ÷ Fare per Person`

The application also identifies any remainder when the amount is not evenly divisible by the fare.

### 4. Multi-Stage Trips
- Create trips containing multiple journey stages.
- Configure individual fares and passenger capacities per stage.
- Record payments separately for each stage.
- Track passengers who have paid.
- Monitor remaining passengers.
- Calculate outstanding change.
- Validate trip completion.

### 5. Route Management
- Save frequently used routes.
- Store departure and destination information.
- Associate fares with saved routes.
- Reuse saved route information.
- Delete saved routes.

### 6. Change Tracker
- Track change owed to passengers.
- Identify outstanding change.
- Mark change as given.
- Track change across standard and multi-stage trips.

### 7. Trip History
- Save completed trips locally.
- Review previous journey records.
- View passenger and payment information.
- Calculate collected revenue and change.
- Identify single-stage and multi-stage journeys.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application framework |
| Dart | Programming language |
| Provider | State management |
| MVVM | Application architecture |
| Hive | Local data persistence |
| Git | Version control |
| GitHub | Source code hosting |

### Dependencies

- `provider` – application state management.
- `hive` – local database.
- `hive_flutter` – Flutter integration for Hive.
- `cupertino_icons` – Cupertino-style icons.

## Architecture

TaxiMaths follows an MVVM-inspired architecture, separating the user interface, application logic and data models.

- **Models:** Represent application data, including fares, payments, stages, routes and trips.
- **ViewModels:** Manage application state, calculations, validation and interactions with the data layer.
- **Views:** Present the application interface and user workflows.
- **Widgets:** Provide reusable interface components.
- **Services:** Handle infrastructure responsibilities, including local database initialization and access.
- **Routes:** Manage application navigation.

### Project Structure

```text
lib/
├── core/
│   └── services/
│       └── hive_service.dart
├── models/
│   ├── fare_model.dart
│   ├── payment_model.dart
│   ├── route_model.dart
│   ├── stage_model.dart
│   └── trip_model.dart
├── routes/
│   └── app_router.dart
├── viewmodels/
│   ├── fare_viewmodels.dart
│   ├── payment_viewmodel.dart
│   ├── route_viewmodel.dart
│   └── stage_viewmodel.dart
├── views/
├── widgets/
└── main.dart

test/
```

## Local Data Persistence

TaxiMaths uses Hive to store application data locally.

The application initializes five data boxes:

| Box | Purpose |
|---|---|
| `active_fare` | Current fare configuration |
| `active_payments` | Active trip payments |
| `active_stages` | Active multi-stage trip data |
| `trip_history` | Completed trip records |
| `routes` | Saved routes |

Hive adapters serialize and deserialize the application's data models.

No cloud synchronization or remote database integration is currently implemented.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK (3.11.0 or compatible)
- Visual Studio Code or Android Studio
- An Android emulator, physical device or supported Flutter desktop/web target

### Installation

1. Clone the repository:

```bash
git clone https://github.com/Leratogladys/taxi_fare_app.git
```

2. Navigate into the project:

```bash
cd taxi_fare_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

### Code Analysis

Run Flutter's static analysis:

```bash
flutter analyze
```

### Automated Tests

Run the available tests:

```bash
flutter test
```

Feature-specific business-logic and integration test coverage is still a development priority.

## Current Limitations

- Partial passenger payments are not supported.
- Cloud synchronization is not implemented.
- User authentication is not implemented.
- Automated tests for the application's core business workflows need further development.
- Cross-device data synchronization is not available.

These are known development areas, not currently implemented features.

## Future Development

Potential improvements include:

- Comprehensive unit and widget testing.
- Improved payment validation and edge-case handling.
- Enhanced trip reporting and revenue summaries.
- Further UI and usability improvements.
- Optional cloud backup and synchronization.
- Additional data management capabilities.

## Project Motivation

TaxiMaths explores how software development can address practical operational challenges within South Africa's informal public transport sector.

The project demonstrates practical application of:

- Flutter and Dart development.
- Object-oriented programming.
- MVVM architecture.
- State management with Provider.
- Local database integration.
- Financial calculations and validation.
- Persistent application data management.

## Author

**Lerato Molefe**

- GitHub: https://github.com/Leratogladys
- Portfolio: https://leratogladys.github.io/Portfolio

---

*TaxiMaths — simplifying taxi fare and payment management.*
