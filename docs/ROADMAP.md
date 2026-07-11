# Nexora Roadmap - Version 1.0.0

This roadmap outlines the milestones for delivering the initial stable release (v1.0.0) of the Nexora IPTV Player.

---

## 🗺️ Milestone 1: Core Foundation & UI Shell (Current)
- [x] Establish Clean Architecture folder boundaries.
- [x] Configure Material 3 Theme tokens and customized dark palettes.
- [x] Setup declarative GoRouter paths.
- [x] Map Riverpod state structures and basic data models.
- [x] Establish linting metrics with custom `analysis_options.yaml`.

## 🗺️ Milestone 2: Playlist Engine & Storage
- [ ] Implement local database storage wrappers using SharedPreferences.
- [ ] Build the M3U parser parser engine to extract stream links, logos, and categories.
- [ ] Build UI views for the add-playlist dialog and parsing splash feedback.
- [ ] Integrate local bookmarks and favorite lists caching.

## 🗺️ Milestone 3: High-Performance Media Player
- [ ] Add `media_kit` dependency wrappers.
- [ ] Implement hardware accelerated media playback controls (Play, Pause, Ratio, Fit).
- [ ] Code custom cinematic controls overlay (brightness, volume slide, HLS quality).
- [ ] Add Picture-In-Picture (PIP) layout.

## 🗺️ Milestone 4: Sports Integration & Custom Themes
- [ ] Integrate custom FIFA World Cup 2026 styled visual layouts (high contrast grid, active status ribbons).
- [ ] Add fixture notifications and tournament countdown panels.
- [ ] Build search system to query channels on-the-fly.

## 🗺️ Milestone 5: Telegram Updates & App Release
- [ ] Integrate the Telegram update system to receive real-time admin messages.
- [ ] Run full performance benchmarking on low-end Android mobile hardware.
- [ ] Deliver fully localized, compiled v1.0.0 APK release.
