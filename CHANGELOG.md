# Change Log

## [1.6.0] 2026-02-13

### Improvements

* Update avd@5.7.2
* Update anta@1.7.0

## [1.5.0] 2025-08-26

### Improvements

* Update avd@5.5.1
* Refactor AVD config to new models

## [1.4.0] 2025-06-20

### Improvements

* Update doppel-tools@v0.0.19
* Improved pre-deployment pipeline cv-validate with pre-deployment workspaces
* Add post-deployment-nrfu job on deployment pipeline
* Improved cv-deploy job on deployment pipeline with Auto-Execute action
* Add linter rules to add "---" on all yaml files

## [1.3.0] 2025-05-28

### Improvements

* Update avd@5.4.0
* Update anta@1.4.0
* Update doppel-tools@v0.0.18
* Improved pre-deployment pipeline with anta_runner
* Add mtu discovery pipeline

## [1.2.0] 2025-04-08

### Improvements

* AVD config fixes and improvements
* Configurable digital twin custom mtu
* Fix cvp setting
* Improve destroy script: Only kill containers with clab labels & clean old topology files
* Update doppel-tools@v0.0.17

## [1.1.1] 2025-03-14

### Improvements

* Adjust self-test-pipeline.yml check-ci-variables
* Set ANTA connection defaults
* List agent keys in ssh job
* NRFU jobs generated from anta_inventory
* Early exit generate-anta-test-catalogs if no test_catalogs are generated when all nodes have is_deployed=false
* Update anta@blue (1.3.0+RLIMIT_NOFILE fix)
* Update doppel-tools@v0.0.16

## [1.1.0] 2025-03-06

### Improvements

* Refactor variable names
* Use tools from upstream GitHub
* Better logs
* Configurable avd build engine: new AVD_BUILD_ENGINE environment variable to choose between `ansible` (default) and `pyavd` build engines
* Playbook hosts inventory group variable from environment. Default `FABRIC`

## [1.0.0] 2025-02-13

### Improvements

* Update tools to v0.0.15
* Set interface defaults
* Set the Overlay Controller management interface to Management 1/1
* Fix inventory CV credentials
* Update dependencies
* Add container scanning pipeline
* Add self-test pipeline

## [0.0.5] 2025-01-24

### Improvements

* Rename some CI/CD variable names to make them more consistent. See README.md
* Add new cvp-validate job to pre-deployment pipeline to send changes to CVP for validation
* Add CLAB_ENV variable to control the environment in containerlab deployments

## [0.0.4] 2025-01-10

### Improvements

* Updated dependencies: tools@0.0.14, anta@1.2.0
* Split NRFU jobs between fast and slow jobs
* Add docker login before deployment to log into gitlab registry
* Add TOPOLOGY_SPLIT_STRATEGY variable to control topology split strategy
* Simplify known hosts setup

### Fixed

* Fixed unhealthy nodes check after deployment
