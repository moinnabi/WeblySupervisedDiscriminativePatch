function displayExamplesPerAspect_kmeans_v2(objname, outdir)
%multimachine_warp('displayExamplesPerAspect', 20, resdir, 2)

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';

VOCopts = VOCinit;
myClasses = VOCopts.classes;

if 0
objname = myClasses{19};
outdir = fullfile(basedir, 'results', 'uoctti_models', 'release3_retrained', '2007', objname, [objname '_kmeanssplit_5_simple'], 'test', 'candidates');
else
outdir = fullfile(outdir, '..', '..');
end
resdir = [outdir filesep 'display/']; mymkdir(resdir);

numToDisplay = 49;

disp(['Processing Class ' objname]);
%mymkdir([resdir filesep objname]);
%disp('here'); keyboard;
    
try
    load([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos', 'validInds');
catch
    try
        load([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos');
        load([outdir filesep objname '_random'], 'models');
        for i=1:length(models)
            validInds{i} = mygetValidInds(objname, models{i}, 1, spos{i});
        end
        %save([outdir filesep objname '_displayInfo2.mat'], 'validInds');
    catch
        disp('do the clustering?'); keyboard;
        numComp = 3;
        numClustersPerSplit = 2;
        [pos, neg] = pascal_data(cls, outdir);
        spos = split(pos, numComp);
        for i=1:numComp
            disp(['processing component ' num2str(i)]);
            models_tmp = initmodel(spos{i});
            warped{i} = warppos(cls, models_tmp, 1, spos{i});
            %inds{i} = lrsplit(models_tmp, spos{i}, i, warped{i});
            inds{i} = mylrsplit_kmeans(models_tmp, spos{i}, warped{i}, i, numClustersPerSplit);
        end
        save([outdir filesep objname '_displayInfo.mat'], 'inds', 'warped', 'spos');
    end
end

disp('printing');
for k=1:numel(inds)
    myprintf(k);
    savename = [resdir filesep 'img_kmeans' num2str(length(unique(inds{1}))) '_' num2str(k) '.jpg'];
    if ~exist(savename, 'file')
        inds{k} = inds{k} .* (inds{k} & validInds{k});
        unids = unique(inds{k});
        for jj = 1:length(unids)
            A = find(inds{k} == unids(jj));
            %A = find(inds{k} == unids(jj) & validInds{k});
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
        imwrite(mim, savename);            
    end
end
myprintfn;   

catch
    disp(lasterr); keyboard;
end
