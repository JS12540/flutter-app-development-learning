# Mobile App Architecture — A Beginner's Guide (Android & iOS)

This guide explains how mobile apps actually work under the hood: processes, memory (RAM), storage, permissions, and sandboxing — using your **Only Us** Flutter app as the running example throughout.

---

## 1. The Big Picture — What Is "An App" to the OS?

On your laptop, "Only Us" is just a folder full of Dart files. Once installed on a phone, the OS treats it completely differently. Think of it like this:

```mermaid
flowchart TB
    subgraph Phone["📱 Your Phone (Hardware)"]
        CPU[CPU - the brain]
        RAM[RAM - short-term memory]
        Storage[Flash Storage - long-term memory]
    end

    subgraph OS["Operating System (Android / iOS)"]
        Kernel[Kernel - traffic cop for everything]
        AppA[App: Only Us]
        AppB[App: Instagram]
        AppC[App: WhatsApp]
    end

    Kernel -->|"gives each app its own slice"| AppA
    Kernel -->|"gives each app its own slice"| AppB
    Kernel -->|"gives each app its own slice"| AppC

    AppA -->|uses| RAM
    AppA -->|reads/writes| Storage
    AppB -->|uses| RAM
    AppB -->|reads/writes| Storage

    style Phone fill:#1a1a2e,stroke:#8B5CF6,color:#fff
    style OS fill:#16213e,stroke:#38BDF8,color:#fff
```

**Key idea:** Every app runs in its own isolated bubble. Only Us cannot see Instagram's files, cannot read Instagram's memory, and cannot use Instagram's camera permission. This isolation is called **sandboxing**, and it's the single most important security concept in mobile development.

---

## 2. RAM vs Storage — The #1 Confusion for Beginners

This trips up almost everyone starting out. Here's the plain-English version:

| | **RAM (Memory)** | **Storage (Disk)** |
|---|---|---|
| What it is | Short-term "scratchpad" | Long-term "filing cabinet" |
| Speed | Extremely fast | Much slower |
| Survives phone restart? | ❌ No — wiped clean | ✅ Yes — stays forever |
| Survives app force-close? | ❌ No | ✅ Yes |
| Analogy | Your desk while working | Your filing cabinet at home |
| In Only Us | The `_messages` list you see on screen right now | The `LocalMessage` rows saved in Isar |

### Real example from your app

Before you added Isar, your chat messages lived in a `List<Message>` in RAM only:

```mermaid
flowchart LR
    A[User sends message] --> B["Added to List in RAM"]
    B --> C["Shown on screen"]
    D["User force-closes app"] --> E["RAM is wiped"]
    E --> F["Message is GONE forever"]

    style E fill:#7f1d1d,color:#fff
    style F fill:#7f1d1d,color:#fff
```

After adding Isar (a local database that writes to **storage**, not RAM):

```mermaid
flowchart LR
    A[User sends message] --> B["Added to RAM (for instant UI update)"]
    B --> C["ALSO written to Isar (storage)"]
    C --> D["Shown on screen"]
    E["User force-closes app"] --> F["RAM wiped, but..."]
    F --> G["Storage file still has it"]
    G --> H["Next app open: read from storage back into RAM"]

    style G fill:#14532d,color:#fff
    style H fill:#14532d,color:#fff
```

This is *exactly* why your `LocalMessageStore.put()` call happens on every send — it's writing to the filing cabinet (storage), not just the desk (RAM), so the message survives a restart.

---

## 3. What Happens When You Tap an App Icon? (The Process Lifecycle)

This is different enough between Android and iOS that it deserves its own section each.

### 3a. Android: Processes and the Activity Lifecycle

Android apps run as a **Linux process**. Each app = one process (mostly). Inside that process, your app has "Activities" (basically: screens) that go through a lifecycle.

```mermaid
stateDiagram-v2
    [*] --> Created: User taps icon
    Created --> Started: onStart()
    Started --> Resumed: onResume()
    Resumed --> Paused: another app covers it (e.g. notification)
    Paused --> Resumed: user comes back
    Paused --> Stopped: user presses Home
    Stopped --> Started: user reopens app
    Stopped --> Destroyed: OS needs RAM, kills process
    Destroyed --> [*]

    note right of Resumed
        This is when your app is
        actually visible & interactive
        (e.g. chat_screen.dart is on screen)
    end note

    note right of Destroyed
        Your RAM-only data (in-memory
        lists, variables) is WIPED here.
        This is why Isar/SharedPreferences
        matter — anything not saved
        to storage is lost.
    end note
```

