#!/bin/bash
## code to stem stopwords in ngram files

#fname=$(tempfile);
fname1=$(mktemp);
fname2=$(mktemp);
fname3=$(mktemp);

#objname=$1_NOUN;
inpfname=$2;
ngramtype=$3;
#objnameplural=$4_NOUN;  #plural form of query word
posTag=$4;
outfname=$5;

objname=$1_$4;

# first get counts
#echo "getting counts";
#grep $objname $inpfname | awk '{print $NF}' > $fname1

# now do stemming 
#echo "doing stemming";
#grep $objname $inpfname | 
#gawk '{NF--};1' |
#gawk '{gsub(" $","")};1' > $fname2

#cat $inpfname | grep $objname |
grep -w $objname $inpfname |
gawk '{if (gsub(/_/,"_") >= 2) print }' |
grep -vE '(_DET|_CONJ|_PRON|_NUM|_ADP|_PRT|_X)' |
gawk '{gsub("NOUN","nnnnn")};1' |
gawk '{gsub("VERB","vvvvv")};1' |
gawk '{gsub("ADJ","jjjjj")};1' |
gawk '{gsub("ADV","ddddd")};1' |
tr [[:upper:]] [[:lower:]] |
grep -v '_\.' > $fname2



##gawk '{gsub("^ ","")};1' 
##gawk '{gsub("  "," ")};1' |
##gawk '{gsub(/[[:punct:]]/, "")}; 1' |
##gawk '{gsub(/\.|\?|\-|\—|\;|\(|\)|\!|\@|\#|\$|\%|\&|\*|\"|\,|\<|\>|\'/, "")}; 1' |

# now convert plural form to singular (overlap issue)
##echo "plural to singular";
##cat $fname2 | gawk '{gsub($objnameplural,$objname)}; 1' > $fname3
# 9Jul13: commenting this as this doesnt work (1. you just search for horse_noun 2. you converted _noun to _nnnnn and then search for _noun!)
# nonteless there is overlap issue and you dont want to further confuse things by including plurals (see notes)
#cat $fname2 | sed "s/$objnameplural/$objname/" > $fname3
#mv $fname3 $fname2

# now copy back coounts and write to outfile
#paste $fname2 $fname1 > $outfname
mv $fname2 $outfname

# delete temp files
#rm $fname1 $fname2 $fname3

