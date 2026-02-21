#!/usr/bin/env bash

set -euo pipefail

TERRAFORM_VERSION="${TERRAFORM_VERSION:-latest}"

TERRAFORM="docker run --rm -i \
  -v $(pwd):/workspace \
  -w /workspace \
  --env-file .env \
  hashicorp/terraform:${TERRAFORM_VERSION}"

echo "Reading repository list from Terraform variables..."

# Use terraform console to evaluate the variable and encode as JSON
VAR_FILE="${VAR_FILE:-repositories.tfvars}"

repos=$(echo 'jsonencode(var.repositories)' | $TERRAFORM console -var-file="$VAR_FILE" | jq -r '.' | jq -c '.[]')

while IFS= read -u 3 -r repo; do
  name=$(echo "$repo" | jq -r '.name')

  echo ""
  echo "=== $name ==="

  repo_resource="github_repository.repos[\"$name\"]"
  branch_resource="github_branch_default.default[\"$name\"]"

  # Import repository if not already in state
  if $TERRAFORM state show "$repo_resource" &>/dev/null; then
    echo "  repository: already in state, skipping"
  else
    echo "  repository: importing..."
    $TERRAFORM import -var-file="$VAR_FILE" "$repo_resource" "$name"
  fi

  # Import default branch if not already in state
  if $TERRAFORM state show "$branch_resource" &>/dev/null; then
    echo "  default branch: already in state, skipping"
  else
    echo "  default branch: importing..."
    $TERRAFORM import -var-file="$VAR_FILE" "$branch_resource" "$name"
  fi

done 3<<< "$repos"

echo ""
echo "Done. Run 'make plan' to review any drift."
