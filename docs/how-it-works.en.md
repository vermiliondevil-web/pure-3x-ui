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
2. AmneziaWG (Obfuscated UDP Datagram)
Before establishing a connection, "junk" packets (Jc) are sent, while the handshake header itself is replaced with a random value (H1) and padded with a random tail (S1).
```text
[ Junk packet 1 (random bytes, 64 B) ] ──> [ Junk packet 2 (random bytes, 112 B) ] ──>
+-------------------+-------------------+-------------------+-------------------+---------------+
| IPv4 / IPv6 | UDP Header | Custom H1 (4 B) | Encrypted Payload | Random Junk |
| Header (20 B) | (8 bytes) | e.g.: 0x8A3F19C2 | (144 bytes) | (S1 bytes) |
+-------------------+-------------------+-------------------+-------------------+---------------+
▲
└── No known signature; packet size varies every time
```
3. VLESS + XHTTP + Reality (TCP/TLS Packet)
Traffic is encapsulated inside a standard HTTPS request over a genuine TLS connection. From the ISP's perspective, it is simply a visit to the masquerade site.
```text
+-------------------+-------------------+-------------------+-----------------------------------+
| IPv4 / IPv6 | TCP Header | TLS 1.3 Record | Encrypted Application Data |
| Header (20 B) | (20 bytes) | SNI: decoy site | [HTTP/2 POST] -> [VLESS + Data] |
+-------------------+-------------------+-------------------+-----------------------------------+
▲ ▲
│ └── Inside: UUID, Flow (Vision), & traffic
└── DPI verifies cert & SNI → SEES A REGULAR BROWSER
```
## 🛡️ Why XHTTP + Reality Cannot Be Blocked Without Shutting Down the Entire Internet
At the network packet level, VLESS + XHTTP + Reality traffic is 100% identical to visiting a regular HTTPS website (such as an online bank, search engine, or e-commerce marketplace).
OUTER SHELL (Visible to ISP & DPI) — Identical to any HTTPS website:
```text
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 / IPv6       | TCP Header        | TLS 1.3 Header    | TLS Application Data              |
| Server IP         | Port 443 (HTTPS)  | SNI: decoy site   | [ ENCRYPTED WITH REALITY KEY ]    |
+-------------------+-------------------+-------------------+-----------------------------------+
                                         ▲                   ▲
                                         │                   └── DPI CANNOT SEE INSIDE:
                                         │                       no access to HTTP headers
                                         └── Genuine certificate & browser TLS fingerprint

INNER PAYLOAD (Visible only to your server after TLS decryption):
                                                             ┌─────────────────────────────────┐
                                                             │ HTTP/2 or HTTP/3 (POST / GET)   │
                                                             │   └── VLESS (UUID + Flow)       │
                                                             │         └── Your actual traffic │
                                                             └─────────────────────────────────┘
```
ISP Filter (DPI) Logic
Packet Comparison	Visiting the Decoy Site Normally	Connecting via XHTTP + Reality	DPI Conclusion
Port & Transport	TCP 443 (HTTPS)	TCP 443 (HTTPS)	Identical
TLS Handshake (SNI)	example.com	example.com	Identical
Certificate	Genuine cert from example.com	Genuine cert from example.com	Identical
Data Payload	Encrypted HTTP/2	Encrypted HTTP/2 (XHTTP)	Unreadable without keys
Bottom Line: The ISP has zero technical indicators (signatures) to distinguish an XHTTP packet from a legitimate HTTPS request. The only way to block such a connection is to shut down port 443 entirely (all HTTPS traffic), which effectively means disconnecting the entire internet.

## 🌐 How VLESS + XHTTP + Reality + WARP Works

