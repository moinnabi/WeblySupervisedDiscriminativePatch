function findNearDuplicates_parfor(cachedir, dtype) %, hogchi2ThisDimThresh)
% HOG based dup detection

try
           
%hogchi2ThisDimThresh = 0.15;
%if isdeployed, hogchi2ThisDimThresh = str2num(hogchi2ThisDimThresh); end

conf = voc_config('paths.model_dir', 'blah');
%hogchi2ThisDimThresh = conf.threshs.hogchi2_dupDtn;
hogchi2ThisDimThresh_bit = conf.threshs.hogchi2_dupDtn_bit;


%diary([cachedir '/../diaryoutput_findNearDuplicates_parfor.txt']);
disp(['findNearDuplicates_parfor(''' cachedir ''',''' dtype ''');' ]);

try
    load([cachedir '/../allResults.mat'], 'dupinfo1', 'dupinfo2');   
catch
    
    disp('loading data');
    tic;
    tmp = load([cachedir '/../posData_train.mat'], 'posData_bit');
    posData = tmp.posData_bit;
    clear tmp;
    toc;
    if strcmp(dtype, 'val2')
        tic;
        tmp = load([cachedir '/../posData_val2.mat'], 'posData_val_bit');
        posData2 = tmp.posData_val_bit;
        clear tmp;
        toc;
    end
        
    mymatlabpoolopen;
    
    disp('check if any imag of val occurs in train');
    tic;
    distVal1 = hammingDist(posData2, posData);
    dupinfo1 = find(distVal1 < hogchi2ThisDimThresh_bit);
    toc;
    
    disp('check if any img of val is repeated');  
    tic;
    distVal2 = hammingDist(posData2, posData2);
    dupinfo2 = find(distVal2 < hogchi2ThisDimThresh_bit);
    toc;
    
    save([cachedir '/../allResults.mat'], 'dupinfo1', 'dupinfo2', 'distVal1', 'distVal2', '-v7.3');
end 

%[ids_val, gt] = textread([imgsetdir '/val2_withLabels.txt'], '%s %d');
%ids_val = ids_val(gt==1);

%{  
tic;
numcnt = size(posData2,1);
dupfnd = zeros(numcnt,1);
dupinfo1 = cell(numcnt, 1);
dupinfo2 = cell(numcnt, 1);
parfor f = 1:numcnt    
    
    
    disp(['Doing ' num2str(f)]);
        
    % check if any imag of val occurs in train
    % when posData2 is 30Kx12K size, this takes 5 secs
    dstmd = chi2_mex_float(posData2(f,:)', posData')/2;
    % when posData2 is 30Kx12K size, this takes negligible time
    dupinfo1{f} = find(dstmd < hogchi2ThisDimThresh);
    if ~isempty(dupinfo1{f})
        dupfnd(f) = 1;
    end
        
    if dupfnd(f) == 0   % if no dup in val, chk in train
        % check if any img of val is repeated
        % when posData2 is 30Kx12K size, this takes 2.5secs
        dstmd = chi2_mex_float(posData2(f,:)', posData2')/2;
        % when posData2 is 30Kx12K size, this takes negligible time
        dupinfo2{f} = setdiff(find(dstmd < hogchi2ThisDimThresh),f);
        if ~isempty(dupinfo2{f})
            if f > dupinfo2{f}(1)  % if fth img matches to 1:f-1, its a repition of sth already there
                dupfnd(f) = dupinfo2{f}(1);
            end
        end
        
    end
end
myprintfn;
toc;
%}



diary off;

catch
    disp(lasterr); keyboard;
end
