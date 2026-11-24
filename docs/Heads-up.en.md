## **A CALL TO UPSTREAM COMMITTERS AND CONTRIBUTORS**

**This section is not a complaint. It is a requirement for the development process.**

A proxy control panel is an **infrastructure tool**. Its code
runs on servers that people rely on to bypass censorship. A flaw in this
code is not an "app bug" — it is a **vulnerability** that can cost a
server operator their freedom or safety.

**We call on upstream committers and contributors to exercise discipline:**

1. **Audit every PR for security.** Do not merge code that
   adds network calls without explaining why. Do not merge code that
   connects to domains unique to the panel. Do not merge code that
   writes files outside the panel's directories.

2. **Require signed commits.** The xz/liblzma (Jia Tan) scenario is
   not a theory. It is reality. If a contributor cannot sign their
   commit, that is a reason for extra review, not for "taking their word for it."

3. **Respond to security issues.** If the community opens an
   Issue stating that the panel generates an identifying SNI, that is not "not
   planned." That is a **task**. If the community asks for an opt-out from
   sponsor tracking, that is not "we don't want to." That is a **security
   requirement**.

4. **Do not ignore calls to harden the supply chain.** If
   users ask for PR audits and contributor verification, that is not
   "paranoia." That is **accountability** to those who use your code.

**We call on the community to hold contributors accountable:**

- If you spot an issue — **open an Issue**, do not stay silent.
- If an Issue is closed as "not planned" — **reopen it**,
  with a description of the threat model.
- If upstream ignores it — **fork and strip it out**. Silence = consent.
- If you are a contributor — **do not merge what you have not verified**. Your name
  is on the commit. Your responsibility.

**This fork is our response to negligence.** We do not claim that the upstream
author is malicious. We assert that **the development process does not
ensure security**, and this creates real risks. Until upstream
changes its process, forks will exist. This is not a "split." It is
**insurance**.

**If you use upstream — audit it. If you are a contributor —
own your code. If you are the author — listen to the community.**

### Update Policy

- Critical security fix (CVE).
- The panel fails to start / breaks.
- Xray core reset upon update.
- Personal necessity.

Niche fixes (multi-user Shadowsocks, node sync, MTProto, vmess import) are **skipped** unless needed.

## Policy Regarding Sponsor Commits

This fork **deliberately removes** upstream sponsor infrastructure:
`sponsor.go`, `SponsorSlot`, `SponsorsPage`, `useSponsorsQuery`, donate buttons,
and the `/sponsors` endpoint. The reason is privacy: upstream code queries
`sponsors.sanaei.dev` on every login page load (whenever the cache
expires), exposing the server's IP and SNI to a third party with no option to disable it.
For operators in censored countries, this allows DPI to fingerprint
the panel as 3x-ui.

**What this means for upstream commits:**

- Sponsor commits (new slots, new endpoints, changes to
  `sponsor.go` or sponsor frontend components) **are not accepted in this
  fork in their original form**. They will be **reworked** via
  `scripts/remove-ads.sh`: sponsor code is stripped out, `sponsor.go`
  is replaced with a stub, and endpoints are removed.
- This is **not** hostility toward upstream. [3x-ui](https://github.com/MHSanaei/3x-ui)
  is a great panel, and we are grateful to the author and contributors. However, this fork
  exists **specifically** to eliminate sponsor tracking. If
  upstream adds new sponsor features, this fork will strip them out rather than
  inherit them.
- If you want your sponsor feature to **remain** in the panel —
  use [upstream](https://github.com/MHSanaei/3x-ui). It works as intended there.
  **Here — NO! And IT NEVER WILL!**

**How it works technically:**

After every `Sync Upstream`, `scripts/remove-ads.sh` runs and:

1. Removes sponsor frontend components.
2. Replaces `internal/web/service/panel/sponsor.go` with a stub (functions
   return empty values; no network requests are made).
3. Strips sponsor routes, menus, and locales.
4. Removes `/sponsors` from `openapi.json` and regenerates the MDX documentation.

If upstream adds a **new location** for sponsors (a new file, a new
endpoint, a new button) — `remove-ads.sh` might not cover it immediately. In
that case, the fork will **update** the script rather than inherit the feature. **This
is a deliberate policy**, not a bug.

### Our Stance

We **do not call** for a boycott of upstream. The 3x-ui project is an important
tool, and we are grateful to the author for the code. However, we believe that:

1. **Security negligence is not a "development style."** When a
   censorship-circumvention panel generates an identifying SNI, writes
   arbitrary files, and fails to verify node signatures — those are **architectural
   flaws**, not "features."

2. **The community must influence contributors.** If you use
   upstream and see a problem — open an Issue, demand reviews,
   and advocate for signed commits. Silence = consent.

3. **Forks are not a "split," they are insurance.** When upstream fails to respond
   to security issues, forks (like this one) take on the role of
   "stripping out what is dangerous and documenting why."

**We urge panel operators:**

- **Check where your panel connects (`tcpdump`, `strings`).**
- **Do not update to every upstream release without auditing it first.**
- **If you spot an issue — report it upstream, do not stay silent.**
- **If upstream ignores it — fork and strip it out.**

**This fork is our response to negligence. It is not perfect, but it is **transparent**:
everything we strip out is documented in `scripts/remove-ads.sh`, and
anyone can inspect what remains.**
