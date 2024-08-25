include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

#-------------------------------------------------------------------------------
# Locals block used for this module only
#-------------------------------------------------------------------------------
locals {
  enabled = can(include.root.locals.env_vars.locals.dashboard.argo) ? try(include.root.locals.env_vars.locals.dashboard.argo.enabled, true) : false
}

#-------------------------------------------------------------------------------
# Module definition
#-------------------------------------------------------------------------------
terraform {
  source = local.enabled ? "git@github.com:UQThesisENGG7817/thesis-terraform-modules.git//grafana/terraform-grafana-dashboard?ref=main" : null
}

inputs = {
  create_folder    = true
  create_dashboard = true

  folder = {
    title                        = "Argo"
    uid                          = "argo-folder"
    prevent_destroy_if_not_empty = true
  }
}