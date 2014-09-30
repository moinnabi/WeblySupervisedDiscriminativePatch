function findNearDuplicates_hashing(cachedir, dtype)
% HOG based dup detection

try
           
conf = voc_config('paths.model_dir', 'blah');
%hogchi2ThisDimThresh = conf.threshs.hogchi2_dupDtn;
hogchi2ThisDimThresh_bit = conf.threshs.hogchi2_dupDtn_bit;

disp('loading data');
tmp = load([cachedir '/../posData_train.mat'], 'posData_bit');
posData = tmp.posData_bit;
if strcmp(dtype, 'val2')
    tmp = load([cachedir '/../posData_' dtype '.mat'], 'posData_val_bit');
    posData2 = tmp.posData_val_bit;
elseif strcmp(dtype, 'test')
    tmp = load([cachedir '/../posData_' dtype '.mat'], 'posData_test_bit');
    posData2 = tmp.posData_test_bit;
elseif strcmp(dtype, 'test_2007') || strcmp(dtype, 'test_2010') 
    tmp = load([cachedir '/../posData_' dtype '.mat'], 'posData_test_bit');
    posData2 = tmp.posData_test_bit;
end

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
        
        dstmd = hammingDist(posData2(f,:), posData);
        dupinfo1 = find(dstmd < hogchi2ThisDimThresh_bit);
        if ~isempty(dupinfo1)
            dupfnd = 1;
        end
              
        dupinfo2 = [];
        if strcmp(dtype, 'val2')        % only if val2, chk amongst itslef; test can be duplicates and you dont care much about that
            dstmd = hammingDist(posData2(f,:), posData2);
            dupinfo2 = setdiff(find(dstmd < hogchi2ThisDimThresh_bit),f);
            if ~isempty(dupinfo2)
                if f > dupinfo2(1)      % if fth img matches to 1:f-1, its a repition of sth already there
                    dupfnd = dupinfo2(1);
                end
            end
        end
                        
        save(fname, 'dupfnd', 'dupinfo1', 'dupinfo2');        
    end
    
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end
myprintfn;

catch
    disp(lasterr); keyboard;
end

%{
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
%}
%{
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
%}

