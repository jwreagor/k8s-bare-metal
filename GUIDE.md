1. Packer build bastion instance.
2. `triton create --wait --name=fubarnetes -m user-data="hostname=fubarnetes" k8s-bastion-lx-16.04 14ad9d54`
3. Use bastion instance to build remaining images on private network.
4. ... more to go ...
