# Contributing to peerads (Flutter)

Thank you for your interest in contributing! This document covers everything you need to get started.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating you agree to uphold it.

## Reporting Bugs

Before opening an issue, search [existing issues](https://github.com/peer-ads/flutter-sdk/issues) to avoid duplicates. When filing a bug report please include:

- SDK version (from `pubspec.lock`)
- Flutter and Dart versions (`flutter --version`)
- Platform (iOS / Android) and OS version
- Minimal reproduction steps
- Expected vs actual behaviour
- `flutter run` output or crash logs

## Suggesting Features

Open a [GitHub Discussion](https://github.com/peer-ads/flutter-sdk/discussions) before filing a feature request.

## Development Setup

```bash
git clone https://github.com/peer-ads/flutter-sdk.git
cd peerads-flutter
flutter pub get
flutter test
flutter analyze
```

## Pull Request Guidelines

1. **Branch** — create a feature branch from `main`: `git checkout -b feat/your-feature`
2. **Small PRs** — one logical change per PR
3. **Tests** — add or update widget/unit tests for any changed behaviour
4. **Linting** — `flutter analyze` must report no issues
5. **Formatting** — run `dart format .` before committing
6. **Commit style** — follow [Conventional Commits](https://www.conventionalcommits.org/)
7. **Changelog** — update `CHANGELOG.md` following pub.dev format

## pub.dev Guidelines

All public APIs must have DartDoc comments. Run `dart doc` to verify before submitting.

## Security

Do **not** open a public issue for security vulnerabilities. See [SECURITY.md](SECURITY.md).

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
