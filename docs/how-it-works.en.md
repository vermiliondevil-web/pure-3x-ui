### ⚠️ SNI Must Match the Server Location

When configuring VLESS + Reality, **do not use** popular domains from the panel's default preset lists (such as `://microsoft.com`, `://google.com`, or `api-maps.yandex.ru`) if your server is located in a different country.

**Why:** DPI (TSPU) sees a TLS handshake with the SNI `://microsoft.com` going to an IP address belonging to a Finnish or German hosting provider. This is an **anomaly** — Microsoft does not host its services on random VPS providers. This "foreign domain + foreign IP" mismatch is one of the easiest patterns for proxy detection.

**What to do:**
- Choose an SNI that is **logically tied** to your server's location. If the server is in Finland, look for Finnish domains that support TLS 1.3 and HTTP/2 (H2). If it is in Germany, look for German domains.
- Ideally, pick a domain hosted on the **same hosting provider or ASN** as your server (you can find these using a scanner such as RealiTLScanner).
- **Avoid** domains that have already been widely "burned" in public Reality guides (such as `ya.ru`, `vk.com`, `max.ru`, etc.) — they are under heightened DPI scrutiny.

**How to check:** Utilities like `findsni.sh` or `RealiTLScanner` scan your server's subnet and find neighboring domains.

> **Regarding the XDRIVE transport:** This new transport from Xray-core is **not covered** in this fork. It is not supported in the 3x-ui web interface, suffers from high latency due to file-based exchange, and is intended strictly for extreme IP allowlisting scenarios.

## 🖼️ Diagram: Why SNI Must Match the Server

Reality disguises your connection as a regular HTTPS visit to the website specified in the SNI. When both the website and your server reside within the **same infrastructure** (country, CDN, ASN), the traffic looks natural. Otherwise, DPI flags it as an anomaly.

```text
🟢 CORRECT: Server and SNI in the same region
┌─────────────┐      TLS ClientHello       ┌─────────────────────┐
│  Client     │ ──── (SNI: finnish.com) ──>│  Server in Finland  │
│  in Russia  │                            │  IP: 95.x.x.x       │
└─────────────┘                            └─────────────────────┘
                                                    │
                                           DPI sees: "Finnish IP + 
                                           Finnish domain = normal"

🔴 INCORRECT: US SNI with a Finnish server
┌─────────────┐      TLS ClientHello       ┌─────────────────────┐
│  Client     │ ──── (SNI: usa-site.com) ─>│  Server in Finland  │
│  in Russia  │                            │  IP: 95.x.x.x       │
└─────────────┘                            └─────────────────────┘
                                                    │
                                           DPI sees: "US domain on a 
                                           Finnish IP = suspicious"
```

## 🖼️ How VLESS + XHTTP + Reality Works

```text
┌──────────────┐          ┌──────────────────────────────────────┐          ┌──────────────┐
│    Client    │          │            Server (VPS)              │          │   Internet   │
│ (v2rayN etc.)│          │                                      │          │              │
└──────┬───────┘          └──────────────────┬───────────────────┘          └──────┬───────┘
       │                                     │                                     │
       │ 1. TLS ClientHello (SNI: decoy site)│                                     │
       │ ───────────────────────────────────>│                                     │
       │                                     │ 2. Reality verifies the SNI         │
       │                                     │    and serves the genuine TLS cert  │
       │ 3. TLS ServerHello                  │    of the masquerade site           │
       │ <───────────────────────────────────│                                     │
       │                                     │                                     │
       │ 4. VLESS Request (UUID + XHTTP)     │                                     │
       │    + Flow (xtls-rprx-vision)*       │                                     │
       │ ───────────────────────────────────>│                                     │
       │                                     │ 5. What Flow (Vision) does:         │
       │                                     │    • Disguises "TLS inside TLS"     │
       │                                     │      (adds padding to packets)      │
       │                                     │    • Eliminates double encryption   │
       │                                     │      after handshake (speed boost)  │
       │                                     │                                     │
       │                                     │ 6. Xray unpacks XHTTP and forwards  │
       │                                     │    the request to the target        │
       │                                     │ ───────────────────────────────────>│
       │                                     │                                     │
       │                                     │ 7. Response from the target site    │
       │                                     │ <───────────────────────────────────│
       │                                     │                                     │
       │ 8. Response to client (via XHTTP)   │                                     │
       │ <───────────────────────────────────│                                     │
       │                                     │                                     │
```

