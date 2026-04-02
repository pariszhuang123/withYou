# CI/CD - GitHub Actions

## Pipeline Overview

```text
Push/PR to main or develop
    ->
[CI] Static Analysis
    ->
[CI] Tests + Coverage
    ->
[CI] Android flavor build matrix (dev + prod)
    ->
[CI] Build through lib/main.dart with --dart-define-from-file
    ->
[CD] Triggered only after CI completes successfully on a push to main
    ->
[CD] Build signed prod AAB
    ->
[CD] Upload to Google Play internal track
```

## Workflow Files

### CI

Location: `.github/workflows/ci.yml`

CI behavior:

- Runs on pushes to `main` and `develop`.
- Runs on pull requests targeting `main` and `develop`.
- Validates `flutter analyze`.
- Runs tests and coverage enforcement.
- Builds both Android release flavors as a sanity check.
- Uses a single Flutter entrypoint, `lib/main.dart`.
- Generates ephemeral env files in CI and builds with:
  - `flutter build apk --release --flavor=dev --target=lib/main.dart --dart-define-from-file=env/dev.json`
  - `flutter build apk --release --flavor=prod --target=lib/main.dart --dart-define-from-file=env/prod.json`

### Deploy

Location: `.github/workflows/deploy.yml`

Deployment behavior:

- CD is chained from CI with `workflow_run`.
- CD runs only when the `CI` workflow completed successfully for a push to `main`.
- Pull requests do not trigger deployment.
- `develop` never deploys.
- Manual dispatch remains available only for `prod`.
- Production deploy builds through `lib/main.dart` with `--dart-define-from-file=env/prod.json`.

Current deploy target:

- `prod`: build signed `app-prod-release.aab`, upload it as an artifact, then upload it to the Google Play `internal` track via Fastlane.

## Flutter Environment Strategy

Flutter now uses a single entrypoint:

- `lib/main.dart`

Runtime environment selection comes from `APP_ENV` in `--dart-define` values. The app resolves that into `dev` or `prod` at startup.

Example local commands:

```bash
flutter run --flavor dev -t lib/main.dart --dart-define-from-file=env/dev.json
flutter run --flavor prod -t lib/main.dart --dart-define-from-file=env/prod.json
```

Tracked example files:

- `env/dev.example.json`
- `env/prod.example.json`

These examples are safe to commit. Real `env/*.json` files remain gitignored.

## Android Flavor Strategy

Android uses a single flavor dimension: `environment`.

Base Android package ID: `com.makinglifeeasie.withyou`

- `dev`
  - Application ID suffix: `.dev`
  - Version name suffix: `-dev`
  - App label: `With You Dev`
  - Kept for local and tester separation, but not deployed by CD

- `prod`
  - App label: `With You`
  - Release signing comes from GitHub environment secrets

Signing behavior:

- `dev` uses the debug signing config.
- `prod` uses the `prodRelease` signing config when `android/key.properties` and `android/app/prod_keystore.jks` are present.
- If prod signing assets are absent locally, Gradle falls back to debug signing so local sanity builds still work.

## Required GitHub Environment And Secrets

Create a GitHub Environment named `prod`.

`prod` secrets required for signed AAB + Play upload:

- `PROD_KEY_ALIAS`
- `PROD_KEY_PASSWORD`
- `PROD_STORE_PASSWORD`
- `PROD_KEYSTORE_BASE64`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

## Fastlane

Fastlane files live in `android/fastlane/`.

- `Fastfile` defines `android deploy_internal`
- `Appfile` reads:
  - `ANDROID_PACKAGE_NAME`
  - `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON_PATH`

The deployment lane uploads the built prod AAB to the Google Play `internal` track.

## Branch Protection

Configure in GitHub Settings -> Branches:

- `main`: require PRs, up-to-date branches, approval, and passing CI.
- `develop`: require PRs and passing CI before merges.
- Disable direct pushes to `main`.

## Quality Gates Summary

| Gate | Job | Threshold |
|------|-----|-----------|
| Static analysis | `analyze` | Zero issues (`--fatal-infos`) |
| Unit tests | `test` | 100% pass |
| Widget tests | `test` | 100% pass |
| Integration tests | `test` | 100% pass |
| Line coverage | `test` | >= 80% |
| Dev Android build | `build` | Successful `devRelease` APK |
| Prod Android build | `build` | Successful `prodRelease` APK |
| Prod deployment | `deploy-prod` | Signed AAB uploaded to Play internal |

## Future Additions

- Add Firebase App Distribution if you later want automated non-prod distribution
- Add Play release promotion from `internal` to `closed` or `production`
- Add app metadata, changelog, and screenshot publishing to Play
- Add Android emulator integration tests before release jobs
