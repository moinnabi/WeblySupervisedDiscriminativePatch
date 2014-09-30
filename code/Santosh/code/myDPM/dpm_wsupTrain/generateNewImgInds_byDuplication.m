function thisimpos_new = generateNewImgInds_byDuplication(thisimpos, numInstToTrain_allNgrams, dataids)

thisimpos_new = thisimpos(mod(0:numInstToTrain_allNgrams-1, length(thisimpos))+1);
for j=length(thisimpos)+1:numInstToTrain_allNgrams  
    dataids = dataids + 1;
    thisimpos_new(j).dataids = dataids;
end

