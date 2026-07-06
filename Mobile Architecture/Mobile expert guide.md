# Becoming an Expert Mobile Developer — Performance, UX & Architecture

A structured path from beginner → intermediate → advanced, covering everything that separates a "works on my phone" app from a production app used by millions (Instagram, WhatsApp, Spotify, etc.). Every concept includes a Mermaid diagram, a real popular-app example, and how it maps to your **Only Us** codebase where relevant.

---

# PART A — BEGINNER LEVEL

## A1. The Golden Rule: Build Off the Main Thread

Every mobile OS has ONE thread responsible for drawing pixels and responding to touches — the **Main/UI thread**. If you do slow work there (network calls, heavy computation, big loops), the screen **freezes** — this is what causes "App Not Responding" (Android) or the classic **jank/stutter**.

```mermaid
flowchart TB
    subgraph BadPattern["❌ BAD: Blocking the Main Thread"]
        Tap1["User taps 'Load Profile'"] --> Network1["Network call runs directly on Main Thread"]
        Network1 --> Frozen["Screen freezes for 2 seconds"]
        Frozen --> Janky["User sees a frozen, unresponsive app"]
    end

    subgraph GoodPattern["✅ GOOD: Off-loading work"]
        Tap2["User taps 'Load Profile'"] --> BG["Network call runs on a background thread/isolate"]
        BG --> MainStillFree["Main thread stays free — spinner animates smoothly"]
        BG --> Done["Result posted back to Main Thread"]
        Done --> UIUpdate["UI updates in a single fast frame"]
    end

    style Frozen fill:#7f1d1d,color:#fff
    style Janky fill:#7f1d1d,color:#fff
    style MainStillFree fill:#14532d,color:#fff
```

**Real example — Instagram:** When you pull-to-refresh your feed, Instagram shows a smooth spinner while the network request and JSON parsing happen entirely off the main thread. If Instagram did this synchronously, every refresh would freeze your screen for however long the network takes.

**In Flutter (your stack):** Flutter's `async`/`await` with `Future`s automatically keeps I/O (network, file reads) off the main thread's *hot path* using the event loop. But **CPU-heavy** work (like decoding a huge image, parsing a massive JSON, or a heavy loop) still blocks the UI unless you explicitly move it to a separate **Isolate** using `compute()`.

```dart
// BAD - blocks UI if the JSON is large
final data = jsonDecode(hugeJsonString);

// GOOD - runs on a separate isolate, UI stays smooth
final data = await compute(jsonDecode, hugeJsonString);
```

---

## A2. Frame Budget — Why "60fps" Actually Matters

Phones redraw the screen 60 (or 90/120) times per second. Each frame has a strict time budget.

```mermaid
gantt
    dateFormat X
    axisFormat %L ms
    title One Frame's Time Budget at 60fps (16.6ms total)
    section Frame
    Layout & Build       :0, 6
    Paint                :6, 12
    Compositing/GPU      :12, 16
    Idle (frame delivered):16, 17
```

If your code takes **longer than 16.6ms** to produce a frame, that frame is dropped — the user perceives this as a stutter ("jank"). Do this repeatedly and the whole app feels laggy, even if it's technically "working."

**Real example — Spotify's now-playing screen:** The album art blur/gradient animation as you scroll must complete well under 16ms per frame, or the smooth "parallax" effect breaks and looks choppy. Spotify's engineers profile this specific screen constantly because it's the most-viewed screen in the app.

**Tooling:** Both platforms give you frame-timing tools — Android Studio's **Profiler** (GPU rendering) and Xcode's **Instruments** (Core Animation). In Flutter, run `flutter run --profile` and use the **Performance Overlay** (`showPerformanceOverlay: true` on `MaterialApp`) — two colored bars appear; if either bar's graph spikes above the middle line, you're dropping frames.

---

## A3. Widget/View Rebuilds — The Root of Most Jank

Every time state changes, the framework re-evaluates what needs to be redrawn. **Rebuilding more than necessary is the #1 beginner performance mistake** in Flutter, SwiftUI, and Jetpack Compose alike (all three use a "declarative" model where this problem looks the same).