> **\*Note on Flow (`xtls-rprx-vision`) with XHTTP:** 
> When paired with **XHTTP**, the Flow parameter works **only if VLESS Encryption is enabled** (i.e., `decryption`/`encryption` keys are configured on both the panel and the client). If VLESS Encryption is not used (`none`), leave the Flow field empty — the traffic is already encrypted and obfuscated by XHTTP itself.

## 🚫 Why Standard WireGuard Gets Blocked (and How AmneziaWG and Reality Differ)

Deep Packet Inspection (DPI) systems can easily fingerprint classic **WireGuard** due to its rigid technical signatures, as it makes no attempt to disguise itself as regular web traffic.

```text
┌──────────────┐          ┌───────────────────────────────┐          ┌──────────────┐
│    Client    │          │         ISP / DPI             │          │   Server     │
└──────┬───────┘          └───────────────┬───────────────┘          └──────┬───────┘
       │                                  │                                 │
       │ 1. Standard WireGuard Handshake  │                                 │
       │    • Protocol: plain UDP         │                                 │
       │    • Size: exactly 148 bytes     │                                 │
       │    • Header: 0x01 0x00 0x00      │                                 │
       │ ────────────────────────────────>│                                 │
       │                                  │ 2. DPI detects WG signature:    │
       │                                  │    • No TLS or SNI              │
       │                                  │    • Recognizable packet size   │
       │                                  │    ❌ PACKET DROPPED            │
       │       [ Connection terminated ]  │                                 │
       │ < ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─│                                 │
       │                                  │                                 │
```

### How Different Protocols Solve This Problem

* **AmneziaWG (UDP obfuscation).** Modifies WireGuard itself by injecting random "junk" packets prior to the handshake, altering standard headers (`H1–H4`), and randomizing packet sizes. To DPI, the traffic no longer matches known WireGuard signatures and instead resembles an arbitrary UDP stream (such as online gaming or VoIP calls). **Drawback:** If an ISP enforces strict blocking of all unrecognized UDP traffic (protocol allowlisting), AmneziaWG can still be blocked.
* **VLESS + XHTTP + Reality (full HTTPS masquerading).** Instead of trying to hide VPN traffic as "random noise," it impersonates a standard web browser visiting a real third-party website (complete with a genuine TLS certificate and SNI). It continues to work even on networks where all non-standard UDP traffic is blocked.

### DPI Comparison

| Traffic Characteristic | Classic WireGuard | AmneziaWG | VLESS + XHTTP + Reality |
| :--- | :--- | :--- | :--- |
| **Transport** | Plain UDP | Obfuscated UDP | TCP / QUIC (HTTP/2, HTTP/3) |
| **First Packet** | Strictly 148 bytes, unencrypted signature | Randomized size + junk packets, altered headers | Standard TLS ClientHello with a real SNI |
| **Appearance** | Recognizable VPN protocol | Unidentified encrypted UDP stream | Indistinguishable from visiting a regular HTTPS website |
| **DPI Reaction** | Instant block by signature | Passes through (unless all unknown UDP is blocked) | Passes through as legitimate web traffic |

### 📦 Datagrams (Packet Structure for DPI)

#### 1. Classic WireGuard (UDP Datagram, 148 Bytes)
The packet begins with a plaintext, fixed header. DPI reads the first 4 bytes and immediately identifies the protocol.

```text
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 / IPv6       | UDP Header        | WG Type (4 bytes) | Encrypted Payload (144 bytes)     |
| Header (20 B)     | (8 bytes)         | 0x01 0x00 0x00 00 | Ephemeral key, timestamp          |
+-------------------+-------------------+-------------------+-----------------------------------+
                                         ▲
                                         └── DPI sees rigid signature & 148 B size → BLOCK
```
