resource "dynatrace_management_zone_v2" "mzEnvAppIDAppName" {
  name        = join("_", [upper(var.app_env), "GE", var.app_id, var.app_name])
  description = "Dies ist eine mit terraform erzeugte Management Zone."

  rules {

    rule {
      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type = "WEB_APPLICATION"
        attribute_conditions {
          condition {
            case_sensitive = true
            key            = "WEB_APPLICATION_NAME"
            operator       = "EQUALS"
            string_value   = join("_", [upper(var.app_env), var.app_id, var.app_name])
          }
        }
      }
    }


    rule {
      type    = "ME"
      enabled = "true"
      attribute_rule {
        entity_type           = "HOST"
        host_to_pgpropagation = true
        attribute_conditions {
          condition {
            key      = "HOST_TAGS"
            operator = "EQUALS"
            tag      = join(":", ["[AWS]environment", var.app_env])
          }

          condition {
            key      = "HOST_TAGS"
            operator = "EQUALS"
            tag      = join(":", ["[AWS]appid", var.app_id]) //[AWS]appid: APP-4366
            //hostToPGPropagation = "true" // will er irgendwie nicht in diesem Block
          }
        }
      }
    }

    rule {
      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type = "CLOUD_APPLICATION_NAMESPACE"
        attribute_conditions {
          condition {
            case_sensitive = false
            key            = "KUBERNETES_CLUSTER_NAME"
            operator       = "EQUALS"
            string_value   = join("_", [var.app_env, var.app_id, var.app_name])
          }
        }
      }
    }


    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(CONTAINER_GROUP_INSTANCE),tag(\"component:${var.app_name}\")"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(CONTAINER_GROUP),tag(\"component:${var.app_name}\")"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(CLOUD_APPLICATION_NAMESPACE),toRelationship.isCgiOfNamespace(type(CONTAINER_GROUP_INSTANCE),tag(\"component:${var.app_name}\"))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(cloud_application),toRelationship.isCgiOfCa(type(CONTAINER_GROUP_INSTANCE),tag(\"component:${var.app_name}\"))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(SERVICE),databaseName.exists(),toRelationship.calls(type(SERVICE),tag(\"component:${var.app_name}\"))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(PROCESS_GROUP_INSTANCE),tag(\"component:${var.app_name}\")"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(KUBERNETES_CLUSTER),fromRelationships.isClusterOfCa(type(CLOUD_APPLICATION),toRelationships.isPgOfCa(type(PROCESS_GROUP),tag(\"component:${var.app_name}\")))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(KUBERNETES_NODE),toRelationships.runsOn(type(CLOUD_APPLICATION_INSTANCE),toRelationships.isPgOfCai(type(PROCESS_GROUP),tag(\"component:${var.app_name}\")))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(CLOUD_APPLICATION_INSTANCE),toRelationships.isPgOfCai(type(PROCESS_GROUP),tag(\"component:${var.app_name}\"))"

    }
    rule {

      type            = "SELECTOR"
      enabled         = true
      entity_selector = "type(KUBERNETES_SERVICE),fromRelationships.isKubernetesSvcOfCa(type(CLOUD_APPLICATION),toRelationships.isPgOfCa(type(PROCESS_GROUP),tag(\"component:${var.app_name}\")))"

    }

    rule {

      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type = "HTTP_MONITOR"
        attribute_conditions {
          condition {
            key      = "HTTP_MONITOR_TAGS"
            operator = "EQUALS"
            tag      = "component:${var.app_name}"
          }
        }
      }

    }

    rule {

      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type = "EXTERNAL_MONITOR"
        attribute_conditions {
          condition {
            key      = "EXTERNAL_MONITOR_TAGS"
            operator = "EQUALS"
            tag      = "component:${var.app_name}"
          }
        }

      }
    }

    rule {

      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type = "BROWSER_MONITOR"
        attribute_conditions {
          condition {
            key      = "BROWSER_MONITOR_TAGS"
            operator = "EQUALS"
            tag      = "component:${var.app_name}"
          }
        }

      }
    }

    rule {

      type    = "ME"
      enabled = true
      attribute_rule {
        entity_type               = "PROCESS_GROUP"
        pg_to_host_propagation    = true
        pg_to_service_propagation = true
        attribute_conditions {
          condition {
            key      = "PROCESS_GROUP_TAGS"
            operator = "EQUALS"
            tag      = "component:${var.app_name}"
          }
        }
      }

    }
  }




}


resource "dynatrace_alerting" "Default" {
  name            = join("_", [upper(var.app_env), "GE", var.app_id, var.app_name, "Alertingprofile"])
  management_zone = dynatrace_management_zone_v2.mzEnvAppIDAppName.id
  rules {
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "MONITORING_UNAVAILABLE"
    }

    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "AVAILABILITY"
    }
    rule {
      delay_in_minutes = 0
      include_mode     = "NONE"
      severity_level   = "ERRORS"
    }
  }
}

resource "dynatrace_browser_monitor" "synth" {
  name                   = join("_", [upper(var.app_env), "GE", var.app_id, var.app_name])
  frequency              = 15
  locations              = ["GEOLOCATION-195845BAEB760941"]
  manually_assigned_apps = ["APPLICATION-B89A1342ACE6B9D6"]
  enabled = true
  anomaly_detection {
    loading_time_thresholds {
      enabled = true
    }
    outage_handling {
      global_outage  = true
      retry_on_error = true
      global_outage_policy {
        consecutive_runs = 1
      }
    }
  }
  key_performance_metrics {
    load_action_kpm = "VISUALLY_COMPLETE"
    xhr_action_kpm  = "VISUALLY_COMPLETE"
  }
  script {
    type = "clickpath"
    configuration {
      bypass_csp = true
      user_agent = "Mozilla"
      bandwidth {
        network_type = "GPRS"
      }
      device {
        name        = "Apple iPhone 8"
        orientation = "landscape"
      }
      headers {
        header {
          name  = "kjh"
          value = "kjh"
        }
      }
      ignored_error_codes {
        status_codes = "400"
      }
      javascript_setttings {
        timeout_settings {
          action_limit  = 3
          total_timeout = 100
        }
        visually_complete_options {
          image_size_threshold = 0
          inactivity_timeout   = 0
          mutation_timeout     = 0
        }
      }
    }
    events {
      event {
        description = "Loading of \"https://www.hornbach.de/"
        navigate {
          url = "https://www.hornbach.de/"
          wait {
            wait_for = "page_complete"
          }
        }
      }
      event {
        description = "test"
        click {
          wait {
            wait_for = "page_complete"
          }
          target {
            locators {
              locator{
              type  = "css"
              value = "a:contains(\"Artikelvergleich\"):eq(0)"
              }
            }
          }
          button = 0
        }
      }
    }
  }
}