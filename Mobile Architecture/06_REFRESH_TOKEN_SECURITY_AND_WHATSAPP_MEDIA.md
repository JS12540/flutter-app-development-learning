# Refresh Token Attacks & Defenses, and How WhatsApp Actually Encrypts Media

Two related deep-dives: (1) what happens if a refresh token is stolen, and the real production defenses against it — including an honest check of what *this app's* Firebase Auth actually does vs. the more advanced schemes companies like LinkedIn use — and (2) exactly how WhatsApp encrypts and stores images/GIFs, compared directly to how Only Us does it today.

---

# PART A — Refresh Token Theft: Attacks and Defenses

## A1. The Baseline Flow (Recap, Corrected Slightly)

```mermaid
sequenceDiagram
    participant Client
    participant Server

    Client->>Server: Login (email + password)
    Server-->>Client: Access Token (short-lived, e.g. 15min-1hr)<br/>+ Refresh Token (long-lived, e.g. 30 days)

    loop Every API call
        Client->>Server: Request + Access Token
        Server-->>Client: Response (if token valid)
    end

    Note over Client,Server: Access Token expires
    Client->>Server: Send Refresh Token
    Server->>Server: Verify refresh token is valid
    Server-->>Client: New Access Token (+ possibly new Refresh Token)
```

This matches how this app's own auth works too (see Guide 1) — Firebase's SDK plays the role of "Client" here, doing this refresh dance automatically in the background, so `FirebaseAuth.instance.currentUser` never needs you to manually intervene.

## A2. The Theft Scenario — Why a Stolen Refresh Token Is So Dangerous

```mermaid
sequenceDiagram
    participant You
    participant Attacker
    participant Server

    Note over You,Attacker: Refresh Token somehow leaks<br/>(malware, XSS, insecure storage, network capture)
    Attacker->>Server: Sends the stolen Refresh Token
    Server->>Server: Token is cryptographically valid —<br/>server has NO way to distinguish<br/>"real you" from "attacker with your token"
    Server-->>Attacker: New Access Token issued
    Note over Attacker: Attacker now has full API access —<br/>WITHOUT ever knowing your password
```

**The core danger**: a refresh token is a bearer credential — whoever *possesses* it is treated as authenticated, full stop. Unlike a password, there's no additional "prove you know this" step at refresh time. This is exactly why every defense below exists.

## A3. Defense 1 — Secure, HttpOnly Storage (Web Context)

```mermaid
flowchart LR
    subgraph Bad["❌ Refresh token in localStorage/JS-accessible cookie"]
        XSS["Any XSS vulnerability anywhere<br/>on the page can run:<br/>document.cookie or localStorage.getItem()"]
        XSS --> Steal["Attacker's injected JS<br/>exfiltrates the token"]
    end

    subgraph Good["✅ HttpOnly Secure Cookie"]
        Cookie["Cookie flagged HttpOnly —<br/>JavaScript CANNOT read it,<br/>even via a successful XSS injection"]
        Cookie --> Safe["Cookie only sent automatically<br/>by the browser on requests to the<br/>right domain, over HTTPS (Secure flag)"]
    end

    style Steal fill:#7f1d1d,color:#fff
    style Safe fill:#14532d,color:#fff
```

**This specific defense is web-browser-specific** — mobile apps (like Only Us) don't have cookies or XSS in the browser sense. The mobile equivalent is **Android Keystore / iOS Keychain** storage (see Guide 1, Section 5) — hardware-backed, not readable by other apps, and not extractable even with root access on a patched device. Different mechanism, same underlying goal: make the token inaccessible to anything except the legitimate app/browser session.

## A4. Defense 2 — Refresh Token Rotation

This is the most important mechanism, and worth being precise about exactly how it works:

