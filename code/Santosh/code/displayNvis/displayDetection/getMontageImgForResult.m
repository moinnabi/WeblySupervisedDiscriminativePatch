function mimg = getMontageImgForResult(thisresult, imgdir, nImgMont, ids, intensty, resolutn)

if nargin < 6
    resolutn = [5000 5000 3];
end

if isempty(thisresult)
    mimg = zeros(10,10,3);
    return;
end

% get sorted inds
allScores = cat(1, thisresult.scores);
allLabels = cat(1, thisresult.labels);
imgIds = getImgsIds(thisresult);
bboxes = cat(1,thisresult.bbox);
%cumScCnts = getCumSumCnts(thisresult);

if 0, labinds = find(allLabels == 1);
else labinds = 1:length(allLabels); end
allScores = allScores(labinds,:);
allLabels = allLabels(labinds,:);
imgIds = imgIds(labinds,:);
bboxes = bboxes(labinds,:);

[allScores, sInds] = sort(allScores, 'descend');
imgIds = imgIds(sInds, :);
bboxes = bboxes(sInds, :);
allLabels = allLabels(sInds,:);

flipbool = 0;
if 2*length(ids) == numel(thisresult) 
    flipbool = 1;
end

%resimg = cell(nImgMont,1); ressc = cell(nImgMont,1);
resimg = []; ressc = [];
k = 1;
for j=1:min(nImgMont,length(imgIds))
    myprintf(j, 10);    
    if imgIds(j) > numel(ids) && flipbool
        imgname = [imgdir '/' ids{imgIds(j)-length(ids)} '.jpg'];
        img = imread(imgname);
        img = img(:,end:-1:1,:);
    else
        imgname = [imgdir '/' ids{imgIds(j)} '.jpg'];
        img = imread(imgname);
    end 
    resimg{k} = draw_box_image(img, bboxes(j,:), intensty);
    ressc{k} = [num2str(j) ' (' num2str(allScores(j)) ' ' num2str(allLabels(j))  ' ' num2str(imgIds(j))  ')'];
    k = k+1;
end
myprintfn;

if exist('resimg', 'var')
    mimg = montage_list_w_text2(resimg, ressc, 2, [], [1 1 1], resolutn);
end
