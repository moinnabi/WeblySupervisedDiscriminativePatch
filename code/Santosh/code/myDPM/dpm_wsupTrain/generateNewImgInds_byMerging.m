function thisimpos_new = generateNewImgInds_byMerging(thisimpos, otherCompInfo, cachedir, phrasenames, cls, vocyear, dataids, numLimitToTrain)

otherCompInfo(find(otherCompInfo(:,1) == find(strcmp(phrasenames, cls))),:) = []; % delete that ngram as already assigning it
thisimpos_new = thisimpos;  

for i=1:size(otherCompInfo, 1)    
    load([cachedir '/../' phrasenames{otherCompInfo(i,1)} '/' phrasenames{otherCompInfo(i,1)} '_train_' vocyear '.mat'], 'impos');
    load([cachedir '/../' phrasenames{otherCompInfo(i,1)} '/' phrasenames{otherCompInfo(i,1)} '_mix.mat'], 'inds_mix');
    thisimpos_new = [thisimpos_new impos(inds_mix == otherCompInfo(i,2))];
end   

% restrict number of samples so that 1. doesnt take forever to train
% 2. things remain balanced across components
numSamples=length(thisimpos_new);
thisimpos_new = thisimpos_new(1:min(numSamples,numLimitToTrain));

for j=length(thisimpos)+1:length(thisimpos_new)    
    dataids = dataids + 1;
    thisimpos_new(j).dataids = dataids;
end
  