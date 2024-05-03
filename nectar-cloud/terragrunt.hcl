#-------------------------------------------------------------------------------
# CONFIGURE TERRAFORM COMMANDS
#-------------------------------------------------------------------------------
terragrunt_version_constraint = ">= 0.12"

terraform {
  extra_arguments "disable_input" {
    commands  = get_terraform_commands_that_need_input()
    arguments = ["-input=false"]
  }

  extra_arguments "init_args" {
    commands  = ["init"]
    arguments = ["-upgrade=true"]
  }

  extra_arguments "plan_args" {
    commands  = ["plan"]
    arguments = ["-lock=false"]
  }

  # Clear cache after run
  # after_hook "after_hook" {
  #   commands     = ["terragrunt-read-config"]
  #   execute      = ["rm", "-rf", "${get_terragrunt_dir()}/.terragrunt-cache"]
  #   run_on_error = true
  # }
}

#-------------------------------------------------------------------------------
# CONFIGURE TERRAGRUNT TO STORE TERRAFORM STATE IN S3 BUCKET
#-------------------------------------------------------------------------------
remote_state {
  backend = local.env_vars.locals.backend
  # disable_dependency_optimization = true

  config = {
    path = "${get_path_to_repo_root()}/${local.env_vars.locals.stack}-state/${path_relative_to_include()}/terraform.tfstate"
  }
}

#-------------------------------------------------------------------------------
# LOCAL VARS
#-------------------------------------------------------------------------------
# -- File path
locals {
  # -- File path
  env_path    = fileexists("${get_parent_terragrunt_dir()}/envs/envs.hcl") ? "${get_parent_terragrunt_dir()}/envs/envs.hcl" : ""
  secret_path = fileexists("${get_parent_terragrunt_dir()}/secrets/secrets.yaml") ? "${get_parent_terragrunt_dir()}/secrets/secrets.yaml" : ""

  # -- Automatically load env variables
  env_vars = read_terragrunt_config(local.env_path)
}

#-------------------------------------------------------------------------------
# GENERATE TERRAFORM AND PROVIDERS CONFIGURATION BLOCK
#-------------------------------------------------------------------------------
generate "providers" {
  path      = "providers.terragrunt.generated.tf"
  if_exists = "overwrite"
  contents  = <<EOF
    terraform {
      backend "local" {}
      required_version = ">= 0.13"
    }

    provider "kubernetes" {
       config_path = "~/.kube/config"
       config_context = "${local.env_vars.locals.context}"
    }
  EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        kubernetes = {
          source = "hashicorp/kubernetes"
          version = "~> 2.26.0"
        }
        helm = {
          source = "hashicorp/helm"
          version = "2.11.0"
        }
      }
    }
EOF
}