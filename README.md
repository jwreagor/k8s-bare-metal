# k8s-bare-metal

Guide for building Kubernetes on [Triton][triton] using Packer, Terraform and
Ansible. Automates the installation of a bare metal control plane and KVM
instance worker nodes all running on [Joyent's Triton][triton].

The initial goal of this guide is to build out the following instances akin to
[the Hard Way post][hard] but with extended Triton exclusive features.

- 1x `bastion` node (jump box) for tunneling into our private network.
- 1x `controller` infrastructure container running `kube-apiserver`,
  `kube-controller-manager`, and `kube-scheduler`.
- 3x `worker` running KVM for `kubelet`, `kube-proxy`, and `docker`.
- `etcd` cluster provided by the Autopilot Pattern

**Note**: Pods/containers run on KVM instances running Docker, for the moment.

## Dependencies

- Install [Packer][packer] 1.1.0.
- Install [Terraform][terraform] 0.9.8.
- Install [Ansible][ansible] 2.3.0.0.
- Install the [Triton CLI][triton-cli].
- Install the [Triton Docker CLI][triton-docker].
- Certificates are created via CloudFlare's PKI toolkit [`cfssl`][cfssl].
- I use [`jq`][jq] below for parsing JSON.
- I also use [`direnv`][direnv] for storing environment variables.

### Note on Packer

Packer templates in this project require JSON5 support in `packer(1)` or the
`cfgt(1)` utility. Most of this tool interaction is handled by the `makefile`.

- Usage with unpatched packer: `cfgt -i kvm-worker.json5 | packer build -`
- Usage with patched packer: `packer build kvm-worker.json5`

[Packer w/ JSON5 support][packer-json5]
cfgt: `go get -u github.com/sean-/cfgt`

## Setup your Triton CLI tool

```sh
$ eval "$(triton env us-sw-1)"
$ env | grep SDC
SDC_ACCOUNT=test-user
SDC_KEY_ID=22:45:7d:1c:f5:f0:b9:13:14:d9:ad:9d:aa:1c:83:44
SDC_KEY_PATH=/Users/test-user/.ssh/id_rsa
SDC_URL=https://us-sw-1.api.joyent.com
```

## Create a private fabric network

* In the Triton dashboard, create a private fabric network with the following
  configuration.
* Also, set it as your default Docker network.

```json
{
    "id": "00000000-0000-0000-0000-000000000001",
    "name": "fubarnetes",
    "public": false,
    "fabric": true,
    "gateway": "10.20.0.1",
    "internet_nat": true,
    "provision_end_ip": "10.20.0.254",
    "provision_start_ip": "10.20.0.2",
    "resolvers": [
        "8.8.8.8",
        "8.8.4.4"
    ],
    "routes": {},
    "subnet": "10.20.0.0/24",
    "vlan_id": 2
}
```

* Set our private network's UUID as an environment variable to `export PRIVATE_NETWORK=$(triton network get fubarnetes | jq -r .id)`
* We'll also set Joyent's public network UUID to `export PUBLIC_NETWORK=$(triton network get Joyent-SDC-Public | jq -r .id)`

## Create your etcd cluster

This is a great chance to use the Autopilot Pattern etcd project to spin-up a
private etcd cluster for our Kubernetes services.

* Make sure your new private fabric network is the default network for Docker
  containers under the Joyent Public Cloud Portal. This helps support creating
  all of our non-public etcd containers in the correct network through Docker
  Compose.
* `git clone git@github.com:autopilotpattern/etcd.git && cd etcd` and run
  `./start.sh`
* Your cluster should bootstrap on its own.
* Note your cluster IP addresses, I use the following rather obtuse line of
  shell.

```sh
$ triton-docker inspect $(triton-docker ps --format "{{.Names}}" --filter 'name=e_etcd') | jq -r '.[].NetworkSettings.IPAddress'
```

## Create Kubernetes images using Packer

Next, we'll use Packer to prebuild some of the utilities and tooling required by
the remainder of the process. This helps cut down on setup time else where,
especially when adding more nodes.

First create a bastion for securing our build environment, then build an image
for each part of our Kubernetes cluster.

1. Run `make build/bastion` to build a bastion image.
1. `triton create --wait --name=fubarnetes --network=Joyent-SDC-Public,fubarnetes -m user-data="hostname=fubarnetes" k8s-bastion-lx-16.04 14ad9d54`
1. Note the IP address of your bastion instance and set it to `export BASTION_HOST` env var.
1. Use bastion instance to build remaining images on your private fabric network.
1. Run `make build/controller build/worker`

## Provision infrastructure using Terraform

Next, we'll use Terraform to create the instances we'll be deploying Kubernetes
onto, both the `controller` and `worker`. This will interface with the Triton
API and create our nodes.

1. Create input variables for Terraform within `.terraform.vars` by copying the
   sample `.terraform.vars.example` file.
1. Run `make plan` first and make sure everything is configured.
1. `make apply` when ready to create your infrastructure.

## Run Ansible to upload assets and restart the cluster

After we've created our infrastructure we're left with a few files and
networking configured across our cluster. We'll use Ansible here since it works
great for this sort of thing. Terraform will output everything we need and make
use of our bastion instance to bounce into our private network.

Everything is automatically generated so we simply need to run `make config`.

Ansible performs the following...

1. Uploads generated configs and certificates onto all controllers and workers.
1. Restarts systemd services.
1. ~~Post installation Kubernetes setup.~~
1. ~~Creates VXLAN networking and routes based on `kubectl get nodes`~~

**WIP**: This part isn't complete yet. Cluster is healthy but pod networking is
not hooked up yet.

## Notes

- Generated JSON files in this project are treated as ephemeral build
  assets. They're deleted during most `make build` steps.
- When debugging packer use `PACKER_LOG=1 make build/worker`.
- When working with Ubuntu images on Triton, note the difference between
  [default SSH users][default]. On Ubuntu Certified images the default user is
  `ubuntu`, on Joyent built Ubuntu images use `root`.

[default]: https://github.com/joyent/node-triton/issues/3#issuecomment-136519245

## License

Mozilla Public License Version 2.0

[packer]: https://www.packer.io/
[terraform]: https://www.terraform.io/
[ansible]: https://www.ansible.com/
[triton-cli]: https://docs.joyent.com/public-cloud/api-access/cloudapi
[triton-docker]: https://github.com/joyent/triton-docker-cli
[cfssl]: https://cfssl.org/
[jq]: https://stedolan.github.io/jq/
[direnv]: https://direnv.net/
[triton]: https://www.joyent.com/triton/compute
[hard]: https://www.joyent.com/blog/kubernetes-the-hard-way
[packer-json5]: https://github.com/sean-/packer/tree/f-json5
