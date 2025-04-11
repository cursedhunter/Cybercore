### Generic Variables
ACT_INVENTORY_PATH:=$(ROOT_DIR)act-xfab.yml
CLAB_HOSTS_PATH:=$(ROOT_DIR)clab_hosts.csv
KNOWN_HOSTS_PATH:=$(ROOT_DIR)known_hosts
IMAGE_REPOSITORY:=docker_images

$(CLAB_HOSTS_PATH): $(ACT_INVENTORY_PATH)
	yq '.all.children.GENERIC.hosts.[] | select(key | test("lab(29|30)") | not) | key + "," + .ansible_host' < $(ACT_INVENTORY_PATH) | sort -V > $@

$(KNOWN_HOSTS_PATH): $(ACT_INVENTORY_PATH)
	yq '.all.children.GENERIC.hosts.[] | key + "," + .ansible_host' < $(ACT_INVENTORY_PATH) | sort -V | xargs -n1 ssh-keyscan -t ed25519 > $@

anta/inventory.yml: $(INVENTORY_PATH)/inventory.yml
	generate-anta-inventory -i $(INVENTORY_PATH)/inventory.yml -v

clab/clever_jones.clab.yml: $(CLAB_HOSTS_PATH)
	split-topology -i $(INVENTORY_PATH)/inventory.yml -o host_mapping.yml $$(cut -d "," -f2 < $(CLAB_HOSTS_PATH))
	generate-clab-topology -i $(INVENTORY_PATH)/inventory.yml -m host_mapping.yml -c tools_config.yml -v

.PHONY: check-act-topology-defined-and-exists
check-act-topology-defined-and-exists:
	@[ -f "$(ACT_INVENTORY_PATH)" ] || (echo "ACT_INVENTORY_PATH=$(ACT_INVENTORY_PATH) not found." && exit 1)

.PHONY: generate-clab-hosts-from-act-topology
generate-clab-hosts-from-act-topology: check-act-topology-defined-and-exists $(CLAB_HOSTS_PATH)
	@echo "Set gitlab CI/CD variable file CLAB_HOSTS="
	@cat $(CLAB_HOSTS_PATH)

.PHONY: generate-clab-known-hosts-from-act-topology
generate-clab-known-hosts-from-act-topology: check-act-topology-defined-and-exists $(KNOWN_HOSTS_PATH)
	@echo "Set gitlab CI/CD variable file CLAB_KNOWN_HOSTS="
	@cat $(KNOWN_HOSTS_PATH)

.PHONY: encode-ssh-private-key
encode-ssh-private-key:
	@[ -f "$(SSH_PRIVATE_KEY_PATH)" ] || (echo "SSH_PRIVATE_KEY_PATH=$(SSH_PRIVATE_KEY_PATH) not found." && exit 1)
	@echo "Set gitlab CI/CD variable file SSH_PRIVATE_KEY="
	@echo $$(base64 -w0 < $(SSH_PRIVATE_KEY_PATH))

.PHONY: build-runtime-environment-image
build-runtime-environment-image:
	docker build -t runtime-env:$$(scripts/runtime_env_version.sh) -f runtime-env/Dockerfile .

.PHONY: load-and-tag-runtime-env-image
load-and-tag-runtime-env-image: ## Load runtime-env image from $IMAGE_REPOSITORY into local docker and tag it
	@[ -n "$(RUNTIME_ENV_IMAGE_TAG)" ] || (echo "RUNTIME_ENV_IMAGE_TAG is not set." && exit 1)
	docker load < $(IMAGE_REPOSITORY)/runtime-env.$(RUNTIME_ENV_IMAGE_TAG).tar
	docker tag runtime-env:$(RUNTIME_ENV_IMAGE_TAG) $(CI_REGISTRY_IMAGE)/runtime-env:$(RUNTIME_ENV_IMAGE_TAG)

.PHONY: push-runtime-env-image
push-runtime-env-image: ## Push all runtime-env image tags from local docker into project registry
	docker logout $(REGISTRY_HOST) || echo "Not logged"
	echo $(GITLAB_TOKEN) | docker login $(REGISTRY_HOST) -u $(GITLAB_USER) --password-stdin
	docker push --all-tags $(CI_REGISTRY_IMAGE)/runtime-env
