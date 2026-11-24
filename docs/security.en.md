## Upstream Security: Known Incidents and Our Stance

This fork exists not merely to remove ads. We closely monitor upstream
security because a proxy control panel is an infrastructure tool, not a toy.
Below are the incidents that led us to treat upstream code with caution. We **do not claim** that
the upstream author is malicious. We assert that **the development process
is prone to negligence**, and this creates real risks for operators.

## 1. Sponsor Tracking as a Leak Channel (Issue #6824)

Prior to v3.10.2, whenever the login page loaded (upon cache expiration), the panel
queried `sponsors.sanaei.dev` — a domain unique to 3x-ui.
In TLS SNI, this domain was visible to any on-path observer, including DPI.
This allowed identifying a server as a 3x-ui panel **from a single
connection**. The upstream author (MHSanaei) **acknowledged the issue** and in
v3.10.2 replaced the domain with `raw.githubusercontent.com`, which is used
by countless tools and does not fingerprint the panel. However, the issue
persisted **for years**, and fixing it required a public Issue
outlining the threat model.

**What this means:** the sponsor infrastructure was not "just ads."
It generated an **identifying signal** for censors.

## 2. Unsigned Node-Sync (GHSA-rr44-v4rv-x654)

In September 2026, security researchers discovered that the master panel fetches data from
nodes via `GET panel/api/inbounds/list` and **does not verify the response signature**.
A compromised node could **overwrite client UUIDs/Passwords** on the
master (via global email lookup) and **inject its own endpoint** into
user subscriptions.

**What this means:** the trust architecture between master and node was
broken. A node could attack the master, and the master would not notice.

## 3. Arbitrary File Write (CVE-2026-55477)

Prior to v3.3.1, any panel admin could, via database import, redirect the Xray log
to `~/.ssh/authorized_keys` and write their own key there — effectively **gaining
root access to the server**. The vulnerability was patched only after
public disclosure (CVSS 7.2).

**What this means:** path validation was absent upstream. The flaw
allowed turning the panel into a server takeover tool.

## 4. Calls for Supply Chain Hardening (Issue #4962)

In June 2026, users **explicitly asked** the upstream author to:
audit PRs, verify contributor identities (to prevent a
"Jia Tan"-style scenario as seen in xz/liblzma), require signed commits,
and stop merging massive PRs without review. The upstream author
**did not provide a substantive response** — offering only downgrade instructions.

**What this means:** the community sees the problem, yet the development process
remains unchanged.

---

## 🕵️ Operator Security Rules (How to Avoid Exposing Your Server)

To keep your VPS and control panel invisible to network scanners (Shodan/Censys) and deep packet inspection systems (DPI), follow basic network hygiene.

## 1. Hiding the Panel Web Interface (3x-ui)

- **Close the panel port in your firewall.** The web interface (port `2053` or any other) must not be exposed to the internet by IP. Externally, only the Xray port (`443`) and SSH port should be accessible.
- **Access the panel only via an SSH tunnel.** Forward the panel port locally to your machine:
  ```bash
  ssh -L 2053:127.0.0.1:2053 user@your-vps-ip
  ```
  Afterward, open the panel in your browser at `http://127.0.0.1:2053`, leaving the port completely invisible from the outside.
- **Use a random path (Web Base Path).** Set a long random prefix of 16–24 characters in the panel settings (e.g., `/x9kLm2pQ8vR4tW7z/`) so that random requests do not return the 3x-ui login page.
- **No plain HTTP.** If you expose the panel via a domain, always use a reverse proxy (Nginx / Caddy) with a valid TLS certificate. Logging in over plain HTTP transmits your password and cookies in cleartext.

## 2. Network Masquerading and SNI Selection (Reality)

- **Choose a "neighboring" decoy site.** The domain for Reality (SNI) should be located in the same country or data center as your VPS, support **TLS 1.3** and **HTTP/2**, and not be blocked in the client's country. A geographic mismatch between the server IP and the decoy site (e.g., a VPS in the Netherlands with a Russian SNI) creates latency anomalies for DPI.
- **Avoid popular SNIs from public guides.** Do not use `google.com`, `microsoft.com`, `apple.com`, or `yahoo.com` — these domains are under heightened monitoring. Find a small local website hosted on the same provider (such as a local university, museum, or regional store).
- **Do not mix Reality and websites on the same port.** If Reality is running on port `443` with a third-party SNI, do not point your own control panel domain to the same IP without separating them via an SNI router (Nginx stream).

## 3. Key and Subscription Hygiene

- **Disable the Subscription server.** If you only have 3–5 personal users, it is safer to disable the subscription service entirely in panel settings and distribute keys (`vless://...`) manually. An open subscription port is easily fingerprinted by scanners via its distinct HTTP headers.
- **Do not test your server in public online checkers.** Never paste your active `vless://` keys and server IP into dubious web checkers or Telegram bots — many of them harvest lists of working nodes.
- **Use a telemetry-free fork.** This clean build strips background requests to sponsor servers and update checks that could expose the server via recognizable outbound TLS SNI.

## 4. Baseline Server OS Security

| Parameter                | Recommended Setting                                           | Why It Matters                                              |
| :----------------------- | :------------------------------------------------------------ | :---------------------------------------------------------- |
| **SSH Access**           | SSH key only (`PasswordAuthentication no`), non-standard port | Protects against automated password brute-forcing by bots   |
| **ICMP (Ping)**          | Disabled in firewall (UFW / iptables)                         | Prevents the server from responding to mass subnet scans    |
| **Third-party software** | No torrents, scrapers, or public services on the same VPS     | Prevents abuse complaints and IP blacklisting by the hoster |

> [!CAUTION]
> ⚠️ **Do not use `dev-latest` / pre-release builds**
>
> `dev-latest` builds (and any pre-releases) are compiled automatically from upstream's latest `main` branch and **do not undergo manual testing**. They may contain:
>
> - **Critical vulnerabilities** (e.g., CVE-2026-98432 in Xray-core v26.10.29, related to MPTCP and allowing remote root execution).
> - **Broken configurations** (format incompatibilities, protocol regressions).
>
> **Only use stable releases for updates** via the "Update" button in the panel (Settings → Panel) or via `install.sh` with a specific tag. Do not deploy `dev-latest` on a production server.

## Other Security Measures (Inherited)

- **Per-client IP limits** with fail2ban integration.
- **Granularly scoped API tokens** (SHA-256 hashes).
- **Two-factor TOTP authentication**.
- **CSRF protection, login rate limiting, SSRF protection**.
- **Path traversal protection** (verified by `TestGeodataRejectsBadRequests`).

## What Remains (Inherited, Unpatched)

- **Client IP addresses are stored in plaintext** in the SQLite database (`inbound_client_ips`, `node_client_ip`).
- **The panel scans its environment** at startup.

## Recommendations for Operators

1. **Upgrade to v3.3.1+** (this fork is already ahead of it).
2. **Change admin credentials** immediately after installation.
3. **Restrict panel access** to trusted IPs.
4. **Run Xray with minimal privileges**.
5. **Enable fail2ban**.
6. **Take regular backups** of the database.
