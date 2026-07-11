# Full CI/CD Guide for Mobile Apps (Android & iOS)

What Continuous Integration and Continuous Deployment actually mean for a Flutter app specifically, what belongs in each stage, and the complete automated path from a `git push` to your app appearing on the Play Store / App Store. Includes a full pipeline this project could adopt.

---

## 1. CI vs CD — The Distinction That Matters

```mermaid
flowchart LR
    subgraph CI["Continuous Integration"]
        CIGoal["Goal: catch problems<br/>EVERY time code changes,<br/>automatically, before a human<br/>has to look at it"]
    end
    subgraph CD["Continuous Deployment/Delivery"]
        CDGoal["Goal: get a VALIDATED build<br/>into users' hands with<br/>minimal manual steps"]
    end

    CI -->|"Only if CI passes"| CD

    style CI fill:#1e3a5f,color:#fff
    style CD fill:#14532d,color:#fff
```

**CI answers**: "Does this code still work?" — runs on every push/PR, fast, no app store involvement.
**CD answers**: "Is this specific validated version now available to real users?" — runs less often (e.g. on merging to `main`, or a manual trigger), involves signing, versioning, and store upload.

A team can have CI without CD (tests run automatically, but a human still manually builds and uploads to stores). Full CI/CD means both are automatic — merging to `main` can result in a new build reaching testers or even production with zero manual steps.

---

## 2. The Full Pipeline — High Level

```mermaid
flowchart TB
    Push["Developer pushes code /<br/>opens a Pull Request"] --> CI

    subgraph CI["🔵 CI Stage — runs on EVERY push/PR"]
        Format["dart format --set-exit-if-changed"]
        Analyze["flutter analyze"]
        UnitTest["flutter test (unit + widget)"]
        Coverage["Coverage threshold check (this project: ≥90%)"]
        SecurityScan["Dependency vulnerability scan"]
        Format --> Analyze --> UnitTest --> Coverage --> SecurityScan
    end

    CI -->|All green| Gate{"Merged to main?"}
    Gate -->|No, just a PR| StopHere["Stop here — PR shows<br/>green checkmarks, awaits review"]
    Gate -->|Yes| CD

    subgraph CD["🟢 CD Stage — runs on merge to main / manual trigger"]
        Version["Bump version number<br/>(build number auto-increments)"]
        BuildAndroid["Build signed Android App Bundle (.aab)"]
        BuildIOS["Build signed iOS .ipa"]
        UploadPlay["Upload to Google Play<br/>(Internal/Beta/Production track)"]
        UploadApple["Upload to App Store Connect<br/>(TestFlight / App Store review)"]
        Version --> BuildAndroid --> UploadPlay
        Version --> BuildIOS --> UploadApple
    end

    style CI fill:#1e3a5f,color:#fff
    style CD fill:#14532d,color:#fff
    style StopHere fill:#78350f,color:#fff
```

---

## 3. CI Stage — Exactly What Should Run, and Why Each Piece

```mermaid
flowchart TB
    Trigger["git push / PR opened"] --> Setup["1. Set up Flutter SDK<br/>(EXACT pinned version —<br/>never 'latest', for reproducibility)"]
    Setup --> Deps["2. flutter pub get<br/>(uses committed pubspec.lock —<br/>same exact dependency versions<br/>every single run)"]
    Deps --> Fmt["3. dart format --set-exit-if-changed .<br/>Fails the build if anyone forgot<br/>to format their code"]
    Fmt --> Lint["4. flutter analyze<br/>Fails on any error (this project's<br/>own analysis_options.yaml also<br/>enforces complexity/doc-comment rules)"]
    Lint --> Unit["5. flutter test test/unit/<br/>Pure logic, no Flutter widgets,<br/>fastest tests — run first"]
    Unit --> Widget["6. flutter test test/widget/<br/>UI rendering + interaction tests"]
    Widget --> Constants["7. flutter test test/test_constants_integrity_test.dart<br/>This project's own guard against<br/>silently-changed critical constants"]
    Constants --> Cov["8. flutter test --coverage<br/>+ check against threshold<br/>(this project: 90%)"]
    Cov --> Vuln["9. Dependency vulnerability scan<br/>(e.g. `dart pub outdated`,<br/>or a dedicated tool like Snyk/Dependabot)"]
    Vuln --> Done["✅ CI passes — safe to merge"]

    style Done fill:#14532d,color:#fff
```

