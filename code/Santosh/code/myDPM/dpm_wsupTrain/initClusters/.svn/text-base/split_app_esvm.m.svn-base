function [bestIdx, bestclusCentMat, mimg] = split_app_esvm(pos, numClustersPerSplit, esvmmodfile)

try
    
fprintf(' warping instances\n');
% see covstruct.params.init_params and tomasz' email
model = root_model('blah', pos, []);
%model = root_model('blah', pos, [], 8, [12 12]);
warped = warppos(model, pos);

fprintf(' load esvm precomputed stuff\n');
%esvmmoddir = '/projects/grail/santosh/objectNgrams/results/tomasz_esvm/';   % move this path info to voc_config
%load([esvmmoddir '/hog_covariance_pascal_voc2007_trainval.mat'], 'covstruct');
%esvmmodfile = '/projects/grail/santosh/objectNgrams/results/tomasz_esvm/hog_covariance_pascal_voc2007_trainval.mat';   % move this path info to voc_config
load(esvmmodfile, 'covstruct');
%cinv = inv(covstruct.c);

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
parfor i = 1:length(warped)
    myprintf(i,100);    
    feats = features(double(warped{i}), sbinval);    
    feats = feats(:,:,1:end-1);
    %feats{i} = feats{i}(:);
    %esvmw{i} =  cinv * (feats(:) - covstruct.mean(:));
    esvmw{i} =  covmat \ (feats(:) - covmean);
end
myprintfn;
%featMat = cat(2,feats{:})';
featMat = cat(2,esvmw{:})';
  
%maxiter = 2;
maxiter = 5;    % changed it back to 5 as I have uncanny feeling that results would be hurt and then this is just one time investment
disp([' doing kmeans clustering k=' num2str(numClustersPerSplit)]);  
%{
disp('study if for can be replaced by parfor, kmeans seeding'); keyboard;
% this would depend on extensive experimentation, but on one run that I
% conducted, parfor seems same as for
bestv = inf; 
for j = 1:maxiter
    myprintf(j);
            
    if numel(pos) < 4000  % plug added to deal with 'person', 6May12
        [Idx, clusCentMat, v] = kmeans(featMat, numClustersPerSplit, 'Replicates', 5);
    else
        [Idx, clusCentMat, v] = kmeanspp(featMat', numClustersPerSplit);
        Idx = Idx(:); clusCentMat = clusCentMat';
    end
        
    v = sum(v);
    if v < bestv
        fprintf('new total intra-cluster variance: %f\n', v);
        bestv = v;
        bestIdx = Idx';
        bestclusCentMat = clusCentMat';
    end
end
myprintfn;
%}
bestv = inf; 
[pf_Idx, pf_clusCentMat, pf_v] = deal(cell(numel(maxiter),1));
parfor j = 1:maxiter    
    myprintf(j);
              
    if numel(pos) < 4000  % plug added to deal with 'person', 6May12        
        [pf_Idx{j}, pf_clusCentMat{j}, pf_v{j}] = kmeans(featMat, numClustersPerSplit, 'Replicates', 5);
    else
        [pf_Idx{j}, pf_clusCentMat{j}, pf_v{j}] = kmeanspp(featMat', numClustersPerSplit);
        pf_Idx{j} = pf_Idx{j}(:); pf_clusCentMat{j} = pf_clusCentMat{j}';
    end
end

for j=1:maxiter
    v = pf_v{j};
    v = sum(v);
    if v < bestv
        fprintf('new total intra-cluster variance: %f\n', v);
        bestv = v;
        bestIdx = pf_Idx{j}';
        bestclusCentMat = pf_clusCentMat{j}';
    end
end
myprintfn;

%sid1 = tic;
try
% visualize
[mimg_lrs, mlab_lrs] = getMontagesForModel_latent(bestIdx(:), bestIdx(:), ...
    bestIdx(:), [], [], [], pos, [], numClustersPerSplit);  
mimg = montage_list_w_text2(mimg_lrs, mlab_lrs, 2, '', [0 0 0], [2000 2000 3]);
end
%disp('visualize for clustering took');
%toc(sid1);

catch
    disp(lasterr); keyboard;
end
