function displayExamplesPerAspect_kmeans
%multimachine_warp('displayExamplesPerAspect_kmeans', 20, resdir, 2)

try
basedir = '/nfs/hn12/sdivvala/partsBasedObjDet/';
resdir = [basedir filesep 'results/UoCTTIaspects_release3/display/']; mymkdir(resdir);

VOCopts = VOCinit;
myClasses = VOCopts.classes;
numToDisplay = 49;

n = 3;
numClustersPerSplit = 4;
%numClustersPerSplit = 2;

mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(myClasses));
%for f = 1:numel(myClasses)
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end         
    
    objname = myClasses{f};
    disp(['Processing Class ' objname]);
    mymkdir([resdir filesep objname]);
    
    outdir = [basedir filesep 'results/UoCTTIaspects_release3/' objname filesep];
    load([outdir filesep 'warpedInfo.mat'], 'warped', 'models', 'spos');
    load([outdir filesep 'leftRightInfo_kmeans4.mat'], 'Idx');
    %load([outdir filesep 'leftRightInfo_pedroLR.mat'], 'Idx');
    
    for k=1:numel(Idx)
        %disp(['Processing aspect ' num2str(k)]);
        myprintf(k);
        %uncnts = uniqueCounts(Idx{k});
        %fname = [num2str(uncnts(1)) '_' num2str(uncnts(2)) '_' num2str(uncnts(3)) '_' num2str(uncnts(4))];
        savename = [resdir filesep objname filesep 'img_kmeans_' num2str(numClustersPerSplit) '_' num2str(k) '.jpg'];
        %savename = [resdir filesep objname filesep 'img_lrsplit' '_' num2str(k) '.jpg'];
        if ~exist(savename, 'file')            
            for jj = 1:numClustersPerSplit
                A = find(Idx{k} == jj);
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
            %mim = [mimg{1} zeros(size(mimg{1},1),10,3) mimg{2};...
            %    zeros(10, size(mimg{1},2)*2+10,3);...
            %    mimg{3} zeros(size(mimg{1},1),10,3) mimg{4}];            
            %mim = montage_list_w_text2(mimg, mlab, 2);
            %mim = montage_list(mimg,2, [0 0 0], [1500 1500 3]);   
            mim = montage_list_w_text2(mimg, mlab, 2, [], [], [1500 1500 3]);
            imwrite(mim, savename);            
        end
    end
    myprintfn;
   
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end

function uncnts = uniqueCounts(Idx)

unids = unique(Idx);
uncnts = zeros(length(unids),1);
for i=1:length(unids)
    uncnts(i) = length(find(Idx == unids(i)));
end
