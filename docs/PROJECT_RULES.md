# Nexora Project Rules & Standards

To ensure Nexora remains highly maintainable, scalable, and error-free, all developers and AI assistants must strictly follow these rules.

---

## 🏗️ 1. Architecture & Design Principles

- **Clean Architecture is Mandatory**:
  - Keep domain entities (`models/`) completely pure. They must never depend on any database, network libraries, or UI components.
  - Presenters and UI (`screens/` and `widgets/`) must only communicate with repositories and providers. They are forbidden from invoking raw API connections directly.
- **Single Source of Truth**:
  - Avoid duplicate or local component state where possible. Use Riverpod state providers to represent the global active streams, favorite records, and playlist configurations.

---

## 🏃 2. Agile Development & Sprint Cadence

- **One Feature Per Sprint**:
  - Focus on one logical feature (e.g., "Add Favorites", "IPTV Stream Parser", "MediaKit Player Overlay") per sprint.
  - Do not introduce unrelated code or half-implemented panels in a feature branch.
- **Build After Every Sprint**:
  - Before completing any sprint, the code must compile successfully and linting checks must pass cleanly.
  - No code with compilation warnings or broken imports should ever be merged.

---

## 🧑‍💻 3. Code Standards & Reusability

- **No Code Duplication (DRY)**:
  - If a layout pattern or mathematical calculation appears twice, extract it into a utility helper or a reusable widget.
- **Strict Reusable Widget Practice**:
  - Distinguish between a Screen and a Widget. Screens represent the structural routing page. Widgets are independent, highly customizable, and reusable components.
  - All interactive buttons must support custom touch boundaries (minimum 48x48 dp) and standard material feedback ripples.

---

## 🎨 4. Design Guidelines (Material Design 3)

- **Strict Material 3 Compliance**:
  - Use M3 design tokens for sizing, typography scales (Display, Headline, Title, Body, Label), and card elevations.
  - Apply the premium Dark Theme exclusively as Nexora is a cinema-first application. High-contrast indicators and bright active highlights (e.g., FIFA World Cup inspired Neon Green) must guide user focus.
- **Documentation & Comments**:
  - Every file must start with a file header block explaining its responsibility.
  - Every function, class, and property must be documented with clean Dart doc comments (`///`).
