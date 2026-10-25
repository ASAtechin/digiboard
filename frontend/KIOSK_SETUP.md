# Setting up a DigiBoard screen (kiosk guide)

For the person installing screens at a school: school IT, the vendor's installer, or a trained office staff member. Allow 20 minutes per screen. Read `PLATFORM_MODE.md` for how the screen behaves once running.

## 1. What to buy (decision D-007)

| Part | Requirement | Why |
|---|---|---|
| Player | An Android signage box or Android/Google TV device, **Android 11 or later**, 2 GB RAM or more, Ethernet port, from a maker that ships security updates. Not Fire OS | Runs the DigiBoard app; Fire OS lacks the device-management features used here |
| Display | Any TV or monitor with HDMI; HDMI-CEC and an on/off schedule help | The box keeps the screen awake; the TV's schedule turns it off at night |
| Network | **Wired Ethernet** where possible; otherwise strong Wi-Fi on a staff or devices network, not guest Wi-Fi | Drills arrive within about 15 seconds only while online |
| Power | A socket that stays on, ideally on the school's backup supply; the box set to power on when power returns | Screens come back by themselves after a power cut |
| Mounting | Out of reach, cable locked, USB ports covered | Stops casual tampering |

Buy one box first and run through this guide and the checks in section 5 before buying for the whole school.

## 2. Install the app

Use one of these, in order of preference:

1. **Device management (recommended for more than five screens).** Enrol the boxes in an Android Enterprise device-management tool as *dedicated devices* (kiosk), add the DigiBoard APK as a managed app, and set it as the single kiosk app. The app pins itself (lock task) when the tool allows it, so the remote cannot leave it. Updates are pushed from the tool.
2. **Directly on the box.** Copy the signed `app-release.apk` provided by Shiksha Tantra to a USB stick, allow installation from that file manager once, install, then turn "install unknown apps" off again.

Only install an APK provided by Shiksha Tantra. Its signature must match: Android refuses an update signed by anyone else.

