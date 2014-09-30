function printImagesTogether_4(myOpts, resdir1, resdir2)

if isempty(resdir1)
    %resdir1 = [myOpts.resdir '/objectDetections/hardNegCandidates_LabelMeSubsetPersonNegImgs/hardNegImgs/'];
    %resdir2 = [myOpts.resdir '/objectDetections_context/hardNegCandidates_LabelMeSubsetPersonNegImgs/'];
    %resdir1 = [myOpts.resdir '/testing/detections_HOG_bigppl_context_labelMeTrain/test1/'];
    resdir1 = [myOpts.resdir '/detectionWithContext/labelMeSubset_WithPerson_144/UoCTTI_smallppl_train4_10it_specialTestingMode/top200Detections/'];
    resdir2 = [myOpts.resdir '/detectionWithContext/labelMeSubset_WithPerson_144/UoCTTI_smallppl_train4_context3_10it_run2a/top200Detections/'];
    %resdir3 = [myOpts.resdir '/detectionWithContext/labelMeSubset_WithPerson_144/UoCTTI_smallppl_train4_context3_correctTestSet_025overlapWithGtruth_075nms_200perImg/top200Detections/'];
    %resdir4 = [myOpts.resdir '/detectionWithContext/50_144_09_test/HOG_smallppl_train4_context3_run1_writeCandNotSorted/images/'];    
    resdir4 = [myOpts.datadir '/labelMe/labelMeSubset_WithPerson_144_gtruth/'];
end
%ids=textread(sprintf(myOpts.imgsetpath, 'val'),'%s');
%ids = load([myOpts.datadir '/INRIAPerson/imnames_INRIAPerson_neg.mat'],'fn');
ids = dir([resdir4 '/*.jpg']);
ids = {ids(:).name};
outdir = [resdir2 '/../top200_3/'];
mymkdir(outdir);
for i=1:numel(ids)
    fprintf('%d ', i);
    fname1 = [resdir1 '/' ids{i}];
    fname2 = [resdir2 '/' ids{i}];
    %fname3 = [resdir3 '/' ids{i}];
    fname4 = [resdir4 '/' ids{i}];
    %gtname = [gtdir '/' ids{i}];
    resname = [outdir '/' ids{i}];    
    if 1 %(exist(fname1,'file') && exist(fname2,'file'))
        im4 = imread(fname4);
        if exist(fname1,'file')
        im1 = imread(fname1);
        else
        im1 = ones(size(im4)); %imread(fname3);    
        end
        if exist(fname2,'file')
        im2 = imread(fname2);
        else
        im2 = ones(size(im1)); %imread(fname3);
        end
        im3 = ones(size(im1)); %imread(fname3);
                            
        %gim = imread(gtname);
        if ~all(size(im1) ~= size(im2))
            imsize = size(im1);
            im2 = imresize(im2, imsize([1 2]));
            im4 = imresize(im4, imsize([1 2]));
        end
        %im = [im1 ones(size(im1,1),10,3) im2];
        im = [im1 ones(size(im1,1),10,3) im2; ones(10,2*size(im1,2)+10,3); im3 ones(size(im1,1),10,3) im4 ];
        %im = [im1 ones(size(im1,1),10,3) im2 ones(size(im1,1),10,3) gim; ...
        %    ones(10,3*size(im1,2)+20,3); ...
        %    im3 ones(size(im1,1),10,3) im4  ones(size(im1,1),10,3) zeros(size(gim))];
        if (exist(fname1,'file') || exist(fname2,'file'))
        imwrite(im, resname);
        end
    elseif exist(fname1,'file')
        im1 = imread(fname1);
        im = [im1 ones(size(im1,1),10,3) ones(size(im1))];
        imwrite(im, resname);
    elseif exist(fname2,'file')
        im2 = imread(fname2);
        im = [ones(size(im2)) ones(size(im2,1),10,3) im2];
        imwrite(im, resname);
    end
end