```mermaid
flowchart TB
    subgraph BadRebuild["❌ Whole-tree rebuild"]
        StateChange1["One counter value changes"] --> WholeScreen["ENTIRE screen widget tree rebuilds<br/>(header, list, footer, everything)"]
        WholeScreen --> Waste["Wasted CPU on unchanged widgets"]
    end

    subgraph GoodRebuild["✅ Scoped rebuild"]
        StateChange2["One counter value changes"] --> OnlyCounter["ONLY the Text widget showing<br/>the counter rebuilds"]
        OnlyCounter --> Efficient["Header, list, footer untouched — fast"]
    end

    style Waste fill:#7f1d1d,color:#fff
    style Efficient fill:#14532d,color:#fff
```

**In your Only Us app:** Look at `chat_screen.dart` — when a new message arrives, you want ONLY the `ListView` (or ideally just the new `ChatBubble`) to rebuild, not the entire `Scaffold` including the `_ChatHeader`. Riverpod helps here: `ref.watch(someProvider)` inside a small `Consumer` widget scopes the rebuild to just that widget, instead of watching at the top of a giant `build()` method.

**Real example — WhatsApp:** When a typing indicator appears in a chat, WhatsApp doesn't rebuild the entire message list — only the small "typing..." bubble at the bottom updates. This is why you can be mid-scroll through months-old messages and the typing indicator updates instantly without your scroll position jumping.

---

## A4. Lazy Lists — Never Build What Isn't Visible

```mermaid
flowchart LR
    subgraph Eager["❌ ListView (eager) — builds ALL 10,000 items immediately"]
        E1["Item 1"] --- E2["Item 2"] --- E3["..."] --- E4["Item 10,000"]
        EAll["All built into RAM upfront, even off-screen ones"]
    end

    subgraph Lazy["✅ ListView.builder (lazy) — builds only visible + small buffer"]
        L1["Item 1 (visible)"] --- L2["Item 2 (visible)"] --- L3["Item 3 (buffer)"]
        LNote["Items 4-10,000 don't exist in memory<br/>until scrolled into view"]
    end

    style EAll fill:#7f1d1d,color:#fff
    style LNote fill:#14532d,color:#fff
```

**Real example — Twitter/X's timeline:** With potentially millions of tweets in your history, Twitter never keeps them all in memory. It uses a windowed/lazy list (RecyclerView on Android under the hood) that recycles view objects as you scroll — old off-screen tweet views get their content swapped for new content rather than creating brand-new views every scroll.

**Your app already does this correctly** — `chat_screen.dart`'s message list uses `ListView.builder`, which is the right call, especially once conversations grow to hundreds of messages.

---

## A5. Understanding Widget Keys (Beginner Gotcha)

When list items get reordered, added, or removed, the framework needs to know "is this the *same* logical item that moved, or a *new* item?" Without a `Key`, Flutter (and Compose, and SwiftUI) can get this wrong and either lose state or do unnecessary rebuilds.

```mermaid
flowchart TB
    Before["List: [🐶 Rex, 🐱 Milo, 🐹 Peanut]"] --> Action["User deletes 🐱 Milo"]
    Action --> WithoutKey["❌ Without Key:<br/>Framework assumes item at index 1 changed<br/>(Peanut's widget now shows Milo's old state, e.g. scroll position/animation)"]
    Action --> WithKey["✅ With Key (ValueKey(item.id)):<br/>Framework tracks each item by identity<br/>Milo's widget is correctly removed, Peanut keeps its own state"]

    style WithoutKey fill:#7f1d1d,color:#fff
    style WithKey fill:#14532d,color:#fff
```

