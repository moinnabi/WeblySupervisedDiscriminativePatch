

Information
===========

This is an implementation of the "Learning Everything about Anything" system. The system 
is implemented in MATLAB, with various helper functions written in Shell, Python, MEX C++ 
for efficiency reasons. For details about the method, please see [1].

This readme contains instructions on using the code, as well as accessing/using already 
trained models for various concepts.

For questions concerning the code please contact Santosh Divvala (http://homes.cs.washington.edu/~santosh) 
at santosh@cs.washington.edu. 

The software has been tested on Linux using MATLAB versions R2011a. There may be compatibility 
issues with older versions of MATLAB. At least 4GB of memory (plus an additional 0.75GB for each 
parallel matlab worker) is assumed.


Citation
========

[1] "Learning Everything about Anything: Webly-Supervised Visual Concept Learning"
Santosh K. Divvala, Ali Farhadi, Carlos Guestrin. 
CVPR 2014 (in Review)
Paper: http://grail.cs.washington.edu/projects/visual_ngrams/objectNgrams_cvpr14_inReview_withAuthorNames.pdf
Project webpage: http://grail.cs.washington.edu/projects/visual_ngrams/ngrams.html


Downloading the code
====================

There are two ways to download the code:

1. Zipped file
http://grail.cs.washington.edu/projects/visual_ngrams/ngrams/visualNgrams_10Dec13.tgz

Download (using "wget") and unzip (using "tar -xvzf") the code.


2. Using SVN
svn co svn://frame.cs.washington.edu/projects/grail/santosh4/svnRepository/objectNgrams/trunk/code

This will download a directory named "code" to your current directory. In case
you are prompted for a username and password when you run the above command, 
please let me know.


Using the code
===============

1. Download the code.
2. Download and install the 2007 PASCAL VOC dataset (for UW CSE GRAIL lab users, this step
is not needed as a copy is already available at '/projects/grail/santosh/Datasets/Pascal_VOC/VOC2007/')
3. Start matlab (in the folder where the code has been downloaded)
4. Run myaddpath.m
5. Run the 'myDPM/compile_wsup.m' function to compile the helper functions
(used by the DPM code)
6. Use the 'masterScript_ngrams' script to train and evaluate a model. (Do not
forget to modify the directory paths)

The main function to use the system is masterScript_ngrams.m

It has several functions therein. Some of the main functions are:

downloadNcleanNgramData_2012; 			% Downloads the ngram corpus from Google
objectNgramData_2012;				% Searches the ngram corpus for a given concept
pascal_img_trainNtestNeval_fast; 		% Prunes the list of ngrams found for a given concept
getDiverseNgrams_fastImgCl;			% Merges synonymous ngrams
downloadGoogImgs;				% Downloads the images for the pruned list of ngrams
mvImgsNcreateTxt;				% Re-organizes the image data in a PASCAL VOC friendly format
findNearDuplicates_hashing;			% Near-duplicate image removal
pascal_train_wsup3;				% Trains DPM model for a given ngram
pascal_getNondupComps_noIslands;		% Merges similar Ngram DPM components
pascal_test_sumpool_multi;			% Test the final model
pascal_eval_ngramEvalObj;			% Evaluate results


See "Accessing the results" for details about the structure of the results
directory and the .mat files.


Accessing the results
======================

All results are available at:
/projects/grail/santosh/objectNgrams/results

* The directory "googImg_data" therein holds all the downloaded images from Google
* The directory "ngram_data" therein holds all the Ngram corpus downloaded from Google 
* The directory "ngram_models" therein holds all the trained models and
 intermediate results for all the concepts. 

The directory "object_ngram_data" within ngram_models e.g.,
"/projects/grail/santosh/objectNgrams/results/ngram_models/chair/object_ngram_data"
holds the concept-specific ngram data files. 

The directory "ngramPruning" within ngram_models e.g.,
"/projects/grail/santosh/objectNgrams/results/ngram_models/chair/ngramPruning"
holds the concept-specific (image-classifier based) pruning and merging files.

The directory "kmeans_6" within ngram_models e.g.,
"/projects/grail/santosh/objectNgrams/results/ngram_models/chair/kmeans_6"
holds the concept-specific per ngram detection model files.

Each sub-directory within the kmeans_6 directory contains the following files:
_mix.mat : this file has the intermediate model (without the DPM parts) as well as
the latent membership information of training instances to the DPM components
_parts.mat : this file has the final model with the DPM parts

* The file 'other_codes/voc-release5/voc_config.m' holds all parameter information.
* The file 'code/utilScripts/VOCoptsClasses.m' holds the list of all concepts.

Results can be browsed online at this link:
https://drive.google.com/folderview?id=0B1Oa1E4wAeBqcmlJVTJQOHBtbGc&usp=sharing


Cluster Computing
=================

Due to the nature of the computations, several steps are implemented in a
cluster-friendly computational setup. These steps have been tested and run on
the UW CSE GRAIL computational server. For using the code on other
computational servers (e.g., Amazon EC2), some modifications would be needed.
Contact the author for any help/questions in this regard.

In addition to cluster computation, distributed computing support is also available 
through the Matlab Parallel Computing Toolbox.  Various loops are implemented using 
the 'parfor' parallel for-loop construct.  


List of Third-Party code/Acknowledgements
=========================================
*** To be completed ***


Known Issues
============
*** To be completed ***