**Real-world trigger:** You open Only Us, then open 5 heavy games. Android's low-memory killer decides it needs RAM back, and **silently kills your Only Us process** in the background — even though you never explicitly closed it. When you tap back to Only Us, Android restarts the process from scratch (that's why apps sometimes "restart" instead of resuming exactly where you left off).

### 3b. iOS: Apps and the Suspended State

iOS is stricter about backgrounding. Instead of freely killing/restarting, iOS moves apps through defined states:

```mermaid
stateDiagram-v2
    [*] --> NotRunning
    NotRunning --> Inactive: user taps icon
    Inactive --> Active: launch finishes
    Active --> Inactive: interrupted (e.g. incoming call)
    Inactive --> Background: user presses Home
    Background --> Suspended: after a few seconds, iOS freezes it
    Suspended --> Background: user switches back (fast resume)
    Suspended --> NotRunning: iOS needs RAM, terminates it
    Background --> NotRunning: same

    note right of Suspended
        App is frozen in RAM but not
        running any code — like a
        paused video game. Very fast
        to resume from here.
    end note

    note right of NotRunning
        Fully removed from RAM.
        Next launch = cold start,
        same as Android's Destroyed.
    end note
```

**Key difference from Android:** iOS tends to *suspend* (freeze) apps rather than kill them outright, so switching back to a backgrounded app on iPhone often feels instant — the app was never actually destroyed, just paused. Android is more aggressive about killing background processes to reclaim RAM, especially on budget phones (like the Moto G45 you're testing on) that have less RAM to begin with.

---

## 4. Where Does Your App's Data Actually Live? (Storage Deep Dive)

Both OSes give every app its own **private storage sandbox** — a folder on disk that only that app (normally) can read/write.

```mermaid
flowchart TB
    subgraph AndroidFS["Android File System (simplified)"]
        direction TB
        Internal["/data/data/com.example.only_us/<br/>— PRIVATE to Only Us only"]
        Internal --> Databases["databases/<br/>(Isar .isar files live here)"]
        Internal --> SharedPrefs["shared_prefs/<br/>(SharedPreferences XML)"]
        Internal --> Cache["cache/<br/>(temp files, can be deleted by OS anytime)"]
        External["/storage/emulated/0/<br/>— shared, other apps CAN see with permission"]
        External --> Pictures["Pictures/, Downloads/, etc."]
    end

    style Internal fill:#14532d,color:#fff
    style External fill:#78350f,color:#fff
```

```mermaid
flowchart TB
    subgraph iOSFS["iOS File System (simplified — the 'App Sandbox')"]
        direction TB
        AppContainer["/var/mobile/Containers/Data/Application/UUID/<br/>— PRIVATE to Only Us only, ALWAYS"]
        AppContainer --> Documents["Documents/<br/>(user-generated data, backed up to iCloud)"]
        AppContainer --> Library["Library/<br/>(app support files, preferences)"]
        AppContainer --> TmpCache["tmp/<br/>(cache/scratch, OS can wipe anytime)"]
    end

    style AppContainer fill:#1e3a5f,color:#fff
```

**The critical difference:** On Android, there's a concept of "external storage" that (with permission) other apps can browse — like a shared Downloads folder. **iOS has no equivalent** — every app's sandbox is 100% private, always. This is why file-sharing on iOS requires special APIs (like the Share Sheet or Files app integration) rather than just "give me the storage permission and I'll read anything."

### Where things live in YOUR app specifically

| What | Where it's stored | Type |
|---|---|---|
| Chat messages (`LocalMessage`) | `databases/` (via `IsarService`, using `path_provider`'s app documents dir) | Internal, private, persistent |
| App branding name/logo choice | `shared_prefs/` (via `shared_preferences` package) | Internal, private, persistent |
| PIN hash for App Lock | Encrypted keystore (via `flutter_secure_storage`) — **not** a plain file | Internal, private, encrypted |
| Custom logo image the user picks | Wherever `image_picker` returns a path from — usually a cache/temp copy | Internal, private, semi-temporary |
| Firebase auth session | Firebase SDK's own secure storage | Internal, private |

---

## 5. Cache vs Persistent Storage — Another Common Mix-up

```mermaid
flowchart LR
    subgraph Persistent["Persistent Storage"]
        P1["Isar database (messages)"]
        P2["SharedPreferences (settings)"]
        P3["Secure Storage (PIN hash)"]
    end

    subgraph CacheDir["Cache Directory"]
        C1["Downloaded images"]
        C2["Temporary picker files"]
    end

    OS["Operating System"] -->|"can delete anytime it needs space,<br/>NO WARNING to your app"| CacheDir
    OS -->|"never touches without user action<br/>(uninstall / clear data)"| Persistent

    style CacheDir fill:#7f1d1d,color:#fff
    style Persistent fill:#14532d,color:#fff
```

**Rule of thumb:** If losing the data would upset the user (their chat history, their PIN setup), it must go in **persistent** storage (Isar, SharedPreferences, Secure Storage). If it's disposable and re-creatable (a thumbnail you can re-download), cache is fine — and both OSes will delete cache contents automatically when the device is low on storage space, without asking you.

---

## 6. Permissions — Why Your App Has to "Ask"

Because of sandboxing (Section 1), your app *cannot* access sensitive hardware/data by default — camera, contacts, location, biometrics. It must explicitly request permission, and the **user** grants or denies it.

```mermaid
sequenceDiagram
    participant App as Only Us App
    participant OS as Android/iOS OS
    participant User as User

    App->>OS: "I want to use the camera"
    OS->>User: Shows system permission dialog
    User->>OS: Taps "Allow" or "Deny"
    OS->>App: Returns the decision
    alt Allowed
        App->>App: Camera API now works
    else Denied
        App->>App: Camera API throws error / returns nothing
        Note over App: App must handle gracefully — never assume "Allow"
    end
```

### Permissions your app actually declares

Looking at your `AndroidManifest.xml`, you already have:

```xml
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

This is a **normal** permission — Android grants it automatically at install time because biometric usage isn't considered highly sensitive on its own (compare to camera/location, which are "dangerous" permissions requiring a runtime popup).

```mermaid
flowchart TD
    Permissions["Android Permission Types"] --> Normal["Normal<br/>(auto-granted at install)"]
    Permissions --> Dangerous["Dangerous<br/>(runtime popup required)"]
    Permissions --> Signature["Signature<br/>(only for apps signed by same key — system apps)"]

    Normal --> N1["USE_BIOMETRIC"]
    Normal --> N2["INTERNET"]
    Dangerous --> D1["CAMERA"]
    Dangerous --> D2["READ_CONTACTS"]
    Dangerous --> D3["ACCESS_FINE_LOCATION"]

    style Dangerous fill:#7f1d1d,color:#fff
    style Normal fill:#14532d,color:#fff
```

If you add photo/camera picking to Only Us later (mentioned in your roadmap), you'll need the `permission_handler` package (already in your `pubspec.yaml`!) to trigger the **dangerous** permission popup for gallery/camera access.

### iOS permissions work similarly, but declared differently

iOS doesn't use an XML manifest — it uses `Info.plist` with **usage description strings** that are *shown to the user* in the popup:

```xml
<key>NSCameraUsageDescription</key>
<string>Only Us needs camera access to let you send photos in chat.</string>
```

**Critical iOS rule:** If you don't include this description string and try to access the camera, iOS crashes your app outright — it doesn't just deny quietly. Android is more forgiving here.

---

## 7. Your App Disguise Feature — A Perfect Case Study

You just built a home-screen disguise feature. This is actually a great way to understand **Activities** vs the **app process** — let's map it out.

```mermaid
flowchart TB
    subgraph SingleProcess["ONE Android Process (com.example.only_us)"]
        MainActivity[".MainActivity<br/>(the real app, always exists)"]
        Alias1[".NotesAlias<br/>(fake front door #1)"]
        Alias2[".CalculatorAlias<br/>(fake front door #2)"]
        Alias3[".SafeAlias<br/>(fake front door #3)"]

        Alias1 -.->|"targetActivity points to"| MainActivity
        Alias2 -.->|"targetActivity points to"| MainActivity
        Alias3 -.->|"targetActivity points to"| MainActivity
    end

    HomeScreen["Android Home Screen<br/>(launcher)"] -->|"shows only the ENABLED one"| SingleProcess

    style MainActivity fill:#14532d,color:#fff
    style Alias1 fill:#374151,color:#fff
    style Alias2 fill:#374151,color:#fff
    style Alias3 fill:#374151,color:#fff
```

**What's really happening:** There is only ever *one* real screen/app (`MainActivity`). The "aliases" are just alternate **front doors** with different names/icons that all lead to the same house. Your `AppDisguiseManager.kt` doesn't create new apps — it just flips a switch (`setComponentEnabledSetting`) telling the Android launcher which front door to display.

```mermaid
sequenceDiagram
    participant User
    participant ProfileScreen as Profile Settings (Flutter)
    participant Channel as MethodChannel
    participant Kotlin as AppDisguiseManager.kt
    participant PackageManager as Android PackageManager
    participant Launcher as Home Screen Launcher

    User->>ProfileScreen: Taps "Calculator" + confirms
    ProfileScreen->>Channel: invokeMethod("setDisguise", {type: "calculator"})
    Channel->>Kotlin: setActiveAlias(context, "calculator")
    Kotlin->>PackageManager: disable .NotesAlias, .SafeAlias
    Kotlin->>PackageManager: ENABLE .CalculatorAlias
    Kotlin->>PackageManager: enable .MainActivity
    Note over PackageManager,Launcher: This change only shows up<br/>after app restart —<br/>launcher caches icons
    User->>User: App restarts (exit(0) call)
    Launcher->>Launcher: Re-reads enabled activities
    Launcher->>User: Shows "Calculator" icon + name
```

This also explains **why you needed the restart** — the Android home screen launcher caches the list of visible icons and doesn't re-scan until the app is relaunched from scratch.

**iOS has no equivalent to this.** Apple doesn't allow apps to dynamically change their home-screen name/icon via arbitrary code (there's a very limited "Alternate App Icons" API, but it can't change the *name*, and requires Apple-approved icon assets bundled at build time — no user-picked custom images). This is a genuine Android-only capability in your app.

---

## 8. How Your App Actually Affects RAM (Memory) in Practice

```mermaid
flowchart TB
    subgraph RAMUsage["What consumes RAM while Only Us runs"]
        Widgets["Flutter Widget Tree<br/>(every screen, every ChatBubble)"]
        Images["Decoded images<br/>(heart_logo_mark.png, custom logos)"]
        IsarCache["Isar's in-memory query cache"]
        Providers["Riverpod provider state<br/>(authProvider, appLockProvider, etc.)"]
        Dart["Dart VM / engine overhead"]
    end

    RAMUsage --> Total["Total RAM footprint of your app"]
    Total --> Compare{"Compare to available RAM"}
    Compare -->|"Plenty free"| Fine["App runs smoothly"]
    Compare -->|"RAM is tight"| Killed["OS may kill background apps<br/>(including yours if backgrounded)"]

    style Killed fill:#7f1d1d,color:#fff
    style Fine fill:#14532d,color:#fff
```

**Concrete example in your codebase:** Every time `ChatScreen` builds its `ListView` of messages, each `ChatBubble` widget consumes a small amount of RAM. If you had 10,000 messages and rendered them all at once (not lazily), RAM usage would spike. This is why Flutter's `ListView.builder` (lazy — only builds visible items) matters over a plain `ListView` (builds everything upfront) for anything that could grow large, like a chat history.

**Images are a common RAM killer:** A photo picked via `image_picker` might be a 4000x3000 pixel JPEG (12+ million pixels). If displayed at full resolution in a 300x300 avatar circle, Flutter still often decodes the *original* size into RAM unless you explicitly downsample — that's megabytes of RAM for something the user sees as a tiny circle. (Not an issue yet in Only Us since you only picked one custom logo at a time, but worth knowing before adding photo messages.)

---

## 9. Android vs iOS — Summary Comparison Table

| Concept | Android | iOS |
|---|---|---|
| Process model | Each app = Linux process, can be killed anytime for RAM | Similar, but apps get "Suspended" (frozen) before being killed |
| App unit of UI | Activity (one Activity = ~one screen) | ViewController (roughly equivalent) |
| Storage sandbox | `/data/data/<package>/` — private; also has *shared* external storage | `Containers/Data/Application/<uuid>/` — always fully private, no shared storage concept |
| Manifest file | `AndroidManifest.xml` | `Info.plist` |
| Permission model | Install-time (normal) + runtime (dangerous) popups | All sensitive permissions are runtime, with mandatory usage-description strings or the app crashes |
| Background execution | More lenient historically, though modern Android restricts it too (Doze mode, battery optimization) | Very strict — background tasks must use specific APIs (Background Tasks framework, silent push, etc.) |
| Changing home-screen name/icon | Possible via activity-alias (what you just built!) | Not possible for arbitrary user-picked names; only pre-bundled "Alternate Icons," no name change |
| Secure credential storage | Android Keystore (used under the hood by `flutter_secure_storage`) | iOS Keychain (used under the hood by `flutter_secure_storage`) |
| Local database options | SQLite, Isar, Hive, Room (native) | SQLite, Isar, Hive, Core Data (native) — same Flutter packages work on both since Isar wraps SQLite-like storage per-platform |

---

## 10. Putting It All Together — Your App's Full Data Flow

```mermaid
flowchart TB
    User["👤 User opens Only Us"] --> OSLaunch["OS creates/resumes the process"]
    OSLaunch --> FlutterInit["Flutter engine boots (main.dart)"]
    FlutterInit --> IsarOpen["IsarService.open() reads database FROM STORAGE into RAM-accessible handles"]
    IsarOpen --> Firebase["Firebase init — checks auth session (cached credentials from Secure Storage)"]
    Firebase --> Router["GoRouter redirect logic decides first screen"]
    Router --> UI["UI renders — everything visible now lives in RAM as widgets"]

    UI --> UserAction["User sends a chat message"]
    UserAction --> RAMUpdate["1. Update RAM (Riverpod state / local list) — instant UI feedback"]
    RAMUpdate --> DiskWrite["2. LocalMessageStore.put() writes to Isar file ON STORAGE"]

    UserAction2["User backgrounds the app"] --> OSDecision{"OS decides based on available RAM"}
    OSDecision -->|"RAM is fine"| Suspended["App suspended/paused — instant resume later"]
    OSDecision -->|"RAM is tight"| Killed["Process killed — RAM state (in-memory list) LOST"]
    Killed --> Reopen["User reopens app — cold start"]
    Reopen --> IsarOpen

    style DiskWrite fill:#14532d,color:#fff
    style Killed fill:#7f1d1d,color:#fff
    style RAMUpdate fill:#374151,color:#fff
```

**The one sentence that ties this whole guide together:** *Anything only in RAM disappears the moment the OS decides it needs that memory back — which can happen at any time, for reasons outside your control — so anything that matters must be explicitly written to storage, and your job as a mobile developer is deciding exactly which data needs that guarantee.*

---

## Glossary (Quick Reference)

- **Process** — a running instance of your app that the OS tracks and can kill
- **RAM (Random Access Memory)** — fast, temporary memory; wiped when the process dies
- **Storage / Disk / Flash Storage** — slower, permanent memory; survives restarts and force-closes
- **Sandbox** — the isolated private area (both storage and process) the OS gives each app so it can't interfere with others
- **Cache** — a storage subfolder the OS is allowed to delete automatically without warning
- **Persistent storage** — storage the OS will never delete on its own (only on uninstall/manual clear)
- **Permission** — explicit user grant required before your app can access sensitive data/hardware
- **Activity (Android)** / **ViewController (iOS)** — the unit representing one screen/UI context
- **Activity-alias (Android only)** — an alternate "front door" pointing to the same Activity, used for your app disguise feature
- **Cold start** — launching an app from a fully-killed state (must reload everything from storage)
- **Warm start / resume** — returning to a suspended/backgrounded app (much faster, RAM state intact)
