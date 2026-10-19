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
5. **Time:** Settings → Date & time → *automatic* and the time zone **India Standard Time (Asia/Kolkata)**. When offline, the screen uses the box's date to decide whether its saved timetable is today's, so a wrong date or time zone can hide it.
6. **Updates:** allow automatic system updates out of school hours.
7. **Lock it down:** turn off developer options and USB debugging; set a settings PIN if the box offers one.

The app runs full screen without status or navigation bars.

## 4. Pair it with the school

1. The platform address is built into the APK (`--dart-define=PLATFORM_BASE_URL=...`); you do not type it on the box. Browser-based screens can open https://shikshatantra-display.vercel.app instead of installing anything.
2. Open DigiBoard. It shows an eight-character code, such as `K7QM-4PXA` (it changes every 10 minutes).
3. A school admin or office staff member signs in to the admin, opens **Screens → Add a screen**, types the code, names the screen after where it hangs ("Class 7B front wall"), and chooses its room. Choose *no room* for lobby or staff-room screens, which show the whole school's day.
4. Within a few seconds the screen shows its room's timetable. In the admin, the screen shows as **Online**.

No password, key or school code is ever typed on the screen.

## 5. Check it works (every new screen)

| Check | How | Expected |
|---|---|---|
| Online | Admin → Screens | Status *Online*, last seen seconds ago |
| Right room | Look at the screen | The current and next period for that room |
| Notices | Admin → Notices: a short notice for that room, starting now | Appears on the screen within a minute |
| Drill | With the principal's agreement and staff told in advance: Admin → Drills → Start a drill, *Chosen rooms*, that room only | Red drill message within about 15 seconds; the drill page shows the screen *Confirmed*. Then **Send all-clear**: the screen returns to the timetable and confirms it |
| Network loss | Unplug the network cable for two minutes | The timetable stays, with a banner saying it is offline; after 45 seconds any alert area says "Alert status unavailable". Plug it back: the banner goes |
| Power cut | Switch the socket off and on | The box starts and DigiBoard opens by itself |

Withdraw the test notice afterwards. Record the screen's name, room and the date checked.

## 6. Day to day

| You see | Meaning | Do |
|---|---|---|
| A pairing code instead of the timetable | The screen was revoked or its data reset | Pair it again (section 4) |
| "Offline" banner with a saved timetable | No network | Check the cable or Wi-Fi. It keeps showing today's timetable meanwhile, but no new drills or notices |
| "Timetable unavailable" | No network and nothing saved for today | Restore the network |
| "Alert status unavailable" | The screen could not confirm alert status for 45 seconds | Check the network. If it persists while the screen shows as online, restart the box and tell Shiksha Tantra support |
| Screen *Offline* in the admin | No contact for over 2½ minutes | Check power, network, and that DigiBoard is open |
| A drill still showing after a drill ended | The all-clear was not sent | Admin → Drills → the drill → **Send all-clear** |

## 7. When a box is lost, stolen, replaced or moved

- **Lost, stolen or replaced:** Admin → Screens → the screen → **Revoke**. It stops receiving school data at its next contact and wipes what it saved. A replacement is paired as a new screen.
- **Moved to another room:** Admin → Screens → the screen → change the room. No need to pair again.
- **Before disposal:** revoke it, then factory-reset the box.

Screens never show staff phone numbers or emails, and never anything about an individual student, so a lost box exposes only the school's timetable.

## Before the first school installation (vendor)

- **Application ID** (decision D-015): the app is still `com.example.digiboard_app`. Choose the permanent ID (for example `shop.shikshatantra.digiboard`) before the first install; it cannot change afterwards without reinstalling every screen.
- **Release signing key** (owner action O-13): release builds are currently signed with the debug key. Create the release key, keep it in the secret store with an offline copy, and sign every release with it. Losing it means every screen must be reinstalled.
- Build: `flutter build apk --release` (or in the `ghcr.io/cirruslabs/flutter:3.35.5` image), with `assets/config.json` pointing at the school's platform address.
