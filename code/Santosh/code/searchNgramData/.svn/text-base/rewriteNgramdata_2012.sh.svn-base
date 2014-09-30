#!/bin/bash
## code to stem stopwords in ngram files

#fname=$(tempfile);
fname1=$(mktemp);
fname2=$(mktemp);
fname3=$(mktemp);

inpfname=$1;
outfname=$2;
objname=$3;

cat $inpfname | awk '{print $NF}' > $fname1

# now do stemming 
#echo "doing stemming";
cat $inpfname |
gawk '{NF--};1' |
gawk '{gsub(/_nnnnn/,"")};1' |
gawk '{gsub(/_vvvvv/,"")};1' |
gawk '{gsub(/_jjjjj/,"")};1' |
gawk '{gsub(/_ddddd/,"")};1' |
gawk '{gsub(/=>/," ")};1' |
gawk '{gsub(/_/,"")};1' > $fname2

# need to do this separately as it doesnt seem to work when put together
cat $fname2 |
gawk '{gsub(/[[:punct:]]/, "")}; 1' |
gawk '{print$2,$1}' | 
gawk '{gsub("^ ","")};1' |
gawk '{gsub(" $","")};1' > $fname3
# flip order (for head modifier dependecny)

# convert phœbus  to phoebus
iconv -f UTF-8 -t US-ASCII//TRANSLIT < $fname3 > $fname2

#gawk '{gsub("  "," ")};1' |
#gawk '{gsub(/\.|\?|\-|\—|\;|\(|\)|\!|\@|\#|\$|\%|\&|\*|\"|\,|\<|\>|\'/, "")}; 1' |

# now copy back coounts and write to outfile
paste $fname2 $fname1 > $outfname
#mv $fname2 $outfname

#if [$objname != "xxxxxx"]
#then
# ignore vicar in car
grep -w $objname $outfname > $fname3

# disabling this while running "jumping" (as missed "dog jumping")
# ignore horse X (just keep X horse)
#head -n 1 $fname3 > $outfname
#grep -v ^$objname $fname3 >> $outfname
mv $fname3 $outfname
#fi

# delete temp files
rm $fname1 $fname2

