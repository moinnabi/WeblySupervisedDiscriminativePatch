function [trainInds, testInds, model, pr] = doTrainNtestImgCl_func(ids, cls, fsize, sbin, biasval, negData_train, negData_test, Cval, featExtractMode)

%featExtractMode = 2;

%myRandomize;

disp('split positives into half n half');
numTotImgs = numel(ids);
tids = randperm(numTotImgs);
trainInds = tids(1:floor(numTotImgs/2));
testInds = tids(floor(numTotImgs/2)+1:end);

%{
disp('split positives into 2/3 train & 1/3 test');
numTotImgs = numel(ids);
tids = randperm(numTotImgs);
trainInds = tids(1:floor(2*numTotImgs/3));
testInds = tids(floor(2*numTotImgs/3)+1:end);
%}

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

feats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, featExtractMode);
posData = cat(2, feats{:})';

disp(' learn the model...');
trainData = [posData; negData_train];
trainGt = [ones(size(posData,1),1); -1*ones(size(negData_train,1),1)];
[model, err] = svm_one_vs_all_data(trainData',trainGt,Cval,[]);
%[model1, err1, Cval, thresh] = svm_one_vs_all_data_linear(trainData,trainGt,Cval,[]);

%%%% TESTING
disp(' caching positive features: test...');
ids_test = ids(testInds);
clear pos;
for i=1:length(ids_test)
    pos(i).im = ids_test{i};
    pos(i).flip = 0;
end
clear ids_test;     % if using, update with dupfnd info!!!!

%{
            % this is not very effective for same class train/test as the
            % duplicate detection has already been done by google (for
            % e.g., for dog poker, this code doesn't help as images are
            % minor alterations (in color balance etc) and thus I cant
            % catch them
            disp('doing dup detection');
            dupfnd = zeros(length(warped),1);
            for i=1:length(warped)
                %myprintf(i);
                queryImg = warped{i};
                j = 1;
                while j <= length(warped_train)
                    %myprintfdot(j,10);
                    if numel(queryImg) == numel(warped_train{j})
                        if sqrt(sum((queryImg(:) - warped_train{j}(:)).^2)) == 0
                            disp(' caught duplicate');
                            dupfnd(i) = j;
                            break;
                        end
                    end
                    j=j+1;
                end
            end
            % all those that have a duplicate reject them
            testInds(logical(dupfnd)) = [];
            warped(logical(dupfnd)) = [];
            pos(logical(dupfnd)) = [];
%}

feats = getHOGFeaturesFromWarpImg(pos, fsize, sbin, biasval, featExtractMode);
posData = cat(2, feats{:})';

disp(' classifying...');
testData = [posData; negData_test];
testGt = [ones(size(posData,1),1); -1*ones(size(negData_test,1),1)];
score_test = testData  * model.W - model.rho;

disp(' computing pr...');
pr = computePR(score_test, testGt);
disp(['  result for ' cls ' is ' num2str(100*pr.ap)]);

myprintfn;
