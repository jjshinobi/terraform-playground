-include .env
export

TERRAFORM_VERSION ?= latest
TERRAFORM = docker run --rm -it \
	-v $(PWD):/workspace \
	-w /workspace \
	--env-file .env \
	hashicorp/terraform:$(TERRAFORM_VERSION)

VAR_FILE ?= repositories.tfvars

.PHONY: init plan apply destroy import

init:
	$(TERRAFORM) init

plan:
	$(TERRAFORM) plan -var-file=$(VAR_FILE)

apply:
	$(TERRAFORM) apply -var-file=$(VAR_FILE)

destroy:
	$(TERRAFORM) destroy -var-file=$(VAR_FILE)

import:
	bash scripts/import.sh
