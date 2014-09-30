function [posData, posData_val] = findNearDuplicates_cacheFeats(inpdir, objname, jpgimagedir, imgsetdir, dtype) %, dpsbin, fsize)
% HOG based dup detection

try

conf = voc_config('paths.model_dir', 'blah');
dpsbin = conf.threshs.sbin_dupDtn;
fsize = conf.threshs.fsize_dupDtn;

%dpsbin = 4;
%fsize = [20 20];
%%%hogchi2ThisDimThresh = 0.15;
fsize = [fsize fsize];

mymatlabpoolopen;

try
    load([inpdir '/posData_train.mat'], 'posData_bit', 'medVal');
catch
    disp('extract features: train');
    tic;
    [ids_train, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_val1_withLabels.txt'], '%s %d');    % 'train' is gotten thru 'val1'
    ids_train = ids_train(gt==1);
    clear pos;
    for i=1:length(ids_train)
        pos(i).im = [jpgimagedir '/' ids_train{i}  '.jpg'];
        pos(i).flip = 0;
    end
    feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
    for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end  % normalize (to keep consistent with chisq)
    posData = single(cat(2, feats{:})');
    disp(size(posData));
    toc;
        
    % compute median stats per dimension
    medVal = median(posData, 1);
    
    disp('compute hash codes');
    tic;
    H = posData > repmat(medVal, [numel(feats) 1]);
    posData_bit = compactbit(H);
    toc;
    
    %{
    %distVal = hammingDist(posData_bit, posData_bit);
    for i=1:numel(feats)
        H = posData(i,:) > medVal;  % simple hash code
        posData_bit(i,:) = compactbit(H);
    end
    %}
    
    tic;
    %save([inpdir '/posData_train.mat'], 'posData', 'posData_bit', 'medVal', '-v7.3');  % posData is too huge to save to disk
    save([inpdir '/posData_train.mat'], 'posData_bit', 'medVal');
    toc;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(dtype, 'val2')    
    try
        load([inpdir '/posData_val2.mat'], 'posData_val_bit');
    catch
        disp('extract features: val');
        tic;
        [ids_val, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_val2_withLabels.txt'], '%s %d');        
        ids_val = ids_val(gt==1);
        clear pos;
        for i=1:length(ids_val)
            pos(i).im = [jpgimagedir '/' ids_val{i}  '.jpg'];
            pos(i).flip = 0;
        end
        feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
        for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end      % normalize (to keep consistent with chisq)
        posData_val = single(cat(2, feats{:})');
        disp(size(posData_val));
        toc;
        
        disp('compute hash codes');
        tic;
        H = posData_val > repmat(medVal, [numel(feats) 1]);
        posData_val_bit = compactbit(H);
        toc;
        
        tic;
        %save([inpdir '/posData_val2.mat'], 'posData_val', 'posData_val_bit', '-v7.3');
        save([inpdir '/posData_val2.mat'], 'posData_val_bit');
        toc;
    end
elseif strcmp(dtype, 'test')
    try
        load([inpdir '/posData_test.mat'], 'posData_test_bit');
    catch
        disp('extract features: test');
        tic;
        [ids_val, gt] = textread([imgsetdir '/baseobjectcategory_' objname '_test_withLabels.txt'], '%s %d');        
        ids_val = ids_val(gt==1);
        clear pos;
        for i=1:length(ids_val)
            pos(i).im = [jpgimagedir '/' ids_val{i}  '.jpg'];
            pos(i).flip = 0;
        end
        feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
        for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end      % normalize (to keep consistent with chisq)
        posData_test = single(cat(2, feats{:})');
        disp(size(posData_test));
        toc;
        
        disp('compute hash codes');
        tic;
        H = posData_test > repmat(medVal, [numel(feats) 1]);
        posData_test_bit = compactbit(H);
        toc;
        
        tic;
        %save([inpdir '/posData_val2.mat'], 'posData_val', 'posData_val_bit', '-v7.3');
        save([inpdir '/posData_test.mat'], 'posData_test_bit');
        toc;
    end
elseif strcmp(dtype, 'test_2007')
    try
        load([inpdir '/posData_test_2007.mat'], 'posData_test_bit');
    catch
        disp('extract features: test_2007');
        tic;
        ids_test = textread([imgsetdir '/test.txt'], '%s');               
        clear pos;
        for i=1:length(ids_test)
            pos(i).im = [jpgimagedir '/' ids_test{i}  '.jpg'];
            pos(i).flip = 0;
        end
        feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
        for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end      % normalize (to keep consistent with chisq)
        posData_test = single(cat(2, feats{:})');
        disp(size(posData_test));
        toc;
        
        disp('compute hash codes');
        tic;
        H = posData_test > repmat(medVal, [numel(feats) 1]);
        posData_test_bit = compactbit(H);
        toc;
        
        tic;        
        save([inpdir '/posData_test_2007.mat'], 'posData_test_bit');
        toc;
    end
end
   
try matlabpool('close', 'force'); end

%{
%%%%%%%%%%%%%%%%%%%%%%%%%%
try
    load([inpdir '/posData_test.mat'], 'posData_test');
catch    
    disp('extract features: test');
    [ids_test, gt] = textread([imgsetdir '/test_withLabels.txt'], '%s %d');
    ids_test = ids_test(gt==1);
    clear pos;
    for i=1:length(ids_test)
        pos(i).im = [jpgimagedir '/' ids_test{i}  '.jpg'];
        pos(i).flip = 0;
    end
    feats = getHOGFeaturesFromWarpImg(pos, fsize, dpsbin, 0, 1);
    for i=1:numel(feats), feats{i} = feats{i}/(sum(feats{i})+eps); end  % normalize (to keep consistent with chisq)
    posData_test = single(cat(2, feats{:})');
    save([inpdir '/posData_test.mat'], 'posData_test');
end
%}

catch
    disp(lasterr); keyboard;
end
