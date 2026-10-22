#!/usr/bin/env sh


CONFIG_FILE="$HOME/config/config.xml"
if [ ! -f "$CONFIG_FILE" ]; then
	# Generate default config files
	# But first create the necessary directory with the appropriate permissions
	mkdir -p "$HOME/config"
	chown "$PUID:$PGID" "$HOME/config"
	su-exec "$PUID:$PGID" env HOME="$HOME" syncthing generate --skip-port-probing
fi


sed -i -e 's/<localAnnouncePort>[[:digit:]]\+<\/localAnnouncePort>/<localAnnouncePort>'"$LOCAL_ANNOUNCE_PORT"'<\/localAnnouncePort>/' "$CONFIG_FILE"
sed -i -e 's/<localAnnounceMCAddr>\(\[[^]]\+\]\):[[:digit:]]\+<\/localAnnounceMCAddr>/<localAnnounceMCAddr>\1:'"$LOCAL_ANNOUNCE_PORT"'<\/localAnnounceMCAddr>/' "$CONFIG_FILE"

# STGUIADDRESS is set in the Dockerfile, and (unintuitively and undocumentedly) overrides the configured web UI address and port
unset STGUIADDRESS
sed -i -e '/<gui[^>]*>/,/<\/gui>/ s/<address>\(\[[^]]\+\]\|[^:]*\)\(:[[:digit:]]\+\)\?<\/address>/<address>\1:'"$WEBUI_PORT"'<\/address>/' "$CONFIG_FILE"
# Valid web UI addresses are documented here: https://docs.syncthing.net/v1.18.6/users/config.html#gui-element

if grep '<listenAddress>default</listenAddress>' "$CONFIG_FILE"; then
	# Default listen addresses are documented here: https://docs.syncthing.net/v1.18.6/users/config.html#listen-addresses
	sed -i -e 's/^\([[:space:]]*\)<listenAddress>default<\/listenAddress>[[:space:]]*$/\1<listenAddress>tcp:\/\/0.0.0.0:'"$LISTEN_PORT"'<\/listenAddress>\n\1<listenAddress>quic:\/\/0.0.0.0:'"$LISTEN_PORT"'<\/listenAddress>\n\1<listenAddress>dynamic\+https:\/\/relays.syncthing.net\/endpoint<\/listenAddress>/' "$CONFIG_FILE"
else
	# Valid listen addresses documented at the same page as above
	sed -i -e 's/<listenAddress>\(\(tcp[46]\?\|quic\):\/\/\(\[[^]]\+\]\|[^:]*\)\):[[:digit:]]\+<\/listenAddress>/<listenAddress>\1:'"$LISTEN_PORT"'<\/listenAddress>/' "$CONFIG_FILE"
fi


# Original entrypoint
exec env HOME="$HOME" /bin/entrypoint.sh /bin/syncthing
