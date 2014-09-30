#!/bin/bash

outfname="/projects/grail/$USER/outputs/tempout.txt"
matfname="/projects/grail/$USER/outputs/MultiMatlab.o"

echo "time now is " > $outfname 
date >> $outfname

 echo "-------------" >> $outfname 
for i in `qstat |grep $USER | awk {' print $1 '}`
do
 echo "summary of job $i" >>  $outfname 
 echo "last file update at " >> $outfname 
 ls -l $matfname$i | awk {'print $6 " " $7 " " $8'} >> $outfname 
 tail -n 10 $matfname$i >> $outfname 
 printf "\n" >> $outfname 
 echo "total number of lines: " >> $outfname 
 wc -l $matfname$i >> $outfname 
 printf "\n" >> $outfname 
 echo "-------------" >> $outfname
done

