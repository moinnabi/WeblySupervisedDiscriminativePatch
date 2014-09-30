function mvImgsNcreateTxt(objname, inpfname, ngramcntrfname, rawgoogimgdir_obj, jpgimagedir, imgsetdir, annosetdir) 
% in v3 - i dont create val.txt; here in v4 I create separate val
% in v5 - implementation after updting pipeline in March'13
% in v6 - v5 assumed download of images for slow classifier; here we download just before running this
% createXMLannotation(destfname_anno, [newids{j} '.jpg'], ngramPhraseName2, ['baseobjectcategory_' objname], destfname);

try
    
conf = voc_config('paths.model_dir', 'blah');
pcntTrng = conf.threshs.pcntTrngImgsPerNgram;
pcntVal =  conf.threshs.pcntValImgsPerNgram;
pcntTst = conf.threshs.pcntTstImgsPerNgram;
minNumImgs = conf.threshs.minNumImgsDownloadCheck;

[~, phrasenames] = system(['cat ' inpfname]);
phrasenames = regexp(phrasenames, '\n', 'split');
phrasenames(cellfun('isempty', phrasenames)) = [];

numcls = numel(phrasenames);
disp(['To process ' num2str(numcls) ' ngrams']);

%maxNegImages_test = 2500;
% 5Jul13: disabled as too trivial of a detail to complicate things
%maxPosImages = 7500; % +2500negs = 10000total
%numMaxInstances_perNgram = 2*maxPosImages/numcls;

disp([' split positives into ' num2str(pcntTrng*100) '% for training & ' num2str(pcntVal*100) ...
    '% for validation & ' num2str(pcntTst*100) '% for testing']);

mymatlabpoolopen;

for f=1:numcls
    ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');    
    imgtxtfname_train = [imgsetdir '/' ngramPhraseName2 '_train.txt'];
    imgtxtfname_val = [imgsetdir '/' ngramPhraseName2 '_val.txt'];
    imgtxtfname_test = [imgsetdir '/' ngramPhraseName2 '_test.txt'];
    if ~exist(imgtxtfname_test, 'file')        
                        
        ids = mydir([rawgoogimgdir_obj '/' ngramPhraseName2 '/*.jpg'],1);
        numTotImgs = numel(ids);        
        
        fidc = fopen(ngramcntrfname, 'r');
        ngramPhraseIndex = num2str(fgetl(fidc));
        fclose(fidc);
        
        disp(['Processing ' num2str(f) ' : ' ngramPhraseName2 ' (' num2str(ngramPhraseIndex) ')']);
        disp([num2str(numTotImgs) ' images for training+testing+validation']);
        if numTotImgs < minNumImgs, disp('some issue with #images for this ngram'); keyboard; end 
        
        disp(' copy image with appropriate filenames');
        newids = cell(numTotImgs,1);
        parfor j=1:numTotImgs            
            newids{j} = sprintf('%06s_%05s', num2str(ngramPhraseIndex), num2str(j));
            destfname = [jpgimagedir '/' newids{j} '.jpg'];
            destfname_anno = [annosetdir '/' newids{j} '.xml'];
            if ~exist(destfname_anno, 'file')
                system(['ln -s "' ids{j} '" ' destfname]); 
                createXMLannotation(destfname_anno, [newids{j} '.jpg'], ngramPhraseName2, ...
                    ['baseobjectcategory_' objname], destfname);
            end
        end
        
        tids = randperm(numTotImgs);
        trainInds = tids(1:floor(numTotImgs*pcntTrng));
        valInds = tids(floor(numTotImgs*pcntTrng)+1:floor(numTotImgs*(pcntTrng+pcntVal)));
        testInds = tids(floor(numTotImgs*(pcntTrng+pcntVal))+1:end);
        disp([' using ' num2str(length(trainInds)) ' ' num2str(length(valInds)) ' ' num2str(length(testInds)) ' images for training, validation and testing']);
               
        disp(' creating .txt files');
        parfor do_mode = 1:3
            mvImgsNcreateTxt_parforhelper(imgtxtfname_train, trainInds, imgtxtfname_val, valInds, ...
                imgtxtfname_test, testInds, newids, imgsetdir, objname, do_mode)
        end        
                                       
        % update phrase counter
        fidc = fopen(ngramcntrfname, 'w');
        fprintf(fidc, '%d', str2num(ngramPhraseIndex) + 1);
        fclose(fidc);
    end
end

