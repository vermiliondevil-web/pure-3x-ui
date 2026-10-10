#!/bin/bash
DB="/etc/x-ui/x-ui.db"
CUTOFF=$(date -d "30 minutes ago" +%s)

# Очистка в inbound_client_ips (JSON-поле ips)
sqlite3 "$DB" <<SQL
UPDATE inbound_client_ips
SET ips = (
  SELECT json_group_array(json_object('ip', json_extract(value, '$.ip'), 'timestamp', json_extract(value, '$.timestamp')))
  FROM json_each(ips)
  WHERE json_extract(value, '$.timestamp') > $CUTOFF
);
DELETE FROM inbound_client_ips WHERE ips = '[]' OR ips IS NULL;
SQL

# Очистка node_client_ip (только если таблица существует)
if sqlite3 "$DB" "SELECT name FROM sqlite_master WHERE type='table' AND name='node_client_ip';" | grep -q node_client_ip; then
  sqlite3 "$DB" "DELETE FROM node_client_ip WHERE last_seen < datetime('now', '-30 minutes');"
fi
echo "[$(date)] Cleanup done."
