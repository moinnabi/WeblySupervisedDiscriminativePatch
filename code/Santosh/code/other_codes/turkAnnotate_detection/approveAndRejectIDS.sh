#!/usr/bin/env sh
#
# Copyright 2008 Amazon Technologies, Inc.
# 
# Licensed under the Amazon Software License (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at:
# 
# http://aws.amazon.com/asl
# 
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and
# limitations under the License.
 
worker_approve_dir=~/Research/PASCAL/VOCdevkit/AMTcode/segmentation/worker
cd ../../bin
echo "worker approval directory : $worker_approve_dir"

for cat in `cat ../samples/segmentation/category.list`
do
    approvefile=$worker_approve_dir/$cat/approveids.txt
    rejectfile=$worker_approve_dir/$cat/rejectids.txt
    
    echo "run on category : $cat"
    echo $approvefile $rejectfile
    ./approveWork.sh -approvefile $approvefile
    ./rejectWork.sh -rejectfile $rejectfile

done

cd ../samples/segmentation

