// DigiBoard web display: an installable app that starts without a network.
//
// Caches the app shell only (this site's own files: the page, the compiled
// app, its engine, fonts, icons). It never touches the platform's API: those
// requests go to another origin, are never intercepted, and are never
// stored here. The app keeps today's timetable itself, with the expiry rules
// the platform sends (see PLATFORM_MODE.md).
//
// Network first: a screen that is online always gets the latest release; the
// cached copy is used only when the network is down.
const CACHE = 'digiboard-shell-2.2.0';
// The first visit loads these before the worker is in control, so they are fetched again here.
const SHELL = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'canvaskit/chromium/canvaskit.js',
  'canvaskit/chromium/canvaskit.wasm',
  'assets/FontManifest.json',
  'assets/AssetManifest.bin.json',
  'assets/fonts/MaterialIcons-Regular.otf',
  'assets/packages/cupertino_icons/assets/CupertinoIcons.ttf',
  'assets/assets/config.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches
      .open(CACHE)
      .then((cache) => Promise.all(SHELL.map((url) => cache.add(url).catch(() => undefined))))
      .then(() => self.skipWaiting()),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith('digiboard-shell-') && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim()),
  );
});

/** Only this site's own files; never anything that looks like the platform's API or carries a credential. */
function isShell(request) {
  if (request.method !== 'GET') return false;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return false;
  if (url.pathname.includes('/v1/') || url.pathname.includes('/api/')) return false;
  if (request.headers.has('authorization')) return false;
  return true;
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (!isShell(request)) return;
  event.respondWith(
    fetch(request)
      .then((response) => {
        if (response.ok && response.type === 'basic') {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(request, copy));
        }
        return response;
      })
      .catch(async () => {
        const cached = await caches.match(request);
        if (cached) return cached;
        // A page address the cache has not seen: the app itself handles it.
        if (request.mode === 'navigate') return (await caches.match('index.html')) ?? Response.error();
        return Response.error();
      }),
  );
});
