######################################
################ ENVs ################
######################################

VARIABLES_FILE := ./.env
SECRETS_VARIABLES_FILE := ./.secrets

ifneq (,$(wildcard $(VARIABLES_FILE)))
    include $(VARIABLES_FILE)
    export
endif

ifneq (,$(wildcard $(SECRETS_VARIABLES_FILE)))
    include $(SECRETS_VARIABLES_FILE)
    export
endif

######################################
########### MAKE SETTINGS ############
######################################
.DEFAULT_GOAL := help

######################################
############# VARIABLES ##############
######################################
PLAN_FILE=plan_output_file
TERRAFORM_DIR=terraform

######################################
############## PIPELINE ##############
######################################

deploy: ## Deploy the infra
	@$(MAKE) create-backend-file
	@cd ${TERRAFORM_DIR} && \
		terraform init && \
		terraform validate && \
		terraform plan -out ${PLAN_FILE} && \
		terraform apply ${PLAN_FILE}

destroy: ## Destroy the infra
	@$(MAKE) create-backend-file
	@cd ${TERRAFORM_DIR} && \
		terraform init && \
		terraform validate && \
		terraform destroy -auto-approve

create-backend-file:
	@cd ${TERRAFORM_DIR} && envsubst < backend.tpl > backend.tf

cleanup:
	@rm -rf ${TERRAFORM_DIR}/.terraform* || true
	@rm -rf ${TERRAFORM_DIR}/backend.tf || true
	@rm -rf ${TERRAFORM_DIR}/${PLAN_FILE} || true

######################################
################ HELP ################
######################################
##@ Target
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

