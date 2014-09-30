function findNearDuplicates(cachedir, dtype, jpgimagedir, imgsetdir) %, hogchi2ThisDimThresh)
% HOG based dup detection

try
   
        
%hogchi2ThisDimThresh = 0.15;
%if isdeployed, hogchi2ThisDimThresh = str2num(hogchi2ThisDimThresh); end

conf = voc_config('paths.model_dir', 'blah');
hogchi2ThisDimThresh = conf.threshs.hogchi2_dupDtn;

disp('loading data');
if 0
load([cachedir '/../posData_train.mat'], 'posData');
if strcmp(dtype, 'val2')
    tmp = load([cachedir '/../posData_val2.mat'], 'posData_val');
    posData2 = tmp.posData_val;
else strcmp(dtype, 'test')
    tmp = load([cachedir '/../posData_test.mat'], 'posData_test');
    posData2 = tmp.posData_test;
end
else    
    [posData, posData2] = findNearDuplicates_cacheFeats_helper(jpgimagedir, imgsetdir);
end

%[ids_val, gt] = textread([imgsetdir '/val2_withLabels.txt'], '%s %d');
%ids_val = ids_val(gt==1);

resdir = cachedir;
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(size(posData2,1));
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end
    
    disp(['Doing ' num2str(f)]);
    fname = [cachedir '/file_' num2str(f) '.mat'];
    try
        load(fname, 'dupfnd');
    catch    
        dupfnd = 0;
        
        tic;
        % check if any imag of val occurs in train
        % when posData2 is 30Kx12K size, this takes 5 secs
        dstmd = chi2_mex_float(posData2(f,:)', posData')/2;
        % when posData2 is 30Kx12K size, this takes negligible time
        dupinfo1 = find(dstmd < hogchi2ThisDimThresh);
        if ~isempty(dupinfo1)
            dupfnd = 1;
        end
        toc;
                
        % check if any img of val is repeated
        % when posData2 is 30Kx12K size, this takes 2.5secs
        dstmd = chi2_mex_float(posData2(f,:)', posData2')/2;
        % when posData2 is 30Kx12K size, this takes negligible time
        dupinfo2 = setdiff(find(dstmd < hogchi2ThisDimThresh),f);
        if ~isempty(dupinfo2)
            if f > dupinfo2(1)  % if fth img matches to 1:f-1, its a repition of sth already there
                dupfnd = dupinfo2(1);
            end
        end
        
        tic;
        save(fname, 'dupfnd', 'dupinfo1', 'dupinfo2');
        toc;
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end
myprintfn;

catch
    disp(lasterr); keyboard;
end

%{
numImgsT = size(posData{fi},1);
for j=1:numImgsT
    if dupfnd{fi}(j,1) == 0   % check if this image is only not duplicate
        %{
        if sqrt(sum((queryImg(:) - feats{j}(:)).^2)) == 0
            disp(' caught duplicate');
            dupfnd(j) = i;
        end
        %}
        %dstmd = sqrt(sum((queryImg(:) - feats{j}(:)).^2));
        dstmd = chi2_mex_float(queryImg', posData{fi}(j,:)');
        if dstmd < hogchi2ThisDimThresh
            %fprintf('%d:%d ', i, j);
            dupfnd{fi}(j,:) = [f i];
        end
    end
end
%}

%{
% before switching to matrix version
for i = 1:size(posData{f},1)    % for each image in it
        if dupfnd{f}(i,1) == 0      % if its not already a duplicate
            queryImg = posData{f}(i,:);
            for fi=f+1:numcls       % compare to all remaining ngrams' images
                dstmd = chi2_mex_float(queryImg', posData{fi}')/2;
                dupinds = find(dstmd < hogchi2ThisDimThresh);
                for ii=1:length(dupinds), dupfnd{fi}(dupinds(ii), :) = [f i]; end
                
            end
        end
    end
%}

%{
% both give same result
%dstmd1 = chisq(queryImg, posData{fi}(j,:));
%dstmd2 = chi2_mex_float(queryImg', posData{fi}(j,:)')/2;
                
% 3X slower than matrix based version
tic;
for i = 1:size(posData{f},1)    % for each image in it
    queryImg = posData{f}(i,:);
    dstmd = chi2_mex_float(queryImg', posData{fi}')/2;
end
toc
%}
