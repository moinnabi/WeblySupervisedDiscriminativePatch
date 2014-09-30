function displayExamplesPerAspect_kmeans_overIt_latent(objname, outdir)
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

%if 0
try
% if 'without parts', then do this!    
load([outdir filesep objname '_hard_info'], 'sigAB', 'posclusinds', 'pos_cell', 'posscores');
%else
catch
tmp_fin1 = load([outdir filesep objname '_box'], 'posclusinds', 'pos_cell', 'posscores');
if exist([outdir filesep 'sigAB_info_final'], 'file'), tmp_fin2 = load([outdir filesep 'sigAB_info_final'], 'sigAB');
else tmp_fin2.sigAB = []; end
%tmp_part1 = load([outdir filesep 'myposlatentInfo_51'], 'posclusinds', 'pos_cell', 'posscores');
tmp_part1 = load([outdir filesep 'myposlatentInfo_51'], 'clusinds', 'pos_new', 'scores');
if exist([outdir filesep 'sigAB_info_51'], 'file'), tmp_part2 = load([outdir filesep 'sigAB_info_51'], 'sigAB');
else tmp_part2.sigAB = []; end
tmp_hard1 = load([outdir filesep 'myposlatentInfo_31'], 'clusinds', 'pos_new', 'scores');
if exist([outdir filesep 'sigAB_info_31'], 'file'), tmp_hard2 = load([outdir filesep 'sigAB_info_31'], 'sigAB');
else tmp_hard2.sigAB = []; end
%tmp_init1 = load([outdir filesep 'myposlatentInfo_51'], 'sigAB', 'posclusinds', 'pos_cell', 'posscores');
%tmp_init2 = load([outdir filesep 'sigABinfo_51'], 'sigAB');
sigAB{3} = tmp_fin2.sigAB; sigAB{2} = tmp_part2.sigAB; sigAB{1} = tmp_hard2.sigAB;
%posclusinds{3} = tmp_fin1.posclusinds; posclusinds{2} = tmp_part1.posclusinds; posclusinds{1} = tmp_hard1.posclusinds;
%pos_cell{3} = tmp_fin1.pos_cell; pos_cell{2} = tmp_part1.pos_cell; pos_cell{1} = tmp_hard1.pos_cell;
%posscores{3} = tmp_fin1.posscores; posscores{2} = tmp_part1.posscores; posscores{1} = tmp_hard1.posscores;
posclusinds{3} = tmp_fin1.posclusinds; posclusinds{2} = tmp_part1.clusinds; posclusinds{1} = tmp_hard1.clusinds;
pos_cell{3} = tmp_fin1.pos_cell; pos_cell{2} = tmp_part1.pos_new; pos_cell{1} = tmp_hard1.pos_new;
posscores{3} = tmp_fin1.posscores; posscores{2} = tmp_part1.scores; posscores{1} = tmp_hard1.scores;
end

savename = [resdir '/finalMontage_overIt_perComp.jpg'];

if ~exist(savename, 'file')

disp('base clustering');
%imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds');
try
imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds');
catch   % if baseline, then there exists no inds, so create dummy ones
[spos posindx] = split(pos, numel(rmodel.models));
for i=1:numel(rmodel.models), imodel.inds{i} = ones(length(spos{i}),1); end    
end
[spos posindx] = split(pos, numel(imodel.inds));

imodelinds = imodel.inds{1};
numclusters = length(unique(imodelinds));
for k=2:length(imodel.inds)
    imodelinds = [imodelinds; numclusters*(k-1)+imodel.inds{k}];    
end

posI = posindx{1};
for k=2:length(posindx)
posI = [posI; posindx{k}];
end

posclusinds0 = [];
for i=1:length(imodelinds), posclusinds0(i) = imodelinds(find(posI == i)); end
[mim{1} mimg_all{1} mlab_all{1}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg...
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
[mim{2} mimg_all{2} mlab_all{2}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds{1}, posclusinds0, thispos, posscores{1}, rmodel.model, numToDisplay, modelthresh);

disp('latent update It2');
%[blah, blah, posclusinds2, pos_cell2, posscores2] = myposlatent(objname, 1, hmodel.model, nextpos, 0.7, 0, sigAB{2});
thispos = pos_cell{2};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
if ~isempty(sigAB{2}) & 0 % disabling it here as hmodel cannot be used here and I am too lazy to update it (18Jan11)
modelthresh = [1 ./ (1+exp(sigAB{2}(:,1).*hmodel.model.thresh(:)+sigAB{2}(:,2)))];    % include 0 for '0' cluster
else
modelthresh = hmodel.model.thresh(:);
end
[mim{3} mimg_all{3} mlab_all{3}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds{2}, posclusinds{1}, thispos, posscores{2}, hmodel.model, numToDisplay, modelthresh);

disp('latent update It3');
%[blah, blah, posclusinds2, pos_cell2, posscores2] = myposlatent(objname, 1, hmodel.model, nextpos, 0.7, 0, sigAB{2});
thispos = pos_cell{3};
for i=1:length(thispos)     % fill empty pos(i) cells
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
if ~isempty(sigAB{3}) & 0 % disabling it here as hmodel cannot be used here and I am too lazy to update it (18Jan11)
modelthresh = [1 ./ (1+exp(sigAB{3}(:,1).*hmodel.model.thresh(:)+sigAB{3}(:,2)))];    % include 0 for '0' cluster
else
modelthresh = hmodel.model.thresh(:);
end
[mim{4} mimg_all{4} mlab_all{4}] = displayExamplesPerAspect_kmeans_overIt_getMontageImg2...
    (posclusinds{3}, posclusinds{2}, thispos, posscores{3}, hmodel.model, numToDisplay, modelthresh);

disp('montage per component');
if length(mimg_all{1}) == length(mimg_all{2})-1   % zero ind
    for k=1:length(mimg_all{1})
        myprintf(k);        
        allimgs{1} = mimg_all{1}{k}; alllabs{1} = mlab_all{1}{k};
        allimgs{2} = mimg_all{2}{k+1}; alllabs{2} = mlab_all{2}{k+1};
        allimgs{3} = mimg_all{3}{k+1}; alllabs{3} = mlab_all{3}{k+1};        
        allimgs{4} = mimg_all{4}{k+1}; alllabs{4} = mlab_all{4}{k+1};
        allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
        allmlab{k} = num2str(k);        
        imwrite(allmim{k}, [resdir '/finalMontage_overIt_perComp_' num2str(k) '.jpg']);
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
