#!/bin/bash

#jobids=$(qstat |grep ubuntu | awk {' print $1 '});
#for i in ${#jobids[@]}

#ls summary.sh > tempout.txt
echo "time now is " > tempout.txt
date >> tempout.txt

for i in `qstat |grep ubuntu | awk {' print $1 '}`
do
 echo "summary of job $i" >> tempout.txt
 echo "last file update at " >> tempout.txt
 ls -l /home/ubuntu/outputs/MultiMatlab.o$i | awk {'print $6 " " $7'} >> tempout.txt
 tail -n 10 /home/ubuntu/outputs/MultiMatlab.o$i >> tempout.txt
  echo "total number of lines: " >> tempout.txt
 wc -l /home/ubuntu/outputs/MultiMatlab.o$i >> tempout.txt
 printf "\n" >> tempout.txt
 echo "-------------" >> tempout.txt
done

