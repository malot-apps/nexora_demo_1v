# Nexora IPTV & Sports — GitHub Actions CI/CD & Production Build Systems

This document describes the enterprise-grade automated build, test, and release pipeline configured for **Nexora IPTV & Sports**.

---

## 🗺️ CI/CD Architecture Overview

The Nexora project utilizes a modern GitHub Actions CI/CD framework to automate testing, static analysis, artifact generation, and deployment of production-ready APKs. 

```text
               +----------------------------------------+
               |          Push / Pull Request           |
               +-------------------+--------------------+
                                   |
                                   v
               +-------------------+--------------------+
               |           Continuous Integration       |
               |                 (ci.yml)               |
               +-------------------+--------------------+
                                   |
                  +----------------+----------------+
                  |                                 |
                  v                                 v
        [ Lint & Format Check ]             [ Run Unit Tests ]
                  |                                 |
                  v                                 v
        [ Analyzer Verification ]          [ Version Validation ]
                                   |
                                   v
                        +----------+----------+
                        |   All Checks Passed  |
                        +----------+----------+
                                   |
         +-------------------------+-------------------------+
         |                                                   |
         v                                                   v
+--------+--------+                                 +--------+--------+
|  Manual / Dev   |                                 |  Release Event  |
| (debug.yml)     |                                 |  (release.yml)  |
+--------+--------+                                 +--------+--------+
         |                                                   |
         v                                                   v
+--------+--------+                                 +--------+--------+
| Build Debug APK |                                 |Build Release APK|
+--------+--------+                                 +--------+--------+
         |                                                   |
         v                                                   v
+--------+--------+                                 +--------+--------+
|  Upload Build   |                                 |  Attach to Tag  |
|   Artifacts     |                                 |   & Release     |
+-----------------+                                 +--------+--------+
                                                             |
                                                             v
                                                    +--------+--------+
                                                    |Auto-Release Note|
                                                    +-----------------+
```

---

## 🛠️ Workflow Pipelines

The automation stack consists of three modular pipelines inside `.github/workflows`:

### 1. Continuous Integration (`ci.yml`)
Runs automatically on every `push` and `pull_request` targeting major development branches (`main`, `master`, `develop`, and `release/*`).
- **Validates Versioning**: Automatically executes `scripts/validate_version.py` to ensure build metadata is consistent and compliant with semantic standards.
- **Dependency Isolation**: Installs correct project pub packages.
- **Code Hygiene**: Checks formatting via `dart format` and enforces static analysis with zero warnings via `flutter analyze`.
- **Dual Testing**: Executes both Dart unit tests (if any are present) and native Android JVM tests (`gradle :app:testDebugUnitTest`) to guarantee cross-framework integrity.

### 2. Android Debug Builder (`android-debug.yml`)
Triggers on direct push to major branches or via manual execution (`workflow_dispatch`).
- Compiles the development `app-debug.apk`.
- Generates a rich Markdown **Workflow Summary** directly in GitHub, listing the Flutter SDK version, total compilation time, output APK size, commit SHA, and branch.
- Publishes the compiled debug package as a secure build artifact.

### 3. Android Release Builder (`android-release.yml`)
Triggers when a GitHub Release Tag is created, or manually on-demand.
- Compiles the optimization-hardened `app-release.apk`.
- Attaches the production binary directly to the GitHub Release.
- Leverages Git history to automatically generate comprehensive release notes.
- Logs full build analytics and metadata directly in the GitHub run summaries.

---

## 📂 Created & Configured Artifacts

| Workflow File | Purpose | Triggers | Key Outputs |
| :--- | :--- | :--- | :--- |
| `.github/workflows/ci.yml` | Static check, validation, testing | Push/PR to major branches | Test logs & analysis reports |
| `.github/workflows/android-debug.yml` | QA & Testing APK compilation | Push to major branches / Manual | `nexora-iptv-debug-apk` (artifact) |
| `.github/workflows/android-release.yml` | Production build and automated release | Release tags / Manual | Attached Release APK, Release Notes |
| `scripts/validate_version.py` | Version format & lockstep checking | Pre-Build in all workflows | Non-blocking stdout / sync validation |

---

## ⬇️ How to Download Built APKs

### From the GitHub Releases Page (Production Releases)
1. Navigate to the **Releases** section on the right side of the repository home page.
2. Find the latest release version badge (e.g., `v1.4.0-RC1`).
3. Under the **Assets** header, click on `app-release.apk` to download the production bundle directly.