**Order matters for speed**: cheapest/fastest checks first (formatting, linting) so a trivial mistake fails in seconds, not after waiting for a 5-minute test suite to finish. This is why format/lint come before the test suite above.

**What should NOT run in CI**: anything that touches real external services (a real Firebase project, a real Cloudinary account, a real device) — CI must be fully deterministic and runnable with zero network dependencies, which is exactly why this project's own testing standard (`CLAUDE.md`) mandates mocked collaborators via `mocktail` for every test.

---

## 4. Android CD Pipeline — Full Detail

```mermaid
flowchart TB
    Start["Merge to main"] --> Version["Bump pubspec.yaml version:<br/>1.2.0+15 → 1.2.0+16<br/>(build number MUST increase<br/>every single Play Store upload,<br/>version name can stay the same)"]

    Version --> Sign["Sign the build using a<br/>RELEASE KEYSTORE"]

    subgraph SignDetail["Signing — the part that trips up beginners"]
        Keystore["A .jks keystore file +<br/>its password + key alias +<br/>key password — FOUR secrets"]
        Keystore --> Secret["Stored as CI/CD secrets<br/>(GitHub Actions Secrets, etc.),<br/>NEVER committed to the repo"]
        Secret --> BuildSigned["flutter build appbundle<br/>--release<br/>reads these via key.properties<br/>at build time"]
    end

    Sign --> AAB["Produces a signed .aab<br/>(Android App Bundle — the modern<br/>format Play Store requires,<br/>NOT a plain .apk)"]

    AAB --> Track{"Which Play Store track?"}
    Track -->|"Automatic on every merge"| Internal["Internal Testing track<br/>— your team only, instant"]
    Track -->|"Manual approval gate"| Beta["Closed/Open Beta track<br/>— wider tester group"]
    Track -->|"Manual approval gate,<br/>usually with staged rollout"| Prod["Production track<br/>— real users, often rolled<br/>out to 10% → 50% → 100%<br/>over days to catch issues early"]

    Internal --> Upload["Uploaded via the<br/>Google Play Developer API<br/>(fastlane supply, or the<br/>official upload GitHub Action)"]
    Beta --> Upload
    Prod --> Upload

    style AAB fill:#14532d,color:#fff
    style Prod fill:#78350f,color:#fff
```

**The four Android signing secrets, explained simply**:
- **Keystore file** (`.jks`) — a file containing your app's private signing key. Google verifies every update to your app is signed with the SAME key, forever — lose this file and you can never update your app again under the same listing (this is a real, permanent-consequence risk, not hypothetical).
- **Keystore password** — unlocks the keystore file itself
- **Key alias** — a keystore file can technically hold multiple keys; this picks which one
- **Key password** — unlocks that specific key inside the keystore

**Staged rollout matters for real apps**: shipping straight to 100% of users means a bad build hits everyone before you can react. Rolling out 10% → 50% → 100% over a few days lets crash reports/reviews surface problems while limiting the blast radius — genuinely standard practice, not overcaution.

---

## 5. iOS CD Pipeline — Full Detail

```mermaid
flowchart TB
    Start["Merge to main"] --> Version2["Bump version + build number<br/>in Info.plist / pubspec.yaml"]

    Version2 --> Certs["Code signing — iOS's<br/>equivalent, but more involved"]

    subgraph CertDetail["iOS Signing — genuinely more complex than Android"]
        DistCert["Distribution Certificate<br/>(.p12 file + password) —<br/>proves you're an authorized<br/>Apple Developer"]
        Profile["Provisioning Profile —<br/>ties together: your App ID,<br/>your certificate, and which<br/>devices/capabilities are allowed"]
        DistCert --> Profile
        Profile --> Match["Best practice: use `fastlane match`<br/>to manage/sync these across a team<br/>and CI, stored encrypted in a<br/>private git repo or cloud storage"]
    end

    Certs --> Archive["flutter build ipa<br/>produces a signed .ipa"]

    Archive --> ASC["Upload to App Store Connect<br/>via Transporter / fastlane<br/>pilot / altool"]

    ASC --> Track2{"Which distribution?"}
    Track2 -->|"Automatic on every merge"| TestFlightInternal["TestFlight Internal<br/>— your team, no Apple<br/>review needed, near-instant"]
    Track2 -->|"Manual trigger"| TestFlightExternal["TestFlight External<br/>— up to 10,000 testers,<br/>requires a LIGHT Apple review<br/>(usually hours, not days)"]
    Track2 -->|"Manual trigger,<br/>deliberate decision"| AppStoreReview["Full App Store submission<br/>— FULL Apple review<br/>(can take 24hrs-several days,<br/>can be rejected)"]

    style Archive fill:#14532d,color:#fff
    style AppStoreReview fill:#78350f,color:#fff
```

