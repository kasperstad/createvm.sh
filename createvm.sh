#!/bin/bash
set -e

# MIT License
# 
# Copyright (c) 2020 Kasper Stad
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

export CLOUDIMG="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Help meassage
function get_help()
{
    echo "
Usage: $0 <parameters> ...

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
    --ssh-key               (required) SSH Key used for ssh'ing in using the user \"ubuntu\"
    --no-start-created      Don't start the VM after it's created
"
    exit 1
}

# This script needs root permissions to run, check that
if [ "$EUID" -ne 0 ]; then
    echo "[$0] Error: You must run this script as root!"
    exit 1
fi

# Get Help if you don't specify any arguments...
if [ ${#} -eq 0 ]; then
    get_help
fi

# Parse all parameters 
while [ ${#} -gt 0 ]; do
    case "${1}" in
        -h|--help)
            get_help
            ;;
        -n|--name)
            VM_NAME="$2"
            if [[ $VM_NAME == *['!'@#\$%^\&*()\_+\']* ]];then
                echo "[$0] specified hostname is invalid"
                exit 1
            fi
            shift
            shift
            ;;
        -c|--cores)
            VM_CORES="$2"
            shift
            shift
            ;;
        -m|--memory)
            VM_MEMORY="$2"
            shift
            shift
            ;;
        -s|--storage)
            VM_STORAGE="$2"
            shift
            shift
            ;;
        -d|--domain)
            VM_DOMAIN="$2"
            shift
            shift
            ;;
        -i|--ip-address)
            VM_IP_ADDRESS="$2"
            shift
            shift
            ;;
        --network-bridge)
            VM_NET_BRIDGE="$2"
            ;;
        --disk-size)
            VM_DISK_SIZE="$2"
            shift
            shift
            ;;
        --disk-format)
            VM_DISK_FORMAT="$2"
            shift
            shift
            ;;
        --dns-server)
            VM_DNS_SERVER="$2"
            shift
            shift
            ;;
        --gateway)
            VM_GATEWAY="$2"
            shift
            shift
            ;;
        --ssh-key)
            VM_SSH_KEY="$2"
            shift
            shift
            ;;
        --no-start-created)
            VM_NO_START_CREATED=1
            ;;
        *)
            get_help
            ;;
    esac
done

# Default values if they wasn't defined as parameters
VM_CORES=${2:-1}
VM_MEMORY=${VM_MEMORY:-1024}
VM_STORAGE=${2:-"local-lvm"}
VM_DOMAIN=${2:-"localdomain"}
VM_NET_BRIDGE=${2:-"vmbr0"}
VM_DISK_SIZE=${2:-20}
VM_DISK_FORMAT=${2:-"raw"}
VM_DNS_SERVER=${VM_DNS_SERVER:-"8.8.8.8"}

# Get Help if you don't specify required parameters (yes I know I'm a little demanding ;) )...
if [[ -z $VM_SSH_KEY || -z $VM_NAME || -z $VM_IP_ADDRESS ]]; then
    get_help
fi

# Fetch the next available VM ID 
VMID=$(pvesh get /cluster/nextid)

# Local Storage where template and snippets will be stored
# there should only be one, ideally you wold use the default "local here"
localStorage=$(awk '{if(/path/) print $2}' /etc/pve/storage.cfg | head -n 1)

# Retrive the latest cloud image from URL
tempCloudImg="/tmp/$(basename $CLOUDIMG)"
wget --show-progress -o /dev/null -O $tempCloudImg $CLOUDIMG

# Generate the Cloud-init user-data
cat > "${localStorage}/snippets/${VMID}.yml" << EOF
#cloud-config
hostname: ${VM_NAME}
manage_etc_hosts: true
fqdn: ${VM_NAME}.${VM_DOMAIN}
ssh_authorized_keys:
  - ${VM_SSH_KEY}
chpasswd:
  expire: False
users:
  - default
package_upgrade: true
packages:
  - qemu-guest-agent
runcmd:
  - systemctl enable qemu-guest-agent
  - systemctl restart qemu-guest-agent
EOF

# Create the new VM
qm create $VMID --name $VM_NAME --cores $VM_CORES --memory $VM_MEMORY --agent 1

# Import the image to the storage and attach it
qm importdisk $VMID $tempCloudImg $VM_STORAGE
qm set $VMID --scsihw virtio-scsi-pci --scsi0 $VM_STORAGE:vm-$VMID-disk-0,discard=on

# Resize the imported disk
qm resize $VMID scsi0 ${VM_DISK_SIZE}G

# Set the default boot disk to be the newly imported disk
qm set $VMID --boot c --bootdisk scsi0

# Add a cloud-init drive
qm set $VMID --ide2 $VM_STORAGE:cloudinit
qm set $VMID --cicustom "user=local:snippets/$VMID.yml"

# Set the VM to use serial0 as the default vga device
qm set $VMID --serial0 socket --vga serial0

# Attach network interface to a bridge
qm set $VMID --net0 virtio,bridge=$VM_NET_BRIDGE

# If no default gateway is defined, we're creating one
if [ -z "${VM_GATEWAY}" ]; then
    VM_GATEWAY="$(echo ${VM_IP_ADDRESS} | cut -d '.' -f 1,2,3).1"
fi

# Setup the network, DNS server and domain
qm set $VMID --ipconfig0 ip=$VM_IP_ADDRESS,gw=$VM_GATEWAY
qm set $VMID --nameserver $VM_DNS_SERVER
qm set $VMID --searchdomain $VM_DOMAIN

# if --no-start-created wasn't spedified, start the VM after it's created
if [ -z $VM_NO_START_CREATED ]; then
    qm start $VMID
fi

# remove the downloaded image
rm -f $tempCloudImg
