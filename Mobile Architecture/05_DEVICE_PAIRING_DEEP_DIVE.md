# Device Pairing — Deep Dive (and: Could We Do It Like WhatsApp?)

How two phones actually find and connect to each other in this app, why it's designed the way it is, and an honest comparison against WhatsApp's "just add a number" model — including whether that model would even make sense for an app like this one.

---

## 1. The Fundamental Problem Pairing Solves

Two phones, on two different networks, with no prior connection to each other, need to agree: **"You and I are now going to talk, and we both know who the other one is."**

```mermaid
flowchart LR
    A["📱 Phone A<br/>(has no idea Phone B exists)"] -.->|"❓ No connection"| B["📱 Phone B<br/>(has no idea Phone A exists)"]
    A --> Need["Both need to discover EACH OTHER'S<br/>identity (Firebase uid) and agree<br/>to start a shared conversation"]
```

There are exactly two ways any app solves this:
1. **Out-of-band code exchange** — the two people exchange a secret (a code, a QR, a link) through some channel *outside* the app (voice, text, in person) — **this is what Only Us does**.
2. **Directory lookup** — the app already has a way to look you up by something you already know about the other person (their phone number) — **this is what WhatsApp does**.

These are genuinely different trust models, not just different UI. Let's go deep on both.

---

## 2. How Pairing Actually Works in This App — Full Low-Level Walkthrough

### Step 1: Generating a Code

```mermaid
sequenceDiagram
    participant DeviceA as Device A (Initiator)
    participant Firestore

    DeviceA->>DeviceA: generatePairCode() called
    DeviceA->>DeviceA: Random.secure().nextInt() picks<br/>6 characters from 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'<br/>(32 possible chars, no 0/O/1/I to avoid misreads)
    Note over DeviceA: 32^6 = ~1.07 BILLION possible codes.<br/>Guessing one specific code by brute<br/>force is computationally infeasible<br/>within the 10-minute expiry window.
    DeviceA->>Firestore: SET pairings/{code} = {<br/>  initiatorUid: "abc123",<br/>  initiatorName: "Alex",<br/>  status: "waiting",<br/>  createdAt: serverTimestamp(),<br/>  expiresAt: now + 10 minutes<br/>}
    Firestore-->>DeviceA: Confirms write succeeded
    DeviceA->>DeviceA: Displays code as TEXT + QR code
```

**Why `Random.secure()` and not a plain `Random()`?** Dart's default `Random()` is a pseudo-random number generator seedable and predictable in some contexts — fine for game logic, **not fine for anything security-adjacent**. `Random.secure()` pulls from the OS's cryptographically-secure random number source (which itself draws from hardware entropy — things like timing jitter, sensor noise). This matters because a *predictable* pairing code would let an attacker who somehow learned the generation pattern guess valid codes instead of needing all 1.07 billion attempts.

### Step 2: The Code Leaves the App (Out-of-Band)

```mermaid
flowchart LR
    DeviceA["Device A shows:<br/>'X7K2QP' + QR code"] --> Channel{"How does Device B<br/>learn this code?"}
    Channel --> Voice["🗣️ Said out loud"]
    Channel --> Text["💬 Texted via SMS/another app"]
    Channel --> InPerson["👀 Shown the screen directly"]

    Note1["None of these channels are<br/>controlled by Only Us or Firebase —<br/>this is the 'out-of-band' part"]
```

This is the crucial design choice: **the code transmission itself never touches this app's servers.** Only Us has zero visibility into *how* the code got from Device A to Device B — it could be whispered, texted, or shown on-screen. This is deliberately similar to how Signal's "safety number" verification works, or how a Wi-Fi password gets shared — the secret handshake token moves through a channel the app itself doesn't control or log.

### Step 3: Joining