In this architecture, Reality + XHTTP handles secure ingress to your VPS (protecting against ISP DPI), while Cloudflare WARP acts as an outbound gateway on the server itself, masking your hosting provider's IP address from destination websites.
1. Traffic Flow Diagram (Routing)
```text
┌──────────────┐       1. XHTTP + Reality       ┌───────────────────────────┐       2. WireGuard (WARP)       ┌────────────────┐
│    Client    │ ─────────────────────────────> │       Your Server (VPS)   │ ──────────────────────────────> │   Cloudflare   │
│ (v2rayN etc.)│   (Masqueraded as HTTPS site)  │                           │   (Tunnel from VPS to CF)       │  WARP Network  │
└──────────────┘                                │  ┌─────────────────────┐  │                                 └───────┬────────┘
                                                │  │      Xray-core      │  │                                         │
                                                │  │  1. Decrypts        │  │                                         │ 3. Egress to web
                                                │  │     Reality/XHTTP   │  │                                         │    with a clean IP
                                                │  │  2. Routes traffic  │  │                                         ▼
                                                │  │     to WARP Outbound│  │                                 ┌────────────────┐
                                                │  └─────────────────────┘  │                                 │ Target Website │
                                                └───────────────────────────┘                                 │ (Google, ChatGPT│
                                                                                                              │  & other sites)│
                                                                                                              └────────────────┘
```
## 3. Packet Transformation Datagram (Step by Step)
The packet changes its "wrapping" twice: upon entering the VPS (where ISP protection is stripped away) and upon exiting the VPS (where the Cloudflare WARP tunnel is applied).

```text
STAGE 1: From Client to Your VPS (Visible to your ISP / DPI)
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 / IPv6       | TCP Header        | TLS 1.3 Header    | Encrypted Application Data        |
| Your VPS IP       | Port 443 (HTTPS)  | SNI: decoy site   | [HTTP/2 XHTTP] -> [VLESS + Data]  |
+-------------------+-------------------+-------------------+-----------------------------------+
                                         ▲
                                         └── ISP sees only a visit to a normal HTTPS website.
                                             Your actual request is encrypted inside.

STAGE 2: Inside Your VPS (Xray-core routes the data)
  [ Decrypted User Request ] ──> Routing Rule (e.g., for Google / OpenAI / all traffic)
                                     └── Forwarded to Outbound: warp (WireGuard / MASQUE)

STAGE 3: From Your VPS to Cloudflare Network (Visible to your VPS hoster)
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 / IPv6       | UDP Header        | WARP / WireGuard  | Encrypted Payload                 |
| Cloudflare IP     | Port 2408 (UDP)   | Tunnel header     | [Your request to target site]     |
+-------------------+-------------------+-------------------+-----------------------------------+
                                         ▲
                                         └── Foreign VPS providers do not block WireGuard,
                                             so WARP runs at full speed.

STAGE 4: From Cloudflare to Target Website (Visible to the website itself)
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 / IPv6       | TCP Header        | TLS 1.3 Header    | Request to Website                |
| Clean CF WARP IP  | Port 443          | SNI: target site  | (Site sees you as a normal user)  |
+-------------------+-------------------+-------------------+-----------------------------------+

```
Why Use This Setup?

Bypassing ISP DPI (XHTTP + Reality). Using standard WARP directly from a phone or PC in Russia is frequently blocked via WireGuard signatures. In this setup, WARP runs on a foreign VPS where no blocks exist, while your connection to the VPS uses censorship-resistant XHTTP + Reality.

Avoiding CAPTCHAs and IP Bans (WARP Outbound). Many websites (Google, ChatGPT, Netflix, banking portals) block datacenter (VPS) IP addresses or bombard them with CAPTCHAs. Routing egress traffic through WARP provides a trusted Cloudflare IP address.
Flexible Routing. Inside the 3x-ui panel, you can route either all traffic through WARP or only specific domains (geosite:google, geosite:openai, etc.), letting the rest go directly through your VPS.

