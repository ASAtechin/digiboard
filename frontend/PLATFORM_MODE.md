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

Each screen has a mode, set in the admin: **classroom** (its room's lessons, now and next), **lobby** (the whole school's day; public notices only) or **staff room** (today's substitutions still to come, with teachers' names, staff notices and events). Classroom and lobby screens show up to three cards along the bottom: events and announcements, and cards from other modules (bus delays, an exam timetable), drawn from labelled lines so a new kind of card needs no app update.

| Situation | Screen |
|---|---|
| Connected | The live content, refreshed every minute in the school day (every 5 minutes outside it); **Updated hh:mm** in the top right corner; a heartbeat tells the admin what it shows |
| No new content for longer than the last one was good for (two refreshes and 30 s), or the last refresh failed | The corner turns amber: **Not updated since hh:mm** |
| Network down, timetable saved today | Today's saved timetable, with a banner saying it is offline and when it was saved |
| Network down, nothing saved for today | "Timetable unavailable"; never another day's timetable |
| Outside the screen's on hours | A clock and the school's name, or a dimmed screen. Drills still show |
| Removed by the school | Credential and saved data are wiped; the pairing code returns with a notice |

A server error or timeout counts as offline; only an explicit "not authorised" reply counts as removed.

### Expiry

Every feed says when it was made and how long each kind of content may stay without a newer one. The screen measures these on its own clock from when the feed arrived, so a wrong clock does not keep content on longer:

| Content | Leaves the screen without a newer feed |
|---|---|
| Today's timetable | At midnight (never shown on another day) |
| Notices | After 30 minutes, or at the notice's own end |
| Events and announcements | After 4 hours, or when the event ends |
| Staff-room substitutions | After 30 minutes |
| Other cards | As each card type says |

### On and off hours

The feed carries the screen's hours for the day (by default an hour before the first period to an hour after the last; or set times; or always). The screen switches on its own clock, so it goes dark on time even offline. Drills always show, at any hour.

### Heartbeat

After every refresh the screen reports its app version, mode, what it shows (`live`, `stale`, `offline_cached`, `unavailable`, `off_hours`, `not_active`), the content fingerprint of the feed it shows, a one-line summary, when the app started, and its clock. The admin shows this as the screen's health. A platform older than 2.2 refuses the extra fields; the screen then sends the short form it understands.

## The web display (installable)

The web build is an installable app (manifest, icons, a service worker in `web/sw.js`). The service worker caches this site's own files only, network first, so the app starts without a network and still gets each new release when online. It never intercepts or stores the platform's API: the app keeps today's content itself, with the expiry rules above. Build with `--no-web-resources-cdn` so the engine is served by the site and cached too. Installing it: `KIOSK_SETUP.md`, section 4a.

## Alerts and notices

- The screen asks the platform for alerts every 10 seconds, so an online screen shows a drill within about 15 seconds. Drills are labelled `DRILL:`.
- Each answer is trusted for 45 seconds, timed on the screen's own clock. If no fresh answer arrives in that time, the screen keeps the last confirmed alert and adds "Alert status unavailable". It never treats silence as an all-clear.
- An alert goes only when the platform confirms the all-clear; the platform records that the screen received it.
- Notices for the screen's room (or all screens) appear in a bar at the bottom during their time window.

## Tests

- `test/platform/display_controller_test.dart`, `test/platform/alerts_test.dart`, `test/platform/freshness_test.dart` and `test/widget_test.dart`: pairing, offline, a new day, server errors, revocation, drills, alert status timing, notices, banners, last updated and the stale state, expiry per kind of content, on and off hours, modes, the staff room, cards, the heartbeat. No network.
- `test/platform/live_platform_test.dart`: the same flow against a running platform (skipped unless `PLATFORM_URL` and `PLATFORM_TOKEN` are set); with staff sign-in details it also runs a drill end to end.