```mermaid
sequenceDiagram
    participant DeviceB as Device B (Joiner)
    participant Firestore
    participant DeviceA as Device A (still watching)

    DeviceB->>DeviceB: User types "X7K2QP", taps Join
    DeviceB->>Firestore: GET pairings/X7K2QP
    Firestore-->>DeviceB: {initiatorUid, status: "waiting", expiresAt, ...}
    DeviceB->>DeviceB: Check: does it exist? Not expired?<br/>Status still "waiting"? Not my OWN code?
    alt All checks pass
        DeviceB->>Firestore: UPDATE pairings/X7K2QP:<br/>{joinerUid: "xyz789", joinerName: "Sam", status: "paired"}
        Note over DeviceA: Device A is LIVE-WATCHING this document<br/>via watchPairStatus() — a Firestore snapshot listener
        Firestore->>DeviceA: Snapshot update fires INSTANTLY<br/>(no polling — this is a real-time push)
        DeviceA->>DeviceA: Sees status == "paired",<br/>extracts joinerUid + joinerName
    else Any check fails
        DeviceB->>DeviceB: Show error: "not found" /<br/>"expired" / "already used"
    end
```

**The "watching" mechanism is the same real-time technology used throughout this app's chat** — `watchPairStatus()` opens a Firestore **snapshot listener**, which is a persistent connection where Firestore proactively pushes updates the instant a matching document changes, rather than Device A repeatedly asking "has anything changed yet?" (which would be inefficient polling — see the Mobile Expert Guide's section on push vs. polling for why this matters for battery).

### Step 4: The Conversation Gets Created

```mermaid
sequenceDiagram
    participant DeviceA
    participant Firestore

    Note over DeviceA: watchPairStatus() stream fires<br/>with joinerUid + joinerName
    DeviceA->>Firestore: ensureConversation():<br/>GET conversations/X7K2QP (does it exist?)
    Firestore-->>DeviceA: Doesn't exist yet
    DeviceA->>Firestore: SET conversations/X7K2QP = {<br/>  participantUids: ["abc123", "xyz789"],<br/>  participantNames: {abc123: "Alex", xyz789: "Sam"},<br/>  createdAt: serverTimestamp()<br/>}
    Note over DeviceA: The PAIRING CODE ITSELF becomes<br/>the CONVERSATION ID — a deliberate<br/>reuse, since it's already guaranteed unique
```

**Why reuse the pairing code as the conversation id?** It's already guaranteed unique (Firestore would have rejected a duplicate write if two people ever generated the identical random code, astronomically unlikely at 1-in-1.07-billion odds anyway), so generating a *second* unique id for the conversation would be redundant work solving an already-solved problem.

---

## 3. Security Analysis — Why This Design Is Actually Sound

```mermaid
flowchart TB
    Q1["Can a stranger guess a valid code?"] --> A1["Extremely unlikely: 1-in-1.07-billion,<br/>AND the code expires in 10 minutes,<br/>AND Firestore rules only allow reading<br/>a SPECIFIC document, not listing all codes"]

    Q2["Can someone reuse a code after it's paired?"] --> A2["No — joinWithCode() checks<br/>status == 'waiting' first; once 'paired',<br/>Firestore rules ALSO enforce this<br/>server-side (defense in depth, Guide 4)"]

    Q3["Can the initiator's identity be spoofed?"] --> A3["No — initiatorUid comes from<br/>FirebaseAuth.instance.currentUser.uid,<br/>which is cryptographically tied to that<br/>device's authenticated session (Guide 1)<br/>— not a value the client can fake"]

    Q4["What if someone intercepts the code<br/>in transit (e.g. reads an SMS)?"] --> A4["⚠️ Real risk — see Section 5.<br/>This is the SAME risk category as anyone<br/>intercepting a Wi-Fi password shared via SMS"]

    style A1 fill:#14532d,color:#fff
    style A2 fill:#14532d,color:#fff
    style A3 fill:#14532d,color:#fff
    style A4 fill:#78350f,color:#fff
```

**The Firestore rules doing real enforcement work here** (from `firestore.rules`):
```
allow update: if request.auth != null
  && resource.data.status == 'waiting'
  && request.resource.data.joinerUid == request.auth.uid;
```
This isn't just app-code politeness — it's a **server-side guarantee**. Even if someone reverse-engineered the app and tried to call Firestore directly (bypassing the Flutter UI entirely), this rule still blocks joining an already-paired code, and still requires `joinerUid` to match whoever is actually authenticated in that request. The client-side checks in `PairingService.joinWithCode()` are a nice UX (fast local validation, friendly error messages) — the *real* security boundary is the server-enforced rule, which cannot be bypassed by a modified or malicious client.

