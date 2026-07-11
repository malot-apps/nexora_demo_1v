# Nexora - Developer Bible

Welcome to the **Nexora Developer Bible**. This document defines the architectural vision, primary objectives, selected technology stack, and standard directory patterns for Nexora.

---

## 🌌 Project Vision

**Nexora** is envisioned as a premier, ultra-smooth, high-performance IPTV and live media streaming application. It provides media consumers with a premium cinematic viewing experience that operates with zero-latency channel zapping, offline-first stream buffering, and state-of-the-art visual telemetry. 

The application is heavily optimized for sports broadcasting, bringing the high-octane stadium energy of events like the **FIFA World Cup 2026** directly to the user's mobile screen.

---

## 🎯 Project Goal

The absolute goal of Nexora is to deliver an enterprise-grade, robust, and beautiful mobile application. To achieve this, Nexora avoids quick hacks in favor of strict software craftsmanship:
- **Clean Architecture & Decoupled Design**: Keep the core business logic independent of external streaming players and database frameworks.
- **Visual Polish**: Employ Material Design 3 guidelines to build visually arresting interfaces characterized by depth, rich colors, and fluid motion.
- **Production-Ready & Error-Free**: Ensure every code block is compiled strictly, completely typed, and fully documented with clean class guidelines.

---

## 🛠️ Technology Stack

Nexora leverages modern, stable cross-platform frameworks and community-vetted Dart libraries:

- **Core Framework**: Flutter (Latest Stable Version)
- **Programming Language**: Dart
- **State Management**: Flutter Riverpod (`flutter_riverpod` & `riverpod_annotation`)
- **Navigation Engine**: Go Router (`go_router`)
- **Video Playback Engine (Target)**: MediaKit (`media_kit`)
- **Local Storage / Cache**: Shared Preferences (`shared_preferences`)
- **Networking Library**: HTTP (`http`)
- **Design System**: Material Design 3 (M3)

---

## 📁 Folder Structure

We adhere to a strict Layered Clean Architecture pattern to partition responsibilities cleanly:

```text
nexora/
├── assets/                    # Static Assets & Media Resources
│   ├── animations/            # Lottie or motion vectors
│   ├── fonts/                 # Typography definitions
│   ├── icons/                 # System glyph vectors
│   ├── images/                # Background wallpapers
│   └── logos/                 # Branding badges & app symbols
│
├── docs/                      # Technical specification journals
│
├── lib/                       # Primary Source Code
│   ├── core/                  # Globally shared utility modules
│   │   ├── constants/         # Shared preference keys, config strings
│   │   ├── errors/            # Failure definitions mapping exceptions
│   │   └── network/           # Connectivity monitors
│   │
│   ├── models/                # Decoupled domain models (Entities)
│   │   ├── category_model.dart
│   │   ├── channel_model.dart
│   │   └── playlist_model.dart
│   │
│   ├── services/              # Purely functional operational engines
│   │   ├── api/               # Server-facing HTTP clients
│   │   ├── playlist/          # M3U parser algorithms
│   │   └── storage/           # Disk cache and preference writers
│   │
│   ├── providers/             # Centralized Riverpod state indicators
│   │
│   ├── screens/               # High-level layouts & page navigators
│   │   ├── splash/            
│   │   ├── home/              
│   │   ├── live_tv/           
│   │   ├── search/            
│   │   ├── favorites/         
│   │   └── settings/          
│   │
│   ├── widgets/               # Reusable small design components
│   │   ├── buttons/           
│   │   ├── cards/             
│   │   ├── dialogs/           
│   │   ├── player/            
│   │   └── common/            
│   │
│   ├── theme/                 # Design tokens (M3 dark theme, typography)
│   │
│   ├── utils/                 # Helpers (parsers, loggers)
│   │
│   └── main.dart              # Routing configurations & app initializer
│
├── test/                      # Unit, widget, and integration tests
├── pubspec.yaml               # Metadata and dependency manager
└── analysis_options.yaml      # Static code analyzer rules
```
