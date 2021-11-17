#!/bin/sh
touch /home/vmadmin/hosts
echo -e "[ansiblevm]\n$(az vm show -d -g linuxVMRg -n ansiblevm --query publicIps -o tsv)" > /home/vmadmin/hosts
cat /home/vmadmin/hosts