## 🚨 Why Egress via a VPS in Russia Fails (Even with DoH)
If you use a Russian VPS as your final exit node, enabling DoH (DNS over HTTPS) will not prevent ISP block pages or null-routed IPs. Filtering (TSPU) occurs at the backbone level as traffic exits Russia—by inspecting the unencrypted SNI field and injecting forged packets.
How TSPU Spoofs Responses on Egress from a Russian VPS
```text
┌──────────────┐       1. Tunnel to Russia     ┌─────────────────────────┐       2. Outbound Request (SNI: google.com)   ┌─────────────────────────┐
│    Client    │ ───────────────────────────> │      VPS in Russia      │ ──────────────────────────────────────────> │   Backbone TSPU Filter  │
│              │   (Traffic reaches RU clean) │   (Attempts to access   │    • DoH is blocked or bypassed             │   (DPI inside Russia)   │
└──────┬───────┘                              │    the open internet)   │    • Yet TLS ClientHello exposes SNI!       │                         │
       │                                      └────────────┬────────────┘                                             └────────────┬────────────┘
       │                                                   │                                                                       │
       │                                                   │ 3. TSPU intercepts TLS via SNI:                                       │
       │                                                   │    • Terminates real Google link (TCP RST)                            │
       │                                                   │    • Injects a FORGED packet pretending to be the site:               │
       │                                                   │      "302 Redirect to block page" or null IP                          │
       │ 4. Client receives block page                     │ <─────────────────────────────────────────────────────────────────────┤
       │ <─────────────────────────────────────────────────┤                                                                       │
       │    (Appears as if the site returned a block page) │                                                                       │
```
TCP Injection Packet Forgery Datagram

```text
STEP 1: Russian VPS sends a normal request to the target site (DoH doesn't help because SNI is plaintext):
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 Header       | TCP Header        | TLS ClientHello   | SNI: "blocked-site.com" (PLAINTEXT)|
| Russian VPS IP    | Port 443          | (Session start)   | (TSPU reads domain from SNI)      |
+-------------------+-------------------+-------------------+-----------------------------------+
                                                             ▲
                                                             └── TSPU detects restricted SNI

STEP 2: TSPU instantly generates and injects a spoofed reply faster than the real server:
+-------------------+-------------------+-------------------+-----------------------------------+

| IPv4 Header       | TCP Header        | Fake HTTP / TLS   | Spoofed: Block Page IP / TCP Reset|
| Spoofed: Site IP  | Port 443          | (Reply from TSPU) | (Browser loads the block page)    |
+-------------------+-------------------+-------------------+-----------------------------------+

```
The Only Working Solution ("RU Bridge → Foreign VPS" Cascade)
A Russian VPS must act strictly as a blind relay (Dock / Bridge), without ever resolving DNS or opening websites itself. All traffic passing through it stays sealed inside an encrypted VLESS + XHTTP + Reality container all the way to a foreign server.

```text
┌──────────────┐   Reality Enc. (Allowlisted SNI) ┌─────────────────────────┐   Reality Enc. (Allowlisted SNI) ┌─────────────────────────┐   Plain Request     ┌──────────────┐
│    Client    │ ───────────────────────────────> │      VPS in Russia      │ ───────────────────────────────> │       Foreign VPS       │ ──────────────────> │ Target Site  │
└──────────────┘                                  │  (TCP relay only;       │                                  │  (Decryption + DoH +    │                     │   (Google)   │
                                                  │   never opens traffic)  │                                  │   egress without TSPU)  │                     └──────────────┘
                                                  └─────────────────────────┘                                  └─────────────────────────┘
```

## 🧭 Technical Documentation: DNS Routing in 3x-ui (Xray-core)
Proper DNS configuration in 3x-ui is critical for preventing DNS leaks, protecting against ISP-level IP spoofing (TSPU), and accurately splitting traffic (Split Tunneling) across direct egress, WARP, and ad-blocking outbounds.
## 1. How DNS Works Inside Xray-core
Unlike a standard OS system resolver, Xray-core includes a built-in DNS server (dns in the JSON configuration). It intercepts domain queries and decides which IP address to return or which outbound gateway should handle the request.
Request Processing Flow in Xray

