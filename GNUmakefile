TFSTATE_FILE ?= .terraform.state
TFVARS_FILE ?= .terraform.vars
TF_PLAN ?= .terraform.plan
TERRAFORM=$(shell which 2>&1 /dev/null terraform | head -1)
PACKER=$(shell which 2>&1 /dev/null packer | head -1)

TEMPLATES ?= kvm-edge-worker.json kvm-worker.json lx-bastion.json lx-controller.json lx-etcd.json

.SUFFIXES: .json .json5

# NOTES:
#
# cfgt: Required to convert from JSON5 to JSON (unless you've patched your
#       packer(1) install to accept JSON5:
#       https://github.com/sean-/packer/tree/f-json5)
#
# env: SDC_URL, SDC_ACCOUNT, SDC_KEY_ID must be set.  Run `triton env` to get
#      these values.  https://www.npmjs.com/package/triton

default: help

# Packer Targets

%.json: %.json5
	cfgt -i $< -o $@

build:: $(TEMPLATES) ## Build our Triton images
	@for template in $+; do \
		$(PACKER) build $$template; \
	done

# Terraform Targets

apply: ## Applies a given Terraform plan
	$(TERRAFORM) apply -state-out=${TFSTATE_FILE} ${TF_PLAN}

plan: ## Plan a Terraform run
	$(TERRAFORM) plan -state=${TFSTATE_FILE} -var-file=${TFVARS_FILE} -out=${TF_PLAN}

plan-target: ## Plan a Terraform run against a specific target
	$(TERRAFORM) plan -state=${TFSTATE_FILE} -var-file=${TFVARS_FILE} -out=${TF_PLAN} -target=${TARGET}

fmt: ## Format Terraform files inline
	$(TERRAFORM) fmt

show: ## Show the Terraform state
	$(TERRAFORM) show ${TFSTATE_FILE}

taint: ## Taints a given resource
	$(TERRAFORM) taint -state=${TFSTATE_FILE} $(TARGET)

# Triton Targets

list-lx:: ## Show all Ubuntu images on Triton
	triton images -l name=~ubuntu type=lx-dataset

list-kvm:: ## Show all Ubuntu images on Triton
	triton images -l name=~ubuntu type=zvol

instances:: ## Show all running instances on Triton
	triton instances -o name,ips,id

custom-images:: ## Show my Triton images
	triton images -l public=false

networks::  ## Show Triton networks
	triton network list -l

packages::  ## Show Triton Packages
	triton packages

# Misc Targets
deps:: deps/terraform deps/packer deps/cfgt ## Install all dependencies

deps/terraform:: ## Install terraform(1)
	go get -u github.com/hashicorp/terraform

deps/packer:: ## Install packer(1)
	go get -u github.com/hashicorp/packer

deps/cfgt:: ## Install cfgt(1)
	go get -u github.com/sean-/cfgt

env:: ## Show local environment variables
	@env | egrep -i '(SDC|Triton|Manta)' | sort

.PHONY: help
help:
	@echo "Valid targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
