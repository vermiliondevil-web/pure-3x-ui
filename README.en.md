## pure-3x-ui [Русская версия](README.md) 

[![Build and Release](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/release.yml)
[![Sync Upstream](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml/badge.svg)](https://github.com/vermiliondevil-web/pure-3x-ui/actions/workflows/sync-upstream.yml)
[![Release](https://img.shields.io/github/v/release/vermiliondevil-web/pure-3x-ui?label=release)](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest)
[![License](https://img.shields.io/github/license/vermiliondevil-web/pure-3x-ui)](LICENSE)

## [How It Works]
## [Known Limitations]
## [Security](docs/security.md)
## [Regional Hosting Provider Lockouts]
## [Thoughts on the Original Project]
## [About the Project and Build Automation]

### Current Sync and Build Status

- **Fork:** [Releases](https://github.com/vermiliondevil-web/pure-3x-ui/releases/latest) **Upstream:** [Releases](https://github.com/MHSanaei/3x-ui/releases) **Release Changelog:** [docs/upstream-changelog.md](docs/upstream-changelog.md)

> **This is a fork.** This project is a derivative work of [3x-ui](https://github.com/MHSanaei/3x-ui) (created by [MHSanaei](https://github.com/MHSanaei)) and is distributed under the **AGPL-3.0** license. All modifications made in this fork are published under the same license.

A clean build of [3x-ui](https://github.com/MHSanaei/3x-ui) without ads or donation blocks.

## Installation

### Primary Method (Recommended)

Run as **root**:

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```

### Alternative Methods

```bash
# 1. Via github.com/raw (redirects to raw.githubusercontent)
bash <(curl -Ls "https://github.com/vermiliondevil-web/pure-3x-ui/raw/main/install.sh")

# 2. With a specific tag (stable release)
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/v3.9.22/install.sh)
```

## Docker (Alternative Fork)

This fork **does not include** a Docker build (use `install.sh` for personal VPS setups).

If you need a **Docker image**, check out the fork by [@Az-1-2](https://github.com/Az-1-2):
it supports Docker builds and provides installation instructions.


### What the Script Does

1. Detects the OS and architecture.
2. Installs dependencies.
3. Downloads the latest release from **this** repository.
4. Verifies `.sha256`.
5. Configures the service, database, and SSL.
6. Outputs the panel's **username, password, port, webBasePath**, and **URL**.

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

---

## Updating

### Via UI ("Update" Button)

The panel **automatically checks** for the latest release on GitHub via
`api.github.com/repos/vermiliondevil-web/pure-3x-ui/releases/latest`
and **downloads** `update.sh` from `raw.githubusercontent.com`.

| Version in File | Tag on GitHub | Button |
|---|---|---|
| `3.9.21` | `v3.9.21` | ❌ disabled |
| `3.9.21` | `v3.9.22` | ✅ enabled |
| `3.9.22` | `v3.9.22` | ❌ disabled |

### Via `install.sh`

```bash
bash <(curl -Ls https://raw.githubusercontent.com/vermiliondevil-web/pure-3x-ui/main/install.sh)
```

### Xray Core

The Xray update button in the panel is **safe** — it pulls the core directly from [XTLS/Xray-core](https://github.com/XTLS/Xray-core), which contains **no** ads.

**Important:** Updating the panel **does not** overwrite the installed Xray core — the version you selected via Settings → Xray Updates is preserved. For details, see [docs/xray-core-preservation.md](docs/xray-core-preservation.md).

---

## Building from Source

```bash
git clone https://github.com/vermiliondevil-web/pure-3x-ui.git
cd pure-3x-ui/frontend
npm install
npm run build
cd ..
CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -ldflags "-w -s" -o x-ui-main main.go
```

The binary will be created as `./x-ui-main`.

---
---

## Origin and License

### This Is a Fork

`pure-3x-ui` is a derivative work (fork) of [3x-ui](https://github.com/MHSanaei/3x-ui).

- This project **is not** an original work.
- It is based on the code of [MHSanaei/3x-ui](https://github.com/MHSanaei/3x-ui).
- All changes are additions built on top of the original.
- The original author **bears no responsibility** for this fork.

### AGPL-3.0 License

This project is distributed under the **GNU Affero General Public License v3.0** (AGPL-3.0).

**What this means:**

- ✅ You may use, modify, and distribute it.
- ✅ You may create forks.
- ⚠️ You must retain the same license (AGPL-3.0).
- ⚠️ You must credit the original author.
- ⚠️ If you provide network access to the panel, you must make the source code available.
- ⚠️ You cannot create closed-source forks.

### Links

- **This fork:** https://github.com/vermiliondevil-web/pure-3x-ui
- **Original:** https://github.com/MHSanaei/3x-ui
- **License text:** [LICENSE](LICENSE)

---

## Acknowledgments

- [MHSanaei](https://github.com/MHSanaei) — for the original 3x-ui
- [XTLS/Xray-core](https://github.com/XTLS/Xray-core) — for Xray-core
- [Acme.sh](https://github.com/acmesh-official/acme.sh) — for SSL certificates
- [@Az-1-2](https://github.com/Az-1-2) — for the idea of stripping `SponsorsPage` from `panelRoutes.tsx` (block `4.1b` in `remove-ads.sh`).
- All contributors to the original project

---

## Feedback

- Issues: https://github.com/vermiliondevil-web/pure-3x-ui/issues
- Pull Requests: welcome

---

## Disclaimer

This is an **unofficial fork**. This project is not affiliated with MHSanaei or XTLS.

The panel is provided "as is", for personal and non-commercial use.