```text
┌────────────────┐      1. Request (Domain)    ┌──────────────────────────────────────────┐
│ Inbound Stream │ ──────────────────────────> │            Inbound (3x-ui)               │
│ (VLESS/XHTTP)  │                             │  Sniffing: ON (extracts domain from TLS) │
└────────────────┘                             └────────────────────┬─────────────────────┘
                                                                    │
                                                                    ▼
┌────────────────┐      3. IP Resolution       ┌──────────────────────────────────────────┐
│   Built-in     │ <────────────────────────── │            Routing Module                │
│   Xray DNS     │ ──────────────────────────> │  Matches domain against rules (geosite)  │
└────────────────┘                             └────────────────────┬─────────────────────┘
                                                                    │
                        ┌─────────────────────────┬─────────────────┴─────────────────┐
                        ▼                         ▼                                   ▼
              ┌──────────────────┐      ┌──────────────────┐                ┌──────────────────┐
              │ Outbound: direct │      │  Outbound: warp  │                │ Outbound: block  │
              │ (Direct egress)  │      │ (Via Cloudflare) │                │ (Ads / Trackers) │
              └──────────────────┘      └──────────────────┘                └──────────────────┘

```

## 2. DNS Server Types in Xray Settings
Under Xray Settings → DNS (or in the raw JSON configuration), the following resolution protocols are supported:

| Entry Format | Protocol | Features & Use Cases |
| :--- | :--- | :--- |
| `https://1.1.1` | **DoH** (DNS over HTTPS) | Encrypts DNS queries over HTTPS. Routes through the default `outbound` (respects routing rules). **Recommended for a foreign VPS.** |
| `https+local://8.8.8.8/dns-query` | **DoH Local** | Sends DoH queries directly via the server's network interface (`freedom`), bypassing Xray routing rules. Useful for preventing routing loops when WARP starts up. |
| `tls://1.1.1.1` | **DoT** (DNS over TLS) | Encrypted DNS over port 853. Reliable, though occasionally blocked by strict hosting provider firewalls. |
| `localhost` | **VPS System DNS** | Uses the server's own `/etc/resolv.conf`. **Never use on a VPS in Russia** (causes IP spoofing to TSPU block pages). |
| `fakedns` | **FakeDNS** | Assigns the client a synthetic local IP from the `198.18.0.0/15` pool while mapping "IP ↔ Domain" in memory. Eliminates client-side latency from real DNS lookups. |


## 3. Baseline Secure DNS Configuration (for a Foreign VPS)
On a foreign server, there is no need to split queries by country — all external domains should be resolved via encrypted DoH servers with automatic failover.
```json
{
  "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query",
      "https+local://8.8.8.8/dns-query"
    ],
    "queryStrategy": "UseIPv4",
    "disableCache": false,
    "disableFallback": false
  }
}
```
## Explanation of Key Parameters

* **`https+local://1.1.1.1/dns-query`** - Primary Cloudflare DoH resolver. The +local prefix ensures Xray sends queries directly through the server's network interface (freedom), preventing routing loops.
* **`https+local://8.8.8.8/dns-query`** — Backup Google DoH resolver used automatically if the primary server becomes temporarily unreachable.
* **`queryStrategy: "UseIPv4"`** — Forces Xray to query only IPv4 addresses (A records). Solves website hangs on VPS instances with misconfigured IPv6 or where the datacenter's IPv6 subnet is blocked by target services.
* **`disableCache: false`** — Enables in-memory DNS response caching in Xray to speed up repeated lookups.
* **`disableFallback: false`** — Allows automatic fallback to the backup DNS server in the servers list if the primary resolver fails or times out. When set to true, fallback servers are never queried.
   
