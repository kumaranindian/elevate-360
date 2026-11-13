# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Elevate-360: Flutter (Dart SDK >=3.0 <4.0) employee performance-management app (goals, self/manager assessments, reviews, skills, feedback) backed by Firebase (Auth, Cloud Firestore; hosting on Firebase project `elevate-360-5f40b`). Targets web primarily, plus Android/iOS/desktop.

## Commands

```bash
flutter pub get
flutter run -d chrome            # or -d android / -d ios
flutter analyze                  # lints: flutter_lints (analysis_options.yaml)
flutter test                     # only test/widget_test.dart exists (smoke test)
flutter test test/widget_test.dart --plain-name "App loads without crashing"
flutter build web --release
./deploy.sh                      # clean + pub get + build web + `firebase deploy --only hosting` (deploy.bat on Windows)
firebase deploy --only firestore # rules + indexes (deploy-firestore.bat on Windows)
```

`build_runner`/`json_serializable`/`riverpod_generator` are in dev_dependencies, but models are hand-written; no codegen step is required.

## Architecture

- **Entry**: `lib/main.dart` initializes Firebase (`lib/firebase_options.dart`), calls `IndexInitializationService.checkAndCreateIndexes()` (failures are tolerated; services fall back to non-indexed queries), then runs `Elevate360App` inside a Riverpod `ProviderScope`. `lib/app/app.dart` is a plain `MaterialApp` with `home: LoginScreen` — **there is no go_router/named routing in use** despite the dependency; navigation is imperative `Navigator` pushes.
- **Role-based screens**: `LoginScreen` authenticates, reads the user's role (`lib/utils/role_constants.dart`: `super_admin`, `hr_admin`, `manager`, `employee`, `project_manager`, with a permissions map), and pushes the matching dashboard (`dashboard_screen.dart` for HR/admin, `manager_dashboard_screen.dart`, `employee_dashboard_screen.dart`). Screens in `lib/screens/` are prefixed by role (`employee_*`, `manager_*`, `hr_*`); role-specific variants of the same feature (goals, assessments, skills, reviews) are separate files, so a feature change often means touching all three.
- **Data layer**: no repository abstraction. `lib/services/*_service.dart` (employee, goal, review, self_assessment, skill, manager_rating, master_data, performance_review, firestore) call `FirebaseFirestore.instance` directly with snake_case field names (e.g. `manager_id`). Models in `lib/models/` map to/from Firestore documents. Main collections: `user_accounts`, `employees`, `goals`, `goal_categories`, `reviews`, `performance_reviews`, `self_assessments`, `skills`, `departments`, `teams`, `projects`, `roles`/`system_roles`/`job_roles`.
- **State**: Riverpod providers live in `lib/core/providers/` (`auth_provider`, `performance_review_provider`) backed by `lib/core/services/auth_service.dart`; most screens use `StatefulWidget` + services directly rather than providers.
- **Layout is mixed/legacy**: `lib/features/`, `lib/components/`, `lib/core/` and top-level `lib/screens|services|models|widgets|utils` coexist. The README's project structure (`features/dashboard`, `core/routes`, etc.) does not match the code; trust the actual tree. Theme/responsive helpers are in `lib/core/utils/`.
- **Seed/setup tooling**: `lib/services/{elevate360,firebase}_data_setup.dart`, `lib/scripts/*`, `firebase_init.dart`, and the in-app `elevate360_setup_screen.dart` / `firebase_setup_screen.dart` populate demo data (org structure, roles, goals) and debug permissions. `grow360_schema.sql` is a reference schema only.
- **Security/infra**: `firestore.rules` and `firestore.indexes.json` are deployed via the Firebase CLI; changing queries that need composite indexes requires updating `firestore.indexes.json`.

## Reference docs in repo

`ELEVATE360_IMPLEMENTATION_GUIDE.md` (role/permission matrix, org structure, goal rules), `EMPLOYEE_GOALS_FEATURES.md`, and `FIREBASE_*_GUIDE.md`/`FIREBASE_IMPLEMENTATION_SUMMARY.md` (setup and deployment) describe intended behavior and Firebase setup.
