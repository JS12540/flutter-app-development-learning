# Mobile Notifications — Deep Dive (Android & iOS)

How notifications actually reach your phone, why the answer is completely different depending on whether the app is alive or fully killed, and exactly what this app does at each layer. Grounded in the real implementation: `LocalNotificationService`, `MessageNotificationManager`, `FcmService`, and `fcm_background_handler.dart`.

---

## 1. The Core Confusion Beginners Have

"My app shows a notification" sounds like one feature. It is actually **two completely different mechanisms** depending on whether your app's process is running:

```mermaid
flowchart TB
    Q["A new message arrives.<br/>Is your app's process alive?"] --> Alive["✅ App alive (foreground<br/>or backgrounded, not killed)"]
    Q --> Dead["❌ App fully force-quit /<br/>never launched since reboot"]

    Alive --> Mech1["Mechanism 1:<br/>YOUR OWN CODE detects the<br/>new data and shows a notification"]
    Dead --> Mech2["Mechanism 2:<br/>The OS itself wakes a tiny<br/>piece of your app briefly,<br/>triggered by a REMOTE server"]

    style Mech1 fill:#14532d,color:#fff
    style Mech2 fill:#78350f,color:#fff
```

This single distinction explains almost every confusing thing about mobile notifications — including exactly why this app's notifications didn't work for a force-quit device until a server-side piece was added.

---

## 2. Mechanism 1 — App Alive: You're Just Watching Data Yourself

When your app process is running (foreground, or backgrounded but not killed), there's no magic here at all — it's just regular code, running continuously, that decides to show a notification.

```mermaid
sequenceDiagram
    participant Firestore
    participant Listener as MessageNotificationManager (your code)
    participant OS as Android/iOS notification tray

    Note over Listener: App process is alive — this<br/>Dart code is actively running
    Firestore->>Listener: New message document arrives<br/>(live snapshot listener, no polling)
    Listener->>Listener: Is this NEW and not from me?
    Listener->>OS: LocalNotificationService.show(title, body)
    OS->>OS: Displays the notification banner
```

**This is exactly what `message_notification_manager.dart` does** — it holds a live Firestore subscription (`watchMyConversations()` → `watchMessages()`) that's only running because your app's Dart isolate is alive. The moment you force-quit the app, this code stops executing entirely — there's no more "your code" for anything to run.

**Why this can't possibly work for a killed app**: there is no process, no listener, nothing. Code that isn't running can't detect anything or call anything. This isn't a bug to fix with better code — it's a structural fact about what "the app is killed" means.

---

## 3. Mechanism 2 — App Killed: The OS Itself Has to Wake You

This is the part that actually requires external infrastructure, and it's the same on both platforms conceptually (though the specific services differ).

```mermaid
flowchart TB
    subgraph Persistent["What survives even when YOUR app is killed"]
        OSConn["The OS maintains its OWN persistent,<br/>battery-efficient connection to<br/>Google's/Apple's push servers —<br/>this connection is NOT your app's;<br/>it belongs to the operating system itself"]
    end

    Persistent --> Trigger["Some SERVER (yours, or a\nthird party's) tells Google/Apple:<br/>'wake up THIS specific device,<br/>THIS specific app, with THIS payload'"]
    Trigger --> Wake["OS receives it, briefly starts<br/>a minimal instance of your app<br/>JUST to process this one event"]
    Wake --> Handler["Your app's designated<br/>'background handler' function runs,<br/>decides what to show, then the<br/>process is torn down again"]

    style OSConn fill:#14532d,color:#fff
    style Trigger fill:#78350f,color:#fff
```

**Critical insight**: this "wake the app briefly" capability is a privilege the OS grants specifically to its own push service (Firebase Cloud Messaging on Android, Apple Push Notification service/APNs on iOS) — not to random code. Your app cannot simply "listen in the background forever" on a killed process; that would let every app drain battery/RAM constantly, which both Android and iOS explicitly forbid. The OS-level push channel is the ONE narrow exception, and it only exists because Google/Apple built and maintain it as core OS infrastructure.

---

## 4. Why a Server Is Unavoidable for Mechanism 2 (This Is the Part That Confused Us Earlier)

```mermaid
sequenceDiagram
    participant Sender as Sender's Phone
    participant YourServer as A server YOU control<br/>(this app: Cloudflare Worker)
    participant FCM as Google's FCM servers
    participant OS as Recipient's OS<br/>(background push channel)
    participant App as Recipient's App<br/>(briefly woken)

    Sender->>YourServer: "Hey, tell FCM to notify this device"
    Note over YourServer: MUST prove it's authorized —<br/>using a SECRET credential that<br/>can never live in a mobile app
    YourServer->>FCM: Signed, authenticated request:<br/>"send this payload to device token X"
    FCM->>OS: Delivers via the OS's persistent<br/>background connection
    OS->>App: Wakes app briefly with the payload
    App->>App: Background handler runs,<br/>shows the actual notification
```