```mermaid
sequenceDiagram
    participant Client
    participant Server
    participant DB as Server's Token Database

    Client->>Server: Login
    Server->>DB: Store Refresh Token A (hashed)
    Server-->>Client: Access Token 1 + Refresh Token A

    Note over Client,Server: Time passes, Access Token 1 expires
    Client->>Server: Refresh using Token A
    Server->>DB: Check: is Token A valid & unused?
    DB-->>Server: Yes
    Server->>DB: Mark Token A as USED,<br/>store new Refresh Token B (hashed)
    Server-->>Client: Access Token 2 + Refresh Token B<br/>(Token A is now DEAD)

    Note over Client,Server: Later — an attacker who stole Token A tries it
    Client->>Server: (Attacker) Refresh using Token A
    Server->>DB: Check: is Token A valid & unused?
    DB-->>Server: Token A was ALREADY marked used!
    Server-->>Client: ❌ REJECTED
```

**The key insight**: each refresh token is single-use. The instant it's used once, it's invalidated and replaced. A stolen *old* token that the real user has already refreshed past is worthless — it's already dead in the server's records.

## A5. Defense 3 — Reuse Detection (The Clever Part)

This catches theft **even when the attacker uses the stolen token before the real user does**:

```mermaid
flowchart TB
    Scenario["Attacker steals Refresh Token A<br/>and uses it FIRST, before you do"] --> ServerIssues["Server rotates it normally:<br/>issues Token B to the attacker,<br/>marks A as used"]
    ServerIssues --> YouTry["Later, YOU (the real owner)<br/>try to refresh using Token A<br/>(you didn't know it was already used)"]
    YouTry --> ServerDetects["Server sees: 'Token A is being used<br/>AGAIN, but it's already marked used!'"]
    ServerDetects --> Alarm["🚨 This is the signature of theft —<br/>a legitimate client would never<br/>reuse an already-rotated token"]
    Alarm --> Response["Server response: revoke EVERY refresh<br/>token for this account, force full<br/>re-login, optionally alert the user"]

    style Alarm fill:#7f1d1d,color:#fff
    style Response fill:#14532d,color:#fff
```

**Why this specific signal is so reliable**: in normal, honest operation, a refresh token is used exactly once and then discarded by its legitimate holder. The *only* way a used-and-rotated token gets presented again is if there are now **two parties holding a copy of what was supposed to be a single-use secret** — which can only happen if it was stolen at some point. The server doesn't need to know *how* it leaked; the reuse pattern itself is the alarm.

## A6. Defense 4 — Binding Tokens to Device/Session Metadata

```mermaid
flowchart TB
    Table["Server's token record:<br/>{token_hash, user_id, device_fingerprint,<br/>ip_address, user_agent, created_at, last_used_at}"]
    Table --> Check["On each refresh: does the request's<br/>IP/device/user-agent roughly match<br/>what was recorded at creation?"]
    Check -->|Mismatch| Suspicious["Flag as suspicious —<br/>could require MFA re-verification,<br/>or reject outright"]
    Check -->|Match| Proceed["Proceed normally"]

    style Suspicious fill:#78350f,color:#fff
```

This is a *heuristic*, not a hard guarantee (IP addresses change legitimately — mobile networks, VPNs, travel), so production systems usually treat a mismatch as "add friction / require re-verification" rather than an instant hard block, to avoid locking out legitimate users too aggressively.

## A7. Defense 5 — "Log Out Everywhere" and Defense 6 — Expiration

Both are simple but essential: a server-side revocation list (or database delete) that the "log out all devices" button triggers, and a hard ceiling (7/30/90 days) so even a token that somehow evades all other detection eventually stops working on its own.

## A8. So — What Does *This App* (Firebase Auth) Actually Do?

Time for an honest check against the real implementation, not just theory.

