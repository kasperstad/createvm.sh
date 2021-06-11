# pve-ubuntu-vmbuilder

Create a QEMU VM on Proxmox using the Ubuntu Cloud Image and cloud-init.
Currently this script only supports Ubuntu 20.04 LTS Cloud Image (may be changed in the future)

## Installation

```shell
root@pve:~# wget -O /usr/local/sbin/vmbuilder https://raw.githubusercontent.com/kasperstad/pve-ubuntu-vmbuilder/master/vmbuilder.sh
root@pve:~# chmod a+rx /usr/local/sbin/vmbuilder
```

## Usage

```
Usage: vmbuilder <parameters> ...

Parameters:
    -c, --cores             CPU Cores that will be assigned to the VM (default: 1)
    --disk-size             Size of the VM disk in GB (default: 20)
    --dns-server            DNS Server for deployment (default: 8.8.8.8)
    --docker                Preinstall Docker on the server using cloud-init
    --domain                Domain for deployment (default: cloud.local)
    -h, --help              Show this help message.
    -i, --ip-address        (required) IP Address of this VM in CIDR format (eg. 192.168.1.2/24)
    -m, --memory            Memory that will be allocated to the VM in MB (default: 1024)
    -n, --name              (required) Name of the VM without spaces, dots and other ambiguous characters
    --no-start              Don't start after VM is created (if you need to append user-data)
    --username              Override default username (default: ubuntu)
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
