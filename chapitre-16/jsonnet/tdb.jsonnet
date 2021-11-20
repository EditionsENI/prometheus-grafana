local grafana = import 'grafonnet/grafana.libsonnet';
local row = grafana.row;
local graphPanel = grafana.graphPanel;
local prometheus = grafana.prometheus;
local template = grafana.template;
local singlestat = grafana.singlestat;

grafana.dashboard.new(
  'TDB',
  tags=['my-tdb'],
  refresh="1m",
  time_from="now-1h"
).addTemplate(
  grafana.template.datasource(
    'datasource', 'prometheus', 'default'
  )
).addTemplate(
  template.new(
    "instance",
    '$datasource',
    'label_values(prometheus_http_requests_total, instance)',
    multi=true,
    includeAll=true,
    label="Prometheus instance",
    refresh='time',
  )
).addRow(
  row.new(
    title="Status",
    height='100px'
  ).addPanel(
    singlestat.new(
      'Start time',
      format='dateTimeAsIso',
      datasource='$datasource',
      span=6
    ).addTarget(
      prometheus.target(
        "process_start_time_seconds{instance=~'$instance'}*1000"
      )
    ),
  )
).addRow(
  row.new(
    title="TDB",
    height="300px"
  ).addPanel(
    graphPanel.new(
      'Connections count',
      span=12,
      datasource='$datasource',
    ).addTarget(
      prometheus.target(
        "sum(rate(prometheus_http_requests_total{instance=~'$instance'}[5m])) by (code, handler)",
        legendFormat='{{ code }} {{ handler }}',
      )
    ),
  )
)