---

## 4. High-Level Overview — The Whole Flow in One Diagram

```mermaid
flowchart TB
    subgraph DeviceA["📱 Device A"]
        A1["Tap 'Generate Pair Code'"]
        A2["Show code + QR"]
        A3["Watch for pairing<br/>(live Firestore listener)"]
        A4["See 'Paired!' → tap 'Go to Chat'"]
    end

    subgraph OutOfBand["🗣️ Out-of-band channel<br/>(voice / text / in-person — NOT this app)"]
        Code["'X7K2QP'"]
    end

    subgraph Firestore["☁️ Firestore"]
        PairDoc["pairings/X7K2QP<br/>{status, initiatorUid, joinerUid...}"]
        ConvDoc["conversations/X7K2QP<br/>{participantUids, ...}"]
    end

    subgraph DeviceB["📱 Device B"]
        B1["Enter code, tap 'Join'"]
        B2["See 'Paired!' → tap 'Go to Chat'"]
    end

    A1 --> A2 --> Code
    Code --> B1
    A2 -.->|writes| PairDoc
    B1 -.->|reads, then updates| PairDoc
    PairDoc -.->|live push| A3
    A3 --> A4
    A4 -.->|creates| ConvDoc
    B2 -.->|reads| ConvDoc
    A3 --> B2

    style Code fill:#78350f,color:#fff
    style PairDoc fill:#14532d,color:#fff
    style ConvDoc fill:#14532d,color:#fff
```

---

## 5. Now — Could We Do It Like WhatsApp Instead? ("Just Add a Number")

This is a genuinely different architecture, not a small tweak. Let's break down what WhatsApp *actually* does under the hood.

### How WhatsApp's Model Really Works

```mermaid
sequenceDiagram
    participant You as Your Phone
    participant WhatsAppServer as WhatsApp Servers
    participant Contacts as Your Phone's Contacts

    Note over You,WhatsAppServer: At SIGNUP (once, ever)
    You->>WhatsAppServer: Phone number "+1-555-0123"
    WhatsAppServer->>You: SMS with a 6-digit OTP code
    You->>WhatsAppServer: Enters OTP — proves you OWN this number
    Note over WhatsAppServer: Your account is now PERMANENTLY<br/>tied to this verified phone number

    Note over You,WhatsAppServer: Every time you open the app (contact discovery)
    You->>Contacts: Read entire contact list (with permission)
    You->>You: Hash each phone number locally<br/>(e.g. SHA-256 of "+1-555-0199")
    You->>WhatsAppServer: Send the HASHED numbers (not raw numbers, in theory)
    WhatsAppServer->>WhatsAppServer: Check which hashes match<br/>REGISTERED WhatsApp accounts
    WhatsAppServer->>You: "These 47 of your 300 contacts are on WhatsApp"
    Note over You: No explicit 'pairing' step needed —<br/>you already know their number is registered,<br/>so you just tap and start typing
```

**The critical enabling fact**: WhatsApp's *identity system itself* is the phone number, verified once via SMS OTP. Because identity = a real-world, already-known piece of information (a phone number you already have in your contacts), there's no need for an explicit "handshake" step — discovery *is* the pairing. Only Us's identity system is email + password (Firebase Auth, Guide 1), which is **not** something you'd already have about the other person the way you have their phone number.

### Could This App Add Phone-Number Discovery? Yes, Technically.

```mermaid
flowchart TB
    Step1["1. Add Firebase Phone Auth<br/>(Firebase already supports this —<br/>SMS OTP verification, same tech WhatsApp uses)"]
    Step2["2. Store a lookup collection:<br/>phoneHashes/{hash(phoneNumber)} → uid"]
    Step3["3. Request CONTACTS permission<br/>(permission_handler is already a dependency)"]
    Step4["4. Hash the user's local contacts,<br/>query Firestore for matches"]
    Step5["5. Show 'X of your contacts use Only Us' —<br/>tap to start chatting, no code needed"]

    Step1 --> Step2 --> Step3 --> Step4 --> Step5

    style Step1 fill:#14532d,color:#fff
```

