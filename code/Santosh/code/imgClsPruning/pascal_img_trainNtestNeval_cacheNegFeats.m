function pascal_img_trainNtestNeval_cacheNegFeats(cachedir, inpfname, VOCyear, objname, imgannodir)
% from pascal_img_train
% 9Jul13: disp('check getFeatures function'); keyboard; checked it; issue
% was with doMode; i set it to 1; i want coarse features; fine res features
% might lead to overfitting

try

disp(['pascal_img_trainNtestNeval_cacheNegFeats(''' cachedir ''',''' inpfname ''',''' VOCyear ''',''' objname ''',''' imgannodir ''')' ]);
 
conf = voc_config('paths.model_dir', 'blah');
fsize = conf.threshs.fsize_fastImgClfr;
sbin = conf.threshs.sbin_fastImgClfr;
featExtMode = conf.threshs.featExtMode_imgClfr;

fsize = [fsize fsize];
%fsize = [10 10];
%sbin = 8;
%featExtMode = 1;
biasval = 1;

mymatlabpoolopen;

try
    tmp = load([cachedir '/negData_train.mat'], 'negData');
    tmp.negData(1);
catch    
    fprintf('Caching negative features :: Train\n');    
    [ids, gt] = textread([imgannodir '/ImageSets/voc/' objname '_train.txt'], '%s %d');
    ids = ids(gt == -1);
    neg = [];
    for i = 1:length(ids)        
        neg(i).im = [imgannodir '/JPEGImages/' ids{i} '.jpg'];
        neg(i).flip = false;
    end    
    feats = getHOGFeaturesFromWarpImg(neg, fsize, sbin, biasval, featExtMode);
    %{
    disp('reading images');    
    %warped = warppos_img(neg, fsize, sbin);
    warped = warppos_img_noBdrAdded(neg, fsize, sbin);
    disp('computing features');
    feats = cell(length(neg),1);
    for i = 1:length(neg)
        myprintf(i,100);
        hogfeat = features(double(warped{i}), sbin);
        hogfeat2 = features(double(warped{i}), sbin/2);
        feats{i} = [hogfeat(:); hogfeat2(:); biasval];
    end
    myprintfn;
    %}
    negData = cat(2, feats{:})';        
    save([cachedir '/negData_train.mat'], 'negData');
    %negData_train = negData;
end

try
    tmp = load([cachedir '/negData_test.mat'], 'negData');    
    tmp.negData(1);
catch
    fprintf('Caching negative features :: Test\n');
    [ids, gt] = textread([imgannodir '/ImageSets/voc/' objname '_test.txt'], '%s %d');
    ids = ids(gt == -1);
    neg = [];
    for i = 1:length(ids);        
        neg(i).im = [imgannodir '/JPEGImages/' ids{i} '.jpg'];
        neg(i).flip = false;
    end            
   feats = getHOGFeaturesFromWarpImg(neg, fsize, sbin, biasval, featExtMode);
    %{
    %warped = warppos_img(neg, fsize, sbin);
    warped = warppos_img_noBdrAdded(neg, fsize, sbin);
    disp('computing features');
    feats = cell(length(neg),1);
    for i = 1:length(neg)
        myprintf(i,100);
        hogfeat = features(double(warped{i}), sbin);
        hogfeat2 = features(double(warped{i}), sbin/2);
        feats{i} = [hogfeat(:); hogfeat2(:); biasval];
    end        
    myprintfn;
    %}
    negData = cat(2, feats{:})';
    save([cachedir '/negData_test.mat'], 'negData');
    %negData_test = negData;
end

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end
