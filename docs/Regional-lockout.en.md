### Sanctions Restrictions by VPS Hosting Providers (Geoblocking and KYC)

Major European Union hosting providers (Hetzner, OVH, Contabo, Scaleway, etc.), as well as many local data centers in neighboring countries (including certain facilities in Armenia and Georgia that follow Western compliance standards), enforce sanctions regulations and apply strict restrictions:

* **100% blocking from sanctioned countries and cities.** Registration, payment, and dashboard logins from IP addresses in sanctioned countries and regions (Russia, Belarus, Crimea, Sevastopol, Donetsk, Luhansk, etc.) are blocked automatically. Attempting to access the billing panel without a clean proxy, or switching IPs during a session, frequently triggers an instant account freeze.
* **Strict document verification (KYC) and payment checks.** At the slightest mismatch between the IP country, phone number, or bank card, the hoster requests a passport or proof of address (Utility Bill). Documents from sanctioned countries and cities are rejected, and the account is terminated without a refund.
* **Risk of instant server loss.** When a compliance filter triggers, the VPS is shut down without prior warning along with all stored data. Always keep local backups of your panel database (`x-ui.db`) and configurations on your own device.
* **What to look for when choosing a hoster.** The safest approach is to choose providers and resellers in neutral Asian or Middle Eastern jurisdictions (such as Hong Kong, Singapore, the UAE, or Kazakhstan) or reputable international resellers that **do not require KYC** and accept cryptocurrency payments.

### Hoster Internal Complaint Rating (Abuse Score) and IP Blocking

Almost all foreign data centers maintain an internal **complaint rating (Abuse Score)** for each customer and dedicated IP address. Accumulating complaints leads to forced server termination without refunding the remaining balance.

* **How the Abuse Score increases.** Automated data center anti-fraud systems and external organizations (Spamhaus, copyright holders, national CERTs) detect suspicious activity originating from your IP:
  * **Port scanning and brute-forcing** (if a user or a malicious script on the server scans external networks).
  * **Torrents (BitTorrent / P2P)** — copyright holders automatically send abuse reports to the hoster when movies or games are downloaded through your VPS IP.
  * **Mass requests and scraping (DDoS / aggressive scraping)** — if thousands of identical requests hit a single website from your IP, it gets flagged on botnet blacklists.
  * **Spam mailings** (an open outbound SMTP port 25 or a compromised script on the server).
* **Consequences of a high Abuse Score:**
  * **Server suspension (Null-route / Suspend).** After receiving 1–3 abuse reports, the hoster temporarily suspends the VPS and demands an explanation via a support ticket within 24 hours.
  * **Account termination without a refund.** Upon repeated complaints or ignoring a ticket, the server is deleted with no opportunity to retrieve backups.
  * **"Dirty" IP (CAPTCHAs and blocks).** Even if the hoster does not shut down the server, a high score in global reputation databases (such as AbuseIPDB) will cause Google, Cloudflare, and banking sites to bombard you with endless CAPTCHAs (solvable only by routing egress traffic through **Cloudflare WARP Outbound**).
* **How to keep your Abuse Score at zero:**
  1. **Block torrents at the Xray level.** Add a rule in `routing` to block the `bittorrent` protocol (`"protocol": ["bittorrent"]` → `outboundTag: "block"`), ensuring that even an accidentally left-open torrent client on a phone or PC never compromises your server.
  2. **Close outbound port 25 (SMTP).** Block outbound traffic on port `25` in your firewall (`ufw deny out 25/tcp`) to eliminate any suspicion of spam activity.
  3. **Do not use a personal VPS for scraping or scanning.** Separate your workloads: a personal proxy server should operate strictly as a clean gateway for everyday internet browsing.
