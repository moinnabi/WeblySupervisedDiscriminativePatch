function displayExamplesPerAspect_kmeans_overIt_simple(objname, outdir)
% taken from displayExamplesPerAspect_kmeans_overIt_v4; was
% displayExamplesPerAspect_kmeans_overIt_v5 

% this script shows latent updates of the pos samples over 1 iterations
% (with and without sigmoid)

try
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);
numToDisplay = 100;

disp(['Processing Class ' objname]);
rmodel=load([outdir filesep objname '_random.mat'], 'models', 'model');
load([outdir '/' objname '_train'], 'pos');
load([outdir '/sigAB_info_1'], 'sigAB');

savename = [resdir '/finalMontage_withWithoutSig_perComp.jpg'];

if ~exist(savename, 'file')

disp('base clustering');
[spos posindx] = split(pos, numel(rmodel.models));
try
imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds');
catch   % if baseline, then there exists no inds, so create dummy ones
for i=1:numel(rmodel.models)
    imodel.inds{i} = ones(length(spos{i}),1);        
end    
end

imodelinds = imodel.inds{1};
numclusters = length(unique(imodelinds));
posI = posindx{1};
for k=2:length(imodel.inds)
    imodelinds = [imodelinds; numclusters*(k-1)+imodel.inds{k}];
    posI = [posI; posindx{k}];
end
posclusinds0 = [];
for i=1:length(imodelinds), posclusinds0(i) = imodelinds(find(posI == i)); end
[mim{1} mimg_all{1} mlab_all{1}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
    (posclusinds0, pos, [], rmodel.model, numToDisplay);

disp('latent update with sig');
[blah, blah, posclusinds_sig, pos_cell_sig, posscores_sig] = myposlatent(objname, 1, rmodel.model, pos, 0.7, 0, sigAB);
thispos = pos_cell_sig;
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
if ~isempty(sigAB)
modelthresh = [1 ./ (1+exp(sigAB(:,1).*rmodel.model.thresh(:)+sigAB(:,2)))];    % include 0 for '0' cluster
else
modelthresh = rmodel.model.thresh(:);
end
[mim{2} mimg_all{2} mlab_all{2}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds_sig, posclusinds0, thispos, posscores_sig, rmodel.model, numToDisplay, modelthresh);

disp('latent update without sig');
[blah, blah, posclusinds_nosig, pos_cell_nosig, posscores_nosig] = myposlatent(objname, 1, rmodel.model, pos, 0.7, 0, []);
thispos = pos_cell_nosig;
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
modelthresh = rmodel.model.thresh(:);    % include 0 for '0' cluster
[mim{3} mimg_all{3} mlab_all{3}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds_nosig, posclusinds0, thispos, posscores_nosig, rmodel.model, numToDisplay, modelthresh);

disp('montage per component');
if length(mimg_all{1}) == length(mimg_all{2})-1   % zero ind
    for k=1:length(mimg_all{1})
        myprintf(k);        
        allimgs{1} = mimg_all{1}{k}; alllabs{1} = mlab_all{1}{k};
        allimgs{2} = mimg_all{2}{k+1}; alllabs{2} = mlab_all{2}{k+1};
        allimgs{3} = mimg_all{3}{k+1}; alllabs{3} = mlab_all{3}{k+1};        
        allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
        allmlab{k} = num2str(k);        
        imwrite(allmim{k}, [resdir '/finalMontage_withWithoutSig_perComp_' num2str(k) '.jpg']);
    end    
else
    disp('oops code missing!'); keyboard;
end
mimg = montage_list_w_text2(allmim, allmlab, 2, [], [], [5000 5000 3]);
imwrite(mimg, savename);
end

catch
    disp(lasterr); keyboard;
end