**Why can't the sender's phone just call FCM directly, skipping a server?** Because authenticating to FCM's real send API (HTTP v1) requires a **Google service account private key** — a credential that, if embedded in a mobile app, could be extracted by anyone who decompiles the APK, and then used to send arbitrary push notifications to *every device* registered to your entire Firebase project. This is a categorically different risk than, say, an API key meant to be public — it's specifically designed to be a server-only secret. There is no way around needing *something* (a server, however small) to hold that secret safely. This is universally true — WhatsApp, Instagram, every app with real push notifications has a backend doing exactly this.

**This project's specific answer**: rather than Firebase Cloud Functions (which needs the paid Blaze plan), a free Cloudflare Worker plays the "something with the secret" role — same pattern already used for the Cloudinary media-deletion secret earlier in this project. The mechanism is generic; the specific free hosting choice is not.

---

## 5. Android Specifics — FCM

```mermaid
flowchart TB
    subgraph AndroidStack["Android's Notification Stack"]
        FCMToken["Each installed app instance gets<br/>a unique FCM 'registration token'<br/>(like a mailing address for that<br/>specific app+device combo)"]
        FCMToken --> StoreToken["App sends this token to<br/>whatever server needs to notify it<br/>(this app: written into the<br/>Firestore conversation doc)"]
        StoreToken --> ServerSend["Server later calls FCM's send API<br/>with that exact token"]
        ServerSend --> Payload{"Message type?"}
        Payload -->|"'notification' payload"| AutoDisplay["OS auto-displays a generic<br/>notification using the payload's<br/>title/body — app doesn't even<br/>need to be running any code"]
        Payload -->|"'data' payload (this app's choice)"| WakeApp["OS wakes the app's<br/>background handler function,<br/>YOUR code decides what to show"]
    end

    style WakeApp fill:#14532d,color:#fff
```

**Why this app deliberately uses a data-only payload, not the simpler auto-display option**: with an auto-display "notification" payload, the SENDER'S server would have to already know what text to put in the title/body — which would mean either revealing the recipient's chosen Home Screen Disguise to the sender (a privacy leak this app specifically avoids) or hardcoding something generic and never disguise-aware. Using a data-only payload instead means the OS just wakes the recipient's own code, which reads the recipient's OWN locally-stored disguise preference and decides the notification content itself — nobody else ever needs to know it.

```mermaid
sequenceDiagram
    participant CloudflareWorker
    participant FCM
    participant AndroidOS as Android OS (recipient device)
    participant Handler as fcm_background_handler.dart<br/>(runs in a FRESH isolate)
    participant Prefs as SharedPreferences<br/>(local to this device)

    CloudflareWorker->>FCM: data: {type: "new_message", conversationId}
    FCM->>AndroidOS: Deliver via background push channel
    AndroidOS->>Handler: Spin up a fresh Dart isolate,<br/>call firebaseMessagingBackgroundHandler()
    Handler->>Prefs: Read locally-stored disguise index<br/>(NOT via Riverpod — no provider tree<br/>exists in this throwaway isolate)
    Prefs-->>Handler: e.g. index 1 = "notepad"
    Handler->>Handler: LocalNotificationService.showNewMessageForIndex(1)
    Handler->>AndroidOS: Show "Notes — You have a new note"
```

**Why the background handler can't use Riverpod**: Android creates a brand-new, minimal Dart isolate just to run this one function, then destroys it — there's no `ProviderScope`, no widget tree, none of the app's normal state management running. This is why `fcm_background_handler.dart` reads `SharedPreferences` directly with the exact same storage key `HomeScreenDisguiseNotifier` uses, rather than trying to read the Riverpod provider (which doesn't exist in this isolate).

---

## 6. iOS Specifics — APNs (Apple Push Notification service)

iOS's equivalent is architecturally similar but has real differences worth knowing, even though this app is Android-only today:

```mermaid
flowchart TB
    subgraph iOSStack["iOS's Notification Stack"]
        APNsToken["App registers with APNs,<br/>gets a device token"]
        APNsToken --> ServerHasToken["Server needs this token<br/>(same concept as FCM's token)"]
        ServerHasToken --> Auth["Server authenticates to APNs using<br/>EITHER a p8 auth key (simpler, modern)<br/>OR a full push certificate (older)"]
        Auth --> Send["Server sends the payload<br/>to APNs' servers"]
        Send --> Deliver["APNs delivers via iOS's own<br/>persistent background connection —<br/>conceptually identical to FCM's role"]
    end

    Deliver --> Silent{"Payload type?"}
    Silent -->|"Regular push"| Display["iOS shows it automatically,<br/>can also wake a Notification<br/>Service Extension to modify content"]
    Silent -->|"'content-available: 1'<br/>(silent/background push)"| Background["Wakes app's background<br/>fetch handler — closest<br/>iOS equivalent to Android's<br/>data-only message + background handler"]

    style Background fill:#14532d,color:#fff
```

