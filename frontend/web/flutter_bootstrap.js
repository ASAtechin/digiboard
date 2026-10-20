{{flutter_js}}
{{flutter_build_config}}

// No Flutter service worker: index.html registers sw.js, which caches the app
// shell only (never the platform's data).
_flutter.loader.load();
