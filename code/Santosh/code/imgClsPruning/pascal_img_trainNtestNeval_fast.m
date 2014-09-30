function pascal_img_trainNtestNeval_fast(cachedir, inpfname, VOCyear, objname, imgannodir)
% from pascal_img_train
% pascal_img_trainNtestNeval_fast('/projects/grail/santosh/objectNgrams/results/ngramPruning/person/','/projects/grail/santosh/objectNgrams/results/object_ngram_data/person/person_0_all_uniquedNsort_rewrite.txt','9990','person','/projects/grail/santosh/objectNgrams/results/object_ngramImg_finalData/')

try
    
%if isdeployed, fsize = str2num(fsize); end
%if isdeployed, sbin = str2num(sbin); end
%if isdeployed, Cval = str2num(Cval); end
%if isdeployed, featExtMode = str2num(featExtMode); end

disp(['pascal_img_trainNtestNeval_fast(''' cachedir ''',''' inpfname ''',''' VOCyear ''',''' objname ''',''' imgannodir ''')' ]);

conf = voc_config('paths.model_dir', 'blah');
fsize = conf.threshs.fsize_fastImgClfr;
sbin = conf.threshs.sbin_fastImgClfr;
Cval = conf.threshs.Cval_fastImgClfr;   
featExtMode = conf.threshs.featExtMode_imgClfr;
arthresh = 0.4;     % aspect-ratio threshold
biasval = 1;
minNumImgsToTrainTest = 10;
numRnds = 3;
maxImgReSize = 500;
fsize = [fsize fsize];
%fsize = [10 10];
%sbin = 8;
%Cval = 0.088388;    % magic parameters (set after checking a few classes)
%featExtMode = 1;    % 1 is simple thumbnail clfr, 2 is complex fullimg clfr

mymkdir([cachedir '/results/']);
mymkdir([cachedir '/images/']);
mymkdir([cachedir '/images_plnBgrndMontage/']);

tmp = load([cachedir '/negData_train.mat'], 'negData');
negData_train = tmp.negData; 
tmp = load([cachedir '/negData_test.mat'], 'negData');
negData_test = tmp.negData;

if featExtMode == 1, disp('doing simple feature with thumbnail images');
elseif featExtMode == 2, disp('doig complex feature with full images'); end

[~, phrasenames] = system(['cat ' inpfname ' | gawk ''{NF--};1'' ']);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];

disp(['will process a total of ' num2str(numel(phrasenames)) ' ngrams']);

%mymatlabpoolopen; % commented this as cant see any parfor here

resdir = cachedir;
mymkdir([resdir '/done']);
myRandomize;
list_of_ims = randperm(numel(phrasenames));
%for f=1:numel(phrasenames)
for f = list_of_ims
    if (exist([resdir '/done/' num2str(f) '.lock'],'dir') || exist([ resdir '/done/' num2str(f) '.done'],'dir') )
        continue;
    end
    if mymkdir_dist([resdir '/done/' num2str(f) '.lock']) == 0
        continue;
    end        
    
    cls = strrep(phrasenames{f}, ' ', '_');    
    disp(cls);
    try
        clear pr;
        load([cachedir '/results/' cls '_result'], 'pr', 'model');
        disp(pr.ap);        
        %disp(model.cval);        
    catch
        tic;
        %%%% GET IMAGES
        disp('download images...');
        clear ids ids_train ids_test;
        ids = mydir([cachedir '/images/' cls '/*.jpg'], 1);        
        someval = 25;
        if length(ids) < someval    % should download at least 50, ideally 64 images            
            filenameWithPath = which('googleimages_dsk.py');    % avoids hardcoding filepath %/projects/grail/santosh/objectNgrams/code/downloadImages/googleimages_dsk.py
            if featExtMode == 1         % thumnail image
                dwncmd = ['python ' filenameWithPath ' ' ...
                    [cachedir '/images/' cls '/'] ' ' '''' 'tbUrl' '''' ' ' '''' phrasenames{f} ''''];
                [~, b] = system(dwncmd);                                
            elseif featExtMode == 2     % full image
                dwncmd = ['python ' filenameWithPath ' ' ...
                    [cachedir '/images/' cls '/'] ' ' '''' 'url' '''' ' ' '''' phrasenames{f} ''''];
                [~, b] = system(dwncmd);
                ids = mydir([cachedir '/images/' cls '/*.jpg'], 1);                
                resizeGoogImages(ids, maxImgReSize);
            end
            ids = mydir([cachedir '/images/' cls '/*.jpg'], 1);
            if length(ids) < someval
                disp('did not get images'); keyboard;
            end
        end        
        toc;                  
        
        disp('ignore plain bgrnd & bad aspect images');
        keepinds = doPlainBgrndDetNAspectCheck(ids, arthresh);
        disp([' keeping ' num2str(length(find(keepinds))) ' out of ' num2str(length(keepinds))]);
        ids = ids(logical(keepinds));                
        
        if ~isempty(ids)    % added 20Sep13 (for isolated dog, no images were left)   
            disp(' dup detection using HOG');
            dupfnd = doDupDetection(ids);
            disp([' keeping ' num2str(length(find(dupfnd==0))) ' out of ' num2str(length(dupfnd))]);
            ids = ids(~logical(dupfnd));
        else
            dupfnd = [];
        end  
        
        if length(ids) > minNumImgsToTrainTest      % at least minNumImgsToTrainTest images to train test classifier            
            % do numRnds fold cv and pick median score for more reliability
            apvals = zeros(numRnds,1);
            for kk=1:numRnds        % can parfor this if need to speed things up
                [trainIndsT{kk}, testIndsT{kk}, modelT{kk}, prT{kk}] = doTrainNtestImgCl_func(ids, cls, fsize, sbin, biasval, negData_train, negData_test, Cval, featExtMode);
                apvals(kk) = prT{kk}.ap;
            end
            selk = find(apvals == max(apvals)); % 10Jul13: switched to max from median (if it does well at least once, pick it)
            trainInds = trainIndsT{selk};
            testInds = testIndsT{selk}; 
            model = modelT{selk};
            pr = prT{selk};                        
        else
            disp(' too few images due to plain bgrnd, ignoring ngram');
            pr.ap = 0;
            model = [];
            trainInds = [];
            testInds = [];
            apvals = [];   
        end
        
        disp(' saving result...');        
        save([cachedir '/results/' cls '_result'], 'pr', 'model', 'keepinds', 'dupfnd', 'trainInds', 'testInds', 'apvals');                
        
        myprintfn;        
    end
    mymkdir([resdir '/done/' num2str(f) '.done'])
    rmdir([resdir '/done/' num2str(f) '.lock']);
end

catch
    disp(lasterr); keyboard;
end
