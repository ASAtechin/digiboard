# Play Store data safety answers (draft)

Worked out from the code on `pilot-platform-display` (25 Oct 2026, W18): `lib/platform/platform_client.dart` (pairing, pairing poll, heartbeat; no personal data in any request), `pubspec.yaml` (no analytics, ads, crash reporting, camera, location or file packages) and the manifest (`INTERNET`, `RECEIVE_BOOT_COMPLETED` and `SYSTEM_ALERT_WINDOW` for kiosk start-up). Check again before each release.

| Question | Answer |
|---|---|
| Does the app collect or share any of the required user data types? | No. The check-in carries the screen's own state (on, mode, app version, start time, clock, what it shows), not data about a user |
| Encrypted in transit | Yes (HTTPS to the address it is built with) |
| Data deletion | Nothing collected about users; screens are revoked by the school's admin |
| Target audience | Not a consumer app: school screens, set up by school staff. Not designed for children (children only see the screen, never use it) |

**Distribution.** A kiosk app with `SYSTEM_ALERT_WINDOW` and start on boot is better distributed as a **private app through managed Google Play** (the school's or our device management) or as a signed APK installed by hand (KIOSK_SETUP.md), not as a public listing: Play reviews these permissions for public apps. The owner decides (tracker D-015, O-13); either way it must be signed with the same upload key forever, because screens accept updates only from the same key.