Every piece of this is technically buildable with packages already available in the Flutter ecosystem (`firebase_auth`'s phone provider, a `contacts_service`-style package, the existing `permission_handler`). This is **not** a hypothetical — it's a well-understood, common pattern.

### But Here's the Actual Tradeoff — and Why It May Not Fit *This* App

```mermaid
flowchart LR
    subgraph CurrentModel["Current: Explicit Code Pairing"]
        C1["✅ Nobody can find you<br/>unless YOU hand them a code"]
        C2["✅ No phone number required —<br/>fits an app built around discretion"]
        C3["✅ No contacts list ever leaves the device"]
        C4["❌ Slightly more friction —<br/>an explicit step to connect"]
    end

    subgraph PhoneModel["WhatsApp-style: Phone Discovery"]
        P1["✅ Zero-friction — 'just add a number'"]
        P2["❌ Requires linking a REAL phone number<br/>to the account, permanently"]
        P3["❌ Requires uploading your contact list<br/>(even hashed) to a server"]
        P4["❌ A phone number's hash space is<br/>SMALL (~10 billion possible numbers) —<br/>crackable by brute-forcing all hashes,<br/>unlike this app's 1.07-billion-code,<br/>time-limited pairing token"]
    end

    style C1 fill:#14532d,color:#fff
    style C2 fill:#14532d,color:#fff
    style C3 fill:#14532d,color:#fff
    style P2 fill:#7f1d1d,color:#fff
    style P3 fill:#7f1d1d,color:#fff
    style P4 fill:#7f1d1d,color:#fff
```

**The phone-hash cracking point (P4) deserves real explanation** — this is a genuine, widely-known criticism of contact-discovery systems generally (not specific to WhatsApp, but well-documented in security research about this pattern): there are only about 10 billion possible phone numbers globally (much fewer in any single country code), so an attacker can simply **precompute the hash of every possible phone number once** and permanently reverse any hash they later see — unlike this app's pairing code, hashing a phone number doesn't actually protect it, because the *input space* is small enough to exhaustively hash in advance. This is exactly the "rainbow table" problem from Guide 2, applied to phone numbers instead of PINs. Real-world systems that need contact discovery mitigate this with more advanced cryptographic techniques (Private Set Intersection protocols, or hardware-backed secure enclaves that even the server operator can't inspect) — meaningfully more complex than "just hash and compare."

### My Honest Take, Given This App's Actual Design Goals

This app's entire design philosophy — App Disguise, Fake PIN, deliberately avoiding relationship-specific wording, no permanent visible "Pair" tab — is built around **discretion and minimizing footprint**. Adding phone-number verification and contact-list access would work *against* that goal in two concrete ways: (1) it permanently ties an account to a real phone number, and (2) it requires a Contacts permission grant that itself could raise questions if someone glances at the phone's app permissions list. The current explicit-code model, while requiring one extra step, has **zero such footprint** — no phone number, no contacts access, nothing to explain if someone reviews the app's permissions.

**If reducing friction is the actual goal** (not literally copying WhatsApp's exact mechanism), a smaller, better-fitting improvement would be: making the QR-scan path work (currently manual-entry only, per Guide 3's/README's earlier note) so pairing becomes "scan the other person's screen" instead of "read/type six characters" — same privacy properties, less friction, no new permission or identity model required.

---

## Glossary

- **Out-of-band channel** — a communication path outside the system being secured (e.g. saying a code out loud instead of sending it through the app itself)
- **Snapshot listener** — a persistent, real-time subscription to a Firestore document/query that pushes updates instantly instead of polling
- **Cryptographically secure random number generator (CSPRNG)** — a random source suitable for security purposes, seeded from real hardware entropy, unlike a plain pseudo-random generator
- **Contact discovery** — the technique of matching a user's phone contacts against a service's registered users, typically via hashing
- **Private Set Intersection (PSI)** — advanced cryptographic protocols letting two parties find common elements between their data sets without revealing the rest of either set — the "real" fix for contact-discovery privacy leakage
- **Rainbow table attack** — precomputing hashes of all likely inputs so any observed hash can be reversed instantly; effective when the input space (like phone numbers) is small enough to exhaust
