function displayExamplesPerAspect_kmeans_overIt_v2(objname, outdir)
%multimachine_warp('displayExamplesPerAspect', 20, resdir, 2)

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';

VOCopts = VOCinit;
myClasses = VOCopts.classes;

%objname = myClasses{16};
%outdir = fullfile(basedir, 'results', 'uoctti_models', 'release3_retrained', '2007', objname, [objname '_pedroLRsplit'], 'test', 'candidates');
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);

numToDisplay = 25;

disp(['Processing Class ' objname]);
    
imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos', 'validInds');
rmodel=load([outdir filesep objname '_random.mat'], 'models', 'model');
load([outdir '/' objname '_train'], 'pos');
[spos posindx] = split(pos, numel(rmodel.models));

hmodel=load([outdir filesep objname '_hard_info.mat'], 'pos_cell', 'posclusinds', 'posscores');
hmodel2=load([outdir filesep objname '_hard.mat'], 'model');
hmodel.model = hmodel2.model;
clear hmodel2;

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
pp=0;

disp('printing');
[mim{1} mimg_all{1} mlab_all{1}] = getMontageImg(imodelinds, pos(posI), [], rmodel.model, numToDisplay);

thispos = hmodel.pos_cell{pp+1};
for i=1:length(thispos)
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
%{
thispos = pos_cell;
for i=1:length(thispos)
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
%}
[mim{2} mimg_all{2} mlab_all{2}] = getMontageImg(hmodel.posclusinds{pp+1}, thispos, [], hmodel.model, numToDisplay);

thispos = hmodel.pos_cell{pp+2};
for i=1:length(thispos)
    if isempty(thispos(i).im), thispos(i) = pos(i); end
end
[mim{3} mimg_all{3} mlab_all{3}] = getMontageImg(hmodel.posclusinds{pp+2}, thispos, [], hmodel.model, numToDisplay);

% thispos = hmodel.pos_cell{pp+3};
% for i=1:length(thispos)
%     if isempty(thispos(i).im), thispos(i) = pos(i); end
% end
% [mim{4} mimg_all{4} mlab_all{4}] = getMontageImg(hmodel.posclusinds{pp+3}, thispos, [], hmodel.model, numToDisplay);
mim{4} = zeros(size(mim{3}));

% full montage
[nr nc d]=size(mim{1});
mimg = [mim{1} zeros(nr, 10, 3) mim{2};
    zeros(10, 10+2*nc, 3);...
    mim{3} zeros(nr,10,3) mim{4}];
imwrite(mimg, [resdir '/finalMontage.jpg']);

% montage per component
if length(mimg_all{1}) == length(mimg_all{2})-1   % zero ind
    for k=1:length(mimg_all{1})
        myprintf(k);
        allimgs{1} = mimg_all{1}{k}; alllabs{1} = mlab_all{1}{k};
        allimgs{2} = mimg_all{2}{k+1}; alllabs{2} = mlab_all{2}{k+1};
        allimgs{3} = mimg_all{3}{k+1}; alllabs{3} = mlab_all{3}{k+1};
        %allimgs{4} = mimg_all{4}{k+1}; alllabs{4} = mlab_all{4}{k+1};
        allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
        allmlab{k} = num2str(k);        
    end
end
mimg = montage_list_w_text2(allmim, allmlab, 2, [], [], [5000 5000 3]);
imwrite(mimg, [resdir '/finalMontage_perComp.jpg']);

if 0
% DISP COMPUTE STATISTICS OF CLUSTER MEMBERSHIP CHANGES    
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
disp('here'); keyboard;
end

catch
    disp(lasterr); keyboard;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [mim mimg mlab] = getMontageImg(inds, pos, posscores, model, numToDisplay)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
    randInds = randperm(numel(A));
    randInds = randInds(1:thisNum);
    spos = pos(A(randInds));
    warptmp = warppos_display(model, spos);    
    for j=1:thisNum
        %allimgs{j} = uint8(warped{A(randInds(j))});
        allimgs{j} = uint8(warptmp{j});
        [blah alllabs{j}] = myStrtokEnd(strtok(spos(j).im, '.'), '/');
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    mlab{jj} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;

