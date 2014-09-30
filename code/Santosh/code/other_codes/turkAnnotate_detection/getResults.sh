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


#cat='horse'
categ=$1;

DIR=$(pwd);
cd $MTURK_CMD_HOME/bin

#label=$MTURK_CMD_HOME/samples/object_detection/amt/$categ
label=$2/$categ
successfile=$label.success
outputfile=$label.results

./getResults.sh $1 $2 $3 $4 $5 $6 $7 $8 $9 -successfile $successfile -outputfile $outputfile -sandbox

cd $DIR

