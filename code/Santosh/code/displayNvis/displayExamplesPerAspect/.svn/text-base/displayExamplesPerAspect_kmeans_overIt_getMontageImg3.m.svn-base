function [mim mimg pos]= displayExamplesPerAspect_kmeans_overIt_getMontageImg3...
    (resdir_testImgs, imgdir, numToDisplay)

% in this version, I load results spit by a detector and then show top
% detections per component as a montage to get  a sense of how well each
% component is doing

try
intensty = [255 0 0];

disp(' loading results');
fn = mydir([resdir_testImgs '/*.mat']);
for k = 1:numel(fn)
    myprintf(k,100);
    tmp = load([resdir_testImgs '/' strtok(fn{k}, '.') '.mat'], 'result');
    if ~strcmp(strtok(fn{k}, '.'), tmp.result.imname), disp('problem here'); keyboard; end
    result(k).imname = strtok(fn{k}, '.');
    numboxes = size(tmp.result.bbox,1);
    minBoxesToConsider = numboxes;                  % consider all boxes
    result(k).bbox = tmp.result.bbox(1:minBoxesToConsider,:);
    result(k).comp = tmp.result.comp(1:minBoxesToConsider,:);
    result(k).scores = tmp.result.scores(1:minBoxesToConsider,:);
end
myprintfn;

allcomp = cat(1,result(:).comp);
allbbox = cat(1,result(:).bbox);
allscores = cat(1,result(:).scores);
imgIds = getImgsIds(result);

uncomps = unique(allcomp);
pos = [];
numpos = 0;
for jj = 1:length(uncomps)
    myprintf(jj);
    
    thisinds = find(allcomp == uncomps(jj));
    thisscores = allscores(thisinds);
    thisboxes = allbbox(thisinds,:);
    thisimgIds = imgIds(thisinds);
    
    % select few to display
    thisNum = min(numToDisplay, numel(thisinds));
    allimgs = cell(thisNum,1); alllabs = cell(thisNum,1);
    [sval sinds] = sort(thisscores, 'descend');
    selInds = sinds(1:thisNum);
    thisscores = thisscores(selInds);
    thisboxes = thisboxes(selInds,:);
    thisimgIds = thisimgIds(selInds);
    
    for j=1:thisNum
        imgname = [imgdir '/' result(thisimgIds(j)).imname '.jpg'];                
        tmpim = draw_box_image(color(imread(imgname)), thisboxes(j,:), intensty);
        %allimgs{j} = draw_box_image(color(imread(imgname)), thisboxes(j,:), intensty);
        allimgs{j} = croppos(tmpim, thisboxes(j,:));    % just get cropped piece around displayed bbox rather than entire image                
                
        [blah imname] = myStrtokEnd(result(thisimgIds(j)).imname, '_'); % update for imagenet imnames
        alllabs{j} = [num2str(thisscores(j)) ' ' imname];
        
        numpos = numpos+1;
        pos(numpos).im = imgname;        
        pos(numpos).x1 = single(thisboxes(j,1));
        pos(numpos).y1 = single(thisboxes(j,2));
        pos(numpos).x2 = single(thisboxes(j,3));
        pos(numpos).y2 = single(thisboxes(j,4));
        pos(numpos).flip = false;
        pos(numpos).comp = single(uncomps(jj));
        pos(numpos).score = single(thisscores(j));
    end
    mimg{jj} = montage_list_w_text2(allimgs, alllabs, 2);
    mlab{jj} = num2str(numel(thisinds));    
end
mim = montage_list_w_text2(mimg, mlab, 2, [], [], [3000 3000 3]);
myprintfn;

catch
    disp(lasterr); keyboard;
end
