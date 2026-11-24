## Who This Fork Is For

This fork is **for personal use**. The author does not sell keys, provide access services, or support customers.

**What this means:**

- Updates are **infrequent**, released only when there is a critical fix or personal need.
- Niche upstream features (multi-user Shadowsocks, multi-node sync at scale, high-load MTProto) are **skipped** if unused.
- The fork is **not optimized** for large setups: dozens of nodes, hundreds of clients, or reseller APIs.
- In future major version updates, once significant bug fixes accumulate and after reviewing the original developer's upstream changes, a release will be published if it truly matters. **Cumulative** updates will include improvements made specifically by the original author with whom this fork is synchronized. Automation only strips ads for a clean **home-use** aesthetic.

**If you sell access** — this fork is most likely **not for you**. Use [upstream](https://github.com/MHSanaei/3x-ui) — it has all the features for large setups, and the author maintains them.

**If you have 3–10 users** (family, friends, a personal server) — this fork is for you: ad-free, preserves the Xray core, and has infrequent updates.

## Support

This fork **does not accept donations** and contains no ads. The project is provided as is, for personal and non-commercial use.

If you want to support **upstream development** — please visit the [original repository](https://github.com/MHSanaei/3x-ui).

## About the Project

This is a fork of the **3x-ui** panel by [MHSanaei](https://github.com/MHSanaei). Ads and sponsor infrastructure are automatically stripped from upstream files, and a bug that overwrote the Xray core during panel updates has been fixed.

### Removed from Upstream

- 🚫 Ad blocks in the panel
- 🚫 Donation links and promotional materials
- 🚫 Sponsor slots (`SponsorSlot`, `SponsorCard`, `SponsorsPage`)
- 🚫 Donate button in the sidebar (`DonateButton`)
- 🚫 Documentation button linking to third-party resources (`DocsButton`)
- 🚫 "Sponsors" menu item
- 🚫 `/sponsors` page
- 🚫 `/sponsors` endpoint in the API docs
- 🚫 Sponsor tracking (`sponsors.sanaei.dev`) — IP and SNI leak

### Changed

- 🔄 All links point to **this** repository (`vermiliondevil-web/pure-3x-ui`) instead of upstream
- 🔄 `panel.go`, `install.sh`, `update.sh`, and `README.md` — updated for the fork
- 🔄 **Auto-version from tag**: `release.yml` automatically injects the tag number into `internal/config/version`
- 🔄 **Locales are left untouched** in `remove-ads.sh` — this reduces diffs and simplifies merges
- 🔄 **`sponsor.go` replaced with a stub** — eliminates the `sponsors.sanaei.dev` leak

### Fixed

- 🔧 **The Xray core is no longer overwritten when updating the panel.**
  In upstream `update.sh`, the script runs `cd /usr/local/` before `tar`, causing the relative path `bin/xray-linux-$(arch)` to point to the wrong location — the archive silently overwrote the core selected by the user via Settings → Xray Updates. The fix (`scripts/remove-ads.sh`, patch `[8/8]`) uses absolute paths `${xui_folder}/bin/xray-linux-$(arch)`. Details: [docs/xray-core-preservation.md](docs/xray-core-preservation.md).

- 🔧 **`release.yml` renames `xray` → `xray-linux-amd64`.**
  Previously, the archive contained the `xray` binary while the panel expected `xray-linux-amd64` → `fork/exec bin/xray-linux-amd64: no such file or directory`. Now Xray is extracted to a temporary directory and renamed before packaging.

### Unchanged

Everything else — functionality, Xray core, UI, API, and all protocols — remains unchanged.

---

## Features

- Protocol support: **VLESS, VMess, Trojan, Shadowsocks, WireGuard, TUIC, AmneziaWG**, and more
- Multi-protocol inbounds/outbounds
- Client management and traffic limits
- User and node statistics
- Telegram bot for management
- Discord notifications
- **PostgreSQL** and **SQLite** support
- REST API + OpenAPI specification
- Dark and light themes
- **Let's Encrypt** support (domain and IP)
- Fail2ban integration
- Master-node architecture

---

## Automation

**Two GitHub Actions workflows** are configured in the repository:

### 1. `Sync Upstream` — Auto-Sync with Upstream

**Takes ~17 seconds.** Runs once a day (at 03:00 UTC) or manually:

1. Pulls the latest code from [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
2. **Takes locales and `update.sh` directly from upstream** — to avoid merge conflicts.
3. **Commits** those files.
4. Merges the rest using `-X theirs`.
5. Runs `scripts/remove-ads.sh` — strips ads and replaces `sponsor.go` with a stub.
6. Commits the changes and pushes to `main`.

**What this means:** whenever Sanaei releases an update, ads are stripped **automatically** with **zero** conflicts.

### 2. `Build and Release` — Building and Publishing Releases

Triggered by a `v*` tag or manually:

1. **`Set version from tag`** — extracts the version from the tag and writes it to `internal/config/version`.
2. Strips ads (`scripts/remove-ads.sh`) — including replacing `sponsor.go` with a stub.
3. Builds the frontend (`npm run build`).
4. Builds the Go binary.
5. Downloads Xray core from XTLS.
6. Packages everything into `x-ui-linux-amd64.tar.gz` + `.sha256`.
7. Publishes the release.

### How to Release a New Version

1. **Create a tag** with the new version number:

   ```bash
   cd /workspaces/pure-3x-ui
   git pull
   git tag v3.9.23
   git push origin v3.9.23
   ```

   Or via GitHub: `Releases → Draft a new release → Choose a tag → v3.9.23 → Publish release`.

2. **GitHub Actions** will automatically build the `v3.9.23` release.

3. **The "Update" button** will become active.

4. **Click it** → the panel will update.

### When to Publish a New Release

- ✅ Sanaei released a **new stable release**.
- ✅ **Important bug fixes** have accumulated.
- ✅ You made **significant changes**.
- ❌ **Do not** publish a new release for **every single commit** by Sanaei.

**Rule:** the version in `internal/config/version` **must match** the tag.

---

## Syncing with Upstream

This fork **does not chase** every upstream release. Code is pulled automatically via the `Sync Upstream` workflow, while fork releases are published infrequently — only after verification in a test environment.

### How It Works

1. **Automatically** (once a day, 03:00 UTC): `Sync Upstream` pulls new upstream code into `main`.
2. **`remove-ads.sh`** strips ads/sponsors and patches `update.sh` (preserving the Xray core).
3. **No fork release is published** — `main` is updated, but no `v*` tag is created.
4. **Once enough changes accumulate** — manual testing is run on a separate VPS.
5. **After a successful test** — a tag is created, `Build and Release` builds the release, and production is updated.

### What This Means

- `main` — fresh upstream code with our patches, but **not a release**.
- `v*` tags — verified releases for production.
- Production is not updated on every upstream release.

### Why We Don't Chase Every Release

- Upstream releases **frequently** (v3.9.x → v3.10.0 within a month).
- Fresh releases **may contain bugs** — fixes arrive in v3.10.1, v3.10.2.
- **Systemd sandbox** (v3.10.0) — a major change that can conflict with custom configurations.
- **Stability matters in production**, not bleeding-edge freshness.

## Pre-Release Code Audit

This fork **is not** a blind copy of upstream. Every release is audited for personal data leaks, telemetry, and hidden network requests.

### Why This Matters

The original 3x-ui is developed by a **community of 310+ contributors**. Any PR could introduce:

- Telemetry (sending statistics to third-party servers).
- Sponsor requests (IP and SNI leaks).
- Environment scanning (checking `.env`, `.git/config`).
- New dependencies with unknown behavior.

**The upstream author does not audit every PR** for privacy. Their priority is features and monetization.

### What Is Checked in This Fork

| What Is Checked | How |
|---|---|
| Sponsor code | `scripts/remove-ads.sh` replaces `sponsor.go` with a stub |
| Ad links | Removed from `AppSidebar`, `LoginPage`, and `routes` |
| Telemetry | Inspected via `strings` on the compiled binary |
| Hidden domains | `grep` across the codebase for `http://` and `https://` |
| New dependencies | Manual review of `go.mod` and `package.json` |
