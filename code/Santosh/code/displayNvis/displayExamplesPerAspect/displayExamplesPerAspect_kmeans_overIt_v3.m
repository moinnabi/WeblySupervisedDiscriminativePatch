function displayExamplesPerAspect_kmeans_overIt_v3(objname, outdir)
%multimachine_warp('displayExamplesPerAspect', 20, resdir, 2)

% taken from displayExamplesPerAspect_kmeans_overIt_v2; does the latent
% stuff

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';

VOCopts = VOCinit;
myClasses = VOCopts.classes;

outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);

numToDisplay = 100;

disp(['Processing Class ' objname]);
    
imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos', 'validInds');
rmodel=load([outdir filesep objname '_random.mat'], 'models', 'model');
load([outdir '/' objname '_train'], 'pos');
[spos posindx] = split(pos, numel(rmodel.models));

clear imodelinds warped spos;
imodelinds = imodel.inds{1};
numclusters = length(unique(imodelinds));
warped = imodel.warped{1};
spos = imodel.spos{1};
posI = posindx{1};
for k=2:length(imodel.inds)
    imodelinds = [imodelinds; numclusters*(k-1)+imodel.inds{k}];
    warped = [warped;  imodel.warped{k}];
    spos = [spos  imodel.spos{k}];
    posI = [posI; posindx{k}];
end
model = rmodel.model;

posclusinds0 = [];
for i=1:length(imodelinds), posclusinds0(i) = imodelinds(find(posI == i)); end

disp('here'); keyboard;

% base clustering
[mim{1} mimg_all{1} mlab_all{1}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
    (posclusinds0, pos, [], model, numToDisplay);

% latent update without sigmoid
[blah, blah, posclusinds_noSigAB, pos_cell_noSigAB, posscores_noSigAB] = ...
    myposlatent(objname, 1, model, pos, 0.7, 0, []);
thispos = pos_cell_noSigAB;
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
%[mim{3} mimg_all{3} mlab_all{3}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
%    (posclusinds_noSigAB, thispos, posscores_noSigAB, model, numToDisplay);
modelthresh = [model.thresh(:)];
[mim{3} mimg_all{3} mlab_all{3}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds_noSigAB, posclusinds0, thispos, posscores_noSigAB, model, numToDisplay, modelthresh);

% latent update with sigmoid
%sigAB = hmodel.sigAB{1};
%[sigAB, sigABplotIm, sigAB_mimg] = computeSigmoidParams(model, objname);
[sigAB, sigABplotIm, sigAB_mimg] = computeSigmoidParams(objname, outdir, rmodel.model);
for i=1:length(sigAB_mimg), sigabmlab{i} = num2str(i); end
sigabmimg = montage_list_w_text2(sigAB_mimg, sigabmlab, 2, [], [1 1 1], [5000 5000 3]);
imwrite(sigabmimg, [resdir '/sigABmontage.jpg']);
imwrite(sigABplotIm, [resdir '/sigABplots.jpg']);
[blah, blah, posclusinds, pos_cell, posscores] = myposlatent(objname, 1, model, pos, 0.7, 0, sigAB);
thispos = pos_cell;
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
%[mim{2} mimg_all{2} mlab_all{2}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
%    (posclusinds, thispos, posscores, model, numToDisplay);
modelthresh = [1 ./ (1+exp(sigAB(:,1).*model.thresh(:)+sigAB(:,2)))];    % include 0 for '0' cluster
[mim{2} mimg_all{2} mlab_all{2}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds, posclusinds0, thispos, posscores, model, numToDisplay, modelthresh);

% zero image
mim{4} = zeros(size(mim{3}));

% full montage
[nr nc d]=size(mim{1});
mimg = [mim{1} zeros(nr, 10, 3) mim{2};
    zeros(10, 10+2*nc, 3);...
    mim{3} zeros(nr,10,3) mim{4}];
imwrite(mimg, [resdir '/finalMontage_withWithoutSig.jpg']);

% montage per component
if length(mimg_all{1}) == length(mimg_all{2})-1   % zero ind
    for k=1:length(mimg_all{1})
        myprintf(k);        
        allimgs{1} = mimg_all{2}{k+1}; alllabs{1} = mlab_all{2}{k+1};
        allimgs{2} = mimg_all{3}{k+1}; alllabs{2} = mlab_all{3}{k+1};
        allimgs{3} = mimg_all{1}{k}; alllabs{3} = mlab_all{1}{k};
        %allimgs{4} = mimg_all{4}{k+1}; alllabs{4} = mlab_all{4}{k+1};
        allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
        allmlab{k} = num2str(k);        
        imwrite(allmim{k}, [resdir '/finalMontage_withWithoutSig_perComp_' num2str(k) '.jpg']);
    end    
end
mimg = montage_list_w_text2(allmim, allmlab, 2, [], [], [5000 5000 3]);
imwrite(mimg, [resdir '/finalMontage_withWithoutSig_perComp.jpg']);

disp('here'); keyboard;

%% display samples that have changed their cluster memberships
dispInds = zeros(length(posclusinds_comp),1);
for i=1:length(posclusinds_comp)
    if ~isempty(posclusinds_comp{i}) & posclusinds_comp{i}(1) ~= posclusinds0(i)
        dispInds(i) = 1;
    end
end
mim_indiv = showClusIndsAfterTraining(posclusinds_comp(dispInds==1), thispos(dispInds==1), model, posclusinds0(dispInds==1));

%% DISP COMPUTE STATISTICS OF CLUSTER MEMBERSHIP CHANGES    
unids = unique(imodelinds);
clusInds = cell(length(unids),1);
for k=1:length(unids)
    clusInds{unids(k)} = find(imodelinds == unids(k));
end

for pp=0:2
tmodelinds = hmodel.posclusinds{pp+1};
tmodelinds = tmodelinds(posI);
unids = unique(tmodelinds);
unids(unids == 0) = [];
clusInds2 = cell(length(unids),1);
%chngInClMembs = zeros(length(unids),1);
%commonClMembs = zeros(length(unids),1);
for k=1:length(unids)
    clusInds2{unids(k)} = find(tmodelinds == unids(k));
    %chngInClMembs(unids(k)) = numel(setdiff(clusInds{unids(k)}, clusInds2{unids(k)}));
    %commonClMembs(unids(k)) = numel(intersect(clusInds{unids(k)}, clusInds2{unids(k)}));
    
    chngInClMembs{pp+1}(unids(k)) = numel(setdiff(clusInds2{unids(k)}, clusInds{unids(k)}))/numel(clusInds{unids(k)})*100;
    commonClMembs{pp+1}(unids(k)) = numel(intersect(clusInds{unids(k)}, clusInds2{unids(k)}))/numel(clusInds{unids(k)})*100;
end
end
[commonClMembs{1}; chngInClMembs{1}]
[commonClMembs{2}; chngInClMembs{2}]
[commonClMembs{3}; chngInClMembs{3}]

catch
    disp(lasterr); keyboard;
end

