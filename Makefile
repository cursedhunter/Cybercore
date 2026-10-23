### Generic Variables
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
INVENTORY_PATH?=inventory
PYTHON?=$(shell which python3)
VENV_PATH?=.venv
VENV_BIN_PATH:=$(VENV_PATH)/bin
VENV_PYTHON:=$(VENV_BIN_PATH)/python
VENV_PYAVD_VERSION:=$(VENV_PYTHON) -c 'from importlib.metadata import version; print(version("pyavd").replace(".dev", "-dev"))'
PIP_COMPILE:=$(VENV_BIN_PATH)/pip-compile
PIP_SYNC:=$(VENV_BIN_PATH)/pip-sync
SSL_CERT_FILE?=$(shell $(VENV_PYTHON) -m certifi 2>/dev/null)
export SSL_CERT_FILE
DIST_PATH?=$(realpath $(ROOT_DIR)dist)

PYPROJECT:=pyproject.toml
REQUIREMENTS:=requirements.txt
COLLECTION_REQUIREMENTS:=collection-requirements.yml

# ansible environment variables
export ANSIBLE_CONFIG?=$(ROOT_DIR)/ansible.cfg

$(VENV_PYTHON):
	$(PYTHON) -m venv $(VENV_PATH)

$(PIP_COMPILE) $(PIP_SYNC): $(VENV_PYTHON)
	$(VENV_PYTHON) -m pip install "pip<=25.3" "pip-tools==7.5.2"

$(REQUIREMENTS): | $(PIP_COMPILE)
	$(PIP_COMPILE) $(PYPROJECT) -o $(REQUIREMENTS)

.PHONY: install-deps-python
install-deps-python: $(PIP_SYNC) $(REQUIREMENTS) ## Install required python dependencies
	$(PIP_SYNC) $(REQUIREMENTS)

.PHONY: certify
certify: install-deps-python ## Install certifi and set SSL_CERT_FILE
	@echo "SSL_CERT_FILE is set to: $(SSL_CERT_FILE)"

.PHONY: install-deps
install-deps: install-deps-python $(COLLECTION_REQUIREMENTS) ## Install required dependencies
	$(VENV_BIN_PATH)/ansible-galaxy collection install arista.avd:==$$($(VENV_PYAVD_VERSION))
	$(VENV_BIN_PATH)/ansible-galaxy install -r $(COLLECTION_REQUIREMENTS)

.PHONY: upgrade-deps
upgrade-deps: | $(PIP_COMPILE) ## Upgrade requirements
	$(PIP_COMPILE) --upgrade $(PYPROJECT) -o $(REQUIREMENTS)

.PHONY: help
help: ## Display help message (*: main entry points / []: part of an entry point)
	@grep -hE '^[0-9a-zA-Z_-]+\.*[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build
build: ## Run ansible playbook to build fabric configuration
	$(VENV_BIN_PATH)/ansible-playbook playbooks/build.yml -i $(INVENTORY_PATH)/inventory.yml $(LIMIT_ARGS)

.PHONY: build-pyavd
build-pyavd: ## Run pyavd build
	$(VENV_BIN_PATH)/pyavd-build -i $(INVENTORY_PATH)/inventory.yml -o $(INVENTORY_PATH)/intended -f FABRIC $(LIMIT_ARGS) -v

.PHONY: cv-deploy
cv-deploy: ## Run ansible playbook to deploy fabric to CVP
	$(VENV_BIN_PATH)/ansible-playbook playbooks/cv_deploy.yml -i $(INVENTORY_PATH)/inventory.yml -v

.PHONY: cv-validate
cv-validate: ## Run ansible playbook to validate configs with CVP
	$(VENV_BIN_PATH)/ansible-playbook playbooks/cv_validate.yml -i $(INVENTORY_PATH)/inventory.yml -v

.PHONY: delete-cv-validate-workspace
delete-cv-validate-workspace: ## Delete cv validate workspace
	$(VENV_BIN_PATH)/python scripts/delete_cv_workspace.py --cv-server $$CV_DEPLOY_SERVER --cv-token $$CV_DEPLOY_TOKEN --no-cv-verify-certs $$WORKSPACE_ID


.PHONY: pre-commit-install
pre-commit-install: ## Install pre-commit hooks
	$(VENV_BIN_PATH)/pre-commit install

.PHONY: pre-commit-run
pre-commit-run: pre-commit-install ## Run pre-commit hooks on all files
	$(VENV_BIN_PATH)/pre-commit run --all-files --show-diff-on-failure

.PHONY: pre-commit-autoupdate
pre-commit-autoupdate: pre-commit-install ## Run pre-commit autoupdate
	$(VENV_BIN_PATH)/pre-commit autoupdate

ifndef NO_AUTO_INSTALL_DEPS
build: install-deps
build-skip-doc: install-deps
build-pyavd: install-deps
cv-deploy: install-deps
cv-validate: install-deps
delete-cv-validate-workspace: install-deps-python
pre-commit-install: install-deps-python
pre-commit-run: install-deps-python
endif

-include clever_jones.mk
