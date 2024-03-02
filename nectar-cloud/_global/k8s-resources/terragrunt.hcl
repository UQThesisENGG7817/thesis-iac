include "root" {
  path           = find_in_parent_folders()
  expose         = true
  merge_strategy = "deep"
}

locals {
}

inputs = {

  api_version = include.root.locals.env_vars.locals.k8s_resources.runner_node.api_version
  kind        = include.root.locals.env_vars.locals.k8s_resources.runner_node.kind
  name        = include.root.locals.env_vars.locals.k8s_resources.runner_node.name

}

