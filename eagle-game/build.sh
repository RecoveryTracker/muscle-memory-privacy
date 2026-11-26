#!/usr/bin/env bash
# Wraps the game page (game.html, the same file published as the Claude artifact) into index.html
# as an installable web app: local copy of three.js, manifest, icons and the offline service worker.
set -euo pipefail
cd "$(dirname "$0")"
{
  cat <<'HEAD'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>Talon &amp; Thermal</title>
<meta name="description" content="Fly as a bald eagle over a fjord near Juneau: drop off a cliff, fall through clouds, hunt salmon.">
<meta name="theme-color" content="#0d1f29">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" href="icon-192.png">
<link rel="apple-touch-icon" href="icon-180.png">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="apple-mobile-web-app-title" content="Talon">
<style>html,body{height:100%}body{margin:0;background:#0d1f29;overscroll-behavior:none}[hidden]{display:none!important}:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px);box-sizing:border-box;height:100%}</style>
</head>
<body>
HEAD
  sed 's#https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js#three.min.js#' game.html
  cat <<'TAIL'
<script>
if ('serviceWorker' in navigator && location.protocol !== 'file:') {
  addEventListener('load', () => { navigator.serviceWorker.register('sw.js').catch(() => {}); });
}
</script>
</body>
</html>
TAIL
} > index.html
v=$(cat game.html three.min.js manifest.webmanifest | sha1sum | cut -c1-10)   # a new cache name each build, so phones pick up the update
sed -i "s/^const VERSION = .*/const VERSION = 'talon-$v';/" sw.js
echo "built index.html (offline cache talon-$v)"