imgtxtfname_allobjtest = [imgsetdir '/baseobjectcategory_' objname '_test.txt'];
imgtxtfname_allobjtest2 = [imgsetdir '/baseobjectcategory_' objname '_test_withLabels.txt'];
if ~exist(imgtxtfname_allobjtest, 'file')
    disp('create global test.txt file');    
    allposids = [];    
    disp(' disabled subsampling of instances; may cause an issue if too many ngrams e.g., person');
    for f=1:numcls
        ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');
        [ids, gt] = textread([imgsetdir '/' ngramPhraseName2 '_test.txt'], '%s %d');
        thisposids = ids(gt == 1);        
        %if length(thisposids) > numMaxInstances_perNgram   % if too many instances, then subsample
        %    thisposids = thisposids(1:numMaxInstances_perNgram);
        %end
        allposids = [allposids; thisposids];
    end
    disp(' assuming negative set is same for all phrases, picking the last phrase neg set');
    negids = ids(gt == -1);
    % 5Jul13: disabled as too trivial of a detail to complicate things
    %numNegs = min(maxNegImages_test,length(negids));     % 23Mar13: the positives will have some negatives already (i.e., images with no horse); so restricting to 1/2 of VOC2007 negative test images
    %disp([' picking ' num2str(numNegs) ' negatives']);
    %negids = negids(1:numNegs);    
    
    fidw = fopen(imgtxtfname_allobjtest, 'w');
    fidw2 = fopen(imgtxtfname_allobjtest2, 'w');
    for j = 1:length(allposids)
        fprintf(fidw, '%s\n', allposids{j});
        fprintf(fidw2, '%s 1\n', allposids{j});
    end
    for j = 1:length(negids)
        fprintf(fidw, '%s\n', negids{j});
        fprintf(fidw2, '%s -1\n', negids{j});
    end
    fclose(fidw);
    fclose(fidw2);
end

imgtxtfname_baseclstrain = [imgsetdir '/baseobjectcategory_' objname '_train.txt'];
if ~exist(imgtxtfname_baseclstrain, 'file')
    disp('create global (baseclass) train.txt file');
    allposids = [];        
    for f=1:numcls
        ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');        
        [ids gt] = textread([imgsetdir '/' ngramPhraseName2 '_train.txt'], '%s %d');        
        thisposids = ids(gt == 1);
        %if length(thisposids) > numMaxInstances_perNgram   % if too many instances, then subsample
        %    thisposids = thisposids(1:numMaxInstances_perNgram);
        %end
        allposids = [allposids; thisposids];
    end
    disp(' assuming negative set is same for all phrases, picking the last phrase neg set');
    negids = ids(gt == -1);
    
    fidw = fopen(imgtxtfname_baseclstrain, 'w');
    for j = 1:length(allposids)
        fprintf(fidw, '%s 1\n', allposids{j});        
    end
    for j = 1:length(negids)
        fprintf(fidw, '%s -1\n', negids{j});        
    end
    fclose(fidw);    
end

imgtxtfname_allobjtrainval = [imgsetdir '/baseobjectcategory_' objname '_val1.txt'];
imgtxtfname_allobjtrainval2 = [imgsetdir '/baseobjectcategory_' objname '_val1_withLabels.txt'];
if ~exist(imgtxtfname_allobjtrainval, 'file')    
    disp('create global val1.txt file for calibration');
    allposids = [];    
    for f=1:numcls
        ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');
        [ids, gt] = textread([imgsetdir '/' ngramPhraseName2 '_train.txt'], '%s %d');
        thisposids = ids(gt == 1);
        %if length(thisposids) > numMaxInstances_perNgram   % if too many instances, then subsample
        %    thisposids = thisposids(1:numMaxInstances_perNgram);
        %end
        allposids = [allposids; thisposids];        
    end
    % get negative image names from val
    [negids, gt] = textread([imgsetdir '/../voc/' objname '_val.txt'], '%s %d');
    negids = negids(gt == -1);
    %negids = negids(1:500);     % 22Feb13: may be I thought 500 is sufficient for sigmoid, but should change it to more (as more is better for picking expert_select thresholds)
    % commented on 23Mar13; use all of it; more the merrier
    
    fidw = fopen(imgtxtfname_allobjtrainval, 'w');
    fidw2 = fopen(imgtxtfname_allobjtrainval2, 'w');
    for j = 1:length(allposids)
        fprintf(fidw, '%s\n', allposids{j});
        fprintf(fidw2, '%s 1\n', allposids{j});
    end
    for j = 1:length(negids)
        fprintf(fidw, '%s\n', negids{j});
        fprintf(fidw2, '%s -1\n', negids{j});
    end
    fclose(fidw);
    fclose(fidw2);
