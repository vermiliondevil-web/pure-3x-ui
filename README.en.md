# pure-3x-ui

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

> **This is a fork.** The project is a derivative work of [3x-ui](https://github.com/MHSanaei/3x-ui) (author — [MHSanaei](https://github.com/MHSanaei)) and is distributed under the **AGPL-3.0** license. All changes made in this fork are published under the same license.

A clean build of [3x-ui](https://github.com/MHSanaei/3x-ui) without ads or donation blocks.

> [!CAUTION]
> **Do not use `dev-latest` / pre-release builds**
>
> `dev-latest` builds (and any pre-release) are produced automatically from fresh upstream `main` and **do not go through manual testing**. They may contain:
>
> - **Critical vulnerabilities** (e.g. CVE-2026-98432 in Xray-core v26.10.29, related to MPTCP and allowing remote root access).
> - **Broken configurations** (format incompatibility, protocol regressions).
>
> **Use only stable releases** via the "Update" button in the panel (Settings → Panel) or via `install.sh` with a specific tag. Do not install `dev-latest` on production.

**A CALL TO UPSTREAM COMMITTERS AND CONTRIBUTORS**

**This section is not a complaint. It is a demand on the development process.**

A proxy management panel is **infrastructure**. Its code runs on servers that people use to circumvent censorship. A bug in this code is not "an app bug" — it is a **vulnerability** that can cost a server operator their freedom or safety.

**We call on upstream committers and contributors to exercise discipline:**

1. **Review every PR for security.** Do not merge code that adds network calls without explaining why. Do not merge code that contacts domains unique to the panel. Do not merge code that writes files outside the panel's directories.

2. **Require signed commits.** The xz/liblzma (Jia Tan) scenario is not theory. It is reality. If a contributor cannot sign a commit, that is grounds for additional review — not for "let's trust them".

3. **Respond to security issues.** If the community opens an Issue saying the panel creates an identifying SNI — that is not "not planned". It is a **task**. If the community asks for an opt-out for sponsor tracking — that is not "we don't want to". It is a **security requirement**.

4. **Do not ignore calls to harden the supply chain.** If users ask for PR audits and contributor verification — that is not "paranoia". It is **responsibility** toward those who use your code.

**We call on the community to influence contributors:**

- If you see a problem — **open an Issue**, don't stay silent.
- If an Issue is closed as "not planned" — **open it again**, with a threat model.
- If upstream ignores it — **fork and strip it out**. Silence equals consent.
- If you are a contributor — **do not merge what you have not reviewed**. Your name is on the commit. Your responsibility.
- **This fork is our answer to negligence.** We are not claiming the upstream author is malicious. We are claiming that **the development process does not ensure security**, and this creates real risks. Until upstream changes the process, forks will exist. This is not a "split". It is **insurance**.

**If you use upstream — verify. If you are a contributor — own your code. If you are the author — listen to the community.**
### Update policy

- Critical security fix (CVE).
- Panel does not start / breaks.
- Xray core is reset on update.
- Personal necessity.

Niche fixes (multi-user Shadowsocks, node sync, MTProto, vmess import) are **skipped** unless used.
### Current state

- **Fork:** [Releases](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
- **Upstream:** [Releases](https://github.com/MHSanaei/3x-ui/releases)
- **Sync history:** [docs/upstream-changelog.md](docs/upstream-changelog.md)
## Policy on sponsor commits

This fork **deliberately removes** upstream's sponsor infrastructure: `sponsor.go`, `SponsorSlot`, `SponsorsPage`, `useSponsorsQuery`, donation buttons, the `/sponsors` endpoint. The reason is privacy: upstream code contacts `sponsors.sanaei.dev` on every login page load (when the cache expires), exposing the server IP and SNI to a third party with no way to disable it. For operators in censored countries, this lets DPI identify the panel as 3x-ui.

**What this means for upstream commits:**

- Sponsor commits (new slots, new endpoints, changes to `sponsor.go` or the sponsor frontend components) are **not accepted in this fork as-is**. They are **reworked** via `scripts/remove-ads.sh`: sponsor code is stripped, `sponsor.go` is replaced with a stub, endpoints are removed.
- This is **not** hostility toward upstream. The [3x-ui](https://github.com/MHSanaei/3x-ui) project is an excellent panel, and we are grateful to the author and contributors. But this fork exists **specifically** to remove sponsor tracking. If upstream adds new sponsor features, the fork will strip them, not inherit them.
- If you want your sponsor feature to **stay** in the panel — use [upstream](https://github.com/MHSanaei/3x-ui). It works there as intended. **Here — NO! AND IT NEVER WILL!**

**How it works technically:**

After every `Sync Upstream`, `scripts/remove-ads.sh` runs and:

1. Removes the sponsor frontend components.
2. Replaces `internal/web/service/panel/sponsor.go` with a stub (functions return empty values, no network calls).
3. Removes sponsor routes, menu entries, locales.
4. Strips `/sponsors` from `openapi.json` and regenerates the MDX documentation.
If upstream adds a **new place** for sponsors (a new file, a new endpoint, a new button), `remove-ads.sh` may not cover it immediately. In that case the fork **extends the script**, it does not inherit the feature. **This is a deliberate policy**, not a bug.
## Upstream security: known incidents and our position

This fork exists not only to remove ads. We closely monitor upstream security, because a proxy management panel is infrastructure, not a toy. Below are the cases that made us treat upstream code with caution. We **do not claim** the upstream author is malicious. We claim that **the development process is prone to negligence**, and this creates real risks for operators.
### 1. Sponsor tracking as a leak channel (Issue #6824)

Until v3.10.2, the panel contacted `sponsors.sanaei.dev` on every login page load (when the cache expired) — a domain unique to 3x-ui. In the TLS SNI, this domain was visible to any on-path observer, including DPI. This let anyone identify the server as a 3x-ui panel **from a single connection**. The upstream author (MHSanaei) **acknowledged the problem** and in v3.10.2 replaced the domain with `raw.githubusercontent.com`, which is used by many tools and does not expose the panel. But the problem existed **for years**, and fixing it required a public Issue with a threat model.

**What this means:** the sponsor infrastructure was not "just advertising". It created an **identifying signal** for censors.
### 2. Node sync without signatures (GHSA-rr44-v4rv-x654)

In September 2026, security researchers found that the master panel receives data from nodes via `GET panel/api/inbounds/list` and **does not verify the response signature**. A compromised node could **overwrite client UUIDs/Passwords** on the master (via a global email search) and **inject its own endpoint** into the user's subscription.

**What this means:** the trust architecture between master and node was broken. A node could attack the master, and the master would not notice.
### 3. Arbitrary file write (CVE-2026-55477)

Before v3.3.1, any panel admin could, via a database import, redirect the Xray log to `~/.ssh/authorized_keys` and write their own key there — i.e., **gain root access to the server**. The vulnerability was fixed only after public disclosure (CVSS 7.2).

**What this means:** path validation in upstream was absent. The hole allowed turning the panel into a server takeover tool.
### 4. Calls to harden the supply chain (Issue #4962)

In June 2026, users **directly asked** the upstream author to: audit PRs, verify contributor identities (to avoid the "Jia Tan" scenario from xz/liblzma), require signed commits, and not merge huge PRs without review. The upstream author **did not respond substantively** — only gave downgrade instructions.

**What this means:** the community sees the problem, but the development process does not change.
---

### Our position

We **do not call for** a boycott of upstream. The 3x-ui project is an important tool, and we are grateful to the author for the code. But we believe that:

1. **Security negligence is not a "development style".** When a censorship-circumvention panel creates an identifying SNI, writes arbitrary files, and does not verify node signatures — these are **architectural errors**, not "features".
2. **The community must influence contributors.** If you use upstream and see a problem — open an Issue, demand review, propose signed commits. Silence equals consent.

3. **Forks are not a "split", but insurance.** When upstream does not respond to security issues, forks (like this one) take on the role of "strip out what is dangerous and document why".
4. **We call on panel operators:**
- **Check where your panel phones home (tcpdump, strings).**
- **Do not update to every upstream release without checking.**
- **If you see a problem — report it upstream, don't stay silent.**
- **If upstream ignores it — fork and strip it out.**

**This fork is our answer to negligence. It is not perfect, but it is transparent: everything we strip is documented in `scripts/remove-ads.sh`, and anyone can verify what is left.**
## Upstream release tracking

This fork **does not update** on every upstream release. Below is what came out, what was taken, and why.

| Date | Upstream | What's in it | Decision |
|------|----------|--------------|----------|
| 2026-10-10 | v3.10.0 | MASQUE, WARP modal, Xray 26.10.10, systemd sandbox | ✅ taken (prod + test) |
| 2026-10-13 | v3.10.2 | Shadowsocks hot apply, node sync load, vmess import, MTProto limit, sponsor SNI fix, Windows 3x-ui.exe | ❌ skipped |

### Why v3.10.2 was skipped

- **Shadowsocks hot apply** — only for multi-user Shadowsocks. Not used.
- **Node sync load** — only for multi-node setups. Master only.
- **vmess link import** — only when importing vmess links. Not used.
- **MTProto handshake limit** — only for MTProto. Not used.
- **Sponsor SNI fix** — sponsors are stripped, irrelevant.
- **Windows 3x-ui.exe** — Linux build, irrelevant.
- **Core crash reports** — useful, but not critical.
---

## Who this fork is for

This fork is **for personal use**. The author does not sell keys, does not provide access services, does not serve clients.

**What this means:**

- Updates are **rare**, only when there is a critical fix or a personal need.
- Niche upstream features (multi-user Shadowsocks, node sync for many nodes, MTProto for heavy loads) are **skipped** unless used.
- The fork is **not optimized** for large setups: dozens of nodes, hundreds of clients, reseller APIs.
- In future updates of major versions, when significant bug fixes accumulate and after analyzing the upstream of the original developer, if it really matters, a release will come out. **Cumulative** updates will include improvements specifically from the original author with whom this fork is synchronized. The automation only strips ads for the aesthetics of **home use**.

**If you sell access** — this fork is probably **not for you**. Use [upstream](https://github.com/MHSanaei/3x-ui) — it has all the features for large setups, and the author supports them.

**If you have 3–10 users** (family, friends, personal server) — this fork is for you: no ads, core preservation, rare updates.
## Support

This fork **does not accept donations** and contains no ads. The project is distributed as-is, for personal and non-commercial use.

If you want to support **upstream development** — please refer to the [original repository](https://github.com/MHSanaei/3x-ui).
## About the project

This is a fork of the **3x-ui** panel by [MHSanaei](https://github.com/MHSanaei). Ads and sponsor infrastructure are automatically stripped from upstream files, and a bug where the Xray core was overwritten on panel update has been fixed.

### Removed from the original

- 🚫 Ad blocks in the panel
- 🚫 Donation links and promo materials
- 🚫 Sponsor slots (`SponsorSlot`, `SponsorCard`, `SponsorsPage`)
- 🚫 Donation button in the sidebar (`DonateButton`)
- 🚫 Documentation button linking to third-party resources (`DocsButton`)
- 🚫 "Sponsors" menu item
- 🚫 `/sponsors` page
- 🚫 `/sponsors` endpoint in the API docs
- 🚫 Sponsor tracking (`sponsors.sanaei.dev`) — IP and SNI leak
### Changed

- 🔄 All links point to **this** repository (`vermiliondevil-web/pure-3x-ui`), not upstream
- 🔄 `panel.go`, `install.sh`, `update.sh`, `README.md` — updated for the fork
- 🔄 **Auto-version from tag**: `release.yml` inserts the tag number into `internal/config/version`
- 🔄 **Locales are not touched** in `remove-ads.sh` — this reduces the diff and simplifies merges
- 🔄 **`sponsor.go` replaced with a stub** — removes the `sponsors.sanaei.dev` leak
### Fixed

- 🔧 **The Xray core is no longer overwritten on panel update.**
  In upstream `update.sh`, before `tar`, the script does `cd /usr/local/`, so the relative path `bin/xray-linux-$(arch)` points to the wrong place — the archive silently overwrote the core selected by the user via Settings → Xray Updates. The fix (`scripts/remove-ads.sh`, patch `[8/8]`) uses absolute paths `${xui_folder}/bin/xray-linux-$(arch)`.
  Details: [docs/xray-core-preservation.md](docs/xray-core-preservation.md).
- 🔧 **`release.yml` renames `xray` → `xray-linux-amd64`.**
  Previously the archive contained the `xray` binary, but the panel expected `xray-linux-amd64` → `fork/exec bin/xray-linux-amd64: no such file or directory`. Now Xray is unpacked into a temporary folder and renamed before packaging.

### Not changed

Everything else — functionality, Xray core, interface, API, all protocols — is preserved unchanged.
---

## Known limitations

### `install.sh` does not preserve the Xray core

If you **reinstall** the panel via `install.sh` on a **live** system, the Xray core will be reset to the version from the archive. To **update**, use:

- The "Update" button in the panel (UI).
- The `x-ui update` command.

These methods **preserve** the selected core (patch `[8/8]` in `update.sh`).
### systemd sandbox

Since `v3.10.0`, the panel runs in a sandbox: `/usr`, `/boot`, `/etc`, `/home`, `/root` are read-only, except for the panel's folders (`/etc/x-ui`, `/usr/local/x-ui`, `/var/log/x-ui`).

If you **changed** the panel paths (`XUI_DB_FOLDER`, `XUI_LOG_FOLDER`), the sandbox may **block** writes. Solution — your own drop-in:

```bash
# /etc/systemd/system/x-ui.service.d/20-local.conf
[Service]
ReadWritePaths=/your/path
```
Or — do not use custom paths (keep the default).

### Xray-core 26.10.10 — TLS

Xray-core 26.10.10 verifies outbound TLS through built-in Mozilla roots, not the system ones. If the outbound goes to a server with a private CA — enable Use system CA in the TLS settings of that outbound.

### Ads — if they come back.

This fork strips ads from upstream files via `remove-ads.sh`. If upstream adds a new place for ads, the fork may not strip it immediately. Report it — we will add it.
### What does not work

- Do not update via `install.sh` on a live panel — it resets the core.
- Do not use custom paths without a sandbox drop-in.
- Do not expect instant support — this is one developer.

## Features

- Protocol support: **VLESS, VMess, Trojan, Shadowsocks, WireGuard, TUIC, AmneziaWG** and others
- Multi-protocol inbound/outbound
- Client management and traffic limits
- Statistics per user and per node
- Telegram bot for management
- Discord notifications
- **PostgreSQL** and **SQLite** support
- REST API + OpenAPI specification
- Dark and light themes
- **Let's Encrypt** support (domain and IP)
- Fail2ban integration
- Master-node architecture
---

## Installation

### Main method (recommended)

Run as **root**:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```
### Alternative methods

```bash
# 1. Via github.com/raw (redirects to raw.githubusercontent)
bash <(curl -Ls "https://github.com/vermiliondevil-web/pure-3x-ui/raw/main/install.sh")

# 2. With a specific tag (stable release)
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/v3.9.22/install.sh)
```
### What the script does

1. Detects the OS and architecture.
2. Installs dependencies.
3. Downloads the latest release from **this** repository.
4. Verifies `.sha256`.
5. Configures the service, database, SSL.
6. Prints the **login, password, port, webBasePath**, and **URL** of the panel.
---

## Management

```bash
x-ui              # Management menu
x-ui start        # Start
x-ui stop         # Stop
x-ui restart      # Restart
x-ui status       # Status
x-ui settings     # Current settings
x-ui enable       # Enable autostart
x-ui disable      # Disable autostart
x-ui log          # Logs
x-ui banlog       # Fail2ban ban logs
x-ui update       # Update
x-ui install      # Install
x-ui uninstall    # Uninstall
```
## Update

### Via the UI ("Update" button)

The panel **checks** the latest release on GitHub via `api.github.com/repos/vermiliondevil-web/pure-3x-ui/releases/latest` and **downloads** `update.sh` from `raw.githubusercontent.com`.

| Version in file | Tag on GitHub | Button |
|---|---|---|
| `3.9.21` | `v3.9.21` | ❌ inactive |
| `3.9.21` | `v3.9.22` | ✅ active |
| `3.9.22` | `v3.9.22` | ❌ inactive |

### Via `install.sh`

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```
**Important:** updating the panel does **not** overwrite the installed Xray core — the version you selected via Settings → Xray Updates is preserved. Details — [docs/xray-core-preservation.md](docs/xray-core-preservation.md).


## Building from source

```bash
git clone https://github.com/vermiliondevil-web/pure-3x-ui.git
cd pure-3x-ui/frontend
npm install
npm run build
cd ..
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o x-ui-main main.go
```
## Automation

The repository has **two GitHub Actions workflows**:

### 1. `Sync Upstream` — auto-sync with the original

**Runs in ~17 seconds.** Once a day (at 03:00 UTC) or manually:

1. Pulls fresh code from [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
2. **Takes locales and `update.sh` from upstream directly** — to avoid conflicts.
3. **Commits** those files.
4. Merges the rest with `-X theirs`.
5. Runs `scripts/remove-ads.sh` — strips ads and replaces `sponsor.go` with a stub.
6. Commits the changes and pushes to `main`.

**This means:** when Sanaei releases an update, ads are stripped **automatically**, and there are **no conflicts**.

### 2. `Build and Release` — build and publish releases

Triggered by a `v*` tag or manually:

1. **`Set version from tag`** — extracts the version from the tag and writes it to `internal/config/version`.
2. Strips ads (`scripts/remove-ads.sh`) — including replacing `sponsor.go` with a stub.
3. Builds the frontend (`npm run build`).
4. Builds the Go binary.
5. Downloads the Xray core from XTLS.
6. Packages everything into `x-ui-linux-amd64.tar.gz` + `.sha256`.
7. Publishes the release.

### How to publish a new version

1. **Create a tag** with the new number:

   ```bash
   cd /workspaces/pure-3x-ui
   git pull
   git tag v3.9.23
   git push origin v3.9.23
   ```
2. **GitHub Actions** builds release `v3.9.23` automatically.

3. The **"Update" button** becomes active.

4. **Click it** → the panel updates.

### When to publish a new release

- ✅ Sanaei released a **new stable release**.
- ✅ **Important bug fixes** have accumulated.
- ✅ You made **significant changes**.
- ❌ **Do not** publish a new release for **every commit** from Sanaei.

**Rule:** the version in `internal/config/version` **must match** the tag.
---

## Upstream synchronization

This fork **does not chase** every upstream release. Code is pulled automatically via the `Sync Upstream` workflow, but fork releases are rare — only after testing on a test environment.

### How it works

1. **Automatically** (once a day, 03:00 UTC): `Sync Upstream` pulls new upstream code into `main`.
2. **`remove-ads.sh`** strips ads/sponsors and patches `update.sh` (Xray core preservation).
3. **No fork release is published** — `main` updates, but no `v*` tag is created.
4. **When enough changes accumulate** — manual testing on a separate VPS begins.
5. **After a successful test** — a tag is created, `Build and Release` builds the release, production is updated.

### What this means

- `main` is fresh upstream code with our patches, but **not a release**.
- `v*` tags are verified releases for production.
- Production does not update on every upstream release.

### Why we don't chase every release

- Upstream releases **often** (v3.9.x → v3.10.0 in a month).
- Fresh releases **may contain bugs** — fixes come in v3.10.1, v3.10.2.
- **systemd sandbox** (v3.10.0) is a major change and may conflict with custom configurations.
- **Production needs stability**, not freshness.

## Code review before release

This fork is **not** a simple copy of upstream. Every release is checked for personal data leaks, telemetry, and hidden network requests.

### Why this matters

The original 3x-ui is developed by a **community of 310+ contributors**. Any PR can add:

- Telemetry (sending statistics to third-party servers).
- Sponsor requests (IP and SNI leak).
- Environment scanning (checking `.env`, `.git/config`).
- New dependencies with unknown behavior.

**The upstream author does not check every PR** for privacy. His priority is functionality and monetization.

### What is checked in this fork

| What is checked | How |
|---|---|
| Sponsor code | `scripts/remove-ads.sh` replaces `sponsor.go` with a stub |
| Ad links | Removed from `AppSidebar`, `LoginPage`, `routes` |
| Telemetry | Checked via the binary's `strings` |
| Hidden domains | `grep` over the code for `http://` and `https://` |
| New dependencies | Manual review of `go.mod` and `package.json` |
### How to verify yourself

```bash
# 1. Verify that sponsor code is removed
grep -rn "sponsors.sanaei.dev" internal/ frontend/src/ 2>/dev/null

# 2. Check the binary for suspicious domains
strings /usr/local/x-ui/x-ui | grep -iE "sponsor|sanaei|telemetry" | head

# 3. Monitor outbound connections
tcpdump -i any -n 'not host localhost' -c 20
```
### What this means for the user

- ✅ **Relevant updates** — pulled via `Sync Upstream`.
- ✅ **Leaks** — stripped automatically via `remove-ads.sh`.
- ✅ **New features** — reviewed before release.
- ⚠️ **Not a 100% guarantee** — you can verify the code yourself.
---

## Security

### CVE-2026-55477: Arbitrary file write by an authenticated admin

**What it is:** In 3x-ui versions **before 3.3.1**, an authenticated admin could, via a database import or the Xray config editor, achieve **arbitrary file write** on the server. By manipulating the `xrayTemplateConfig.log.access` value, an attacker could redirect the Xray access log to any file on the filesystem — including `~/.ssh/authorized_keys`.

**Impact:** If Xray runs as root — **full server takeover**.

**CVSS score:** 7.2 (High).

**Is this fork affected?** **No.** This fork is based on **v3.9.22**, which is well above the fixed version 3.3.1.
### `sponsors.sanaei.dev` leak removed

**What it was:** `internal/web/service/panel/sponsor.go` contained hardcoded URLs:
https://sponsors.sanaei.dev/3X/sponsors.json
https://sponsors.sanaei.dev/3X/logos/

On every login page load, the panel sent a request to `sponsors.sanaei.dev` — exposing the **server IP** and **SNI** to a third party. For operators in censored countries, this let DPI identify the panel as 3x-ui.
**What was done:**

- `sponsor.go` replaced with a **stub** (functions return empty values, no network calls).
- `scripts/remove-ads.sh` **automatically** replaces `sponsor.go` with a stub after every `Sync Upstream`.

**Check:**

```bash
strings /usr/local/x-ui/x-ui | grep -c "sponsors.sanaei.dev"
```
# Expected: 0

### Other security measures (inherited)

- **Per-client IP limiting** with fail2ban integration.
- **API tokens with granular scopes** (SHA-256 hashes).
- **TOTP two-factor authentication**.
- **CSRF protection, login rate limiting, SSRF protection**.
- **Path traversal protection** (verified by `TestGeodataRejectsBadRequests`).
### What remains (inherited, not fixed)

- **Client IPs are stored in plaintext** in the SQLite database (`inbound_client_ips`, `node_client_ip`).
- **The panel scans its own environment** at startup.

### Recommendations for operators

1. **Upgrade to v3.3.1+** (this fork is already above).
2. **Change the admin credentials** immediately after installation.
3. **Restrict panel access** to trusted IPs.
4. **Run Xray with minimal privileges**.
5. **Enable fail2ban**.
6. **Make regular backups** of the database.
---

## Origin and license

### This is a fork

`pure-3x-ui` is a derivative work (fork) of [3x-ui](https://github.com/MHSanaei/3x-ui).

- The project **is not** original development.
- Based on [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui) code.
- All changes are a layer on top of the original.
- The original author **bears no responsibility** for this fork.
### AGPL-3.0 license

The project is distributed under the **GNU Affero General Public License v3.0** (AGPL-3.0).

**What this means:**

- ✅ You can use, modify, distribute.
- ✅ You can fork.
- ⚠️ You must keep the same license (AGPL-3.0).
- ⚠️ You must credit the original author.
- ⚠️ If you provide network access to the panel, you must provide the source code.
- ⚠️ Closed forks are not allowed.
### Links

- **This fork:** https://github.com/vermiliondevil-web/pure-3x-ui
- **Original:** https://github.com/MHSanaei/3x-ui
- **License text:** [LICENSE](LICENSE)
---

## Acknowledgements

- [MHSanaei](https://github.com/MHSanaei) — for the original 3x-ui
- [XTLS/Xray-core](https://github.com/XTLS/Xray-core) — for the Xray core
- [Acme.sh](https://github.com/acmesh-official/acme.sh) — for SSL certificates
- [@Az-1-2](https://github.com/Az-1-2) — for the idea to strip `SponsorsPage` from `panelRoutes.tsx` (block `4.1b` in `remove-ads.sh`).
- All contributors to the original project
---

## Feedback

- Issues: https://github.com/vermiliondevil-web/pure-3x-ui/issues
- Pull Requests: welcome
---

## Disclaimer

This is an **unofficial fork**. The project is not affiliated with MHSanaei or XTLS.

The panel is provided as-is, for personal and non-commercial use.
