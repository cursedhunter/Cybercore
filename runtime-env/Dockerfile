ARG PYTHON_VERSION=3.12-slim
ARG DOCKER_REGISTRY_PATH_PREFIX
FROM ${DOCKER_REGISTRY_PATH_PREFIX}python:${PYTHON_VERSION} AS builder
ARG YQ_VERSION=v4.44.2
ARG YQ_BINARY=yq_linux_amd64

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq \
    && apt-get upgrade \
      --yes -qq --no-install-recommends \
    && apt-get install \
      --yes -qq --no-install-recommends \
      git \
      make \
      wget \
      openssh-client

# Authorize SSH Host
RUN mkdir -p /root/.ssh && chmod 0700 /root/.ssh
# See: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
COPY runtime-env/github_known_hosts /root/.ssh/known_hosts

# Add the keys and set permissions
RUN --mount=type=secret,id=doppel-tools,target=/kaniko/doppel-tools cp /kaniko/doppel-tools /root/.ssh/id_ed25519
RUN chmod 400 /root/.ssh/id_ed25519

ENV PRE_COMMIT_HOME=/opt/avd-venv/pre-commit

COPY Makefile pyproject.toml requirements.txt ansible.cfg collection-requirements.yml .pre-commit-config.yaml /opt/avd/
COPY dist /opt/avd/dist

RUN DIST_PATH=/opt/avd/dist VENV_PATH=/opt/avd-venv make -C /opt/avd install-deps
RUN cd /opt/avd && git init && /opt/avd-venv/bin/pre-commit install-hooks

RUN wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/${YQ_BINARY}.tar.gz -O - |\
    tar xz && mv ${YQ_BINARY} /usr/bin/yq

# Main stage
ARG PYTHON_VERSION=3.12-slim
ARG DOCKER_REGISTRY_PATH_PREFIX
FROM ${DOCKER_REGISTRY_PATH_PREFIX}python:${PYTHON_VERSION} AS main

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -qq \
    && apt-get upgrade \
      --yes -qq --no-install-recommends \
    && apt-get install \
      --yes -qq --no-install-recommends \
      git \
      openssh-client \
      parallel

ENV PRE_COMMIT_HOME=/opt/avd-venv/pre-commit
COPY --from=builder /opt/avd-venv /opt/avd-venv
COPY --from=builder /opt/avd/.ansible/collections /usr/share/ansible/collections
COPY --from=builder /usr/bin/yq /usr/bin/yq
COPY runtime-env/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
WORKDIR /opt/avd
ENTRYPOINT ["/entrypoint.sh"]
