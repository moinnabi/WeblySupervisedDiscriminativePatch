function displayDetection_rankedMontages_perComp(objname, testset, cachedir, cachedir_base, VOCyear)

% from displayDetection_rankedMontages_perComp
try
%cls = objname;
%disp(objname);
%globals;
%pascal_init;
%if ~strcmp(VOCyear(1:3), 'VOC'), VOCyear = ['VOC' VOCyear]; end

VOCopts = myVOCinit(VOCyear);

detressavedir = [cachedir '/rankedMontages/']; mkdir(detressavedir);
imgdir = fullfile(VOCopts.datadir, VOCyear, 'JPEGImages');
ids = textread(sprintf(VOCopts.imgsetpath, testset), '%s');

% note: on 26Feb12, i changed the meaning of result_comp; its now on per
% subcatnms with no global nms performed
if 0
load([cachedir objname '_' testset '_result_comp_nms.mat'], 'result_comp', 'roc_comp');
ftag = 'comp_nms';
%catch
else
load([cachedir objname '_' testset '_result_comp.mat'], 'result_comp', 'roc_comp');
ftag = 'comp';
end
disp(ftag);

nImgMont = 25;
intensty = [255 0 0];

%if ~exist([detressavedir '/' num2str(length(result_comp)) ftag '.jpg'], 'file') || 1 
for f = 1:length(result_comp)    
    savename = [detressavedir '/' num2str(f,'%02d') ftag '.jpg'];
    if ~exist(savename, 'file') || 1        
        disp(['Processing component ' num2str(f)]);
        thisresult = result_comp{f};
        mimg = getMontageImgForResult(thisresult, imgdir, nImgMont, ids, intensty, [1500 1500 3]);
        if exist('mimg', 'var')
            imwrite(mimg, savename);
        end
    end
end

if ~strcmp(cachedir, cachedir_base)
    disp('merging images'); 
    for f=1:length(result_comp)
        myprintf(f);
        try
        mimg1 = imread([cachedir  '/rankedMontages/' num2str(f,'%02d') ftag '.jpg']);
        mimg2 = imread([cachedir_base '/rankedMontages/' num2str(f,'%02d') ftag '.jpg']);
        mimg = myCombineNimgs(mimg1, mimg2);
        imwrite(mimg, [cachedir '/rankedMontages/withBase_' num2str(f,'%02d') ftag '.jpg']);
        end
    end
    myprintfn;
end

plotfname = [detressavedir '/roc_per' ftag '.jpg']; 
%if ~exist(plotfname,'file') 
    disp('printing roc plot');
    tmproc.roc_comp = roc_comp;
    printPlotPerComp(tmproc, plotfname); 
%end

%end

catch
    disp(lasterr); keyboard;
end
