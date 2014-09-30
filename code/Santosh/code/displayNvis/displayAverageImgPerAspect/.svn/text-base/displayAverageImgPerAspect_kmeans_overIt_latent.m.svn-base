function displayAverageImgPerAspect_kmeans_overIt_latent(objname, outdir)
% taken from displayExamplesPerAspect_kmeans_overIt_v3; was
% displayExamplesPerAspect_kmeans_overIt_v4

% this script shows latent updates of the pos samples over 2 iterations 

try
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);
numToDisplay = 100;

disp(['Processing Class ' objname]);
rmodel=load([outdir filesep objname '_random.mat'], 'models', 'model');
hmodel=load([outdir filesep objname '_hard.mat'], 'model');
load([outdir '/' objname '_train'], 'pos');
load([outdir filesep objname '_hard_info'], 'sigAB', 'posclusinds', 'pos_cell', 'posscores');

savename = [resdir '/finalAverageMontage_overIt_perComp.jpg'];

if ~exist(savename, 'file')

    %{
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
[mim{1} mimg_all{1} mlab_all{1}] = displayAverageImgPerAspect_kmeans_overIt_func...
    (posclusinds0, pos, [], rmodel.model, numToDisplay);

disp('latent update It1');
thispos = pos_cell{1};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
nextpos = thispos;
if ~isempty(sigAB{1})
modelthresh = [1 ./ (1+exp(sigAB{1}(:,1).*rmodel.model.thresh(:)+sigAB{1}(:,2)))];    % include 0 for '0' cluster
else
modelthresh = rmodel.model.thresh(:);
end
[mim{2} mimg_all{2} mlab_all{2}] = displayAverageImgPerAspect_kmeans_overIt_func...
    (posclusinds{1}, posclusinds0, thispos, posscores{1}, rmodel.model, numToDisplay, modelthresh);

disp('latent update It2');
%[blah, blah, posclusinds2, pos_cell2, posscores2] = myposlatent(objname, 1, hmodel.model, nextpos, 0.7, 0, sigAB{2});
thispos = pos_cell{2};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
if ~isempty(sigAB{2})
modelthresh = [1 ./ (1+exp(sigAB{2}(:,1).*hmodel.model.thresh(:)+sigAB{2}(:,2)))];    % include 0 for '0' cluster
else
modelthresh = hmodel.model.thresh(:);
end
[mim{3} mimg_all{3} mlab_all{3}] = displayAverageImgPerAspect_kmeans_overIt_func...
    (posclusinds{2}, posclusinds{1}, thispos, posscores{2}, hmodel.model, numToDisplay, modelthresh);
%}
    
disp('latent update It3');
thispos = pos_cell{3};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
[mim mimg_all mlab_all] = displayAverageImgPerAspect_kmeans_overIt_func...
    (posclusinds{3}, thispos, posscores{3}, hmodel.model, numToDisplay);

for i=1:length(mimg_all)
    myimagesc(mimg_all{i});
    mysaveas([resdir '/average_perComp_' num2str(numToDisplay) '_' num2str(i) '.jpg']);
    %imwrite((mimg_all{i}), [resdir '/average_perComp_' num2str(i) '.jpg']);            
end

% do average of averages
siz = [size(mimg_all{1},1) size(mimg_all{1},2)];
mimg_all_res = [];
for i=1:length(mimg_all)
    mimg_all_res{i} = imresize(mimg_all{i}, siz);    
end
avgmimg = mean(cat(4,mimg_all_res{:}), 4);
myimagesc(avgmimg);
mysaveas([resdir '/average_acrossAllComp_' num2str(numToDisplay) '.jpg']);

imwrite(mim, savename);


end

catch
    disp(lasterr); keyboard;
end
