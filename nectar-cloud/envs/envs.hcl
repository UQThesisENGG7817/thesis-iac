locals {
  backend = "local"
  context = "uq_thesis_potter"

  #-------------------------------------------------
  # Stack vars
  #-------------------------------------------------
  # TODO: Remember to change
  stack = "uq-thesis-potter"
  stack_tags = {
    Description = "Potter's UQ Thesis stack"
    stack       = local.stack
  }

  #-------------------------------------------------
  # Kubernetes resources vars
  #-------------------------------------------------

  k8s_resources = {
    runner_node = {
      api_version = "v1"
      kind        = "Node"
      name        = "potter-github-action-runner-gpwudckxl5im-node-0"
    }
  }

  #-------------------------------------------------
  # Kubernetes add-ons vars
  #-------------------------------------------------

  k8s_addons_component = "k8s-cluster-addons"
  k8s_addons = {
    argocd = {
      chart_version = "5.49.0"
      node_selector = {
        nodegroup-role = "main"
      }
    }
  }
}