> Build Flutter apps professionally, with proper Git, CI/CD, security, testing, Play Store releases, APK sharing, SonarQube, privacy compliance, and scalable architecture

# Phase 1 — Mac Setup (One Time)

## Install

### VS Code

Download:

```text
https://code.visualstudio.com
```

Size:

```text
~500 MB
```

Extensions:

```text
Flutter
Dart
GitHub Pull Requests
Error Lens
GitLens
```

---

### Flutter

```bash
brew install --cask flutter
```

Size:

```text
~2.5 GB
```

---

### Java

```bash
brew install --cask temurin
```

Size:

```text
~300 MB
```

---

### Android SDK

Current size on your machine:

```text
Android SDK      ~1.1 GB
```

After a few projects:

```text
1–3 GB
```

---

### Gradle Cache

First build:

```text
500 MB – 1.5 GB
```

---

### Android NDK

Installed automatically if required:

```text
2–3 GB
```

---

## Realistic Total Size

Not the internet's optimistic estimate:

```text
VS Code           500 MB
Flutter          2.5 GB
Java             300 MB
Android SDK      1.1 GB
Gradle           1.0 GB
NDK              2.5 GB
-----------------------
Total ≈ 8 GB
```

This is normal.

---

# Phase 2 — Create GitHub Repository

Before creating code.

Go to:

```text
https://github.com/new
```

Create:

```text
expense-tracker
```

Private repository.

---

# Phase 3 — Create Flutter Project

Example:

```bash
mkdir -p ~/Desktop/Projects/Flutter
cd ~/Desktop/Projects/Flutter

flutter create expense_tracker
```

Open:

```bash
cd expense_tracker
code .
```

---

# Phase 4 — Initialize Git

```bash
git init
git add .
git commit -m "Initial commit"
```

Connect GitHub:

```bash
git remote add origin <github-url>
git push -u origin main
```

---

# Phase 5 — Branch Strategy

Don't develop directly on main.

Use:

```text
main
develop
feature/*
release/*
hotfix/*
```

Example:

```text
main
develop

feature/login
feature/dashboard
feature/settings
```

Flow:

```text
feature/*
    ↓
develop
    ↓
main
```

---

# Phase 6 — Flutter Folder Structure

Use:

```text
lib/
│
├── app/
│   ├── routes/
│   ├── theme/
│   └── config/
│
├── core/
│   ├── network/
│   ├── security/
│   ├── utils/
│   └── constants/
│
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── profile/
│   └── settings/
│
└── main.dart
```

Never:

```text
50 files directly in lib/
```

---

# Phase 7 — State Management

Recommended:

```text
Riverpod
```

Packages:

```yaml
flutter_riverpod
riverpod_annotation
```

---

# Phase 8 — Navigation

Recommended:

```yaml
go_router
```

---

# Phase 9 — Networking

Recommended:

```yaml
dio
```

instead of:

```dart
http
```

for larger apps.

---

# Phase 10 — Local Storage

Simple:

```yaml
shared_preferences
```

Sensitive:

```yaml
flutter_secure_storage
```

Never store:

```text
passwords
tokens
```

inside SharedPreferences.

---

# Phase 11 — GitHub Actions

This is your CI/CD.

Location:

```text
.github/workflows/
```

Create:

```text
flutter-ci.yml
```

Every PR should run:

```text
flutter pub get
flutter analyze
flutter test
flutter build apk
```

---

# Phase 12 — GitHub Actions Minutes

GitHub gives free minutes.

Typical Flutter build:

```text
2–8 min
```

per build.

---

# Phase 13 — SonarQube

Use:

```text
SonarCloud
```

instead of self-hosting initially.

Checks:

```text
Code Smells
Bugs
Coverage
Security Hotspots
Duplications
```

Merge blocked if quality gate fails.

---

# Phase 14 — Testing

## Unit Tests

```bash
flutter test
```

Target:

```text
80%+
```

coverage.

---

## Widget Tests

Test:

```text
Buttons
Forms
Navigation
```

---

## Integration Tests

Test:

```text
Login
Payments
Signup
```

end-to-end.

---

# Phase 15 — Security

Never commit:

```text
API Keys
Passwords
Secrets
```

Use:

```text
GitHub Secrets
```

for:

```text
Firebase keys
API tokens
Store credentials
```

---

# Phase 16 — Dependency Scanning

Before every release:

```bash
flutter pub outdated
```

Update packages regularly.

---

# Phase 17 — Release Build

For testing:

```bash
flutter build apk --release
```

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# Phase 18 — Share APK

You can share:

```text
Google Drive
WhatsApp
Slack
Email
OneDrive
```

Install manually on Android.

---

# Phase 19 — Google Play Store

Build:

```bash
flutter build appbundle --release
```

Output:

```text
app-release.aab
```

Upload:

```text
Google Play Console
```

Fee:

```text
$25 one-time
```

---

# Phase 20 — Firebase

Install:

```text
Firebase Auth
Crashlytics
Analytics
```

Why:

### Auth

```text
Google Login
Apple Login
Email Login
```

---

### Crashlytics

Tracks:

```text
Crashes
ANRs
Fatal Errors
```

---

### Analytics

Tracks:

```text
Users
Retention
Screens
Funnels
```

---

# Phase 21 — Privacy

Before Play Store:

Create:

```text
Privacy Policy
Terms of Service
```

Must explain:

```text
What data
Why
How long
Who accesses it
```

---

# Phase 22 — Production Checklist

Every release:

```text
✓ Tests pass
✓ Sonar passes
✓ Security scan passes
✓ Dependencies updated
✓ Crashlytics enabled
✓ Analytics enabled
✓ Privacy policy updated
✓ Release notes written
✓ APK/AAB generated
✓ CI/CD green
```

---

# What I Would Use If Starting Today

```text
Flutter 3.x
Riverpod
GoRouter
Dio
Freezed
Firebase Auth
Firebase Crashlytics
Firebase Analytics
GitHub
GitHub Actions
SonarCloud
Firebase App Distribution
Google Play Console
```

This is a setup that works for:

* Solo developer
* Startup
* Scale-up
* Enterprise mobile teams

without needing Android Studio, while still following modern engineering, security, testing, and release practices.
