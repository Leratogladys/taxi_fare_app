# TaxiMaths

A Flutter application exploring fare calculation, passenger-payment tracking, and change management for South Africa's informal taxi environment.

## Status

**In active development.**

The repository separates working application foundations from planned persistence and cloud features so that the current implementation is clear.

## Problem

Taxi fare collection often involves fast manual calculations, group payments, change owed to passengers, and repeated trips. TaxiMaths explores how a simple mobile tool can reduce calculation errors and make payment status easier to track.

## Implemented / Current Work

- Flutter and Dart application foundation
- MVVM-style separation of views, view models, and models
- Provider-based state-management approach
- Fare calculation workflows
- Passenger/payment tracking work
- Change-management logic
- Trip-management foundations
- Navigation and theme structure

## Planned

The following are roadmap items rather than completed integrations:

- Hive local persistence
- Saved routes and trip history
- Offline-first storage
- Supabase authentication
- Supabase cloud synchronisation
- Fleet-management features
- Revenue analytics

## Tech Stack

### Implemented

- Flutter
- Dart
- MVVM
- Provider

### Planned Integrations

- Hive
- Supabase

## Architecture

```text
View
  |
  v
ViewModel
  |
  v
Model
```

This separation keeps presentation code distinct from application state and fare/payment logic.

## Project Structure

```text
lib/
├── core/
├── models/
├── viewmodels/
├── views/
├── widgets/
└── routes/
```

## Product Direction

TaxiMaths is intentionally grounded in a local operational problem rather than being a generic calculator demo. The product direction prioritises:

- Fast interactions
- Simple fare calculations
- Clear payment status
- Large, practical touch targets
- Minimal distraction in busy taxi environments
- Offline-first capability as a future milestone

## Development Roadmap

### Foundation
- MVVM structure
- Navigation
- Theme system
- Models and view models

### Core Taxi Operations
- Fare calculation
- Payment tracking
- Change management
- Trip workflows

### Persistence — Planned
- Hive local storage
- Trip history
- Saved routes

### Cloud — Planned
- Supabase authentication
- Data synchronisation
- Fleet features

## Why This Project?

TaxiMaths demonstrates:

- Mobile application development
- State and business-logic separation
- Product thinking
- Designing around a specific South African use case
- Incremental delivery rather than claiming unfinished features as complete

## Author

**Lerato Molefe**

- Portfolio: https://leratogladys.github.io/Portfolio
- GitHub: https://github.com/Leratogladys