## 4. DNS Routing When Using Cloudflare WARP
If your server uses a warp outbound gateway (to bypass Google CAPTCHAs, access ChatGPT, etc.), DNS queries for those services must also resolve properly without causing Cloudflare's own endpoint domain to loop.
Example dns + routing Configuration for WARP
```json
{
  "dns": {
    "servers": [
      {
        "address": "https+local://1.1.1.1/dns-query",
        "domains": [
          "geosite:google",
          "geosite:openai",
          "geosite:netflix"
        ]
      },
      "https+local://8.8.8.8/dns-query"
    ],
    "queryStrategy": "UseIPv4"
  },
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "domain": [
          "geosite:category-ads-all"
        ],
        "outboundTag": "block"
      },
      {
        "type": "field",
        "domain": [
          "geosite:google",
          "geosite:openai",
          "geosite:netflix"
        ],
        "outboundTag": "warp"
      },
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "block"
      }
    ]
  }
}
```
**`How domainStrategy Works in Routing`**
1. **`AsIs`** — Inspects only the domain name sent by the client without performing additional DNS lookups (fastest mode; requires Sniffing to be enabled).
2. **`IPIfNonMatch`** — If a domain does not match any domain-based rule, Xray resolves it via its dns module and checks the resulting IP against IP-based rules (geoip:...). **Best balance between speed and accuracy.**.
3. **`IPOnDemand`** — Always resolves the domain to an IP before evaluating rules. Introduces extra latency on every new connection.

## 5. Specifics for Cascade Setups (RU Bridge → Foreign VPS)
When using an intermediate relay server in Russia (Bridge / Relay), follow these strict rules:

    Do not configure (or use) the dns module on the Russian VPS. Incoming traffic (VLESS + XHTTP + Reality or Dokodemo-door) must be forwarded to the outbound tunnel toward the foreign server as-is (byte-for-byte) without attempting to decrypt TLS or resolve domains inside Russia.
    All DNS resolution happens exclusively on the foreign VPS. Only the final exit server outside TSPU's reach may issue DoH requests and connect to target websites.
    On the client side (v2rayN / Nekobox / Happ). Ensure Remote DNS (or FakeDNS) routing is enabled so the client device never sends plaintext UDP queries to your ISP's port 53 outside the tunnel.

6. DNS Troubleshooting Checklist

    ISP block page opens even with VPN enabled:
        Check client settings: verify that FakeDNS or proxy DNS routing (Remote DNS) is active.
        Ensure your browser's built-in "Secure DNS" is either disabled or routed through the VPN tunnel rather than over your local ISP.

Websites take 3–5 seconds to load (IPv6 timeout):

    Set "queryStrategy": "UseIPv4" in the dns section of your Xray configuration in 3x-ui.

Routing rules (geosite / ad-blocking) are not triggering:

    Verify that Sniffing is enabled in your Inbound settings inside the 3x-ui panel.

