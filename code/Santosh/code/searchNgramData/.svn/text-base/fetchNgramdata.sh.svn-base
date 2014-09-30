#!/bin/bash
## code to stem stopwords in ngram files

#fname1=$(tempfile);
#fname2=$(tempfile);
#fname3=$(tempfile);
fname1=$(mktemp);
fname2=$(mktemp);
fname3=$(mktemp);

objname=$1;
inpfname=$2;
ngramtype=$3;
outfname=$4;

#plural form of query word
objnameplural=$1s;

# first get counts
#echo "getting counts";
grep $objname $inpfname | awk '{print $NF}' > $fname1

# now do stemming 
#echo "doing stemming";
grep $objname $inpfname | 
gawk '{NF--};1' |
tr [[:upper:]] [[:lower:]] |
gawk '{gsub(" $","")};1'| 
gawk '{gsub(/\<a\>|\<an\>|\<the\>|\<is\>|\<are\>|\<was\>|\<as\>|\<same\>|\<his\>/, "")}; 1' |
gawk '{gsub(/\<him\>|\<her\>|\<he\>|\<she\>|\<it\>|\<its\>|\<i\>|\<my\>|\<you\>|\<their\>|\<also\>|\<am\>/, "")}; 1' |
gawk '{gsub(/\<any\>|\<can\>|\<had\>|\<has\>|\<have\>|\<my\>|\<our\>|\<your\>|\<so\>|\<that\>|\<them\>/, "")}; 1'  |
gawk '{gsub(/\<their\>|\<they\>|\<there\>|\<this\>|\<these\>|\<those\>|\<too\>|\<us\>|\<very\>|\<we\>|\<were\>/, "")}; 1' |
gawk '{gsub(/\<when\>|\<where\>|\<how\>|\<why\>|\<what\>|\<which\>|\<who\>|\<whom\>/, "")}; 1' |
gawk '{gsub(/\<should\>|\<would\>|\<could\>|\<been\>|\<having\>|\<all\>|\<me\>|\<generally\>/, "")}; 1' |
gawk '{gsub(/[[:punct:]]/, "")}; 1' |
gawk '{gsub(/^in\>|^to\>|^for\>|^of\>|^and\>|^by\>|^but\>|^with\>/, "")}; 1' |
gawk '{gsub(/\<in$|\<to$|\<for$|\<of$|\<and$|\<by$|\<at$/, "")}; 1' |
gawk '{gsub(/\<A\>|\<An\>|\<The\>|\.|\<Is\>|\<Are\>|\<Was\>|\<As\>|\<Same\>|\<His\>/, "")}; 1' |
gawk '{gsub(/\<Him\>|\<Her\>|\<He\>|\<She\>|\<It\>|\<Its\>|\<I\>|\<My\>|\<You\>|\<Their\>|\<Also\>|\<Am\>/, "")}; 1' |
gawk '{gsub(/\<Any\>|\<Can\>|\<Had\>|\<Has\>|\<Have\>|\<Our\>|\<Your\>|\<So\>|\<That\>|\<Them\>/, "")}; 1'  |
gawk '{gsub(/\<Their\>|\<They\>|\<This\>|\<These\>|\<Those\>|\<Too\>|\<Us\>|\<Very\>|\<We\>|\<Were\>/, "")}; 1' |
gawk '{gsub(/\<When\>|\<Where\>|\<How\>|\<Why\>|\<What\>|\<Which\>|\<Who\>|\<Whom\>/, "")}; 1' |
gawk '{gsub(/\<Should\>|\<Would\>|\<Could\>|\<Been\>|\<Having\>|\<All\>/, "")}; 1' |
gawk '{gsub(/^In\>|^To\>|^For\>|^Of\>|^And\>|^By\>|^But\>|^With\>/, "")}; 1' |
gawk '{gsub(/\<In$|\<To$|\<For$|\<Of$|\<And$|\<By$|\<At$|\<across$|\<Across$|\<while$|\<While$|\<On$/, "")}; 1' |
gawk '{gsub("  "," ")};1' |
gawk '{gsub("^ ","")};1' > $fname2

#gawk '{gsub(/\.|\?|\-|\—|\;|\(|\)|\!|\@|\#|\$|\%|\&|\*|\"|\,|\<|\>|\'/, "")}; 1' |

# now do additional rounds to stem stuff at the begining or end
#for (( c = 1; c < $ngramtype-1; c++ )) 	# changed it as no harm running it again
for (( c = 1; c < $ngramtype; c++ )) 	
do
	#echo "doing additional rounds";
	cat $fname2 |
	gawk '{gsub(/^in\>|^to\>|^for\>|^of\>|^and\>|^by\>|^but\>|^with\>/, "")}; 1' |
	gawk '{gsub(/\<in$|\<to$|\<for$|\<of$|\<and$|\<by$|\<at$|\<from$|\<with$|\<be$|\<or$|\<but$/, "")}; 1' |
	gawk '{gsub(/^In\>|^To\>|^For\>|^Of\>|^And\>|^By\>|^But\>|^With\>/, "")}; 1' |
	gawk '{gsub(/\<In$|\<To$|\<For$|\<Of$|\<And$|\<By$|\<At$|\<across$|\<Across$|\<while$|\<While$|\<On$|\<on$/, "")}; 1' |
	gawk '{gsub("  "," ")};1' |
	gawk '{gsub(" $","")};1'| 
	gawk '{gsub("^ ","")};1' > $fname3
	mv $fname3 $fname2;
done

# now convert plural form to singular (overlap issue)
#echo "plural to singular";
#cat $fname2 | gawk '{gsub($objnameplural,$objname)}; 1' > $fname3
cat $fname2 | sed "s/$objnameplural/$objname/" > $fname3
mv $fname3 $fname2

# now copy back coounts and write to outfile
paste $fname2 $fname1 > $outfname

# delete temp files
#rm $fname1 $fname2 $fname3

