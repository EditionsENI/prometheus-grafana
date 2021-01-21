export DASHBOARD_URL=http://127.0.0.1:13000
export GRAFANA_KEY=eyJrIjoibExOMUVDdU54R2lxQWtVT1lCRmh5QTlaZVVWZ0RXNngiLCJuIjoiYXV0b21hdGUiLCJpZCI6MX0=
export GRAFANA_URL=http://127.0.0.1:13000

export DB_API=https://grafana.com/api/dashboards
export DB_ID=893
export DB_URL=${DB_API}/${DB_ID}/revisions/latest/download
export DS_PROMETHEUS="prometheus"

curl -s $DB_URL | \
   sed 's/${DS_PROMETHEUS}/prometheus/g' > /tmp/db-${DB_ID}.json

jq '{dashboard: .}' /tmp/db-$DB_ID.json > /tmp/dbq-${DB_ID}.json

curl -s -H "Authorization: Bearer ${GRAFANA_KEY}" \
  -H "Content-Type: application/json" \
  ${GRAFANA_URL}/api/dashboards/db -d @/tmp/dbq-${DB_ID}.json