**Real-world impact:** Without proper keys, a "swipe to delete" animation on a list (like Gmail's swipe-to-archive) can visually glitch — the wrong row animates away, or expanded/collapsed states jump to the wrong item after a delete.

---

# PART B — INTERMEDIATE LEVEL

## B1. Memory Leaks — The Silent RAM Killer

A memory leak happens when your app keeps a reference to something it no longer needs, so the OS can't reclaim that RAM even though it's logically "done."

```mermaid
flowchart TB
    subgraph Leak["❌ Leaked Stream Subscription"]
        Screen1["User opens Chat Screen"] --> Subscribe["Subscribes to a Stream<br/>(e.g. new-message listener)"]
        Subscribe --> Navigate["User navigates away"]
        Navigate --> NoDispose["dispose() forgotten — subscription NEVER cancelled"]
        NoDispose --> ZombieRef["Screen's widget objects can't be garbage collected<br/>— stream still holds a reference to them"]
        ZombieRef --> Accumulate["Repeat 20 times → 20 dead screens still in RAM"]
    end

    subgraph Fixed["✅ Properly Disposed"]
        Screen2["User opens Chat Screen"] --> Subscribe2["Subscribes to Stream"]
        Subscribe2 --> Navigate2["User navigates away"]
        Navigate2 --> DisposeCalled["dispose() cancels the subscription"]
        DisposeCalled --> GCFree["Garbage collector reclaims the screen's RAM"]
    end

    style Accumulate fill:#7f1d1d,color:#fff
    style GCFree fill:#14532d,color:#fff
```

**This is exactly why your `analysis_options.yaml` enforces `cancel_subscriptions` and `close_sinks` lints** (see your project's `CLAUDE.md` §4) — these catch exactly this class of bug at compile-review time rather than letting the app slowly balloon in RAM usage during a long session.

**Real example — a common bug pattern in production apps:** A chat app subscribes to a "user is typing" WebSocket stream when you open a conversation. If closing the conversation doesn't unsubscribe, and you open/close 50 different conversations during one app session, you can end up with 50 active listeners all still firing — RAM usage climbs, and worse, all 50 might try to update UI that no longer exists, causing crashes.

## B2. Image Memory — Decoded Size vs File Size (Critical & Often Missed)

This is one of the most common causes of high RAM usage and out-of-memory (OOM) crashes.

```mermaid
flowchart TB
    File["Image file on disk: 2MB (JPEG, compressed)"] --> Decode["OS decodes it to raw pixels for display"]
    Decode --> Raw["Decoded raw size = width × height × 4 bytes (RGBA)"]
    Raw --> Example["Example: 4000×3000 photo = 4000×3000×4 = 48,000,000 bytes = ~48MB in RAM!"]
    Example --> Displayed["...even if displayed in a tiny 100×100 avatar circle"]

    style Example fill:#7f1d1d,color:#fff
```

**The fix — always decode at target size, never full resolution:**

```mermaid
flowchart LR
    subgraph Bad["❌ Naive"]
        B1["Load 4000x3000 image"] --> B2["Decode full res: ~48MB RAM"] --> B3["Downscale in a 100x100 widget"]
    end

    subgraph Good["✅ Correct"]
        G1["Load 4000x3000 image"] --> G2["Tell decoder: target size = 100x100"] --> G3["Decode directly at ~100x100: ~40KB RAM"]
    end

    style B2 fill:#7f1d1d,color:#fff
    style G3 fill:#14532d,color:#fff
```

**Real example — Instagram/Pinterest's grid views:** These apps request appropriately-sized *thumbnails* from their CDN (e.g., a 300px version) for grid views, rather than downloading and decoding the full 4000px original just to shrink it visually. This alone is why scrolling through hundreds of images in these apps doesn't crash your phone.

**In Flutter:** Use `Image.network(url, cacheWidth: 300)` or `ResizeImage` to tell the decoder the target size *before* decoding, not after. Your `Image.asset('assets/images/heart_logo_mark.png')` calls in `brand_mark.dart` are small fixed assets so this isn't urgent yet — but the moment you add user-uploaded photo messages (on your roadmap), this becomes critical, since a user might send a 12MP photo that gets displayed as a small chat thumbnail.

## B3. Caching Strategy — The Three-Tier Model

```mermaid
flowchart TB
    Request["App needs data (e.g. a user's profile)"] --> L1{"1. Check Memory Cache<br/>(RAM — fastest, ~microseconds)"}
    L1 -->|Hit| Return1["Return instantly"]
    L1 -->|Miss| L2{"2. Check Disk Cache<br/>(Storage — fast, ~milliseconds)"}
    L2 -->|Hit| PromoteToRAM["Load into RAM, return"]
    L2 -->|Miss| L3["3. Fetch from Network<br/>(slowest, ~100s of ms to seconds)"]
    L3 --> WriteBoth["Write to both Disk Cache AND Memory Cache"]
    WriteBoth --> Return3["Return to caller"]

    style L1 fill:#14532d,color:#fff
    style L2 fill:#78350f,color:#fff
    style L3 fill:#7f1d1d,color:#fff
```

**Real example — Spotify's offline mode:** Songs you've played recently are memory-cached (instant replay), previously-downloaded songs are disk-cached (works offline, slightly slower to start), and anything new streams from network. This exact 3-tier model is why Spotify feels instant for recently-played tracks but takes a moment for something brand new.

**This directly maps to your app's architecture:** Your `CachedUserProfile` (Isar) is the **disk cache tier** — it exists so the profile screen has something to show without a network round trip. If you added a Riverpod provider that also memoizes the currently-logged-in user in RAM (which you already effectively get via `currentUserProvider`), that's your **memory tier**. The 3-tier pattern is already partially present in your codebase — worth recognizing it as a deliberate pattern, not an accident.

## B4. Network Efficiency — Batching & Debouncing

```mermaid
sequenceDiagram
    participant User
    participant App
    participant Server

    Note over User,Server: ❌ BAD: Fires a request on every keystroke
    User->>App: types "h"
    App->>Server: search("h")
    User->>App: types "e"
    App->>Server: search("he")
    User->>App: types "l"
    App->>Server: search("hel")
    Note over Server: 3 wasted requests for one intended search

    Note over User,Server: ✅ GOOD: Debounced — waits for a pause
    User->>App: types "h", "e", "l", "l", "o" (fast)
    App->>App: waits 300ms after last keystroke
    App->>Server: search("hello")
    Note over Server: 1 request, correct result
```

**Real example — every search bar you've ever used** (Google, Amazon, Instagram's search) debounces input. Without it, typing "hello" would fire 5 separate network requests, wasting battery, data, and server load — and often showing flickering, out-of-order results as slower earlier requests resolve after faster later ones.

## B5. State Management — Why It's Not Just "Where Do Variables Live"

```mermaid
flowchart TB
    subgraph Scattered["❌ Scattered State (no clear ownership)"]
        WidgetA["Widget A has its own copy of 'isLoggedIn'"]
        WidgetB["Widget B has its own copy of 'isLoggedIn'"]
        WidgetC["Widget C has its own copy of 'isLoggedIn'"]
        WidgetA -.->|"Login happens in A"| OutOfSync["B and C don't know — show stale UI"]
    end

    subgraph Centralized["✅ Single Source of Truth"]
        Provider["ONE authProvider holds the truth"]
        Provider --> WA["Widget A watches it"]
        Provider --> WB["Widget B watches it"]
        Provider --> WC["Widget C watches it"]
        Provider -.->|"Login happens once"| AllUpdate["ALL widgets update automatically, consistently"]
    end

    style OutOfSync fill:#7f1d1d,color:#fff
    style AllUpdate fill:#14532d,color:#fff
```

**This is exactly the architectural improvement you made with GoRouter + Riverpod in Only Us.** Before, login success required *manually* telling the navigator to push `/home` from inside the login screen. After, `authProvider` is the single source of truth, and the router's `redirect` callback — along with any other widget watching `authProvider` — reacts automatically and consistently. This eliminates an entire class of bugs where one part of the UI updates but another part (that forgot to also handle the state change) doesn't.

**Real example — Twitter's like button:** Tap "like" on a tweet in your timeline, and the like count updates *everywhere that tweet appears* — the timeline, the tweet detail view, your profile's "liked tweets" tab — instantly and consistently, because all of them observe the same underlying state rather than each maintaining an independent copy.

---

# PART C — ADVANCED LEVEL

## C1. The Rendering Pipeline — What Actually Happens Per Frame

Understanding this deeply lets you diagnose *why* something is slow, not just *that* it's slow.

```mermaid
flowchart LR
    Build["1. BUILD<br/>(Widget tree → Element tree)<br/>'What should exist?'"] --> Layout["2. LAYOUT<br/>(Element tree → sizes/positions)<br/>'How big, where?'"]
    Layout --> Paint["3. PAINT<br/>(Layout → Canvas draw commands)<br/>'What pixels?'"]
    Paint --> Composite["4. COMPOSITE<br/>(Layers → GPU)<br/>'Combine layers, send to screen'"]
    Composite --> Screen["📱 Pixels on screen"]

    style Build fill:#1e3a5f,color:#fff
    style Layout fill:#3730a3,color:#fff
    style Paint fill:#6d28d9,color:#fff
    style Composite fill:#be185d,color:#fff
```

Each stage can be a bottleneck for different reasons:
- **Build is slow** → too many widgets rebuild unnecessarily (see A3/B1)
- **Layout is slow** → deeply nested constraint-dependent widgets (e.g. `IntrinsicHeight`, which must measure children twice)
- **Paint is slow** → complex custom painting, too many `Opacity`/`ClipRect` layers (each forces a new compositing layer)
- **Composite is slow** → too many separate GPU layers, or expensive blur/shadow effects

**Real example — why `Opacity` is a known Flutter performance trap:** Wrapping a widget in `Opacity` forces it onto its own compositing layer if the value isn't 0 or 1, which is expensive if that widget rebuilds frequently (like something animating). The fix used by production apps: `AnimatedOpacity` with `RepaintBoundary`, or pre-baking opacity into the color values directly when possible, avoiding the extra layer entirely.

## C2. Garbage Collection — How "Automatic" Memory Management Actually Works

Dart (Flutter), Kotlin/Java (Android), and Swift (iOS) all avoid manual memory management, but through **different mechanisms** — worth knowing because it changes how leaks manifest.

```mermaid
flowchart TB
    subgraph Dart["Dart / Flutter: Generational GC"]
        NewGen["New Generation<br/>(short-lived objects — most widgets)"] --> Scavenge["Fast 'scavenger' collection<br/>runs very frequently, cheaply"]
        OldGen["Old Generation<br/>(long-lived objects — e.g. app-wide singletons)"] --> MarkSweep["Slower mark-and-sweep,<br/>runs less often"]
    end

    subgraph Swift["Swift / iOS: ARC (Automatic Reference Counting)"]
        RefCount["Every object has a reference count"]
        RefCount --> Increment["Count++ when referenced"]
        RefCount --> Decrement["Count-- when reference dropped"]
        Decrement --> ZeroCheck{"Count == 0?"}
        ZeroCheck -->|Yes| Deallocate["Immediately deallocated"]
        ZeroCheck -->|No| StillAlive["Still alive"]
    end

    style Deallocate fill:#14532d,color:#fff
```

**The critical difference this creates:** Dart/Java's GC can cause occasional **GC pauses** (a brief freeze while it cleans up) — usually imperceptible, but under memory pressure can cause jank. Swift's ARC has **no pause** (it's deterministic, deallocating exactly when the count hits zero) — but introduces a different bug class entirely: **retain cycles**, where two objects reference each other and neither's count ever reaches zero, leaking forever (Swift's `weak`/`unowned` keywords exist specifically to break these cycles).

**Real example — a classic iOS retain cycle:** A `ViewController` holds a closure (e.g. a network callback) that captures `self` strongly, and that closure is stored *inside* a property owned by `self`. Neither can ever be freed — this is such a common bug that Swift style guides universally recommend `[weak self]` in closures stored as properties.

## C3. Startup Time Optimization — Cold Start, Warm Start, Hot Start

```mermaid
flowchart TB
    ColdStart["🥶 Cold Start<br/>Process doesn't exist — must be created from scratch<br/>(binary loaded, classes initialized, first Activity created)<br/>~1-3 seconds typical"]
    WarmStart["🌡️ Warm Start<br/>Process exists (backgrounded), Activity was destroyed<br/>Skip process creation, but still recreate the Activity<br/>~0.5-1 second"]
    HotStart["🔥 Hot Start<br/>Process AND Activity both still alive, just brought to foreground<br/>Nearly instant — just needs to redraw"]

    style ColdStart fill:#1e3a5f,color:#fff
    style WarmStart fill:#78350f,color:#fff
    style HotStart fill:#14532d,color:#fff
```

**Where the time actually goes on a cold start** (this is what your `splash_screen.dart` exists to mask gracefully):

```mermaid
sequenceDiagram
    participant OS
    participant Process as App Process
    participant Engine as Flutter Engine
    participant Firebase
    participant Isar
    participant FirstScreen as First Rendered Screen

    OS->>Process: Fork process, load binary
    Process->>Engine: Initialize Flutter engine (Dart VM, isolates)
    Engine->>Engine: main() runs
    Note over Engine: WidgetsFlutterBinding.ensureInitialized()
    Engine->>Isar: IsarService.open() — reads DB file from disk
    Engine->>Firebase: Firebase.initializeApp() — network handshake possible
    Engine->>FirstScreen: Build widget tree, first frame
    FirstScreen->>OS: First pixels drawn (this is what users perceive as "app opened")
```

**Real example — why big apps show a splash screen at all:** Uber, Instagram, and your Only Us app all show a branded splash screen during this window rather than a blank white screen, because the *actual* work (Firebase init, database opening, auth token validation) takes a non-zero, sometimes-unpredictable amount of time, and a branded screen feels intentional while a blank flash feels broken.

**Advanced optimization — deferred/lazy initialization:** Production apps at scale often *delay* non-critical initialization (like analytics SDKs, or ad network SDKs) until after the first frame is drawn, specifically so cold-start time — a metric app stores literally rank apps by — stays as low as possible. Only initialize on the critical path what's truly needed to render screen #1.

## C4. The "Overdraw" Problem — Painting Pixels Nobody Sees

```mermaid
flowchart TB
    subgraph Overdrawn["❌ Overdraw: 4 layers stacked, all opaque"]
        Bg1["Screen background (opaque)"] --> Bg2["Card background (opaque, covers Bg1 entirely)"]
        Bg2 --> Bg3["Card content background (opaque, covers Bg2 entirely)"]
        Bg3 --> Bg4["Text background highlight (opaque, covers Bg3 entirely)"]
        Bg4 --> Wasted["GPU painted the same pixel 4 times<br/>— only the top layer is ever visible"]
    end

    subgraph Optimized["✅ Flattened — remove unseen layers"]
        Single["Single background layer with the final needed color"]
        Single --> Efficient["GPU paints each pixel ONCE"]
    end

    style Wasted fill:#7f1d1d,color:#fff
    style Efficient fill:#14532d,color:#fff
```

**How to detect it:** Android Studio has a literal "Debug GPU Overdraw" visual overlay that colors your screen based on how many times each pixel was painted (blue = 1x, green = 2x, pink = 3x, red = 4x+ — red means real trouble). iOS's Instruments has a similar "Color Blended Layers" debug option in the Simulator.

**Real example — a common mistake in list-heavy apps (e.g. e-commerce apps like Amazon):** Giving every list item's root `Container` a background color, AND its inner card another background color, AND a nested content wrapper another — when only the innermost color is ever visible — causes measurable overdraw at scale across a long scrolling list, hurting battery life and frame rate on lower-end devices even if it's invisible on a high-end test device.

## C5. Battery & Background Work — The Real Constraint Behind "RAM"

RAM usage and battery usage are related but distinct. A background service that wakes the CPU every 10 seconds to check for something can drain battery dramatically even with modest RAM usage.

```mermaid
flowchart TB
    subgraph BadBattery["❌ Aggressive Polling"]
        Timer1["Every 10 seconds, wake CPU"] --> Check1["Check server for new messages"]
        Check1 --> Sleep1["Sleep 10 sec"]
        Sleep1 --> Timer1
        Timer1 -.-> Drain["Radio + CPU wake constantly = battery drain,<br/>even if user hasn't touched the phone in hours"]
    end

    subgraph GoodBattery["✅ Push Notifications (event-driven)"]
        Idle["App/CPU stays asleep — zero battery cost"] --> PushArrives["Server sends a push notification via FCM/APNs<br/>only WHEN there's actually a new message"]
        PushArrives --> WakeBriefly["OS wakes app briefly, delivers notification"]
        WakeBriefly --> Idle
    end

    style Drain fill:#7f1d1d,color:#fff
    style Idle fill:#14532d,color:#fff
```

**Real example — WhatsApp/iMessage message delivery:** Neither app polls a server every few seconds asking "any new messages?" — that would be a battery disaster at scale. Both rely on **push notification infrastructure** (Firebase Cloud Messaging on Android, Apple Push Notification service on iOS) where the OS itself maintains one persistent, battery-efficient connection to deliver a "wake up, you have something" signal, and the app only does work in response to that signal.

**Relevant to your roadmap:** When you eventually build real messaging for Only Us (currently demo-only, per your README), this is the pattern to use — Firebase Cloud Messaging (which you already have as a dependency: `firebase_core`) rather than an in-app polling timer, specifically to avoid draining the user's battery just for message delivery.

## C6. Platform Channels — The Bridge You Already Built

Your **App Disguise** feature is a genuine advanced-level pattern — bridging Dart code to native platform APIs that Flutter doesn't expose by default.

```mermaid
flowchart TB
    subgraph DartSide["Dart / Flutter Side"]
        FlutterCode["AppDisguiseChannel.setDisguise('calculator')"]
    end

    subgraph Bridge["The Bridge (binary message channel)"]
        Serialize["Arguments serialized to a standard binary format"]
    end

    subgraph NativeSide["Native Side (Kotlin on Android / Swift on iOS)"]
        MethodChannel["MethodChannel.setMethodCallHandler"]
        NativeAPI["Calls PackageManager.setComponentEnabledSetting()<br/>— an Android API Flutter has NO built-in wrapper for"]
    end

    FlutterCode --> Serialize
    Serialize --> MethodChannel
    MethodChannel --> NativeAPI
    NativeAPI -.->|"result.success(true) travels back"| FlutterCode

    style Bridge fill:#374151,color:#fff
```

**Why this matters at the expert level:** Every cross-platform framework (Flutter, React Native, even web-based Capacitor/Cordova apps) is fundamentally limited to whatever the framework team has chosen to wrap. The moment you need something framework-agnostic — like your activity-alias switching, or biometric-specific edge cases, or a niche native SDK — you *must* understand platform channels (Flutter), Native Modules (React Native), or their equivalents. This is genuinely one of the more advanced skills in mobile dev, and you've already built a working example of it.

## C7. Testing Pyramid — Why Your Project Enforces 90% Coverage

```mermaid
flowchart TB
    E2E["🔺 End-to-End / Integration Tests<br/>Few in number, slow, test full user flows<br/>(e.g. 'login → send message → see it appear')"]
    Widget["🔷 Widget/Component Tests<br/>More in number, medium speed<br/>(e.g. 'does ChatBubble render the reply preview correctly')"]
    Unit["🔶 Unit Tests<br/>MANY, extremely fast, test pure logic<br/>(e.g. 'does PinHash.hash() produce a consistent SHA-256')"]

    E2E --> Widget --> Unit

    style E2E fill:#7f1d1d,color:#fff
    style Widget fill:#78350f,color:#fff
    style Unit fill:#14532d,color:#fff
```

**Why the pyramid shape, not a rectangle:** E2E tests are slow (seconds each) and brittle (a UI tweak can break them even if logic is correct) — so you want *few*. Unit tests are milliseconds each and test one thing in isolation — so you want *many*. Getting this balance backwards ("test everything end-to-end") is a common mistake that makes CI pipelines take 40 minutes instead of 3.

**Real example — why your project's `CLAUDE.md` mandates `mocktail` for every repository/datasource:** Production teams at companies like Google and Meta enforce this exact pattern — a `usecase` test should never make a real network call or touch a real database, because that test would then fail for reasons unrelated to the code being tested (network flakiness, a test database being in a weird state), destroying trust in the test suite over time.

---

# PART D — PUTTING IT ALL TOGETHER: A "Best Practices Checklist"

```mermaid
flowchart TB
    Start["Building a new screen/feature"] --> Q1{"Does this list<br/>have >20 items?"}
    Q1 -->|Yes| UseLazy["Use ListView.builder /<br/>lazy loading, never eager"]
    Q1 -->|No| Q2

    UseLazy --> Q2{"Does this show<br/>user/network images?"}
    Q2 -->|Yes| SizeImages["Decode at target display size,<br/>not full resolution"]
    Q2 -->|No| Q3

    SizeImages --> Q3{"Does this subscribe<br/>to a Stream/Listener?"}
    Q3 -->|Yes| Dispose["MUST cancel in dispose()"]
    Q3 -->|No| Q4

    Dispose --> Q4{"Does state change<br/>affect multiple screens?"}
    Q4 -->|Yes| Centralize["Use a single provider/store —<br/>never duplicate state"]
    Q4 -->|No| Q5

    Centralize --> Q5{"Is there background<br/>polling involved?"}
    Q5 -->|Yes| PushInstead["Replace with push notifications<br/>if at all possible"]
    Q5 -->|No| Q6

    PushInstead --> Q6{"Does this run on<br/>every keystroke/scroll event?"}
    Q6 -->|Yes| Debounce["Debounce or throttle it"]
    Q6 -->|No| Done["Ship it — profile with real device<br/>before calling it done"]

    style Done fill:#14532d,color:#fff
```

---

## Appendix: Where Only Us Already Applies These Patterns

| Pattern | Status in Only Us | File |
|---|---|---|
| Lazy lists | ✅ Done | `chat_screen.dart` uses `ListView.builder` |
| Single source of truth (auth state) | ✅ Done | `authProvider` + GoRouter redirect |
| Persistent storage for critical data | ✅ Done | `LocalMessageStore` / Isar |
| Disk-tier caching | ✅ Done | `CachedUserProfile` |
| Secure credential storage | ✅ Done | `flutter_secure_storage` for PIN hash |
| Cancel subscriptions/close sinks | ✅ Enforced by lint | `analysis_options.yaml` |
| Platform channel for native-only API | ✅ Done | `AppDisguiseChannel` + `AppDisguiseManager.kt` |
| Image decode-at-size | ⚠️ Not yet critical | Only fixed small assets so far; **revisit when adding photo messages** |
| Debounced search/input | ⚠️ N/A yet | No search feature yet — apply this pattern if one is added |
| Push notifications instead of polling | ⚠️ Roadmap item | Real messaging is still demo-only; use FCM when built |
| Widget rebuild scoping (small `Consumer`s) | ⚠️ Worth auditing | Check `chat_screen.dart` for over-broad `ref.watch` at top of `build()` |

---

## Glossary (Advanced Terms Used Above)

- **Jank** — a visibly dropped/delayed frame, perceived as stutter
- **Isolate (Dart)** — a separate memory heap + thread Dart can run code on, avoiding blocking the main isolate
- **Compositing layer** — a separate GPU-managed surface; more layers = more GPU work, but sometimes necessary for smooth animation
- **Retain cycle (Swift/ARC)** — two objects holding strong references to each other, preventing either from ever being freed
- **Generational GC** — a garbage collector strategy that treats new (likely short-lived) and old (likely long-lived) objects differently for efficiency
- **Debounce** — delay acting until input has paused for a set time (e.g. 300ms after last keystroke)
- **Throttle** — limit how often an action can fire, regardless of how often it's triggered (different from debounce — throttle still fires periodically during continuous input)
- **Overdraw** — painting the same pixel more than once per frame, wasting GPU work
- **Cold/Warm/Hot start** — the three levels of "how much has to be recreated" when a user opens an app
- **Push notification (FCM/APNs)** — event-driven server-to-device messaging, avoiding battery-draining polling
