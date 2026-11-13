#!/bin/sh
# Start the co-op room (reachable only from inside this container) and the web server in front of it.
# If either stops, stop the container so the host restarts both.
/opt/godot --headless --main-pack /srv/index.pck -- --server --port=8766 ${ZS_ARGS} &
ROOM=$!
caddy run --config /etc/zs.Caddyfile --adapter caddyfile &
WEB=$!
while kill -0 "$ROOM" 2>/dev/null && kill -0 "$WEB" 2>/dev/null; do sleep 2; done
exit 1
