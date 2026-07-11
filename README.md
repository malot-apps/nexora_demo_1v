# Nexora IPTV Player - Clean Architecture Project

<p align="left">
  <a href="https://github.com/tonmoymir9/nexora/actions/workflows/ci.yml">
    <img src="https://github.com/tonmoymir9/nexora/actions/workflows/ci.yml/badge.svg" alt="Build Status" />
  </a>
  <a href="https://github.com/tonmoymir9/nexora/releases">
    <img src="https://img.shields.io/github/v/release/tonmoymir9/nexora?logo=github&color=31c48d" alt="Latest Release" />
  </a>
  <a href="https://github.com/tonmoymir9/nexora/releases">
    <img src="https://img.shields.io/github/downloads/tonmoymir9/nexora/total?logo=github&color=3b82f6" alt="Downloads" />
  </a>
</p>

Nexora is a modern, high-performance IPTV Player built with a clean, decoupled architecture. This repository represents the completed structural initialization, configured with Material 3, cinema-first Dark themes, responsive layout hooks, and state boundaries.

---

## 📁 Repository Directory Structure

```text
nexora/
├── assets/                    # Static Assets & Media Resources
│   ├── animations/            # Lottie / Motion configuration vectors
│   ├── fonts/                 # Typography definitions (Space Grotesk, Inter)
│   ├── icons/                 # System glyph vectors
│   ├── images/                # Background wallpapers & banners
│   └── logos/                 # Branding badges & app symbols
│
├── lib/                       # Flutter Source Code (Dart Core)
│   ├── core/                  # Shared system modules
│   │   ├── constants/         # API nodes, storage keys & configuration maps
│   │   ├── errors/            # Standard exceptions & Failure definitions
│   │   └── network/           # Networking and internet connection checkers
│   │
│   ├── models/                # Immutability data blueprints (domain units)
│   │   ├── category_model.dart # IPTV Channel groupings (e.g. Sports, News)
│   │   ├── channel_model.dart  # Stream endpoints metadata & favorites
│   │   └── playlist_model.dart # M3U links & Xtream Server panel configs
│   │
│   ├── services/              # Functional background engines
│   │   ├── api/               # HTTP connection poolers & Xtream clients
│   │   ├── playlist/          # Custom M3U parser algorithms
│   │   └── storage/           # Local cache & SharedPreferences wrappers
│   │
│   ├── providers/             # Centralized Riverpod state indicators
│   │
│   ├── screens/               # High-level layouts & views
│   │   ├── splash/            # Bootstrapper splash card loader
│   │   ├── home/              # Main playlist explorer & importer
│   │   ├── live_tv/           # Genre catalogs grid & channels browser
│   │   ├── search/            # On-the-fly streaming engine filter
│   │   ├── favorites/         # Bookmarked channels directory
│   │   └── settings/          # Cache flusher & video decoders toggle
│   │
│   ├── widgets/               # Reusable small design components
│   │   ├── buttons/           # Playback dials & capsule pill toggles
│   │   ├── cards/             # Channel banners with live EPG indicators
│   │   ├── dialogs/           # Add playlist inputs & deletion modals
│   │   ├── player/            # Video view overrides (chewie/vlc overlays)
│   │   └── common/            # Skeleton loaders & cached images placeholder
│   │
│   ├── theme/                 # Design tokens (spacings, fonts, M3 Dark schemes)
│   │   └── app_theme.dart     
│   │
│   ├── utils/                 # Diagnostic loggers & parsers helpers
│   │
│   └── main.dart              # Routing configurations & app initializer
│
├── pubspec.yaml               # Flutter module system dependencies config
└── analysis_options.yaml      # Code static linter rules definition
```

---

## 🚀 Key Configurations Added

1. **State Management**: Integrated **Riverpod** (`flutter_riverpod`) for modular, testable, and reactive state tracking across video playback, search queries, and playlists.
2. **Navigation**: Wired up **Go Router** (`go_router`) to control deep linking, transitions, and nested navigation trees.
3. **HTTP Client**: Loaded **HTTP** (`http`) for high-volume playlist fetching.
4. **Local Persistence**: Bound **Shared Preferences** (`shared_preferences`) for offline favorites, state saving, and playlist cache recovery.
5. **Material 3 UI**: Formulated a beautiful **Cinema Dark Scheme** with bold typography (Space Grotesk display headers paired with clean Inter body font) and vivid accent feedback.

---

## 📱 Native Android Development & Visualization Shell

Because the streaming emulator in the development sandbox operates natively on Android, this workspace is also configured with a native **Jetpack Compose "Nexora Visualizer" dashboard**. 

When launching the app in your emulator, you will see a fully interactive, responsive Material 3 dashboard that acts as a **living teacher tool**! It allows you to:
- Browse and explore every Flutter folder & file's responsibility dynamically.
- Review technical mappings of Flutter components to native Android equivalents.
- Check real-time project diagnostic statuses.
- See custom M3 dark style palette and typography configurations live.
