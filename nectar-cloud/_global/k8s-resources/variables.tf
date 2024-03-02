variable "api_version" {
  type = string
  description = "(Required) The API version for the requested resource."
}

variable "kind" {
  type = string
  description = "(Required) The kind for the requested resource."
}

variable "name" {
  type = string
  description = "(Required) The name for the requested resource."
}


variable "namespace" {
  type = string
  description = "(Optional) The namespace of the requested resource."
  default = null
}