```mermaid
flowchart TB
    Feature["Security Feature"] --> Rotation{"Refresh token rotation<br/>on every use?"}
    Rotation --> RotationAnswer["❌ NOT by default — Firebase's refresh<br/>tokens are long-lived and REUSED across<br/>refresh calls, not rotated each time"]

    Feature --> ReuseDetect{"Reuse detection?"}
    ReuseDetect --> ReuseAnswer["❌ Not exposed to this app —<br/>this is Google's internal infrastructure;<br/>not a Flutter/Firebase Auth SDK feature<br/>you configure"]

    Feature --> Revoke{"Can revoke all sessions?"}
    Revoke --> RevokeAnswer["✅ Yes — Firebase Admin SDK's<br/>revokeRefreshTokens(uid) exists,<br/>but requires SERVER-SIDE admin code<br/>(not present in this Flutter-only app today)"]

    Feature --> Storage{"Secure storage on-device?"}
    Storage --> StorageAnswer["✅ Yes — Android Keystore /<br/>iOS Keychain, as covered in Guide 1"]

    Feature --> Expiry{"Hard expiration?"}
    Expiry --> ExpiryAnswer["⚠️ No FIXED expiry — Google's refresh<br/>tokens remain valid indefinitely unless<br/>explicitly revoked or unused for an<br/>extended period"]

    style RotationAnswer fill:#78350f,color:#fff
    style ReuseAnswer fill:#78350f,color:#fff
    style RevokeAnswer fill:#14532d,color:#fff
    style StorageAnswer fill:#14532d,color:#fff
    style ExpiryAnswer fill:#78350f,color:#fff
```

**Why the gap is acceptable here (but wouldn't be for a bank)**: Firebase deliberately optimizes its refresh token model for *convenience at consumer-app scale* rather than the more paranoid rotation/reuse-detection scheme LinkedIn-style enterprise systems build themselves on top of raw OAuth. Google's own infrastructure does have anomaly detection at a platform level (unusual sign-in location prompts, "new device" email alerts on some Google products), but that's Google's *account* security layer, separate from and mostly invisible to what a Firebase Auth *app developer* configures. If this app ever needed LinkedIn-grade protection, the correct move would be layering **Firebase Admin SDK server-side code** (a Cloud Function) that tracks device/session metadata *on top of* Firebase Auth — Firebase gives you the identity primitive, not the full enterprise session-security stack, by design.

---

# PART B — How WhatsApp Actually Encrypts and Stores Images/GIFs

## B1. The Short Answer

**WhatsApp media (photos, videos, GIFs, voice notes) is encrypted client-side before upload, and WhatsApp's servers store only ciphertext — genuinely unreadable to WhatsApp itself.** This is a real, verified end-to-end encryption implementation (published in WhatsApp's own security whitepaper, and independently audited), not marketing language.

## B2. The Full Flow — Step by Step

```mermaid
sequenceDiagram
    participant Sender as Sender's Phone
    participant WAServer as WhatsApp Media Server
    participant Recipient as Recipient's Phone

    Note over Sender: User picks a GIF/photo to send
    Sender->>Sender: Generate a RANDOM AES-256 key<br/>(unique to THIS SPECIFIC media file only)
    Sender->>Sender: Encrypt the media file with this random key
    Sender->>Sender: Compute SHA-256 hash of the CIPHERTEXT<br/>(for integrity verification later)
    Sender->>WAServer: Upload the CIPHERTEXT (encrypted blob)
    WAServer-->>Sender: Returns a media URL/reference

    Note over Sender: Now send the actual "message"
    Sender->>Sender: Package {media URL, the random AES key,<br/>the SHA-256 hash} into the message content
    Sender->>Sender: Encrypt THIS ENTIRE PACKAGE using the<br/>Signal Protocol session key shared<br/>ONLY with the specific recipient<br/>(established via a real Diffie-Hellman<br/>key exchange when you first messaged them)
    Sender->>WAServer: Send the E2E-encrypted message<br/>(which itself contains the media's key, encrypted)
    WAServer->>Recipient: Forwards the E2E-encrypted message<br/>(WhatsApp CANNOT read this envelope either)

    Recipient->>Recipient: Decrypts the message using the<br/>Signal Protocol session key<br/>→ extracts media URL + AES key + hash
    Recipient->>WAServer: Downloads the ciphertext blob using the URL
    Recipient->>Recipient: Verifies SHA-256 hash matches<br/>(confirms it wasn't tampered with)
    Recipient->>Recipient: Decrypts the media using the<br/>extracted AES key → real photo/GIF
```

## B3. The Critical Design Detail — Where Does the Media Key Actually Travel?

This is the exact piece that makes it genuinely end-to-end, and it's the precise thing Guide 3 flagged as **missing** in Only Us's current implementation:

