# Nexora AI Memory

This document is updated regularly to provide context for AI coding assistants working on Nexora. It serves as an executive memory bank containing the foundational pillars of the project.

---

## 📌 Project Overview
- **Project Name**: Nexora
- **Underlying Framework**: Flutter
- **Primary Domain**: IPTV Stream Player & Live Sports Streaming Platform
- **Visual Aesthetic**: Sports-centric, energetic, and cinematic. Features a custom theme inspired by the **FIFA World Cup 2026** (high contrast, neon green accents, deep pitch-dark stadium backgrounds).

---

## ⚙️ Core Technical Architecture
- **State Management**: Flutter Riverpod (`flutter_riverpod` + code generation via `riverpod_generator`). All states are decoupled from widgets using clear providers.
- **Navigation**: GoRouter (`go_router`) with declarative routes. Helps manage nested tabs and backstacks cleanly.
- **Future Video Player**: MediaKit (`media_kit`). Native performance cross-platform player engine supporting HLS, adaptive bitrates, and hardware decoding.
- **Persistence**: SharedPreferences for saving user playlist configs, favorites, and settings.
- **Networking**: Raw `http` package mapping standard REST calls.

---

## 📡 Feature Integrations & Ecosystem
- **Telegram Update System**: Integrates an update notifier system linked directly to Telegram notification channels. This allows administrators to dispatch emergency playlist corrections, platform updates, or tournament schedules directly to clients.
- **Repository Management**: Hosted as a clean Git repository on GitHub for robust continuous integration, version tracking, and code reviews.
- **Offline Resilience**: Automatic cache strategies allowing imported playlists to load instantly from internal storage even when internet connectivity is poor or disconnected.