%%%%%%%%%%%%
function [mim mimg mlab] = getMontageImg2(inds, pos, numToDisplay, model, numnegs)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
    randInds = randperm(numel(A));
    randInds = randInds(1:thisNum);
    spos = pos(A(randInds));
    warptmp = warppos_display(model, spos);    
    for j=1:thisNum        
        allimgs{j} = uint8(warptmp{j});
        [blah alllabs{j}] = myStrtokEnd(strtok(spos(j).im, '.'), '/');         
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    if unids(jj) ~=0 && ~isempty(numnegs)
    mlab{jj} = [num2str(numel(A)) ' - ' num2str(numnegs(unids(jj,:)))];
    else
        mlab{jj} = num2str(numel(A));
    end
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;

%%%%%%%%%%%
function [mim mimg mlab] = getMontageImg_old1(inds, warped, spos, numToDisplay)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1);
    alllabs = cell(thisNum,1);
    
    %randInds = myRand(thisNum, numel(A));
    randInds = randperm(numel(A));
    for j=1:thisNum
        allimgs{j} = uint8(warped{A(randInds(j))});
        [blah imname] = myStrtokEnd(strtok(spos(A(randInds(j))).im, '.'), '/');
        alllabs{j} = imname;
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    mlab{jj} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;

function [mim mimg mlab] = getMontageImg_old2(inds, pos, model, numToDisplay)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
        
    randInds = randperm(numel(A));
    randInds = randInds(1:thisNum);
    spos = pos(A(randInds));
    warptmp = warppos_display(model, spos);    
    for j=1:thisNum
        %allimgs{j} = uint8(warped{A(randInds(j))});
        allimgs{j} = uint8(warptmp{j});
        [blah alllabs{j}] = myStrtokEnd(strtok(spos(j).im, '.'), '/');
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    mlab{jj} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;

function [mim mimg mlab] = getMontageImg2_old(inds, warped, spos, numToDisplay, posI, numnegs)

unids = unique(inds);
for jj = 1:length(unids)
    myprintf(jj);
    A = find(inds == unids(jj));
    thisNum = min(numToDisplay, numel(A));
    allimgs = cell(thisNum,1);
    alllabs = cell(thisNum,1);
    
    %randInds = myRand(thisNum, numel(A));
    randInds = randperm(numel(A));
    for j=1:thisNum
        posind = find(posI == A(randInds(j)));
        allimgs{j} = uint8(warped{posind});
        [blah imname] = myStrtokEnd(strtok(spos(A(randInds(j))).im, '.'), '/');
        alllabs{j} = imname;
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    if unids(jj) ~=0 && ~isempty(numnegs)
    mlab{jj} = [num2str(numel(A)) ' - ' num2str(numnegs(unids(jj,:)))];
    else
        mlab{jj} = num2str(numel(A));
    end
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;

function [mim mimg mlab] = getMontageImg3_old(inds, warped, spos, numToDisplay)

for k=1:numel(inds)
    myprintf(k);
    unids = unique(inds{k});
    for jj = 1:length(unids)
        A = find(inds{k} == unids(jj));
        thisNum = min(numToDisplay, numel(A));
        allimgs = cell(thisNum,1);
        alllabs = cell(thisNum,1);
        
        %randInds = myRand(thisNum, numel(A));
        randInds = randperm(numel(A));
        for j=1:thisNum
            allimgs{j} = uint8(warped{k}{A(randInds(j))});
            [blah imname] = myStrtokEnd(strtok(spos{k}(A(randInds(j))).im, '.'), '/');
            alllabs{j} = imname;
        end
        mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
        mlab{jj} = num2str(numel(A));
    end
    mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
    
end
myprintfn;   
