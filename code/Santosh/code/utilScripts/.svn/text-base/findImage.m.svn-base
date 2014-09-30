function imId = findImage(VOCopts, inputIm)

disp('Loading Features');    

disp('THIS IS UNNECESSARY DOING GIST HERE; IF ITS DUPLICATE IMAGE SEARCH, JUST DO SSD');
allIds = textread(sprintf(VOCopts.imgsetpath, 'test'),'%s');
% allData = loadFeatForImgCl(allIds, 'gist', VOCopts.dataPath, VOCopts);  
% nblocks = 4;
% orientPerScale = [8 8 8 8];
% thisGist = im2gist(inputIm, nblocks, orientPerScale);
% tmp = rgb2lab(imresize(inputIm, [nblocks nblocks], 'bilinear'));    %% Add color info
% thisGist = [tmp(:) ; thisGist(:)];

%VOCopts.imgpath=[VOCopts.datadir VOCopts.dataset '/JPEGImages/%s.jpg'];


for i=1:length(allIds)
    im = imread(sprintf(VOCopts.imgpath, allIds{i}));
    %diffMat(i) = allData - repmat(thisGist', size(allData,1), 1);
    diffIm = im - inputIm;
    diffVal(i) = sqrt(sum(sum(sum(diffIm.^2))));
end
%diffInd = sqrt(sum(diffMat.^2,2));
[blah closestInd] = min(diffVal);
imId = allIds(closestInd);

