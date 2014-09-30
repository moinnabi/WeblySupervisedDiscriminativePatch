%%%PARAM
fsize = [10 10];
sbin = 8;
Cval = 0.088388;    % magic parameters (set after checking a few classes)
biasval = 1;
featExtractMode = 2;    % 1 is simple thumbnail clfr, 2 is complex fullimg clfr

%%%% TRAINING
disp(' caching positive features: train...');
ids_train = ids(trainInds);
clear pos;
numpos = 0;
for i = 1:length(ids_train);
    numpos = numpos+1;
    pos(numpos).im = ids_train{i};
    pos(numpos).flip = false;
    numpos = numpos+1;
    pos(numpos).im = ids_train{i};
    pos(numpos).flip = true;
end

pos(1).im = ps{1}.I;
pos(1).flip = false;

feats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, featExtractMode);
posData = cat(2, feats{:})';

neg = pos;

feats = getHOGFeaturesFromWarpImg(neg, fsize, sbin, biasval, featExtractMode);
negData = cat(2, feats{:})';

disp(' learn the model...');
trainData = [posData; negData];
trainGt = [ones(size(posData,1),1); -1*ones(size(negData,1),1)];
%[model, err] = svm_one_vs_all_data(trainData',trainGt,Cval,[]);
[model1, err1, Cval, thresh] = svm_one_vs_all_data_linear(trainData,trainGt,Cval,[]);