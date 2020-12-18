# createvm.sh

Create a QEMU VM on Proxmox using the Ubuntu Cloud Image and cloud-init.
This script is meant to allow very custom user-data (fx. installing a webserver or other customization actions)

By default this script installs and enables the qemu-guest-agent

## Usage

```bash
Usage: createvm.sh <parameters> ...

Parameters:
    -h, --help              Show this help message.
    -n, --name              (required) Name of the VM without spaces, dots and other ambiguous characters
                            If longer than 15 characters, the name will automatically be shortned
    -c, --cores             CPU Cores that will be assigned to the VM (default: 1)
    -m, --memory            Memory that will be allocated to the VM in MB (default: 1024)
    -s, --storage           Storage where the VM will be placed (default: local-lvm)
    -d, --domain            Domainname of this VM (eg. example.com)
    -i, --ip-address        (required) IP Address of this VM in CIDR format (eg. 192.168.1.2/24)
    --network-bridge        Network Bridge that the VM should be attached to (default: vmbr0)
    --disk-size             Size of the VM disk in GB (default: 20)
    --disk-format           Format of the disk, leave out if not using a supported storage (default: raw)
    --dns-server            DNS Server (default: 8.8.8.8)
    --gateway               Default Gateway, if undefined, script will set it to the specified IP with the fouth octet as .1
                            (eg. default gateway will be 192.168.1.1)
    --ssh-key               (required) SSH Key used for ssh'ing in using the user "ubuntu"
    --no-start-created      Don't start the VM after it's created
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
