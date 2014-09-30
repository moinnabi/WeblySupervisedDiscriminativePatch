function displayDetection_rankedMontages(objname, testset, cachedir, VOCyear)
% from displayDetection_rankedMontages_perComp

try
%cls = objname;
%disp(objname);
%globals;
%pascal_init;
VOCopts = myVOCinit(VOCyear);

detressavedir = [cachedir '/rankedMontages/']; mkdir(detressavedir);
imgdir = fullfile(VOCopts.datadir, VOCyear, 'JPEGImages');
ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

try
tmp1 = load([cachedir objname '_' testset '_result.mat'], 'result_nms', 'roc_nms');
result = tmp1.result_nms;
roc = tmp1.roc_nms;
ftag ='all_nms';
catch
load([cachedir objname '_' testset '_result.mat'], 'result', 'roc');
ftag ='all';
end

nImgMont = 50;
totalNimg = 200;
intensty = [255 0 0];

disp(' displaying results');
thisresult = result;

% get sorted inds
allScores = cat(1, thisresult.scores);
allLabels = cat(1, thisresult.labels);
allComps = cat(1, thisresult.comp);
imgIds = getImgsIds(thisresult);
bboxes = cat(1,thisresult.bbox);
%cumScCnts = getCumSumCnts(thisresult);

%labinds = find(allLabels == 1);
if 0, labinds = find(allLabels == 1);
else labinds = 1:length(allLabels); end

allScores = allScores(labinds,:);
allLabels = allLabels(labinds,:);
allComps = allComps(labinds,:);
imgIds = imgIds(labinds,:);
bboxes = bboxes(labinds,:);

[allScores, sInds] = sort(allScores, 'descend');
imgIds = imgIds(sInds, :);
bboxes = bboxes(sInds, :);
allLabels = allLabels(sInds,:);
allComps = allComps(sInds,:);

%resimg = cell(nImgMont,1); ressc = cell(nImgMont,1);
resimg = [];
ressc = [];
k = 1;
for j=1:min(totalNimg,length(imgIds))
    myprintf(j);
    imgname = [imgdir '/' ids{imgIds(j)} '.jpg'];
    resimg{k} = draw_box_image(imread(imgname), bboxes(j,:), intensty);
    rankind = find(find(allComps == allComps(j)) == j); 
    %ressc{k} = [num2str(j) ' (' num2str(allComps(j)) ' ' num2str(allScores(j), '%1.3f') ' ' num2str(allLabels(j))  ' ' num2str(imgIds(j))  ')'];
    ressc{k} = [num2str(rankind) ' (' num2str(allComps(j)) ' ' num2str(allScores(j), '%1.3f') ' ' num2str(allLabels(j))  ' ' num2str(imgIds(j))  ')'];
    if k == nImgMont
       mimg = montage_list_w_text2(resimg, ressc, 2, [], [1 1 1], [5000 5000 3]);
       imwrite(mimg, [detressavedir '/' ftag '_' num2str(j-nImgMont+1, '%03d') '-' num2str(j, '%03d') '.jpg']);
       k=1;
       clear resimg ressc;
       continue;
    else
    k = k+1;
    end
end
myprintfn;

plotfname = [detressavedir '/roc_' ftag '.jpg']; 
%if ~exist(plotfname,'file') 
    disp('printing roc plot');
    plotROC(roc);
    saveas(gcf, plotfname);
%end

catch
    disp(lasterr); keyboard;
end
