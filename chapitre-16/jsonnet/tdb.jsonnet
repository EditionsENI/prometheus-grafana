local g = import 'github.com/grafana/grafonnet/gen/grafonnet-latest/main.libsonnet';
local d = g.dashboard;

g.dashboard.new('TDB')
+ g.dashboard.withVariables([
    g.dashboard.variable.datasource.new("Prometheus", "prometheus"),
    g.dashboard.variable.query.new("instance", 'label_values(prometheus_http_requests_total, instance)')
    + g.dashboard.variable.query.withDatasource('Prometheus', '$Prometheus')
    + g.dashboard.variable.query.refresh.onLoad()
    + g.dashboard.variable.query.refresh.onTime()
    + g.dashboard.variable.query.selectionOptions.withIncludeAll("All")
    + g.dashboard.variable.query.selectionOptions.withMulti(true)
    + g.dashboard.variable.query.withSort(1)  // tri alphabétique
  ])
+ g.dashboard.withTimezone('browser')
+ g.dashboard.withUid('tdb-eni')
+ g.dashboard.withTags(["my-tdb"])
+ g.dashboard.withRefresh("1m")
+ g.dashboard.time.withFrom("now-1h")
+ g.dashboard.withPanels([
  g.panel.stat.new('Status')
  + g.panel.stat.queryOptions.withTargets([
      g.query.prometheus.new(
        '$Prometheus',
        "process_start_time_seconds{instance=~'$instance'}*1000"
      ),
    ])
    + g.panel.stat.standardOptions.withUnit('dateTimeAsIso')
    + g.panel.stat.options.withGraphMode('none')
    + g.panel.stat.options.withColorMode('none')
    + g.panel.timeSeries.gridPos.withW(12)
  ,
  g.panel.timeSeries.new('Connections activity')
  + g.panel.timeSeries.queryOptions.withTargets([
      g.query.prometheus.new(
        '$Prometheus',
        'sum(rate(prometheus_http_requests_total{instance=~"$instance"}[5m])) by (code, handler)',
      )
      + g.query.prometheus.withLegendFormat("{{ code }} {{ handler }}")
    ])
    + g.panel.timeSeries.gridPos.withW(24)
    + g.panel.timeSeries.gridPos.withH(8),
  ])
