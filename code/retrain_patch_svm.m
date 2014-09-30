function model_retrained = retrain_patch_svm(ps,voc_ng_train,ps_detect,ng_detect,patch_ind)


[ps_score,ng_score,~] = compute_disc_score(ps_detect,ng_detect,1,1,0.25);

ps_th = 70;
ng_th = 50;

ps_ind = find(ps_score(:,patch_ind)>ps_th);
ng_ind = find(ng_score(:,patch_ind)>ng_th);

ps_num = length(ps_ind);
ng_num = length(ng_ind);

%creat positive samples
clear pos;
numpos = 0;
for i = 1:ps_num
    img_ind = ps_ind(i);
    img = imread(ps{img_ind}.I);
    bb = ps_detect{img_ind}.patches{patch_ind};
    imgcroped = imcrop(img,[bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)]);

    numpos = numpos+1;
    pos(numpos).im = imgcroped;
    pos(numpos).flip = true;
    numpos = numpos+1;
    pos(numpos).im = imgcroped;
    pos(numpos).flip = false;    
    
end

%creat negative samples
clear neg;
numneg = 0;
for i = 1:ng_num
    img_ind = ng_ind(i);
    img = imread(voc_ng_train(img_ind).im);
    bb = ng_detect{img_ind}.patches{patch_ind};
    %clear imgcroped;
    imgcroped = imcrop(img,[bb(1) bb(2) bb(3)-bb(1) bb(4)-bb(2)]);

    numneg = numneg+1;
    neg(numneg).im = imgcroped;
    neg(numneg).flip = true;
    
end

% %visualize
% for i=1:30%length(ps_ind)
%     img_ind = ps_ind(i);
%     %patch_ind = 7;
%     figure; showboxes(imread(ps{img_ind}.I),ps_detect{img_ind}.patches{patch_ind});
% end
% 
% 
% for i=1:length(ng_ind)
%     img_ind = ng_ind(i);
%     %patch_ind = 7;
%     figure; showboxes(imread(voc_ng_train(img_ind).im),ng_detect{img_ind}.patches{patch_ind});
% end



addpath('Santosh/code/imgClsPruning');
%%%PARAM
fsize = [10 10];
sbin = 8;
%Cval = 0.088388;    % magic parameters (set after checking a few classes)
biasval = 1;
featExtractMode = 2;    % 1 is simple thumbnail clfr, 2 is complex fullimg clfr

%disp(' Extract HOG');
posFeats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, featExtractMode);
posData = cat(2, posFeats{:})';

negFeats = getHOGFeaturesFromWarpImg(neg, fsize, sbin, biasval, featExtractMode);
negData = cat(2, negFeats{:})';

%disp(' learn the model...');
trainData = [posData; negData];
trainGt = [ones(size(posData,1),1); -1*ones(size(negData,1),1)];

TrainLabel = double(trainGt);
TrainVec = double(trainData);

%Full samples
addpath(genpath('libsvm-3.17/matlab/'));
%Cross validation
bestcv = 0;
for log2c = -6:10,
   cmd = ['-v 5 -c ', num2str(2^log2c)];
   cv = svmtrain(TrainLabel,TrainVec, cmd);
   if (cv >= bestcv),
     bestcv = cv; 
     bestc = 2^log2c;
   end
   fprintf('(best c=%g, rate=%g)\n',bestc, bestcv);
end
%bestc = 0.088388;    % magic parameters (set after checking a few classes) BY SANTOSH
model = svmtrain(TrainLabel, TrainVec,['-t 0 -c ',num2str(bestc)]);

model_retrained = model;