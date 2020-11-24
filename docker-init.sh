#!/bin/bash

[[ ! -f .env ]] && {
    cp .env.example .env
    echo "put true envs in .env file"
}

source .env

VM_NAME="${1:-docker-master}"

docker-machine rm --force $VM_NAME >/dev/null 2>&1 || true

docker-machine --debug \
    create \
    -d proxmoxve \
    --proxmoxve-proxmox-host $PVE_HOST \
    --proxmoxve-proxmox-user-name $PVE_USER \
    --proxmoxve-proxmox-realm $PVE_REALM \
    --proxmoxve-proxmox-user-password $PVE_PASSWD \
    --proxmoxve-proxmox-node "$PVE_NODE" \
    --proxmoxve-vm-cpu-sockets $PVE_CPU \
    --proxmoxve-vm-memory $PVE_MEMORY \
    --proxmoxve-vm-image-file $PVE_IMAGE_FILE \
    --proxmoxve-vm-storage-size $PVE_STORAGE_SIZE \
    --proxmoxve-vm-storage-type $PVE_STORAGE_TYPE \
    --proxmoxve-vm-storage-path $PVE_STORAGE_PATH \
    $VM_NAME

echo "/================================/"
echo "/ VM $VM_NAME is started"
echo "/================================/"
