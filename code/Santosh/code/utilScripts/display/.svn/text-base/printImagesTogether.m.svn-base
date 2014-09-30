function printImagesTogether(myOpts, resdir1, resdir2)

if isempty(resdir1)
    resdir1 = [myOpts.resdir_baikal '/classification/outputWithClassification/images_original/'];
    resdir2 = [myOpts.resdir_baikal '/classification/outputWithClassification/images_confidentRegionsOnly_vhVariable/'];
    resdir3 = [myOpts.resdir '/gc_results/weightedDistances/weightedDistances_5imgs_60K_gcsig5_gist3/' ...
        'weightedDistances_5imgs_60K_gcsig5_gist3_diffDisplay/'];        
    resdir4 = [myOpts.resdir_baikal '/localPrior/diffDisplay/'];    
end

gtdir = [myOpts.datadir '/all_images_gTruth/GConGCimages_gTruth/'];

imageDir = resdir3;
ids = dir([imageDir '/*.jpg']);
ids = {ids(:).name};
outdir = [resdir4 '/../localVsglobal/'];
mymkdir(outdir); 

for i=1:numel(ids)
    fprintf('%d ', i);
    fname1 = [resdir1 '/' ids{i}];
    fname2 = [resdir2 '/' ids{i}]; 
    fname3 = [resdir3 '/' ids{i}]; 
    fname4 = [resdir4 '/' ids{i}]; 
    gtname = [gtdir '/' strtok(ids{i},'.') '_gTruth.jpg'];
    resname = [outdir '/' strtok(ids{i}, '.') '.jpg'];
    bool = 0;
    gtbool = 0;
    
    if(exist(fname1,'file') && exist(fname2,'file'))
        im1 = imread(fname1);
        im2 = imread(fname2);        
        im3 = imread(fname3);        
        im4 = imread(fname4);        
        if ~all(size(im1) ~= size(im2))
            imsize = size(im1);
            im2 = imresize(im2, imsize([1 2]));
        end
        bool = 1;
    elseif exist(fname1,'file')
        im1 = imread(fname1);
        im2 = ones(size(im1));
        bool =1;
    elseif exist(fname2,'file')
        im2 = imread(fname2);
        im1 = ones(size(im2));
        bool = 1;
    end
    
    if exist(gtname,'file')
        gim = imread(gtname);
        gtbool=1;
        if bool == 0
            im1=ones(size(gim));
            im2 =im1;
        end
    elseif bool == 1
        gim = ones(size(im1));        
    end
    
    if bool == 1 
    im = [im1 ones(size(im1,1),10,3) gim ones(size(im1,1),10,3) im2; ...
        ones(10,3*size(im1,2)+20,3); ...
        im3 ones(size(im1,1),10,3) im4 ones(size(im1,1),10,3) ones(size(im2))];    
    %im = [im1 ones(size(im1,1),10,3) im2; ...
    %    ones(10,2*size(im1,2)+10,3); ...
    %    gim ones(size(im1,1),10,3) im3];
        %gim ones(size(im1,1),10,3) zeros(size(gim))];
    %im = [im1 ones(size(im1,1),10,3) im2];
    imwrite(im, resname);
    end
    
    %{
    if bool
        im = [im1 ones(size(im1,1),10,3) im2];
        imwrite(im, resname);
    end
      %}  
end
