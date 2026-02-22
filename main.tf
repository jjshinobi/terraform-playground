terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  token = var.github_token
}

resource "github_repository" "repos" {
  for_each = { for repo in var.repositories : repo.name => repo }

  name          = each.value.name
  visibility    = "private"
  auto_init     = true

  lifecycle {
    ignore_changes = [auto_init]
  }
}

resource "github_branch_default" "default" {
  for_each = { for repo in var.repositories : repo.name => repo }

  repository = github_repository.repos[each.key].name
  branch     = each.value.default_branch
  rename     = each.value.default_branch != "main"

  lifecycle {
    ignore_changes = [rename]
  }
}
