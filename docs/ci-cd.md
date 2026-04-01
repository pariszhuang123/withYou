# CI/CD — GitHub Actions

## Pipeline Overview

```
Push/PR to main
    ↓
[1] Static Analysis (flutter analyze --fatal-infos)
    ↓
[2] Tests + Coverage (flutter test --coverage, ≥ 80%)
    ↓
[3] Build Android (flutter build apk --release)
    ↓ (parallel)
[3] Build iOS (flutter build ios --release --no-codesign)
```

## Workflow File

Location: `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
  analyze:
    name: Static Analysis
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter analyze --fatal-infos

  test:
    name: Tests & Coverage
    runs-on: ubuntu-latest
    needs: analyze
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter test --coverage
      - name: Check coverage threshold
        run: |
          sudo apt-get install -y lcov
          COVERAGE=$(lcov --summary coverage/lcov.info 2>&1 | grep 'lines' | grep -oP '[\d.]+(?=%)')
          echo "Line coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "::error::Coverage $COVERAGE% is below 80% threshold"
            exit 1
          fi
      - name: Upload coverage
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/lcov.info

  build-android:
    name: Build Android APK
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter build apk --release
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
```

## Branch Protection (Recommended Settings)

Configure in GitHub → Settings → Branches → `main`:
- ✅ Require pull request before merging
- ✅ Require status checks to pass (analyze, test, build-android, build-ios)
- ✅ Require branches to be up to date
- ✅ Require 1 approval
- ✅ Squash merge only
- ❌ No direct pushes to main

## Quality Gates Summary

| Gate | Job | Threshold |
|------|-----|-----------|
| Static analysis | `analyze` | Zero issues (--fatal-infos) |
| Unit tests | `test` | 100% pass |
| Widget tests | `test` | 100% pass |
| Integration tests | `test` | 100% pass |
| Line coverage | `test` | ≥ 80% |
| Android build | `build-android` | Successful APK |
| iOS build | `build-ios` | Successful (no codesign) |

## Future Additions
- Automated release to Firebase App Distribution (alpha)
- App Store / Play Store upload via Fastlane
- Integration test job on emulator (Android)
- Screenshot tests for call screen UI
