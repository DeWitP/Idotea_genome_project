#!/bin/bash
# This scripts converts SAM files to sorted BAMs

for i in *.sam;
do
	echo Working with "$i"
	newfile="$(basename $i .sam)"
	samtools view -bS $i | samtools sort -n - ${newfile}
done;
