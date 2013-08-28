#!/bin/bash
for M in $(virsh -q  list $1 | awk '{print $2}');do 
	echo $M
	virsh domiflist $M
done
