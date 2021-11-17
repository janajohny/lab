#!/bin/sh
sudo echo -e "[linuxVM1]\n$(az vm show -d -g linuxVMRg -n linuxVM1 --query publicIps -o tsv)" > /home/vmadmin/hosts
cat /home/vmadmin/hosts