**Key practical difference from Android**: iOS is significantly stricter about background execution time and frequency — a silent push doesn't guarantee your background code gets to run promptly or even at all if the OS decides the app has used its background budget too aggressively recently. Android's guarantee (via FCM's high-priority data messages) is generally more reliable for "wake me up right now" scenarios. This is a real, documented platform difference, not an implementation gap — Apple deliberately throttles background pushes harder to protect battery life fleet-wide.

---

## 7. Notification Permissions — What You Actually Have to Ask For

```mermaid
flowchart TB
    subgraph AndroidPerm["Android Permissions"]
        A12["Android 12 and below:<br/>Notifications allowed automatically,<br/>no runtime prompt needed"]
        A13["Android 13+ (API 33+):<br/>POST_NOTIFICATIONS is a<br/>DANGEROUS permission —<br/>must be requested at runtime,<br/>user can deny it"]
    end

    subgraph iOSPerm["iOS Permissions"]
        iOSReq["ALWAYS requires an explicit<br/>runtime request via<br/>UNUserNotificationCenter,<br/>regardless of iOS version —<br/>iOS has required this since<br/>notifications existed"]
    end

    style A13 fill:#78350f,color:#fff
    style iOSReq fill:#78350f,color:#fff
```

**In this app's code**: `LocalNotificationService.initialize()` calls `Permission.notification.request()` — this is specifically needed because of Android 13's stricter rule (declaring `POST_NOTIFICATIONS` in `AndroidManifest.xml` alone does nothing without also requesting it at runtime, which is why that permission was added there earlier in this project). If the user denies this permission, notifications will silently fail to display — there's no way to force them, by design, on both platforms.

---

## 8. Putting It All Together — This App's Full Notification Architecture

```mermaid
flowchart TB
    NewMsg["New message sent"] --> CheckAlive{"Is recipient's app<br/>process alive?"}

    CheckAlive -->|Yes| Live["MessageNotificationManager's live<br/>Firestore listener detects it,<br/>shows a local notification directly<br/>— NO server round-trip needed"]

    CheckAlive -->|"Unknown / possibly killed"| Push["FcmService.notifyOtherParticipant()<br/>also fires, regardless"]
    Push --> Worker["Cloudflare Worker signs a request,<br/>calls FCM's real send API"]
    Worker --> FCMSend["FCM delivers via Android's<br/>persistent OS-level connection"]
    FCMSend --> BgHandler["fcm_background_handler.dart wakes,<br/>even if the app was fully killed"]
    BgHandler --> ShowIt["Shows the same disguise-aware<br/>notification, read from local prefs"]

    Live --> Note["Both paths CAN fire for the<br/>same message — that's fine,<br/>Android naturally coalesces/dedupes<br/>near-identical notifications in<br/>most cases, and worst case the<br/>user just sees it twice briefly"]

    style Live fill:#14532d,color:#fff
    style BgHandler fill:#14532d,color:#fff
```

**Why both mechanisms run simultaneously rather than picking one**: they cover genuinely different situations. The live-listener path is instant and needs zero external infrastructure when it works, but only works while the process is alive. The FCM path is the only one that reaches a killed app, but depends on the Cloudflare Worker being deployed and network conditions cooperating. Running both means the app degrades gracefully — deploy the Worker and you get full coverage; skip it and you still get live-app notifications for free.

---

## Glossary

- **FCM (Firebase Cloud Messaging)** — Google's free, unlimited push notification service for Android (and cross-platform via Firebase)
- **APNs (Apple Push Notification service)** — Apple's equivalent for iOS
- **Registration/device token** — a unique identifier for one specific app installation on one specific device, used to address a push to it
- **Data-only vs notification payload** — a data payload wakes your own code to decide what to show; a notification payload lets the OS auto-display without your code running at all
- **Background handler** — a designated function the OS calls in a fresh, short-lived process/isolate when a push arrives and the app isn't otherwise running
- **Dangerous permission (Android)** — a permission category requiring an explicit runtime user grant, not just a manifest declaration
- **Service account** — a machine identity credential (not tied to a human user) used for server-to-server authentication, like a Cloudflare Worker calling FCM
