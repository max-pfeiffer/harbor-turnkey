# Harbor on a Kubernetes Single Node Cluster using Talos Linux and Proxmox VE
This infrastructure as code (IaC) project installs [Harbor](https://goharbor.io/) on a single node Kubernetes cluster.
It uses [Talos Linux](https://www.talos.dev/) as an operating system for running Kubernetes and Proxmox as hypervisor.
The provisioning is done with OpenTofu.

## Usage
First clone the repo. The provisioning with OpenTofu needs to be done in two steps:
1. Create the VM on Proxmox hypervisor and install Kubernetes
2. Install Harbor and all applications in the Kubernetes cluster

### Install Virtual Machine with Talos Linux on Proxmox
Go to `proxmox` subdirectory and create a `credentials.auto.tfvars` file using the example:
```shell
$ cp credentials.auto.tfvars.example credentials.auto.tfvars 
```
Then add your credentials to the new file. 

Create the virtual machine, install and configure Talos Linux:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```

### Install Harbor and all other Applications
For bootstrapping the CA [install the step cli tool](https://smallstep.com/docs/step-cli/installation/) on your machine. Then generate your `config.yaml`:
```shell
$ cd kubernetes/step_certificates_config
step ca init --helm > config.yaml
```
This will result in some interactive process where you need to enter the following configuration options:

1. Deployment Type: `Standalone`
2. Name of the PKI: `Harbor`
3. DNS names: `step-certificates.security.svc.cluster.local`
4. IP and port: `:9000`
5. First provisioner name: `cert-manager`
6. Password: generate and capture it, this needs to go into `credentials.auto.tfvars` as `root_ca_password`

Go to `kubernetes` subdirectory and create a `credentials.auto.tfvars` file using the example:
```shell
$ cp credentials.auto.tfvars.example credentials.auto.tfvars 
```
Then add your credentials to the new file. 

Install Harbor and all other applications into the Kubernetes cluster:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```

## Information Sources
* [Talos Linux documentation](https://www.talos.dev/v1.8/)
* [Talos Linux Image Factory](https://factory.talos.dev/)
* Terraform providers/modules
  * Baremetal provisioning
    * [terraform-provider-proxmox](https://github.com/Telmate/terraform-provider-proxmox)
    * [terraform-provider-talos](https://github.com/siderolabs/terraform-provider-talos)
  * Kubernetes
    * [terraform-provider-kubernetes](https://github.com/hashicorp/terraform-provider-kubernetes)
    * [terraform-provider-helm](https://github.com/hashicorp/terraform-provider-helm)
  * Applications
    * [terraform-provider-harbor](https://github.com/goharbor/terraform-provider-harbor)
* Helm charts:
  * [metallb](https://github.com/metallb/metallb/tree/main/charts/metallb) 
  * Certificate Authority
    * [step-certificates](https://artifacthub.io/packages/helm/smallstep/step-certificates)
    * [step-issuer](https://artifacthub.io/packages/helm/smallstep/step-issuer)
  * [cert-manager](https://artifacthub.io/packages/helm/cert-manager/cert-manager)
  * [ingress-nginx](https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
  * [Harbor](https://github.com/goharbor/harbor-helm)