**Why iOS signing is genuinely harder than Android's**: Android's signing is just "one file + a password, done by you alone." iOS's system involves Apple's own certificate authority, per-app provisioning profiles, and (for push notifications, specifically relevant to this app if it ever ships on iOS) separate APNs authentication keys — there are more moving pieces because Apple's model is built around centralized identity verification through their Developer Program, not just a self-signed key you generate once.

**Apple review is the one genuinely unpredictable step**: unlike Android's Play Store (largely automated policy checks), Apple's App Store review involves actual human reviewers who can reject an app for subjective reasons (UI quality, perceived policy violations, even something as specific as this app's core "hide messages/disguise the app" concept potentially drawing extra scrutiny around App Store review guidelines on deceptive functionality — worth researching Apple's specific guidelines before a real submission, not assuming Android's smoother path automatically transfers).

---

## 6. A Complete GitHub Actions Pipeline for This Project

```mermaid
flowchart TB
    subgraph Trigger["Triggers"]
        PR["pull_request → main"]
        MainPush["push → main"]
        Manual["workflow_dispatch<br/>(manual button)"]
    end

    PR --> CIJob["Job: ci<br/>(format, analyze, test, coverage)"]
    MainPush --> CIJob
    CIJob -->|"Only if push to main<br/>AND ci passed"| CDJob

    subgraph CDJob["Job: cd (needs: ci)"]
        direction TB
        DecryptSecrets["Decrypt signing secrets<br/>from GitHub Actions Secrets"]
        BuildBoth["Build Android .aab<br/>AND iOS .ipa in parallel"]
        UploadBoth["Upload Android → Play Console<br/>Upload iOS → App Store Connect"]
        DecryptSecrets --> BuildBoth --> UploadBoth
    end

    Manual --> CDJob

    style CIJob fill:#1e3a5f,color:#fff
    style CDJob fill:#14532d,color:#fff
```

**Example workflow structure** (conceptual — this project's own `TESTING_GUIDE.md` already has a simpler CI-only example to build from):

```yaml
name: CI/CD
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'  # pinned, never "latest"
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
      - run: flutter test --coverage
      - run: |
          # Fail if coverage drops below 90%
          lcov --summary coverage/lcov.info

  cd:
    needs: ci
    if: github.ref == 'refs/heads/main'
    runs-on: macos-latest  # macOS needed for iOS builds
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
      - run: flutter pub get

      # Android
      - name: Decode Android keystore
        run: echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/release.jks
      - run: flutter build appbundle --release
        env:
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
      - uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.PLAY_SERVICE_ACCOUNT_JSON }}
          packageName: com.example.only_us
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal

      # iOS
      - name: Install certificates & provisioning profile
        run: # (typically via fastlane match, or manual keychain import)
      - run: flutter build ipa --release
      - name: Upload to TestFlight
        run: xcrun altool --upload-app -f build/ios/ipa/*.ipa
          -u ${{ secrets.APPLE_ID }} -p ${{ secrets.APP_SPECIFIC_PASSWORD }}
```

---

## 7. Fastlane — The Tool Almost Every Real Mobile CI/CD Pipeline Uses

```mermaid
flowchart LR
    subgraph WithoutFastlane["❌ Without Fastlane"]
        Raw["Dozens of raw shell commands,<br/>manually handling signing,<br/>versioning, upload APIs for<br/>BOTH platforms separately"]
    end
    subgraph WithFastlane["✅ With Fastlane"]
        Lane["One 'lane' definition,<br/>e.g. `fastlane deploy_beta`,<br/>handles signing + build + upload<br/>with battle-tested, actively-<br/>maintained plugins for both stores"]
    end

    style Raw fill:#78350f,color:#fff
    style Lane fill:#14532d,color:#fff
```

Fastlane is the de facto standard specifically because both Google Play's and Apple's upload APIs change occasionally, have quirks (like App Store Connect's API authentication being notoriously fiddly), and Fastlane's plugins absorb that complexity so your CI YAML stays simple (`fastlane android deploy` / `fastlane ios deploy` instead of hand-rolled API calls).

---

## 8. Secrets Management — What Goes Where

```mermaid
flowchart TB
    subgraph NeverCommit["❌ NEVER in the git repo"]
        S1["Android keystore (.jks) + passwords"]
        S2["iOS distribution certificate (.p12) + password"]
        S3["Google Play service account JSON"]
        S4["App Store Connect API key"]
        S5["Firebase service account JSON<br/>(this project already handles this<br/>correctly for the Cloudflare Worker)"]
    end

    subgraph CISecrets["✅ CI/CD platform's secret store"]
        GH["GitHub Actions → Settings → Secrets and variables → Actions"]
        GL["GitLab CI → Settings → CI/CD → Variables"]
    end

    NeverCommit -.->|"stored as"| CISecrets

    style NeverCommit fill:#7f1d1d,color:#fff
    style CISecrets fill:#14532d,color:#fff
```

This is the exact same principle already applied in this project for Cloudinary's API secret and Firebase's service account key (both live in Cloudflare Worker secrets, never in the Flutter codebase) — CI/CD secrets management is the identical concept, just for a different set of credentials at a different stage of the pipeline.

---

## 9. What This Project Would Need to Add for Full CI/CD

```mermaid
flowchart TB
    Have["Already has"] --> H1["✅ Testing standards defined<br/>(mocktail, 90% coverage target,<br/>documented in TESTING_GUIDE.md)"]
    Have --> H2["✅ Lint rules defined<br/>(analysis_options.yaml)"]
    Have --> H3["✅ Constants integrity test<br/>(a genuinely good CI safeguard<br/>already in place)"]

    Missing["Would need to add"] --> M1["A CI workflow file<br/>(e.g. .github/workflows/ci.yml)<br/>actually running the checks above"]
    Missing --> M2["An Android release keystore<br/>(doesn't exist yet — needs generating<br/>ONCE, then guarding forever)"]
    Missing --> M3["Enrollment in Apple Developer<br/>Program ($99/year) — required<br/>before any iOS distribution,<br/>free/CI options don't exist here"]
    Missing --> M4["Play Console + App Store Connect<br/>service account credentials"]
    Missing --> M5["Decide: automatic production<br/>rollout, or human-gated releases?<br/>(most teams start human-gated,<br/>automate later once confident)"]

    style Have fill:#14532d,color:#fff
    style Missing fill:#78350f,color:#fff
```

**Honest note on cost**: unlike this project's careful avoidance of paid Firebase tiers, **the Apple Developer Program's $99/year fee is not optional** — there is no free tier for distributing an iOS app, even to a handful of testers via TestFlight. This is one wall that genuinely cannot be worked around with a clever free-tier substitute, unlike the Firebase Blaze-plan walls solved elsewhere in this project.

---

## Glossary

- **CI (Continuous Integration)** — automatically validating every code change (tests, linting) before it's trusted
- **CD (Continuous Deployment/Delivery)** — automatically getting a validated build to testers/users with minimal manual steps
- **AAB (Android App Bundle)** — the modern Play Store upload format (replaces plain `.apk` uploads), lets Google generate optimized APKs per device
- **Keystore** — a file holding your app's signing key(s); losing it can permanently break your ability to update an existing Play Store listing
- **Provisioning profile (iOS)** — ties together an App ID, a signing certificate, and allowed devices/capabilities
- **Fastlane** — the standard open-source tool automating mobile build/signing/upload for both platforms
- **Staged rollout** — releasing to a percentage of users first, increasing gradually, to limit damage from a bad release
- **TestFlight** — Apple's beta distribution platform, a prerequisite step before full App Store submission
