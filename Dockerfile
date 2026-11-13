# Zombie Surveillance beta: the web game and its co-op room behind one address.
# A small web server hands out the game files and passes co-op connections to the room,
# which is the same game file run with no screen. Both run as an unprivileged user.
FROM caddy:2 AS caddy

FROM debian:bookworm-slim
ARG GODOT_VERSION=4.7.2-stable
ARG GODOT_SHA256=cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl unzip libfontconfig1 \
    && curl -fsSL -o /tmp/godot.zip "https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip" \
    && echo "${GODOT_SHA256}  /tmp/godot.zip" | sha256sum -c - \
    && unzip -q /tmp/godot.zip -d /opt && mv /opt/Godot_v${GODOT_VERSION}_linux.x86_64 /opt/godot && rm /tmp/godot.zip \
    && apt-get purge -y curl unzip && apt-get autoremove -y && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 game
COPY --from=caddy /usr/bin/caddy /usr/bin/caddy
COPY --chmod=644 index.html index.js index.pck index.wasm index.png index.icon.png index.apple-touch-icon.png \
     index.audio.worklet.js index.audio.position.worklet.js robots.txt /srv/
# Compress the big files once here, so the small server does not have to on every download.
RUN gzip -k9 /srv/index.wasm /srv/index.js /srv/index.pck
COPY --chmod=644 deploy/Caddyfile /etc/zs.Caddyfile
COPY --chmod=755 deploy/start.sh /start.sh
USER game
ENV PORT=10000
EXPOSE 10000
# ZS_INVITES (the guest list) comes from the host's secret settings, never from this repository.
CMD ["/start.sh"]
