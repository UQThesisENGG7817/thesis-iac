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
    path = "${get_path_to_repo_root()}/uq-thesis-potter-state/${local.env_vars.locals.stack}/terraform.tfstate"
  }
}

#-------------------------------------------------------------------------------
# LOCAL VARS
#-------------------------------------------------------------------------------
# -- File path
locals {
  # -- File path
  env_vars = read_terragrunt_config(find_in_parent_folders("stack.hcl"))
  secret_path = find_in_parent_folders("secrets.yaml")
  secrets     = yamldecode(sops_decrypt_file(local.secret_path))
  # -- Automatically load env variables
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

    provider "grafana" {
      url  = "${local.env_vars.locals.grafana_url}"
      auth = "${local.secrets.provider.GRAFANA_AUTH}"
    }
  EOF
}

generate "versions" {
  path      = "versions_override.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
    terraform {
      required_providers {
        grafana = {
          source  = "grafana/grafana"
          version = ">= 2.9.0"
        }
      }
    }
EOF
}