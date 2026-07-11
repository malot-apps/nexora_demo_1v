# Changelog

All notable changes to the Nexora IPTV Player project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0-draft] - 2026-07-09

### Added
- Created foundational directory structure representing Clean Architecture (`lib/core`, `lib/models`, `lib/services`, `lib/providers`, `lib/screens`, `lib/widgets`).
- Defined key domain models (`channel_model.dart`, `playlist_model.dart`, `category_model.dart`) with JSON serializers and immutability handlers.
- Implemented high-level route mapping and Material 3 Dark theme configurations in `main.dart`.
- Formulated static analysis configurations (`analysis_options.yaml`) enforcing strict casting and clean coding styles.
- Added platform-level configurations for high-end multimedia playback, adaptive UI layouts, and asset paths in `pubspec.yaml`.
- Created native Android visualizer explorer shell (`MainActivity.kt`) allowing dynamic verification of Clean Architecture directory roles.
