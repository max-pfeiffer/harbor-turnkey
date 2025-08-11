# Harbor Turnkey
This infrastructure as code (IaC) project installs [Harbor](https://goharbor.io/) on a single node Kubernetes cluster.
It uses [Talos Linux](https://www.talos.dev/) as an operating system for running Kubernetes and
[Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) as hypervisor.
The provisioning is done with [OpenTofu](https://opentofu.org/).

It's meant to be a standalone, turnkey solution: so after installing, you will have Harbor available and ready to use
immediately. For making this happen, I had to do some design decisions:
* IaC: every piece of infrastructure is declarative
  * Proxmox VE: installation of this hypervisor itself is a manual task, but everything else can be done fully
    declarative using APIs and a Terraform/OpenTofu provider 
  * Talos Linux/Kubernetes: both can be configured fully declarative using APIs and Terraform/OpenTofu providers
* Local storage for Kubernetes applications on the node: data storage needs to happen without other infrastructure
  dependencies like NFS or Ceph. Providing storage for a Kubernetes cluster can be rather complex if it needs to be
  highly available, and not everyone has a NFS share available or runs a Ceph cluster like me. So I choose to statically
  provision the volumes on the node with Talos Linux and configured
  [local PersistentVolumes](https://kubernetes.io/docs/concepts/storage/volumes/#local).
  This way it can be installed and run anywhere. Plus, I consider the data which will be stored here as
  ephemeral, as the container images can be easily pulled or reproduced again.
* Certificate authority (CA): bootstrapping and running a standalone CA is necessary to issue TLS certificates 
 
## Prerequisites
* [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) with some resources available
  (default: 2 CPUs, 8GB RAM, 275GB disk space)
* [OpenTofu installed locally](https://opentofu.org/docs/intro/install/)
* [Step CLI installed locally](https://smallstep.com/docs/step-cli/installation/)
* Docker Hub account

## Usage
First clone the repo. The provisioning with [OpenTofu](https://opentofu.org/) needs to be done in two steps:
1. Create the VM on Proxmox hypervisor and install Kubernetes
2. Install Harbor and all other applications in the Kubernetes cluster

### Install Virtual Machine with Talos Linux on Proxmox
Go to `proxmox` subdirectory and create a `configuration.auto.tfvars` file using the example:
```shell
$ cp configuration.auto.tfvars.example configuration.auto.tfvars 
```
Then add the configuration as it suits your needs to the new file. 

Create the virtual machine, install and configure Talos Linux:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```
Then grab the kubeconfig and store it in some appropriate space (or merge with your already existing kubeconfig file):
```shell
$ tofu output -raw kubeconfig > ~/.kube/harbor-config
```
In the next step you will need to reference this kubeconfig file in your `configuration.auto.tfvars` of the OpenTofu
`kubernetes` module.

### Configure Kubernetes Cluster and Install Applications
For bootstrapping the CA [install the step cli tool](https://smallstep.com/docs/step-cli/installation/) on your machine. Then generate your `bootstrap.yaml`:
```shell
$ cd kubernetes
$ ./bootstrap_step_certificates.sh
Choose a password for your CA keys and first provisioner.
✔ [leave empty and we'll generate one]: 
```
This will result in an interactive process where you need to enter the password used for root CA and provisioner
Generate and capture the password, this needs to go into `configuration.auto.tfvars` as `root_ca_password`. The script
uses the step cli tool to generate the file `kubernetes/helm_values/step-certificates-bootstrap.yaml` which is used to
bootstrap the Step CA in the cluster.

In `kubernetes` subdirectory create a `configuration.auto.tfvars` file using the example:
```shell
$ cp configuration.auto.tfvars.example configuration.auto.tfvars 
```
Then apply your configuration to the new file. 

Install Harbor and all other applications into the Kubernetes cluster:
```shell
$ tofu init
$ tofu plan
$ tofu apply
```
After everything was provisioned with OpenTofu, [Harbor](https://goharbor.io/) is available locally under the IP
address and domain which you configured earlier. You can now log in with username `admin` and your
`harbor_admin_password` which you specified in `configuration.auto.tfvars`.

You might want to add a DNS entry for it and add the root CA to your local trust store. You can do this conveniently
with Step CLI:
```shell
$ tofu output -raw root_ca_crt > root_ca.crt
$ step certificate install root-ca.crt
```

### Configure Kubernetes Cluster with the new Harbor Image Cache
The objective is to have Harbor available as container image cache eventually. So the last step is to configure
the image cache for your Kubernetes nodes. As this is specific to the container runtime and registry you are using, I
need to exclude instructions here. For those using Talos Linux for running their cluster, [this is straight forward and
well documented](https://www.talos.dev/v1.10/talos-guides/configuration/pull-through-cache/#using-harbor-as-a-caching-registry).

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
