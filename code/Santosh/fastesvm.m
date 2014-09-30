function [ esvmw , feats ] = fastesvm( pos_examplar , covstruct)
%FASTESVM Summary of this function goes here
%   Detailed explanation goes here

%model = root_model('blah', pos_examplar, []);
model = root_model('blah', pos_examplar, [], 8, [12 12]);
tic; warped = warppos(model, pos_examplar); toc;
%warped = model;

fprintf(' load esvm precomputed stuff\n');
%esvmmodfile = '/projects/grail/santosh/objectNgrams/results/tomasz_esvm/hog_covariance_pascal_voc2007_trainval.mat';   % move this path info to voc_config
%load(esvmmodfile, 'covstruct');

fprintf(' marginalize covariance matrix and mean as per given model size\n');
fi = model.symbols(model.rules{model.start}.rhs).filter;
hg_size = model.filters(fi).size;       % from warppos
if hg_size(1) > covstruct.hg_size(1) || hg_size(2) > covstruct.hg_size(2)
    disp('weird aspect ratio; cant do esvm hog; will do regular hog');  
    [bestIdx, bestclusCentMat, mimg] = deal([]);
    return;
end
covstruct = covstruct_subset(covstruct, hg_size);

covmat = covstruct.c;
covmat = covmat + .01*eye(size(covmat));
covmean = covstruct.mean(:);

fprintf(' caching features\n');
esvmw = cell(length(warped),1);
sbinval = model.sbin;
for i = 1:length(warped)
    myprintf(i,100);    
    feats = features(double(warped{i}), sbinval);    
    feats = feats(:,:,1:end-1);
    %feats{i} = feats{i}(:);
    %esvmw{i} =  cinv * (feats(:) - covstruct.mean(:));
    esvmw{i} =  covmat \ (feats(:) - covmean);
end
myprintfn;
%featMat = cat(2,feats{:})';
%featMat = cat(2,esvmw{:})';

end