# pve-ubuntu-vmbuilder

Create a QEMU VM on Proxmox using the Ubuntu Cloud Image and cloud-init.
Currently this script only supports Ubuntu 20.04 LTS Cloud Image (may be changed in the future)

## Usage

```
Usage: createvm.sh <parameters> ...

Parameters:
    -a, --agent             Install QEMU Agent using cloud-init user-data (default is not installed)
                            If this switch is appended to the command a warning about not being able to modify user-data through Proxmox WebUI is shown
    -c, --cores             CPU Cores that will be assigned to the VM (default: 1)
    --cloudimg-cache-path   Path where Ubuntu Cloud Image should be stored (default: /var/lib/vz/template)
    -d, --domain            Domainname of this VM eg. example.com (default: localdomain)
    --disk-format           Format of the disk, leave out if not using a supported storage (valid formats: qcow2/raw/vmdk)
                            For LVM-Thin storage (this scripts default) don't specify anything
    --disk-size             Size of the VM disk in GB (default: 20)
    --dns-server            DNS Server (default: 8.8.8.8)
    --gateway               Default Gateway, if undefined, script will set it to the specified IP with the fouth octet as .1
                            (eg. default gateway will be 192.168.1.1)
    -h, --help              Show this help message.
    -i, --ip-address        (required) IP Address of this VM in CIDR format (eg. 192.168.1.2/24)
    -m, --memory            Memory that will be allocated to the VM in MB (default: 1024)
    -n, --name              (required) Name of the VM without spaces, dots and other ambiguous characters
    --network-bridge        Network Bridge that the VM should be attached to (default: vmbr0)
    --no-start-created      Don't start the VM after it's created
    --ssh-keyfile           (required) SSH Keys used for ssh'ing in using the user "ubuntu", multiple ssh-keys allowed in file (one key on each line)
    -s, --storage           Storage where the VM will be placed (default: local-lvm)
    --vlan                  VLAN Tag for network interface
```

## License

MIT License

Copyright (c) 2020 Kasper Stad

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
