## Known Limitations

### `install.sh` Does Not Preserve the Xray Core

If you **reinstall** the panel via `install.sh` on a **live** system
— the Xray core will reset to the version bundled in the archive. To **update**, use:

- The "Update" button in the panel (UI).
- The `x-ui update` command.

These methods **preserve** the selected core (patch `[8/8]` in `update.sh`).

### Systemd Sandbox

Starting from `v3.10.0`, the panel runs in a sandbox: `/usr, /boot, /etc, /home, /root`
are read-only, except for the panel's directories (`/etc/x-ui`, `/usr/local/x-ui`, `/var/log/x-ui`).

If you have **changed** the panel paths (`XUI_DB_FOLDER`, `XUI_LOG_FOLDER`), the sandbox
may **block** write access. The solution is a custom drop-in:

```bash
# /etc/systemd/system/x-ui.service.d/20-local.conf
[Service]
ReadWritePaths=/your/path
```
Or — do not use custom paths (keep the defaults).

### Xray-core 26.10.10 — TLS

Xray-core 26.10.10 verifies outbound TLS using built-in Mozilla roots
rather than system roots. If an outbound connects to a server with a private CA, enable
Use system CA in that outbound's TLS settings.

### Ads — If They Return

This fork strips ads from upstream files via remove-ads.sh. If
upstream adds a new ad placement, the fork might not remove it right away.
Report it — we will add it to the script.

### What Does Not Work

- Do not update via install.sh on a live panel — it will reset the core.
- Do not use custom paths without a sandbox drop-in.
- Do not expect instant support — this is maintained by a single developer.
