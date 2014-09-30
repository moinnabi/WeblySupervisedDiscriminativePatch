function compinfo = displayDetection_rankedMontages2(objname, testset, cachedir, cachedir_base, VOCyear)
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

%nImgMont = 50;
totalNimg = 25;
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

uncomps = unique(allComps);

compinfo = zeros(max(uncomps),2); 
for i=uncomps(:)'
    myprintf(i);
    thisCompIds = find(allComps == i);
    thisScores = allScores(thisCompIds);    
    thisImgIds = imgIds(thisCompIds);
    thisBoxes = bboxes(thisCompIds,:);
    thisLabels = allLabels(thisCompIds);
        
    resimg = []; ressc = [];
    %k = 1;
    for j=1:min(totalNimg,length(thisImgIds))
        %myprintf(j);
        imgname = [imgdir '/' ids{thisImgIds(j)} '.jpg'];        
        resimg{j} = draw_box_image(imread(imgname), thisBoxes(j,:), intensty);        
        %ressc{k} = [num2str(j) ' (' num2str(allComps(j)) ' ' num2str(allScores(j), '%1.3f') ' ' num2str(allLabels(j))  ' ' num2str(imgIds(j))  ')'];
        ressc{j} = [num2str(j) ' (' num2str(thisCompIds(j)) ' '  num2str(thisScores(j), '%1.3f') ' ' num2str(thisLabels(j))  ' ' num2str(thisImgIds(j))  ')'];
        if thisLabels(j) == -1 && compinfo(i,1) == 0    
            % record the first incorrect index for this subcategory
            compinfo(i,1) = j;
            compinfo(i,2) = thisCompIds(j);
        end
    end
    mimg = montage_list_w_text2(resimg, ressc, 2, [], [1 1 1], [1000 1000 3]);
    imwrite(mimg, [detressavedir '/' ftag '_' num2str(i,'%02d')  '.jpg']);
end
myprintfn;
save([cachedir '/rankedMontages/compresinfo.mat'], 'compinfo');

if ~strcmp(cachedir, cachedir_base)
    disp('merging images'); 
    for i=uncomps(:)'
        try
        mimg1 = imread([cachedir  '/rankedMontages/' ftag '_' num2str(i,'%02d')  '.jpg']);
        mimg2 = imread([cachedir_base '/rankedMontages/' ftag '_' num2str(i,'%02d')  '.jpg']);
        mimg = myCombineNimgs(mimg1, mimg2);
        imwrite(mimg, [cachedir '/rankedMontages/withBase_' ftag '_' num2str(i,'%02d')  '.jpg']);
        myprintf(i);
        end
    end
    myprintfn;
    
    compareResults_visualization(cachedir, cachedir_base, objname, testset)
end

catch
    disp(lasterr); keyboard;
end
