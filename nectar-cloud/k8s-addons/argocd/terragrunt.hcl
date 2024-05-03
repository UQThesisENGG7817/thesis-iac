include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

#-------------------------------------------------------------------------------
# Dependency settings
#-------------------------------------------------------------------------------

dependency "runner_node" {
  config_path = "../../_global/k8s-resources"
  mock_outputs_allowed_terraform_commands = [
    "init",
    "validate",
    "plan",
    "show"
  ]
  mock_outputs = {
    id = "randomoutput",
  }
}

#-------------------------------------------------------------------------------
# Locals block used for this module only
#-------------------------------------------------------------------------------
locals {
  enabled = can(include.root.locals.env_vars.locals.k8s_addons.argocd) ? try(include.root.locals.env_vars.locals.k8s_addons.argocd.enabled, true) : false
  secrets = yamldecode(sops_decrypt_file(include.root.locals.secret_path))
  domain_name = include.root.locals.env_vars.locals.k8s_addons.argocd.domain_name
}

#-------------------------------------------------------------------------------
# Module definition
#-------------------------------------------------------------------------------
terraform {
  source = local.enabled ? "git@github.com:UQThesisENGG7817/thesis-terraform-modules.git//nectar-cloud/k8s-addons/argo-cd?ref=main" : null
}
inputs = {
  cluster_endpoint       = local.secrets.cluster_endpoint
  cluster_ca_certificate = local.secrets.cluster_ca_certificate
  client_key             = local.secrets.client_key
  client_certificate     = local.secrets.client_certificate
  chart_version          = include.root.locals.env_vars.locals.k8s_addons.argocd.chart_version
  nodeSelector           = dependency.runner_node.outputs.runner-node.metadata.labels["magnum.openstack.org/role"]
  # magnum.openstack.org/role

  context = {
    "configs.cm.url"                                   = local.domain_name,
    "configs.secret.extra.github\\.clientID"           = local.secrets.argocd.github.client_id,
    "configs.secret.extra.github\\.clientSecret"       = local.secrets.argocd.github.client_secret,
    "configs.credentialTemplates.https-creds.url"      = "https://github.com/UQThesisENGG7817",
    "configs.credentialTemplates.https-creds.password" = local.secrets.argocd.credential_template.https.password,
    "configs.credentialTemplates.https-creds.username" = local.secrets.argocd.credential_template.https.username,
    "configs.credentialTemplates.helm-creds.url"       = "https://raw.githubusercontent.com/UQThesisENGG7817/helm-charts/gh-pages",
    "configs.credentialTemplates.helm-creds.password"  = local.secrets.argocd.credential_template.helm.password,
    "configs.credentialTemplates.helm-creds.username"  = local.secrets.argocd.credential_template.helm.username,
    "notifications.argocdUrl"                          = local.domain_name,
    "notifications.context.environmentName"           = include.root.locals.env_vars.locals.environment,
    "notifications.secret.items.email-username"       = local.secrets.argocd.notifications.email_username,
    "notifications.secret.items.email-password"       = local.secrets.argocd.notifications.email_password,
    "configs.rbac.create"                             = "true"
    "controller.metrics.enabled"                      = "true"
    "controller.metrics.serviceMonitor.enabled"       = "true"
    "controller.metrics.serviceMonitor.namespace"     = "observability"
    "dex.metrics.enabled"                             = "true"
    "dex.metrics.serviceMonitor.enabled"              = "true"
    "dex.metrics.serviceMonitor.namespace"            = "observability"
    "server.metrics.enabled"                          = "true"
    "server.metrics.serviceMonitor.enabled"           = "true"
    "server.metrics.serviceMonitor.namespace"         = "observability"
    "repoServer.metrics.enabled"                      = "true"
    "repoServer.metrics.serviceMonitor.enabled"       = "true"
    "repoServer.metrics.serviceMonitor.namespace"     = "observability"
    "applicationSet.metrics.enabled"                  = "true"
    "applicationSet.metrics.serviceMonitor.enabled"   = "true"
    "applicationSet.metrics.serviceMonitor.namespace" = "observability"
    "redis.metrics.enabled"                           = "true"
    "redis.metrics.serviceMonitor.enabled"            = "true"
    "redis.metrics.serviceMonitor.namespace"          = "observability"
  }
}
