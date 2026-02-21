variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "repositories" {
  description = "List of repositories to create"
  type = list(object({
    name           = string
    default_branch = string
  }))
}