end

imgtxtfname_allobjtrainval = [imgsetdir '/baseobjectcategory_' objname '_val2.txt'];
imgtxtfname_allobjtrainval2 = [imgsetdir '/baseobjectcategory_' objname '_val2_withLabels.txt'];
if ~exist(imgtxtfname_allobjtrainval, 'file')
    disp('create global val2.txt file for calibration');
    allposids = [];
    for f=1:numcls
        ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');
        [ids, gt] = textread([imgsetdir '/' ngramPhraseName2 '_val.txt'], '%s %d');
        thisposids = ids(gt == 1);
        %if length(thisposids) > numMaxInstances_perNgram   % if too many instances, then subsample
        %    thisposids = thisposids(1:numMaxInstances_perNgram);
        %end
        allposids = [allposids; thisposids];
    end
    % get negative image names from val
    [negids, gt] = textread([imgsetdir '/../voc/' objname '_val.txt'], '%s %d');    
    negids = negids(gt == -1);
    %negids = negids(1:1000);   % commented on 23Mar13
    
    fidw = fopen(imgtxtfname_allobjtrainval, 'w');
    fidw2 = fopen(imgtxtfname_allobjtrainval2, 'w');
    for j = 1:length(allposids)
        fprintf(fidw, '%s\n', allposids{j});
        fprintf(fidw2, '%s 1\n', allposids{j});
    end
    for j = 1:length(negids)
        fprintf(fidw, '%s\n', negids{j});
        fprintf(fidw2, '%s -1\n', negids{j});
    end
    fclose(fidw);
    fclose(fidw2);
end

try matlabpool('close', 'force'); end

catch
    disp(lasterr); keyboard;
end

%{
        % this takes 0.8 secs vs 0.5 secs with the parfor code; did check
        % the parfor code for correctness
        % create train.txt file
        fidw = fopen(imgtxtfname_train, 'w');
        for j=1:length(trainInds)       % first write positive image names
            fprintf(fidw, '%s 1\n', newids{trainInds(j)});
        end
        [negids, gt] = textread([imgsetdir '/../voc/' objname '_train.txt'], '%s %d');
        negids = negids(gt == -1);
        for j = 1:length(negids)        % now write negative image names
            fprintf(fidw, '%s -1\n', negids{j});
        end
        fclose(fidw);
        
        % create val.txt file
        fidw = fopen(imgtxtfname_val, 'w');
        for j=1:length(valInds)         % first write positive image names
            fprintf(fidw, '%s 1\n', newids{valInds(j)});
        end
        [negids, gt] = textread([imgsetdir '/../voc/' objname '_val.txt'], '%s %d');
        negids = negids(gt == -1);
        for j = 1:length(negids)        % now write negative image names
            fprintf(fidw, '%s -1\n', negids{j});
        end
        fclose(fidw);
        
        % create test.txt file
        fidw = fopen(imgtxtfname_test, 'w');
        for j=1:length(testInds)    % first write positive image names
            fprintf(fidw, '%s 1\n', newids{testInds(j)});
        end
        [negids gt] = textread([imgsetdir '/../voc/' objname '_test.txt'], '%s %d');
        negids = negids(gt == -1);
        for j = 1:length(negids)       % now write negative image names
            fprintf(fidw, '%s -1\n', negids{j});
        end
        fclose(fidw);        
        %}

%{
imgtxtfname_baseclsval = [imgsetdir '/baseobjectcategory_' objname '_val.txt'];
if ~exist(imgtxtfname_baseclsval, 'file')
    disp('create global (baseclass) val.txt file');
    allposids = [];
    for f=1:numcls
        ngramPhraseName2 = strrep(phrasenames{f}, ' ', '_');        
        [ids gt] = textread([imgsetdir '/' ngramPhraseName2 '_val.txt'], '%s %d');        
        thisposids = ids(gt == 1);
        if length(thisposids) > numMaxInstances_perNgram   % if too many instances, then subsample
            thisposids = thisposids(1:numMaxInstances);
        end
        allposids = [allposids; thisposids];
    end
    disp(' assuming negative set is same for all phrases, picking the last phrase neg set');
    negids = ids(gt == -1);
    
    fidw = fopen(imgtxtfname_baseclsval, 'w');
    for j = 1:length(allposids)
        fprintf(fidw, '%s 1\n', allposids{j});        
    end
    for j = 1:length(negids)
        fprintf(fidw, '%s -1\n', negids{j});        
    end
    fclose(fidw);    
end
%}
