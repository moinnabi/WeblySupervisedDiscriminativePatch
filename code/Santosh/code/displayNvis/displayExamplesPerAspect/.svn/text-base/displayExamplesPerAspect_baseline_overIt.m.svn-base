function displayExamplesPerAspect_baseline_overIt(objname, outdir)
%multimachine_warp('displayExamplesPerAspect', 20, resdir, 2)

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';

VOCopts = VOCinit;
myClasses = VOCopts.classes;

%objname = myClasses{16};
%outdir = fullfile(basedir, 'results', 'uoctti_models', 'release3_retrained', '2007', objname, [objname '_myPedroCode_noParts'], 'test', 'candidates');
outdir = fullfile(outdir, '..', '..');
resdir = [outdir filesep 'display/']; mymkdir(resdir);

numToDisplay = 25;

disp(['Processing Class ' objname]);
%mymkdir([resdir filesep objname]);
%disp('here'); keyboard;
    
imodel=load([outdir filesep '../' [objname '_kmeanssplit_4'] '/' objname '_displayInfo.mat'], 'warped', 'spos');
rmodel=load([outdir filesep objname '_random.mat'], 'models');
hmodel=load([outdir filesep objname '_hard.mat'], 'model');
fmodel=load([outdir filesep objname '_mine.mat'], 'model');
load([outdir '/' objname '_train'], 'pos');
[spos posindx] = split(pos, 3);

clear imodelinds warped spos;
warped = imodel.warped{1};
spos = imodel.spos{1};
posI = posindx{1};
for k=2:length(imodel.warped)
    warped = [warped;  imodel.warped{k}];
    spos = [spos  imodel.spos{k}];
    posI = [posI; posindx{k}];
end

rmodelinds = ones(size(imodel.spos{1}))';
for k=2:length(rmodel.models)    
    rmodelinds = [rmodelinds; k*ones(size(imodel.spos{1}))'];
end

disp('printing');
mim{1} = getMontageImg(rmodelinds, warped, spos, numToDisplay);
mim{2} = getMontageImg2(hmodel.model.posclusinds{end}, warped, pos, numToDisplay, posI);
mim{3} = getMontageImg2(fmodel.model.posclusinds{end}, warped, pos, numToDisplay, posI);

[nr nc d]=size(mim{1});
mimg = [mim{1} zeros(nr, 10, 3) mim{2};
    zeros(10, 10+2*nc, 3);...
    mim{3} zeros(nr,10,3) zeros(size(mim{1}))];
imwrite(mimg, [resdir '/finalMontage.jpg']);

catch
    disp(lasterr); keyboard;
end

function mim = getMontageImg(inds, warped, spos, numToDisplay)

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

function mim = getMontageImg2(inds, warped, spos, numToDisplay, posI)

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
    mlab{jj} = num2str(numel(A));
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
myprintfn;


function mim = getMontageImg3(inds, warped, spos, numToDisplay)

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
