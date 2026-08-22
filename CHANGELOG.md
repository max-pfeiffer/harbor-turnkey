# Changelog

## [2.0.0](https://github.com/max-pfeiffer/harbor-turnkey/compare/1.1.0...2.0.0) (2026-08-22)


### ⚠ BREAKING CHANGES

* switched to Gateway API for issueing TLS certificates and HTTPRoute for exposing Harbor Web UI
* switched to Gateway API v1.6.1, removed Ingress controller
* the bootstrap for the CA is now using pre-built keys and certificates, no manual action needed any more

### Features

* switched to Gateway API for issueing TLS certificates and HTTPRoute for exposing Harbor Web UI ([a199d5c](https://github.com/max-pfeiffer/harbor-turnkey/commit/a199d5c70a89dc2b982968963d32a669293f88c6))
* switched to Gateway API v1.6.1, removed Ingress controller ([ea19e0a](https://github.com/max-pfeiffer/harbor-turnkey/commit/ea19e0a2230db3e799ab53a7cebfc85d11a310d8))
* updated Cilium to v1.20.0 ([5288921](https://github.com/max-pfeiffer/harbor-turnkey/commit/5288921551fae47f59c39686ae9959ddaa522a10))
* updated Helm chart versions for Step-certificates, Cert-manager and Harbor ([6bff9c8](https://github.com/max-pfeiffer/harbor-turnkey/commit/6bff9c844fd9ae86a6e084b8b9646c394dc23806))


### Bug Fixes

* Generate Hubble TLS certificates in-cluster with a CronJob inste… ([bdd6e14](https://github.com/max-pfeiffer/harbor-turnkey/commit/bdd6e148c73aaa2a68eb4036f8101aabe55394cc))
* Generate Hubble TLS certificates in-cluster with a CronJob instead of at Helm render time, otherwise every render produces new certificates and the machine config never converges ([a9b2eda](https://github.com/max-pfeiffer/harbor-turnkey/commit/a9b2eda1f13c02e07fa4a963b5ce916932707c6a))


### Documentation

* updated versions in README ([e86501e](https://github.com/max-pfeiffer/harbor-turnkey/commit/e86501eea1d1158d43591b03608165bdde265cb0))


### Code Refactoring

* the bootstrap for the CA is now using pre-built keys and certificates, no manual action needed any more ([554e2cb](https://github.com/max-pfeiffer/harbor-turnkey/commit/554e2cbdd10b5cca9890a62fb442681e233af09a))

## [1.1.0](https://github.com/max-pfeiffer/harbor-turnkey/compare/1.0.0...1.1.0) (2026-08-14)


### Features

* switched to bpg/proxmox provider, added GitHub Workflows and pr… ([8975838](https://github.com/max-pfeiffer/harbor-turnkey/commit/8975838ee93aaed050e70d731424c470770c7665))
* switched to bpg/proxmox provider, added GitHub Workflows and pre-commit hooks ([3938685](https://github.com/max-pfeiffer/harbor-turnkey/commit/393868581ed2a3e05f82485fa24542828714e54a))
* updated siderolabs/talos provider to 0.12.0-alpha.5 and refactored resources ([5797cef](https://github.com/max-pfeiffer/harbor-turnkey/commit/5797cefc19b11e83006a307f1932d35f5051f872))


### Bug Fixes

* code formatting kubernetes module ([9da256f](https://github.com/max-pfeiffer/harbor-turnkey/commit/9da256f4b842e6d1c75cfca48c4d1d4d4eee9268))
* release-please config ([8c36b8d](https://github.com/max-pfeiffer/harbor-turnkey/commit/8c36b8d1046bac4f1f3aa571adf6f0cdca2c984c))
* release-please config ([205e7b3](https://github.com/max-pfeiffer/harbor-turnkey/commit/205e7b33badf454d7a7b1e389f8a2efd947ddf7f))
