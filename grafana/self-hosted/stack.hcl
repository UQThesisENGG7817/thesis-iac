locals {
  #-------------------------------------------------
  # General vars
  #-------------------------------------------------
  ## TF State
  account_id = ""
  ## Grafana
  grafana_url = "https://grafana.pinnamon.com"
  backend     = "local"
  context     = "potter_gha_2"
  environment = "uq_thesis_env"
  #-------------------------------------------------
  # Stack vars
  #-------------------------------------------------
  # TODO: Remember to change
  stack = "grafana"
  stack_tags = {
    Description = "Potter's UQ Thesis stack"
    stack       = local.stack
  }

  #-------------------------------------------------
  # Grafana Dashboard
  #-------------------------------------------------
  dashboard = {
    kubernetes = {
      enabled = true
    }
    kubernetes_mixin = {
      enabled = true
    }
    trivy = {
      enabled = true
    }
    argo = {
      enabled = true
    }
    node_exporter = {
      enabled = true
    }
  }
}