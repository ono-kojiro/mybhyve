#!/bin/sh

vms=`sudo vm list | tail -n +2 | awk '{ print $1 }'`

for vm in $vms; do
  zfs get origin zroot/vm/${vm} | tail -n +2
done


