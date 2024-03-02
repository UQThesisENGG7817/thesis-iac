data "kubernetes_resource" "runner-node" {
  api_version = var.api_version
  kind        = var.kind

  metadata {
    name      = var.name
    namespace = var.namespace
  }
}