### From the GitHub Actions Run (Internal QA Builds)
1. Click the **Actions** tab at the top of the repository.
2. Select either the **Android Debug APK Builder** or **Android Release APK Builder** workflow from the left sidebar.
3. Click on the most recent green (successful) run in the list.
4. Scroll to the bottom of the page to find the **Artifacts** section, and click on either `nexora-iptv-debug-apk` or `nexora-iptv-release-apk` to download.

---

## 🔐 Security & Secret Configurations

All credentials, keystores, and passwords are fully isolated and never hardcoded into the source control. They are pulled directly from secure GitHub Repository Secrets.

### Required Secrets for Release Sign-Off
To sign releases for Google Play Store or production distribution, configure these secrets in **GitHub -> Settings -> Secrets and variables -> Actions**:

| Secret Name | Type | Description |
| :--- | :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | Secret | Base64 encoded string of the `.jks` signing key file |
| `STORE_PASSWORD` | Secret | The password associated with the keystore file |
| `KEY_ALIAS` | Secret | The alias used to create the signing key (e.g., `upload` or `production`) |
| `KEY_PASSWORD` | Secret | The password associated with the specific key alias |

---

## 🚀 Future Signed APK Production Setup

Currently, the release pipeline is set up to fallback automatically to debug keystore signing if the production signing key does not exist. To move to full, signed, production-grade automated deployment, follow these exact steps:

### Step 1: Generate your Production Key
Generate a secure Java Keystore (`.jks`) using `keytool` from your local terminal:
```bash
keytool -genkey -v -keystore nexora-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Step 2: Convert the Keystore to Base64 String
To store the binary keystore file safely inside GitHub Secrets, convert it to a Base64 encoded text string:
- **macOS / Linux**:
  ```bash
  base64 -i nexora-release-key.jks -o keystore_base64.txt
  ```
- **Windows (PowerShell)**:
  ```powershell
  [Convert]::ToBase64String([IO.File]::ReadAllBytes("nexora-release-key.jks")) | Out-File -FilePath keystore_base64.txt
  ```

### Step 3: Populate GitHub Secrets
1. Copy the content of `keystore_base64.txt` and save it as `ANDROID_KEYSTORE_BASE64` inside your GitHub repository secrets.
2. Save your passwords and key alias under `STORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` respectively.

### Step 4: Update the Build Workflow (`android-release.yml`)
To decode your keystore at build time, add these steps to the workflow right before the compilation step:
```yaml
      - name: Decode Android Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > app/nexora-release-key.jks
        env:
          ANDROID_KEYSTORE_BASE64: ${{ secrets.ANDROID_KEYSTORE_BASE64 }}

      - name: Build Release APK with Production Signing
        run: |
          flutter build apk --release
        env:
          KEYSTORE_PATH: "nexora-release-key.jks"
          STORE_PASSWORD: ${{ secrets.STORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
```
The Android build system will automatically pick up these environment variables, map them to your `app/build.gradle.kts` configuration, and sign your APK with your production key!

---

## 🔄 Version Synchronization Strategy

To ensure zero divergence between Flutter app assets, native compile targets, and runtime-exposed constants, Nexora utilizes a **Lockstep Version Synchronization Strategy**. 

### 1. Unified Version Metadata
Every release is strictly tracked with the same exact version metadata across four different configuration targets:

- **Flutter Configuration (`pubspec.yaml`)**:
  - `version: 1.4.0-RC1+14` (represented as `VersionName+VersionCode`)
- **Native Android Configuration (`app/build.gradle.kts`)**:
  - `versionName = "1.4.0-RC1"`
  - `versionCode = 14`
- **Application Constants (`lib/core/constants/app_constants.dart`)**:
  - `static const String appVersion = '1.4.0-RC1';`
  - `static const String buildVersion = '14';`
- **Internal Reference Constants (`lib/core/constants/constants.dart`)**:
  - `static const String appVersion = '1.4.0-RC1';`

### 2. Automated Integrity Gatekeeping (`validate_version.py`)
To prevent release errors, `scripts/validate_version.py` acts as a mandatory pre-build blocker in all CI pipelines. It executes before code compilation to check that:
1. `pubspec.yaml` adheres to correct `X.Y.Z-Suffix+BuildCode` formatting.
2. The extracted `versionName` perfectly matches Gradle's `versionName`.
3. The extracted `versionCode` (build number) perfectly matches Gradle's `versionCode`.

If a discrepancy occurs, the validator reports the precise mismatch, prints a diagnostic breakdown, and exits with a non-zero code (`1`) to immediately halt the GitHub Actions build. When successful, it prints:
```text
PASS
Version Name OK
Version Code OK
✨ Version sync validation succeeded! All files are in lockstep.
```

