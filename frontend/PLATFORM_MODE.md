# Running the display on the Shiksha Tantra platform

The display app has two modes:

- **Platform mode** (for pilot schools): set `platformBaseUrl` in `assets/config.json` to the platform API, for example `https://api.example.com/v1`. The screen pairs itself and reads only its own feed.
- **Original mode** (the existing DigiBoard backend and sales demo): leave `platformBaseUrl` empty.

Installing screens at a school (hardware, kiosk settings, checks): see [KIOSK_SETUP.md](KIOSK_SETUP.md).

## Pairing a screen

1. Start the app. It shows an eight-character code, such as `K7QM-4PXA`, which changes every 10 minutes.
2. In the Shiksha Tantra admin, open **Screens → Add screen**, enter the code, give the screen a name, and choose its room (or no room, for a lobby screen showing the whole school).
3. The screen collects its own credential within a few seconds and shows the room's timetable.

No password or shared key is typed on the screen. Each screen's credential works only for that school and that screen's feed.

## What the screen shows

| Situation | Screen |
|---|---|
| Connected | The live timetable; refreshed every minute; a heartbeat tells the admin it is online |
| Network down, timetable saved today | Today's saved timetable, with a banner saying it is offline and when it was saved |
| Network down, nothing saved for today | "Timetable unavailable"; never another day's timetable |
| Removed by the school | Credential and saved data are wiped; the pairing code returns with a notice |

A server error or timeout counts as offline; only an explicit "not authorised" reply counts as removed.

## Alerts and notices

- The screen asks the platform for alerts every 10 seconds, so an online screen shows a drill within about 15 seconds. Drills are labelled `DRILL:`.
- Each answer is trusted for 45 seconds, timed on the screen's own clock. If no fresh answer arrives in that time, the screen keeps the last confirmed alert and adds "Alert status unavailable". It never treats silence as an all-clear.
- An alert goes only when the platform confirms the all-clear; the platform records that the screen received it.
- Notices for the screen's room (or all screens) appear in a bar at the bottom during their time window.

## Tests

- `test/platform/display_controller_test.dart`, `test/platform/alerts_test.dart` and `test/widget_test.dart`: pairing, offline, a new day, server errors, revocation, drills, alert status timing, notices, banners. No network.
- `test/platform/live_platform_test.dart`: the same flow against a running platform (skipped unless `PLATFORM_URL` and `PLATFORM_TOKEN` are set); with staff sign-in details it also runs a drill end to end.
