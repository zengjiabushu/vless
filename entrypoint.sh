#!/bin/sh
# Env: UUID (required), WSPATH (default /ws), PORT (default 8080)
set -e
: "${UUID:?UUID env var required}"
WSPATH="${WSPATH:-/ws}"
P="${PORT:-8080}"
cat > /tmp/xray.json <<JSON
{"log":{"loglevel":"warning"},
 "inbounds":[{"listen":"127.0.0.1","port":10000,"protocol":"vless",
   "settings":{"clients":[{"id":"${UUID}"}],"decryption":"none"},
   "streamSettings":{"network":"ws","wsSettings":{"path":"${WSPATH}"}}}],
 "outbounds":[{"protocol":"freedom"}]}
JSON
cat > /etc/nginx/conf.d/default.conf <<NG
server {
  listen ${P} default_server;
  location = / { default_type text/plain; return 200 "ok"; }
  location ${WSPATH} {
    proxy_pass http://127.0.0.1:10000;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host \$host;
    proxy_read_timeout 3600s;
  }
  location / { return 404; }
}
NG
/usr/local/bin/xray run -c /tmp/xray.json &
exec nginx -g 'daemon off;'
