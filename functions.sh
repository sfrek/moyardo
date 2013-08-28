#!/bin/bash

_get_all_virtual_machines(){
	virsh -q list --all | awk '{print $2}'
}


_get_all_virtual_networks(){
	virsh -q net-list --all | awk '{print $1}'
}

_get_active_virtual_machines(){
	virsh -q list | awk '{print $2}'
}


_get_active_virtual_networks(){
	virsh -q net-list | awk '{print $1}'
}

_get_no_active_virtual_machines(){
	virsh -q list --all | awk '/shut off/ {print $2}'
}

_get_no_active_virtual_networks(){
	virsh -q net-list --all | awk '/inactive/ {print $1}'
}

# echo "_get_all_virtual_machines"

for MV in $(_get_all_virtual_machines)
do
	virsh -q domblkerror $MV
	virsh -q domblkinfo $MV
	virsh -q domblklist $MV
	virsh -q domblkstat $MV
	virsh -q domcontrol $MV
	virsh -q domif-getlink $MV
	virsh -q domiflist $MV
	virsh -q domifstat $MV
	virsh -q dominfo $MV
	virsh -q dommemstat $MV
	virsh -q domstate $MV
	virsh -q domiflist $MV
	exit 1
done

# echo "_get_all_virtual_networks"
# _get_all_virtual_networks

# echo "_get_active_virtual_machines"
# _get_active_virtual_machines

# echo "_get_active_virtual_networks"
# _get_active_virtual_networks

# echo "_get_no_active_virtual_machines"
# _get_no_active_virtual_machines

# echo "_get_no_active_virtual_networks"
# _get_no_active_virtual_networks