```mermaid
flowchart TB
    subgraph WhatsApp["✅ WhatsApp's approach"]
        Key1["Media's AES key travels INSIDE<br/>the Signal-Protocol-encrypted message"]
        Key1 --> OnlyRecipient["Only the intended recipient's device<br/>can decrypt that message envelope<br/>(established via real key exchange<br/>at conversation start)"]
        OnlyRecipient --> ServerBlind["WhatsApp's media server NEVER sees<br/>the AES key — it only ever handles<br/>the already-encrypted blob"]
    end

    subgraph OnlyUsCurrent["⚠️ Only Us's current approach (Guide 3, Section 4)"]
        Key2["Media's AES key is generated<br/>PER-DEVICE, stored locally,<br/>never transmitted to the other device"]
        Key2 --> Gap["Recipient's device has a DIFFERENT key<br/>— can't decrypt what Device A encrypted"]
    end

    style ServerBlind fill:#14532d,color:#fff
    style Gap fill:#7f1d1d,color:#fff
```

**This directly validates the fix already proposed in Guide 3**: the missing piece in Only Us is exactly the mechanism WhatsApp relies on — transmitting the *media's encryption key* through an already-established, genuinely end-to-end encrypted channel between the two specific paired devices (built via Diffie-Hellman key exchange at pairing time), rather than each device generating and keeping its own unrelated key.

## B4. Is the Media Stored on WhatsApp's Servers Forever?

No — and this matters for a full picture:

```mermaid
flowchart LR
    Upload["Media ciphertext uploaded<br/>to WhatsApp's media servers"] --> ShortLived["Stored temporarily —<br/>WhatsApp's documented policy is that<br/>undelivered media is auto-deleted after<br/>a limited window (commonly cited as ~30 days,<br/>though exact figures aren't always public/fixed)"]
    ShortLived --> Delivered{"Delivered & downloaded<br/>by recipient?"}
    Delivered -->|Yes| Deleted["Server copy is deleted<br/>relatively soon after successful delivery"]
    Delivered -->|No, recipient offline long enough| Expired["Eventually expires/deleted regardless"]

    style ShortLived fill:#78350f,color:#fff
    style Deleted fill:#14532d,color:#fff
```

**Compare this directly to Only Us today**: this exact question (should we auto-delete media from Cloudinary once the recipient has downloaded it) is precisely what you asked in an earlier conversation this session — and the honest answer given then still holds: doing this safely requires a small server-side function (since deleting from Cloudinary needs the API secret, which can't live in the client app), which was deliberately deferred until real cross-device photo sharing existed. WhatsApp's server-side deletion is the same *category* of feature — a lifecycle policy layered on top of the encryption, not a replacement for it.

## B5. Side-by-Side Summary

| | WhatsApp | Only Us (current state) |
|---|---|---|
| Is media encrypted before upload? | ✅ Yes (per-file random AES key) | ✅ Yes (per-device AES key) |
| Can the server read the media? | ❌ No — stores ciphertext only | ❌ No — stores ciphertext only |
| Can the *specific recipient* decrypt it? | ✅ Yes — key travels via Signal Protocol's E2E channel | ❌ Not yet — key never leaves the sender's device (Guide 3 gap) |
| Is the server-stored copy deleted after delivery? | ✅ Yes, on a documented retention policy | ❌ Not yet — persists indefinitely in Cloudinary (deferred, needs a server function) |
| Is text also E2E encrypted the same way? | ✅ Yes — same Signal Protocol session | ❌ No — plaintext in Firestore (Guide 3, Section 3) |

---

## Glossary

- **Bearer token** — a credential where mere *possession* grants access, with no further proof required (both access and refresh tokens are bearer tokens by default)
- **Token rotation** — issuing a brand-new refresh token on every use and invalidating the previous one, limiting a stolen old token's usefulness to zero
- **Reuse detection** — recognizing that an already-rotated (dead) token being presented again is a reliable signal of theft
- **Signal Protocol** — the specific end-to-end encryption protocol (Double Ratchet + Diffie-Hellman) that WhatsApp, Signal, and several other messengers use for both text and media
- **Media key** — a random, per-file symmetric encryption key generated just for one piece of media, transmitted only through an already-secure channel to the intended recipient
- **Ciphertext blob** — encrypted binary data stored on a server, meaningless without the corresponding decryption key