🛡️ Technical Documentation: DNS Leak Prevention
A DNS Leak occurs when your device sends domain name resolution requests (such as google.com) directly to your ISP's DNS servers outside the encrypted VPN tunnel. As a result, your ISP can log your browsing history and spoof responses with block page IPs.
To achieve complete DNS isolation, configuration must be applied at two levels: on the server (3x-ui) and on the client device.
1. Server-Side DNS Interception Diagram
text ┌────────────────┐ 1. Client Request ┌──────────────────────────────────────────┐ │ Client (v2rayN │ ───────────────────────> │ Inbound (3x-ui) │ │ / Nekobox/TUN) │ (Including packets to │ Sniffing: ON (http, tls, quic, fakedns) │ └────────────────┘ port 53 UDP/TCP) └────────────────────┬─────────────────────┘ │ ▼ ┌────────────────┐ 3. Outbound DoH Query ┌──────────────────────────────────────────┐ │ Built-in │ <─────────────────────── │ Routing Rule (port: 53) │ │ Xray DNS │ ───────────────────────> │ Intercepts all port 53 traffic & sends │ │ (https+local) │ (Encrypted HTTPS) │ it to a dedicated "dns-out" Outbound │ └────────────────┘ └──────────────────────────────────────────┘
Reference Xray Configuration Against DNS Leaks (by 3x-ui Tab)
In the 3x-ui panel (Xray Settings → Advanced Configuration), settings are organized into tabs. Below is a table of ready-to-use JSON snippets for each tab.
Tab in 3x-ui	Ready-to-Use JSON Block	Purpose & Leak Protection
DNS (dns)	json<br>{<br> "servers": [<br> "https+local://1.1.1.1/dns-query",<br> "https+local://8.8.8.8/dns-query"<br> ],<br> "queryStrategy": "UseIPv4",<br> "disableCache": false,<br> "disableFallback": false<br>}<br>	Encryption & disabling system DNS. Prevents Xray from querying the host's /etc/resolv.conf (localhost). All requests go strictly over HTTPS (DoH) directly via the server's network interface without routing loops.
Outbounds (outbounds)	json<br>[<br> {<br> "tag": "direct",<br> "protocol": "freedom"<br> },<br> {<br> "tag": "block",<br> "protocol": "blackhole"<br> },<br> {<br> "tag": "dns-out",<br> "protocol": "dns"<br> }<br>]<br>	Internal DNS handler. The dns protocol outbound tagged dns-out captures intercepted DNS packets from clients and forwards them to the built-in encrypted dns module configured above.
Routing (routing)	json<br>{<br> "domainStrategy": "IPIfNonMatch",<br> "rules": [<br> {<br> "type": "field",<br> "port": "53",<br> "network": "tcp,udp",<br> "outboundTag": "dns-out"<br> },<br> {<br> "type": "field",<br> "ip": [<br> "geoip:private"<br> ],<br> "outboundTag": "block"<br> }<br> ]<br>}<br>	Forced port 53 interception. Any plaintext DNS query (UDP or TCP on port 53) entering the tunnel from a client is routed to dns-out. Private IP ranges (geoip:private) are blocked to prevent leaks and conflicts.
Inbound (inbound)	json<br>"sniffing": {<br> "enabled": true,<br> "destOverride": [<br> "http",<br> "tls",<br> "quic",<br> "fakedns"<br> ]<br>}<br>	Domain name recovery. Allows Xray to extract the actual target domain from the SNI header or FakeDNS pool, even if the client device connected to the server using a raw IP address.
2. Client-Side Configuration (v2rayN, Nekobox, Happ, v2rayNG)
Even a flawless server configuration will not prevent leaks if your operating system (Windows, Android, iOS) sends DNS queries around the VPN client.
Required Client Settings

    Use TUN Mode (VPN Mode) instead of System Proxy. A system HTTP/SOCKS proxy only intercepts browser traffic, leaving OS background services and games free to query your ISP's DNS servers directly. Always enable TUN mode (virtual network interface) on desktop and mobile devices.

3. Browser and OS-Level Protection (Hidden Leak Channels)
Modern browsers and operating systems often bypass VPN settings in the name of "speed" or "security":
Leak Source	What the Problem Is	How to Fix It
In-Browser DoH (Chrome, Edge, Firefox, Yandex)	The browser sends its own DNS-over-HTTPS queries directly to your ISP or Yandex servers, ignoring system DNS settings.	Disable "Use secure DNS" in your browser settings (or ensure TUN mode is active so all browser traffic is forced through the tunnel).
IPv6 on the Client Device	If your ISP provides IPv6 connectivity while your VPN tunnel only handles IPv4, DNS queries may leak over IPv6 outside the tunnel.	Enable IPv6 support inside your client's TUN settings, or disable IPv6 in your PC's network adapter properties.
Smart Multi-Homed Name Resolution (Windows)	Windows 10/11 broadcasts DNS queries simultaneously across all network adapters (including your ISP's Wi-Fi) and accepts the fastest reply (often a TSPU block page).	Use TUN mode with a high interface metric priority (clients like v2rayN and Nekoray configure this automatically when TUN is enabled).
Browser WebRTC	Video-calling APIs can expose your real local or public ISP IP address outside the proxy tunnel.	Install the WebRTC Leak Prevent extension or disable WebRTC in your browser settings.
4. How to Verify There Are No DNS Leaks

    Connect to your server via your VPN client.

Open an incognito/private browser window and visit any DNS leak testing service:

    ipleak.net
    dnsleaktest.com (select Extended Test)
    browserleaks.com

Criteria for a successful setup:

    The list of detected DNS servers shows only Cloudflare / Google IP addresses located in the country of your foreign VPS.
    There are no IP addresses or names belonging to your Russian ISP.
    Restricted websites load immediately without block pages or delays.
