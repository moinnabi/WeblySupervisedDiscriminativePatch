function displayExamplesPerAspect_kmeans_overIt(objname, outdir)
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
%mymkdir([resdir filesep objname]);
%disp('here'); keyboard;
    
imodel=load([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos', 'validInds');
rmodel=load([outdir filesep objname '_random.mat'], 'models');
hmodel=load([outdir filesep objname '_hard.mat'], 'model');
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
pp=0;

if 0
% DISP COMPUTE STATISTICS OF CLUSTER MEMBERSHIP CHANGES    
unids = unique(imodelinds);
clusInds = cell(length(unids),1);
for k=1:length(unids)
    clusInds{unids(k)} = find(imodelinds == unids(k));
end

tmodelinds = hmodel.model.posclusinds{pp+1};
tmodelinds = tmodelinds(posI);
unids = unique(tmodelinds);
unids(unids == 0) = [];
clusInds2 = cell(length(unids),1);
chngInClMembs = zeros(length(unids),1);
commonClMembs = zeros(length(unids),1);
for k=1:length(unids)
    clusInds2{unids(k)} = find(tmodelinds == unids(k));
    chngInClMembs(unids(k)) = numel(setdiff(clusInds{unids(k)}, clusInds2{unids(k)}));
    commonClMembs(unids(k)) = numel(intersect(clusInds{unids(k)}, clusInds2{unids(k)}));
end
end

disp('printing');
[mim{1} mimg_all{1} mlab_all{1}] = getMontageImg(imodelinds, warped, spos, numToDisplay);
[mim{2} mimg_all{2} mlab_all{2}] = getMontageImg2(hmodel.model.posclusinds{pp+1}, warped, pos, numToDisplay, posI, cat(2,hmodel.model.numnegs{pp+1,:}));
[mim{3} mimg_all{3} mlab_all{3}] = getMontageImg2(hmodel.model.posclusinds{pp+2}, warped, pos, numToDisplay, posI, cat(2,hmodel.model.numnegs{pp+2,:}));
[mim{4} mimg_all{4} mlab_all{4}] = getMontageImg2(hmodel.model.posclusinds{pp+3}, warped, pos, numToDisplay, posI, cat(2,hmodel.model.numnegs{pp+3,:}));

[nr nc d]=size(mim{1});
mimg = [mim{1} zeros(nr, 10, 3) mim{2};
    zeros(10, 10+2*nc, 3);...
    mim{3} zeros(nr,10,3) mim{4}];
imwrite(mimg, [resdir '/finalMontage.jpg']);

disp('here'); keyboard;
if length(mimg_all{1}) == length(mimg_all{2})-1   % zero ind
    for k=1:length(mimg_all{1})
        myprintf(k);
        allimgs{1} = mimg_all{1}{k}; alllabs{1} = mlab_all{1}{k};
        allimgs{2} = mimg_all{2}{k+1}; alllabs{2} = mlab_all{2}{k+1};
        allimgs{3} = mimg_all{3}{k+1}; alllabs{3} = mlab_all{3}{k+1};
        allimgs{4} = mimg_all{4}{k+1}; alllabs{4} = mlab_all{4}{k+1};
        allmim{k} = montage_list_w_text2(allimgs, alllabs, 2, [], [], [1500 1500 3]);
        allmlab{k} = num2str(k);        
    end
end
mimg = montage_list_w_text2(allmim, allmlab, 2, [], [], [2500 2500 3]);
imwrite(mimg, [resdir '/finalMontage_perComp.jpg']);

catch
    disp(lasterr); keyboard;
end

function [mim mimg mlab] = getMontageImg(inds, warped, spos, numToDisplay)

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

function [mim mimg mlab] = getMontageImg2(inds, warped, spos, numToDisplay, posI, numnegs)

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
    if unids(jj) ~=0 
    mlab{jj} = [num2str(numel(A)) ' - ' num2str(numnegs(unids(jj,:)))];
    else
        mlab{jj} = num2str(numel(A));
    end
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;


function [mim mimg mlab] = getMontageImg3(inds, warped, spos, numToDisplay)

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
