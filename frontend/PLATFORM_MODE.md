# Running the display on the Shiksha Tantra platform

The display app has two modes:

- **Platform mode** (for pilot schools): set `platformBaseUrl` in `assets/config.json` to the platform API, for example `https://api.example.com/v1`. The screen pairs itself and reads only its own feed.
- **Original mode** (the existing DigiBoard backend and sales demo): leave `platformBaseUrl` empty.

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

Alerts move to the platform in the next release; until then a platform-mode screen shows "Alert status unavailable" rather than implying there is no alert.

## Tests

- `test/platform/display_controller_test.dart` and `test/widget_test.dart`: pairing, offline, a new day, server errors, revocation, banners. No network.
- `test/platform/live_platform_test.dart`: the same flow against a running platform (skipped unless `PLATFORM_URL` and `PLATFORM_TOKEN` are set).
