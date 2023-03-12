resource "datadog_monitor" "service-check" {
  name    = "service check"
  type    = "service check"
  message = "Service is not responding"
  query   = "\"datadog.agent.up\".over(\"*\").by(\"*\").last(2).count_by_status()"
  monitor_thresholds {
    critical = 1
    warning  = 1
    ok       = 1
  }
  notify_audit      = false
  notify_no_data    = true
  no_data_timeframe = 2
  renotify_interval = 0
  timeout_h         = 0
  include_tags      = false
}