**Until the Play Store release,** APKs are signed with the Android debug key (version 2.1.0 onwards points at the hosted platform, https://shikshatantra-api.vercel.app). When the release key is created (O-13), screens need the release-signed APK installed once over the top, after uninstalling the debug one, and pairing again.

## 3. Make it a kiosk

On the box, after installing:

1. **Home screen.** Settings → Apps → Default apps → Home app → **DigiBoard**. The box now opens DigiBoard every time it starts and when Home is pressed. (Some Google TV devices do not allow another home app; use device management there.)
2. **Start after power cuts**, if DigiBoard cannot be the home app: Settings → Apps → DigiBoard → **Display over other apps → Allow**. The app then opens itself after start-up.
3. **Power on with mains:** in the box's settings (often "Power" or "Boot"), turn on *auto power on* or *power on after power loss*.
4. **Never sleep:** the app keeps the screen on while it runs. Also set the box's screen saver/daydream to *Never* and sleep to *Never*.
5. **Time:** Settings → Date & time → *automatic* and the time zone **India Standard Time (Asia/Kolkata)**. The screen uses the box's clock for its on and off hours and, when offline, to decide whether its saved timetable is today's, so a wrong date or time zone can hide it. The admin flags a screen whose clock is more than two minutes out.
6. **Updates:** allow automatic system updates out of school hours.
7. **Lock it down:** turn off developer options and USB debugging; set a settings PIN if the box offers one.

The app runs full screen without status or navigation bars.

## 4. Pair it with the school

1. The platform address is built into the APK (`--dart-define=PLATFORM_BASE_URL=...`); you do not type it on the box. Browser-based screens use the web display instead (section 4a).
2. Open DigiBoard. It shows an eight-character code, such as `K7QM-4PXA` (it changes every 10 minutes).
3. A school admin or office staff member signs in to the admin, opens **Screens → Add a screen**, types the code, names the screen after where it hangs ("Class 7B front wall"), chooses the room it hangs in, and what it shows:
   - **Classroom**: that room's lessons, now and next (needs a room).
   - **Lobby**: the whole school's day, public notices and events. For entrances and corridors, where visitors stand: internal notices never show there.
   - **Staff room**: today's substitutions with teachers' names, staff notices and events. Only where students and visitors do not look.
4. Within a few seconds the screen shows its content, with **Updated hh:mm** in the top right corner. In the admin, the screen shows as **Online** and **Live**, with a line saying what it shows.
5. **Hours.** By default a screen is on from an hour before the first period to an hour after the last, and shows a clock outside those hours (off all day on days without lessons). To change it: Admin → Screens → the screen → **On and off hours**: set times on chosen days, or always on; and a clock or a dimmed screen when off. Drills always show, at any hour. Also set the TV's own on/off schedule a little wider than these hours, or leave the TV on.

## 4a. Browser screens (the web display)

Any screen with a current Chrome or Edge (a PC, a Chromebook, a smart TV's browser) can be a DigiBoard screen without installing an APK:

1. Open https://shikshatantra-display.vercel.app and pair it as in section 4.
2. **Install it as an app:** the install icon in the address bar, or the menu → *Install DigiBoard*. It then opens full screen, from its own icon, and **starts even when the network is down**: the browser keeps the app itself, never school data. The app keeps today's timetable, notices and events with the same expiry rules as the Android app.
3. For a kiosk: on a managed Chromebook, add the address as a kiosk app; on a PC, start Chrome with `--kiosk https://shikshatantra-display.vercel.app` at sign-in, and set the PC to sign in by itself and never sleep.
4. Keep the browser up to date. Clearing the browser's site data un-pairs the screen; pair it again.

No password, key or school code is ever typed on the screen.

## 5. Check it works (every new screen)

| Check | How | Expected |
|---|---|---|
| Online | Admin → Screens | Status *Online*, last seen seconds ago |
| Right room | Look at the screen | The current and next period for that room |
| Notices | Admin → Notices: a short notice for that room, starting now | Appears on the screen within a minute |
| Drill | With the principal's agreement and staff told in advance: Admin → Drills → Start a drill, *Chosen rooms*, that room only | Red drill message within about 15 seconds; the drill page shows the screen *Confirmed*. Then **Send all-clear**: the screen returns to the timetable and confirms it |
| Last updated | Look at the top right corner | **Updated hh:mm**, a minute ago or less |
| Network loss | Unplug the network cable for three minutes | Within a minute the timetable stays with a banner saying it is offline, and the corner turns amber: **Not updated since hh:mm**; after 45 seconds any alert area says "Alert status unavailable". The admin shows the screen *Offline*. Plug it back: within a minute the banner goes, the corner says *Updated*, and the admin shows *Live* |
| Hours | Admin → Screens → the screen | *Hours today* matches the school day (or the times set). Outside them the screen shows a clock |
| Power cut | Switch the socket off and on | The box starts and DigiBoard opens by itself |

Withdraw the test notice afterwards. Record the screen's name, room and the date checked.

## 6. Day to day

| You see | Meaning | Do |
|---|---|---|
| A pairing code instead of the timetable | The screen was revoked or its data reset | Pair it again (section 4) |
| "Offline" banner with a saved timetable | No network | Check the cable or Wi-Fi. It keeps showing today's timetable meanwhile, but no new drills or notices |
| Amber **Not updated since hh:mm** in the corner | The screen could not get new content at its last refresh, or none arrived for over two refreshes | As for the offline banner. Notices leave the screen after 30 minutes without contact, events after four hours, substitutions after 30 minutes, because any of them may have been withdrawn |
| A clock (or a nearly black screen) instead of the timetable | Outside the screen's on hours | Nothing, or change the hours in the admin. Drills still show |
| *Not up to date* or *Older than its latest content* in the admin | The screen is online but shows older content | Wait a minute; if it stays, restart the app or the box |
| *Clock wrong* in the admin | The box's clock is more than two minutes out | Fix the date, time and time zone on the box (section 3) |
| "Timetable unavailable" | No network and nothing saved for today | Restore the network |
| "Alert status unavailable" | The screen could not confirm alert status for 45 seconds | Check the network. If it persists while the screen shows as online, restart the box and tell Shiksha Tantra support |
| Screen *Offline* in the admin | No contact for over 2½ minutes | Check power, network, and that DigiBoard is open |
| A drill still showing after a drill ended | The all-clear was not sent | Admin → Drills → the drill → **Send all-clear** |

## 7. When a box is lost, stolen, replaced or moved

- **Lost, stolen or replaced:** Admin → Screens → the screen → **Revoke**. It stops receiving school data at its next contact and wipes what it saved. A replacement is paired as a new screen.
- **Moved to another room, or used differently:** Admin → Screens → the screen → change the room and what it shows. No need to pair again.
- **Before disposal:** revoke it, then factory-reset the box.

Screens never show staff phone numbers or emails, and never anything about an individual student, so a lost box exposes only the school's timetable.

## Before the first school installation (vendor)

- **Application ID** (decision D-015): the app is still `com.example.digiboard_app`. Choose the permanent ID (for example `shop.shikshatantra.digiboard`) before the first install; it cannot change afterwards without reinstalling every screen.
- **Release signing key** (owner action O-13): release builds are currently signed with the debug key. Create the release key, keep it in the secret store with an offline copy, and sign every release with it. Losing it means every screen must be reinstalled. `android/app/build.gradle.kts` reads it from the environment (`ST_UPLOAD_KEYSTORE` a path, `ST_UPLOAD_STORE_PASSWORD`, `ST_UPLOAD_KEY_ALIAS`, `ST_UPLOAD_KEY_PASSWORD`) or from `android/key.properties` (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`; git-ignored); without either, release builds stay debug-signed. CI's `release-build` job builds the signed bundle and APK once the repository secrets `ANDROID_UPLOAD_KEYSTORE_BASE64` (`base64 -w0 upload.jks`), `ANDROID_UPLOAD_STORE_PASSWORD`, `ANDROID_UPLOAD_KEY_ALIAS` and `ANDROID_UPLOAD_KEY_PASSWORD` exist (variables `PLATFORM_BASE_URL`, `APPLICATION_ID`), and skips with a notice until then. This repository is public: the key never goes in it, only in those secrets.
- **Application ID** (D-015): still the placeholder `com.example.digiboard_app`, which the Play Store refuses. Build with the chosen one through `ST_APPLICATION_ID` or `-PappId=…` (CI: the `APPLICATION_ID` variable) **together with** the release key, since a screen updates only to the same ID and key. Store drafts (privacy policy, data safety answers, listing, distribution advice) are in `store/`.
- Build: `flutter build apk --release` (or in the `ghcr.io/cirruslabs/flutter:3.35.5` image), with `--dart-define=PLATFORM_BASE_URL=<platform>/v1`.
- Web display: `flutter build web --release --no-web-resources-cdn --dart-define=PLATFORM_BASE_URL=<platform>/v1`. Without `--no-web-resources-cdn` the engine comes from Google's CDN and the installed app cannot start offline. The platform must list the display's address in `CORS_ORIGINS`.
