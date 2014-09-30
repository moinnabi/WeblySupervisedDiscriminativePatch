function result = getSceneMatches_im(queryImg, imdir)

% computes the scene matches for given test image feature vector(s)
% 'testfeat' to all the train image feature vectors 'trainfeats' and
% returns the 'result'
% testfeat = n1 x m matrix and trainfeats = n2 x m matrix
% where n1 = #testimages, n2 = #trainimages, m = #dimensions
% result = n1 x n2 matrix where for each row contains the scene matches for
% a given test image

imdir = '/nfs/hn12/sdivvala/Datasets/Pascal_VOC/VOC2007/JPEGImages/';
imlist = mydir([imdir '/*.jpg']);
% read all images
imgcell = cell(length(imlist),1);
for i=1:length(imgcell)
    myprintf(i);
    imgcell{i} = imread([imdir '/' imlist{i}]);
end

queryImg = imread('/nfs/hn12/sdivvala/partsBasedObjDet/code/temphorse/horse1.jpg');
[ht wd dep] = size(queryImg);
queryImg = imresize(queryImg, 500/max(ht,wd)); 

diff = zeros(length(imgcell),1);
for i=1:length(imgcell)
    myprintf(i,1000);
    if sum(size(queryImg)) == sum(size(imgcell{i}))
        diff(i) = sqrt(sum((queryImg(:) - imgcell{i}(:)).^2));
    end
end


result = zeros(size(testfeat,1), size(trainfeats,1), 'single');
for i=1:size(testfeat,1)    % for each test image vector
    result(i,:) = distSqr_fast(testfeat(i,:)',trainfeats');
end   