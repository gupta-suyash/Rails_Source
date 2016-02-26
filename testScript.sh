#!/bin/bash

lsfiles=`ls tproc_*`
#echo $lsfiles

sum=0
for i in $lsfiles
do
	res=`cat $i`
	sum=`echo $sum + $res | bc`
done
echo $sum
rm tproc_*

