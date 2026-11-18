#!/usr/bin/env bash
# VBoxManage_commands.sh - Comandos completos de VirtualBox (Parte 2)

# Paso 1: Crear VM Lab5-Alpine y adjuntar disco dinamico e ISO de Alpine Linux 3.19
VBoxManage createvm --name "Lab5-Alpine" --ostype "Linux_64" --register
VBoxManage modifyvm "Lab5-Alpine" --memory 1024 --vram 16 --cpus 1 --nic1 nat

VBoxManage createmedium disk --filename "Lab5-Alpine.vdi" --size 10240 --format VDI
VBoxManage storagectl "Lab5-Alpine" --name "SATA" --add sata
VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "Lab5-Alpine.vdi"

VBoxManage storagectl "Lab5-Alpine" --name "IDE" --add ide
VBoxManage storageattach "Lab5-Alpine" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "alpine-standard-3.19.0-x86_64.iso"

# Paso 3: Modos de red (NAT, Host-Only, Bridge)
# VBoxManage controlvm "Lab5-Alpine" poweroff
# VBoxManage hostonlyif create
# VBoxManage modifyvm "Lab5-Alpine" --nic1 hostonly --hostonlyadapter1 "vboxnet0"
# VBoxManage modifyvm "Lab5-Alpine" --nic1 bridged --bridgeadapter1 "Ethernet"
# VBoxManage modifyvm "Lab5-Alpine" --nic1 nat

# Paso 4: Snapshots
# VBoxManage snapshot "Lab5-Alpine" take "snap_base" --description "Alpine Linux 3.19 recien instalado, sin modificaciones"
# VBoxManage snapshot "Lab5-Alpine" take "snap_con_herramientas" --description "Alpine con curl, wget, nano y htop instalados"
# VBoxManage snapshot "Lab5-Alpine" list
# VBoxManage controlvm "Lab5-Alpine" poweroff
# VBoxManage snapshot "Lab5-Alpine" restore "snap_base"

# Paso 5: Reasignacion de recursos (2 CPUs, 2048 MB RAM)
# VBoxManage controlvm "Lab5-Alpine" poweroff
# VBoxManage modifyvm "Lab5-Alpine" --cpus 2 --memory 2048

# Paso 6: Segundo disco de tamano FIJO (4 GB) para benchmark con dd
# VBoxManage controlvm "Lab5-Alpine" poweroff
# VBoxManage createmedium disk --filename "Lab5-Alpine-fixed.vdi" --size 4096 --format VDI --variant Fixed
# VBoxManage storageattach "Lab5-Alpine" --storagectl "SATA" --port 1 --device 0 --type hdd --medium "Lab5-Alpine-fixed.vdi"

# Paso 9: Exportacion en formato OVA
# VBoxManage controlvm "Lab5-Alpine" poweroff
# VBoxManage export "Lab5-Alpine" --output "Lab5-Alpine-export.ova" --manifest --options manifest
