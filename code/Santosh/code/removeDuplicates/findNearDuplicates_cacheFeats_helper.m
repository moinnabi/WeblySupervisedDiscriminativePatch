function [posData, posData_val] = findNearDuplicates_cacheFeats_helper(jpgimagedir, imgsetdir) %, dpsbin, fsize)
% HOG based dup detection

try
    
conf = voc_config('paths.model_dir', 'blah');
dpsbin = conf.threshs.sbin_dupDtn;
fsize = conf.threshs.fsize_dupDtn;

%dpsbin = 4;
%fsize = [20 20];
%%%hogchi2ThisDimThresh = 0.15;
fsize = [fsize fsize];

%mymatlabpoolopen;

disp('extract features: train');
tic;
[ids_train, gt] = textread([imgsetdir '/val1_withLabels.txt'], '%s %d');    % 'train' is gotten thru 'val1'
ids_train = ids_train(gt==1);
clear pos;
for i=1:length(ids_train)
    pos(i).im = [jpgimagedir '/' ids_train{i}  '.jpg'];
    pos(i).flip = 0;
end
feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end  % normalize (to keep consistent with chisq)
posData = single(cat(2, feats{:})');
disp(size(posData));
toc;

disp('extract features: val');
tic;
[ids_val, gt] = textread([imgsetdir '/val2_withLabels.txt'], '%s %d');
ids_val = ids_val(gt==1);
clear pos;
for i=1:length(ids_val)
    pos(i).im = [jpgimagedir '/' ids_val{i}  '.jpg'];
    pos(i).flip = 0;
end
feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end      % normalize (to keep consistent with chisq)
posData_val = single(cat(2, feats{:})');
disp(size(posData_val));
toc;

catch
    disp(lasterr); keyboard;
end
